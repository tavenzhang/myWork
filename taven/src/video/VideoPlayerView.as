package video {
import com.greensock.TweenMax;
import com.junkbyte.console.Cc;
import com.rover022.event.CBModuleEvent;
import com.rover022.CBProtocol;
import com.rover022.IPlayer;
import com.rover022.IVideoModule;
import com.rover022.IVideoRoom;
import com.rover022.ModuleNameType;
import com.rover022.vo.PlayerType;
import com.rover022.vo.VideoConfig;
import com.rover022.event.ModuleEvent;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.media.Camera;
import flash.media.H264Level;
import flash.media.H264Profile;
import flash.media.H264VideoStreamSettings;
import flash.media.Microphone;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.trace.Trace;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.setInterval;

import manger.DataCenterManger;

import sk.video.videoPlayer;

import tool.GoogleAdSence;
import tool.VideoTool;


public class VideoPlayerView extends videoPlayer implements IVideoModule,IPlayer {
	public var isAnchor:Boolean               = false;
	public var flvName:String                 = "";
	public var nc:NetConnection               = null;
	public var ns:NetStream                   = null;
	protected var video_mc:Video              = null;
	protected var _rtmpURL:String             = "";
	protected var cam:Camera                  = null;
	protected var mic:Microphone              = null;
	public var volumeTransform:SoundTransform = new SoundTransform;
	public var cameraConfig:Object            = {frame: 36, fps: 24, favorArea: false, bandwidth: 25600, quality: 0};//摄像头参数配置
	public var microphoneConfig:Object        = {gain: 55, rate: 22, silence: 8, timeout: 100000000};//麦克风参数配置
	public var reconCount:int                 = 0;
	private var reConnTimer:Timer             = new Timer(5000);//重连时间
	private var checkPlayTimer:Timer;
	private var _playOldTimer:int             = 0;
	private var ownerTimeout:Timer            = new Timer(30000);//30秒内没调用,弹出结束面板
	private var soundTimer:Timer              = new Timer(100);//主播音波检测
	public var control_mc:VideoControlView;
	private var _iVideoRoom:IVideoRoom;
	public var videoparam_mc:VideoParamView;
	private var screenshot_mc:VideoShotView;
	private var _isGetMic:Boolean             = false;
	//信息收集器
	//public var inforProxy:InforProxy          = new InforProxy(this as VideoPlayerView);
	//是否关闭rtmp 不在继续重连了
	public var isCloseRestConnectRtmp:Boolean = false;
	public var callTime:Number                = 0;
	public var pingTime:Number                = 0;
//    public var signView:SignViewUI;
	public var rtmpReadyOK:Boolean            = false;
	private var googleAdClip:GoogleAdSence;



	public function VideoPlayerView():void {
		googleAdClip = new GoogleAdSence();
		bgClip.addChild(googleAdClip);
		googleAdClip.loadAdData(VideoConfig.httpFunction, 1);
		x                  = 55;
		video_mc           = new Video(480, 360);
		video_mc.x         = 12;
		video_mc.y         = 18;
		video_mc.smoothing = true;
		addChildAt(this.video_mc, this.getChildIndex(this.loading_mc) + 1);
		//
		googleAdClip.showClip = video_mc;
		setVideoVisible(false);
		//
		control_mc      = new VideoControlView(this);
		screenshot_mc   = new VideoShotView();
		screenshot_mc.x = 12;
		screenshot_mc.y = 18;
		addChild(screenshot_mc);
		this.screenshot_mc.addEventListener("shotCompleteEvent", _shotCompleteEvent);//截图完成
		this.reConnTimer.addEventListener(TimerEvent.TIMER, _reconnTimerEvent);
		this.soundTimer.addEventListener(TimerEvent.TIMER, _soundTimerEvent);
		this.resetView();//重置显示列表
		addEventListener(CBModuleEvent.PLAYER_UPDATE, updateUI);
		addEventListener(CBModuleEvent.PLAYER_GETMIC, onGetMic);
//      signView = new SignViewUI(this, 460, 352);
		//添加按钮事件
		upMic_bt.addEventListener(MouseEvent.CLICK, upMicClick);
		downMic_bt.addEventListener(MouseEvent.CLICK, downMicClick);
		headShot_bt.addEventListener(MouseEvent.CLICK, headShotBtCLickEvent);
		changeline_bt.addEventListener(MouseEvent.CLICK, upMicClick);
		upMic_bt.visible      = false;
		downMic_bt.visible    = false;
		headShot_bt.visible   = false;
		changeline_bt.visible = false;
		addEventListener(Event.ADDED_TO_STAGE, onStageHandle);
	}

	private function onStageHandle(event:Event):void {
		ownerTimeout.addEventListener(TimerEvent.TIMER, _ownerTimerEvent);
		ownerTimeout.start();//启动判断是否有上麦者
		setInterval(updatePer30Second, 30000);
		stage.addEventListener(ModuleEvent.CLOSE_ALL_RTMP_BY_SOCKET, closeRtmpNoResetConnect);
		//
	}

	public function initUI():void {
		pingTime = -1;
//        signView.update(pingTime);
	}

	/**
	 * 获取到当前的视频流的数据大小
	 */
	public function get currentdataBytesPerSecond():Number {
		if (nc && nc.connected) {
			if (ns) {
				return ns.info.currentBytesPerSecond / 1024;
			}
		}
		return 0;
	}

	public function downMicClick(event:MouseEvent):void {
		closeRtmpNoResetConnect();
		if (DataCenterManger.videoOwner) {
			videoRoom.sendDataObject({"cmd": CBProtocol.stopTalkPlay_20003, "sid": DataCenterManger.videoOwner.sid});//下麦;
		}
		isGetMic = false;
		updateUI(null);
	}

	private function upMicClick(event:MouseEvent):void {
		if (videoparam_mc == null) {
			videoparam_mc = new VideoParamView(this);
		}
		stage.addChild(videoparam_mc);
		videoparam_mc.onTestSpeddClick(null);
	}

	private function rtmpValid():void {
		Cc.log("strart------------------Valid");
		nc.call("netping", null,22);
	}

	public function netping(...args):void {
		//只有参数有3个时才开启验证流程
		var arglenth:int = args.length;
		if (arglenth == 3) {
			var result:int = int(args[2]);
			if (result > 1) {
				result = VideoTool.encrypt(result);
				Cc.log("second----------------------" + result);
				nc.call("netping", null, result);
			}
			else if (result == 1) //验证通过
			{
				Cc.log("result- valid-----------ok-------------------" + result);
				startStream();
			}
			else if (result == 0) {
				Cc.log("result- valid-----------faile-------------------" + result);
			}
		}
	}

	/**
	 * 每个5秒发送一次收集到的信息到服务采集服务器
	 */
	public function updatePer30Second():void {
		//inforProxy.sendInforToServer(false);
	}

	//断开rtmp服务器 且不再重连
	public function closeRtmpNoResetConnect(e:* = null):void {
		Cc.log("断开rtmp服务器 且不再重连");
		isCloseRestConnectRtmp = true;
		if (nc) {
			nc.close();
		}
	}

	//获取麦克风
	public function onGetMic(event:CBModuleEvent):void {
		isGetMic = true;
		updateUI(null)
	}

	/**
	 * 统一在这里刷按钮状态
	 * 其他的地方不要再去刷按钮可见不可见了
	 * @param event
	 */
	private function updateUI(event:CBModuleEvent):void {
		var _state:int = videoRoom.checkState();
		switch (videoRoom.checkState()) {
			case PlayerType.GUEST://游客
			case PlayerType.PLAYER://玩家
				upMic_bt.visible      = false;
				downMic_bt.visible    = false;
				changeline_bt.visible = false;
				headShot_bt.visible   = false;
				break;
			case PlayerType.MASTER://管理
			case PlayerType.MANAGER://主持人
				upMic_bt.visible      = false;
				downMic_bt.visible    = false;
				changeline_bt.visible = false;
				headShot_bt.visible   = false;
				break;
			case PlayerType.ANCHOR://主播
				if (DataCenterManger.getInstance().isRoomAdmin) {
					headShot_bt.visible = false;
					if (isGetMic) {
						upMic_bt.visible      = false;
						downMic_bt.visible    = true;
						changeline_bt.visible = true;
					} else {
						upMic_bt.visible      = true;
						downMic_bt.visible    = false;
						changeline_bt.visible = false;
					}
				}
				break;
			default:
		}
	}

	private function resetView():void {
		this.control_mc.alpha      = 0;
		this.control_mc.visible    = false;
		this.screenshot_mc.visible = false;
		this.headShot_bt.visible   = false;
		setVideoVisible(false);
		this.video_mc.clear();//清除视频
		this.endPlay_mc.visible   = false;
		this.soundWave_mc.visible = false;
		this.soundWave_mc.gotoAndStop(1);
		this.soundTimer.stop();
		this.loading_mc.gotoAndPlay(1);
		this.loading_mc.visible = true;
		this.ownerTimeout.reset();//有调用,停止记时
		if (this.checkPlayTimer) {//播放仿假死计时器
			this.checkPlayTimer.stop();
		}
	}

	private function Show(...res):void {
		videoRoom.showAlert(res[0]);
	}

//***************状态文字
	public function set infoText(_v:String):void {
		TweenMax.killTweensOf(info_txt);
		info_txt.alpha   = 0;
		info_txt.text    = _v;
		info_txt.visible = true;
		TweenMax.to(info_txt, 1, {"alpha": 1, yoyo: true, repeat: 1, repeatDelay: 3});
	}

	//-----------------------------------------------------摄像头与麦克风
	protected function initLocalDevice():void {
		//摄像头
		if (Camera.names.length > 0) {
			//设置每秒的最大带宽或当前输出视频输入信号所需的图片品质。此方法通常只在您使用 Flash Communication Server 传输视频时适用。
			var _xml:XML =VideoConfig.ENV_XML as XML ;
			var dataXMl:XMLList;
			  switch (DataCenterManger.videoQType)
			  {
				  case 0://流程
					  dataXMl  = _xml.videoH ;
					  break;
				  case 1://默认
					  dataXMl  = _xml.videoM ;
					  break;
				  case 2://高清
					  dataXMl  = _xml.videoL ;
					  break;
			  }
			cameraConfig.frame     = int(dataXMl.frame);
			cameraConfig.fps       = int(dataXMl.fps);
			cameraConfig.favorArea = dataXMl.favorArea;
			cameraConfig.bandwidth = int(dataXMl.bandwidth);
			cameraConfig.quality   = int(dataXMl.quality);
			this.cam = Camera.getCamera(this.videoparam_mc.cameraValue.toString());
			if (this.cam) {
				this.cam.addEventListener(StatusEvent.STATUS, _cameraStatusEvent);
				this.cam.setKeyFrameInterval(this.cameraConfig.frame);
				this.cam.setMode(480, 360, this.cameraConfig.fps, this.cameraConfig.favorArea);
				this.cam.setQuality(this.cameraConfig.bandwidth, this.cameraConfig.quality);
				this.cam.setLoopback(false);
			} else {
				this.Show("摄像头正被其它程序占用.")
			}
		} else {
			this.Show("本地没有找到摄像头,请安装摄像头后使用.");
		}
		this.initMicrophone();//初始麦克风
	}

	protected function initMicrophone():void {
		//麦克风
		if (Microphone.names.length > 0) {
			if (!this.mic) {
				this.mic = Microphone.getMicrophone(this.videoparam_mc.microphoneValue);
				if (this.mic) {

					//this.mic.codec = SoundCodec.SPEEX;
					this.mic.setSilenceLevel(this.microphoneConfig.silence, this.microphoneConfig.timeout);
					this.mic.rate = this.microphoneConfig.rate;
					this.mic.gain = this.microphoneConfig.gain;
					this.mic.setUseEchoSuppression(true);
					this.mic.setLoopBack(false);
				} else {
					this.Show("麦克风正被其它程序占用.");
				}
			}
		} else {
			this.Show("本地没有找到麦克风,请安装麦克风后使用.");
		}
	}

	private function _cameraStatusEvent(e:StatusEvent):void {
		this.deviceHandle();//设备处理
	}

//-----------------------------------------------------流媒体
	private function initNet(_rtmp:String):void {
		if (nc == null) {
			nc        = new NetConnection();
			nc.client = this;
			nc.addEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
			nc.addEventListener(IOErrorEvent.IO_ERROR, _errorEvent);
		}
		if (this._rtmpURL != _rtmp || !this.nc.connected) {
			this.nc.close();
			if (_rtmp != "") {
				this.nc.connect(_rtmp);
				infoText = "开始连接视频服务器!", _rtmp;
			}
			this._rtmpURL = _rtmp;
		} else {
			dispatchEvent(new Event("connectSuccessEvent"));//流连接成功
			reconCount = 0;
			initStream();
		}
	}

	/**
	 * 初始化流
	 */
	public function initStream():void {
		if (this.flvName == "") {//纯连接
			return;
		}
		if (this.checkPlayTimer) {//取消较验时间事件
			this.checkPlayTimer.stop();
		}
		if (this.ns) {
			this.ns.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
			this.ns.attachAudio(null);
			this.ns.attachCamera(null);
			this.ns.close();
			this.ns = null;
		}
		try {
			this.ns        = new NetStream(this.nc);
			this.ns.client = this;
			this.ns.addEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
			if (this.isAnchor) {
			} else {
				this.ns.bufferTime    = 3;
				this.ns.bufferTimeMax = 10;
				this.rePlay();
			}
		} catch (e:*) {
			this.infoText = "播放时出现异常.请重新进入";
		}
	}

	//rtmp验证完成之后
	private function startStream():void {
		initStream();
		infoText = "连接成功，正在加载画面!";
		onNCConnnetSuccess();
		updatePer30Second();
	}

	private function _netStatusEvent(e:NetStatusEvent):void {
		Cc.log(e.info.code + "-----------" + this.nc.uri+"-----------------vtype:"+DataCenterManger.videoQType);
		switch (e.info.code) {
			case "NetConnection.Connect.Success":
				reConnTimer.stop();//暂停计时器
				if (VideoConfig.isValidRtmp) {
					rtmpValid();
				}
				else {
					startStream();
				}
				break;
			case "NetConnection.Connect.Closed"://关闭
			case "NetConnection.Connect.Failed"://Error 失败
			case "NetConnection.Connect.Rejected"://Error 没有权限
				isGetMic = false;
				resetView();
				initUI();
				if (isCloseRestConnectRtmp == false) {
					if (this.isAnchor)//如果是主播直接提示重新上麦， 直接重连会产生很多问题 不正常
					{
						videoRoom.showAlert("当前视频服务器连接已断开，请重新选择服务器!!");
						downMic_bt.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					}
					else {
						this.reConnTimer.reset();
						this.reConnTimer.start();
						this.infoText = "连接中.第" + reconCount + "次";
					}
					setVideoVisible(false);
				} else {
					this.infoText = "SOCKET连接断开,关闭RTMP连接";
				}
				break;
			case "NetStream.Publish.Start":
				this.infoText   = "成功发布,即将直播.";
				//如果是主播 准备发布的时候重置重连接次数
				this.reconCount = 0;//
				setVideoVisible(true);
				break;
			case "NetStream.Publish.BadName"://Error
				this.infoText = "该视频流已被占用，请重新上麦.";
				videoRoom.showAlert("该视频流已被占用，请重新上麦!");
				break;
			case "NetStream.Record.NoAccess"://Error
			case "NetStream.Record.Failed"://Error
				trace("录制出错..严重bug");
				this.removeMic();//出错,切麦
				this.infoText = "对不起,您没有录制权限.";
				break;
			case "NetStream.Play.Start":
				break;
			case "NetStream.Buffer.Full":
				this.loading_mc.stop();
				this.loading_mc.visible = false;
				this.infoText           = "缓冲中.";
				control_mc.controlChangeEvent();//设置播放参数
				this.endPlayerHide();//隐藏结束面板
				break;
			case "NetStream.Video.DimensionChange"://防止播放假死
				if (this.ns) {
					this.ns.resume();
				}
				break;
			case "NetStream.Play.Stop":
			case "NetStream.Play.UnpublishNotify":
				trace("主播离开");
				this.infoText = "直播中断.";
				if (this.ns) {
					this.ns.dispose();
				}
				this.resetView();//重置显示列表
				this.ownerTimeout.reset();
				this.ownerTimeout.start();//启动,判断是否有主播,没在再提示结束面板
				break;
			case "NetStream.Play.InsufficientBW"://Error
				this.infoText = "带宽不足,请关闭其它应用,确保视频正常播放.";
				break;
			case "NetStream.Play.Failed"://Error
			case "NetStream.Play.FileStructureInvalid"://Error
			case "NetStream.Play.NoSupportedTrackFound"://Error
			case "NetStream.Play.StreamNotFound"://Error
				if (this.nc.connected) {
					this.initStream();
				} else {
					this.reConnTimer.reset();
					this.reConnTimer.start();
				}
				this.infoText = "接收中.";
				initUI();
				break;
			case "NetStream.Failed":
				this.infoText = "播放出现异常.";
				break;
			case "NetConnection.Connect.NetworkChange":
				break;
			default:
		}
	}

	//*连接出错
	private function _errorEvent(e:*):void {
		this.reConnTimer.reset();
		this.reConnTimer.start();
	}

	//重置上传,如果中断,需要重新上传
	public function rePublish():void {
		if (!this.ns) {
			return;
		}
		setVideoVisible(false);
		if (this.isAnchor) {
			if (this.cam) {
				this.ns.attachCamera(this.cam);
			}
			if (this.mic) {
				this.ns.attachAudio(this.mic);
			}
			if (this.cam) {
				try {
					var h264:H264VideoStreamSettings = new H264VideoStreamSettings();
					h264.setProfileLevel(H264Profile.MAIN, H264Level.LEVEL_2_1);
					this.ns.videoStreamSettings = h264;
				} catch (e:Error) {
				}
				this.ns.publish(this.flvName);
				Cc.log("最终播放线路 rtmp=" + this.nc.uri + "----sid=" + this.flvName);
			}
		}
	}

	// 重置播放 如果是用户则播放
	protected function rePlay():void {
		if (!this.ns) {
			return;
		}
		rtmpReadyOK = false;
		setVideoVisible(false);
		this.doSubscribe(this.flvName);
		this.ns.play(this.flvName);
		if (!this.checkPlayTimer) {
			this.checkPlayTimer = new Timer(10000);
			this.checkPlayTimer.addEventListener(TimerEvent.TIMER, _checkPlayTimerEvent);
		}
		this.checkPlayTimer.reset();
		this.checkPlayTimer.start();
		this._playOldTimer = 0;//重置时间
		this.video_mc.attachNetStream(this.ns);
	}

	//播放防假死 //每隔5秒，this.ns.time =0 重新connect  ，防止有时候连接上 但是没数据
	private function _checkPlayTimerEvent(e:TimerEvent):void {
		if (!this.isAnchor && this.ns) {
			if (this._playOldTimer == int(this.ns.time) && !rtmpReadyOK) {//如果rtmpReadyOK ture 即 netStream 触发了full 则跳过
				if (this._playOldTimer == 0) {//重未连上过
					if (this.reconCount < 4) //最多进行4次重连测试
					{
						_reconnTimerEvent(null);
					}
					else {
						this.checkPlayTimer.stop();
						this.connectClose();//断线,或是没有直播
					}
				} else {
					//重连
					this.reConnTimer.reset();
					this.reConnTimer.start();
					this.infoText = "激活中."
				}
			} else {
				Cc.log("------防假死 ---_checkPlayTimerEvent -------------" + rtmpReadyOK + "=====================this.ns.time===" + this.ns.time + "-this._playOldTimer == int(this.ns.time)=" + (this._playOldTimer == int(this.ns.time)));
				this._playOldTimer = int(this.ns.time);
				this.endPlayerHide();//隐藏结束面板
				if (_playOldTimer > 0)
					this.checkPlayTimer.stop();
			}
		}
	}

	//-----------------------连接失败重连
	private function _reconnTimerEvent(e:TimerEvent = null):void {
		this.reConnTimer.stop();
		if (this.reconCount < 5) {
			this.nc.connect(this._rtmpURL);
			trace("连接出错,重连" + this.reconCount);
			this.reconCount++;
		} else {
			if (this.isAnchor) {//主播
				this.removeMic();//切麦
				this.infoText = "无法直播,请检查网络."
			} else {//用户
				this.connectClose();//断线,或是没有直播
			}
		}
	}

	//----忽略
	public function onBWCheck(...rest):void {
	}

	public function onBWDone(...rest):void {
	}

	public function onMetaData(...rest):void {
	}

	private function doSubscribe(id:String):void {
		this.nc.call("FCSubscribe", null, id);
	}

	public function onFCSubscribe(...arg):void {
		//trace("onFCSubscribe:    "+arg[0].code+"="+arg[0].description)
	}

	//断开上传流
	public function closePublish():void {
		if (this.isAnchor) {
			this.removeMic();//切麦
			this.infoText = "您已经下麦,期待您再次光临."
		} else {
			if (nc && nc.connected) {
				isCloseRestConnectRtmp = true;
				nc.close();
			} else {
				trace("RTMP还没有连接成功呢...");
			}
		}
	}

	//用户播放
	public function playRTMP(_flv:String, _rtmp:String):void {
		if (_flv == "") {//纯连接
			this.flvName = "";
			this.initNet(_rtmp);//初始连接
			return;
		}
		this.resetView();//重置显示列表
		this.flvName            = _flv;
		this.isAnchor           = false;
		this.control_mc.visible = true;
		this.initNet(_rtmp);//初始连接
		rtmpReadyOK = false;
	}

	//主播
	public function publish(_flv:String, _rtmp:String):void {
		this.resetView();//重置显示列表
		this.flvName  = _flv;
		this.isAnchor = true;
		this.cam      = null;
		this.mic      = null;
		this.initNet(_rtmp);//初始连接
	}

	//------头像上传
	public function get headData():ByteArray {
		return this.screenshot_mc.headJepgData;
	}

	//*****头像上传完成
	public function headDataComlete():void {
		this.screenshot_mc.rePhoto();
		this.screenshot_mc.visible = false;
		this.headShot_bt.visible   = true;
		setVideoVisible(true);
		this.video_mc.attachCamera(this.cam);
		this.loading_mc.stop();
		this.loading_mc.visible = false;
	}

	//---------------------------主播事件
	public function onNCConnnetSuccess(e:Event = null):void {
		if (isGetMic) {
			this.initLocalDevice();
			this.deviceHandle();//设备处理
			this.headDataComlete();//头像数据上传
		}
	}

	private function deviceHandle():void {//用户拒绝/允许使用摄像头处理函数
		if (!this.cam) {
			//没有找到设备直接切麦
			this.Show("无法在您的电脑上找到摄像头输入设备,请安装后刷新页面重新进入游戏");
			this.removeMic();
			return;
		}
		if (!this.cam.muted) {
			this.rePublish();
			this.soundWave_mc.visible = true;
			this.soundTimer.start();
		} else {
			this.soundWave_mc.visible = false;
			this.soundTimer.stop();
		}
		if (screenshot_mc.visible) {//如果是截图画面
			if (this.cam.muted) {
				this.screenshot_mc.mouseChildren = false;
				this.screenshot_mc.alpha         = 0;
			} else {
				this.screenshot_mc.mouseChildren = true;
				this.screenshot_mc.alpha         = 1;
			}
		} else {
			if (this.cam.muted) {
				this.headShot_bt.visible = false;
			} else {
				this.headShot_bt.visible = true;
			}
		}
		setVideoVisible(!screenshot_mc.visible);
	}

	/**
	 * 设置视频播放器可见或是不可见
	 * @param b
	 */
	public function setVideoVisible(b:Boolean):void {
		video_mc.visible        = b;
		googleAdClip.buttonMode = !b;
	}

	//-------------------------------------------------自身事件
	private function _ownerTimerEvent(e:TimerEvent):void {
		this.ownerTimeout.stop();
		this.endPlayerAlert();//显示结束直播面板
	}

	//截图按钮
	private function headShotBtCLickEvent(e:Event = null):void {
		this.headShot_bt.visible = false;
		setVideoVisible(false);
		this.screenshot_mc.rePhoto();
		this.screenshot_mc.visible = true;
		this.screenshot_mc.video_mc.attachCamera(this.cam);
	}

	/**
	 * 没有直播,显示没有直播面板
	 */
	public function endPlayerAlert():void {
		this.resetView();//重置显示列表
		this.endPlay_mc.visible = true;
		this.endPlay_mc.gotoHall_bt.addEventListener(MouseEvent.CLICK, _gotoHallClickEvent);
		this.loading_mc.stop();
		this.loading_mc.visible = false;
		videoRoom.sendDataObject({"cmd": 50002});//更新人数
		if (!isAnchor) {
			var _imodule:MovieClip = videoRoom.getModule(ModuleNameType.SIDESGROUP) as MovieClip;
			if (_imodule) {
				_imodule.showHotVideo(true);
			}
		}
	}

	private function _gotoHallClickEvent(e:MouseEvent):void {
		this.goHomeVideo();//回到视频大厅
	}

	//*激活隐藏没有直播面板
	private function endPlayerHide():void {
		if (!this.isAnchor) {
			this.endPlay_mc.visible = false;
			this.control_mc.visible = true;
			setVideoVisible(true);//显示视频
			//
			var _imodule:MovieClip = videoRoom.getModule(ModuleNameType.SIDESGROUP) as MovieClip;
			if (_imodule) {
				_imodule.showHotVideo(false);
			}
		}
	}

	//截图完成
	private function _shotCompleteEvent(e:Event):void {
		if (this.screenshot_mc.headJepgData) {
			this.alertHeadUpEvent();//发布截图完成事件
		} else {
			this.headDataComlete();
			this.infoText = "取消海报上传."
		}
	}

	/**
	 * 回到大厅事件
	 */
	private function goHomeVideo():void {
		this.dispatchEvent(new Event("reGOHallEvent"));
	}

	/**
	 * 截图提交事件
	 */
	private function alertHeadUpEvent():void {
		if (headData == null) {
			videoRoom.showAlert("亲,您还没有拍照呢!", "保存形像");
			return;
		}
		var upImgLoad:URLLoader = new URLLoader();
		upImgLoad.addEventListener(Event.COMPLETE, _upImgCompleteEvent);
		upImgLoad.addEventListener(IOErrorEvent.IO_ERROR, _upImgError);
		upImgLoad.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _upImgError);
		var url:String            = VideoConfig.HTTP + videoRoom.getDataByName(ModuleNameType.CONFIGXML).head.@upurl;
		var urlRequest:URLRequest = new URLRequest(url);
		urlRequest.data           = headData;
		urlRequest.method         = URLRequestMethod.POST;
		urlRequest.contentType    = "application/octet-stream";
		upImgLoad.load(urlRequest);
		function _upImgCompleteEvent(e:Event):void {
			headDataComlete();
			infoText = "头像上传成功...";
			try {
				var _v:Object = JSON.parse(e.target.data);
				if (_v && _v.ret == 100) {
					videoRoom.showAlert(_v.retDesc, "上传成功");
				} else {
					videoRoom.showAlert("直播海报更新失败，请稍后点击视频右上角的\"直播头像\"按钮再试哦~", "失败")
				}
			} catch (e:*) {
			}
		}

		function _upImgError(e:*):void {
			headDataComlete();
			videoRoom.showAlert("直播海报更新失败，请稍后点击视频右上角的\"直播头像\"按钮再试哦~", "失败")
		}
	}

	//切麦
	private function removeMic():void {
		if (this.isAnchor) {
			this.resetView();
			if (this.ns) {
				this.ns.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusEvent);
				this.ns.attachAudio(null);
				this.ns.attachCamera(null);
				this.ns.close();
				this.ns = null;
			}
			this.dispatchEvent(new Event("playCompleteEvent"));
			this.ownerTimeout.start();//启动,判断是否有主播
		}
	}

	//*断线了
	private function connectClose():void {
		if (this.checkPlayTimer) {//播放仿假死计时器
			this.checkPlayTimer.stop();
			this.checkPlayTimer.removeEventListener(TimerEvent.TIMER, _checkPlayTimerEvent);
			this.checkPlayTimer = null;
		}
		this.reconCount = 0;
		this.infoText   = "无法获取直播.";
		this.endPlayerAlert();//显示结束直播面板
	}

	private function _soundTimerEvent(e:TimerEvent):void {
		if (this.mic) {
			this.soundWave_mc.gotoAndStop(int(this.mic.activityLevel / 2));
		}
	}

	public function hideVideo(isHide:Boolean):void
	{
		this.visible =  !isHide;
	}
	/**
	 * 可以根据这个值判断主播是否在直播...
	 */
	public function get isGetMic():Boolean {
		return _isGetMic;
	}

	public function set isGetMic(value:Boolean):void {
		_isGetMic = value;
	}

	//------------------------实现接口的方法-----------------
	public function set videoRoom(src:IVideoRoom):void {
		_iVideoRoom = src;
	}

	public function get videoRoom():IVideoRoom {
		return _iVideoRoom;
	}

	public function listNotificationInterests():Array {
		return [];
	}

	public function handleNotification(src:Object):void {
	}
}
}