/*!	SWFObject v2.2 <http://code.google.com/p/swfobject/> 
	is released under the MIT License <http://www.opensource.org/licenses/mit-license.php> 
*/

function evalJS(_cmd) {
    return eval(_cmd);
}

document.domain = document.domain;

(function(window){
	
	var document = window.document;
	var location = window.location;
	var browserName=eval("navigator.userAgent");
	browserName=browserName.toLowerCase();
	
	var S_IFRAME = {
		createIFrame:function(w,h,url,id){
			var iframe = document.createElement("iframe");
			iframe.width=w;
			iframe.height=h;
			iframe.style.border="none";
			iframe.frameBorder=0;
			iframe.scrolling="no";
			iframe.src=url;
			iframe.id=id;
			if (iframe.attachEvent){
			    iframe.attachEvent("onload", function(){
			    	S_IFRAME.hideLoaddingDiv();
			    	S_IFRAME.showIFrame('s_win');
			    });
			} else {
			    iframe.onload = function(){
			    	S_IFRAME.hideLoaddingDiv();
			    	S_IFRAME.showIFrame('s_win');
			    };
			}
			return iframe;
		},
		createOptIFrame:function(w,h,t){
			var iframe = document.createElement("iframe");
			iframe.width=w;
			iframe.height=h;
			iframe.style.border="none";
			iframe.frameBorder=0;
			iframe.scrolling="no";
			iframe.src="about:blank";
			iframe.id="opt_IFrame";
			if (iframe.attachEvent){
			    iframe.attachEvent("onload", function(){
			    	t(iframe);
			    });
			} else {	
			    iframe.onload = function(){
			    	t(iframe);
			    };
			}
			return iframe;
		},
		moveIFrame:function(id,x,y) {
        	var frameRef=document.getElementById(id);
        	frameRef.style.left=x+"px";
        	frameRef.style.top=y+"px";
	    },
        hideIFrame:function(id){
	      	var _e=document.getElementById(id);
	        _e.style.visibility="hidden";
	        _e.innerHTML="";
	        //FEED_TMPL.s_timer=window.clearInterval(FEED_TMPL.s_timer);
        },
		
		loaddingDiv:null,
		
	    showIFrame:function(id){
			document.getElementById(id).style.visibility="visible";
	    },
		
	    showLoaddingDiv:function(){
			
			if(this.loaddingDiv==null) {
				
				var e=document.createElement("div");
				e.style.width=45+"px";
				e.style.height=25+"px";
				e.style.position="absolute";
				
				var x=(document.body.clientWidth - 45) / 2;
				e.style.left=x+"px";
				e.style.top="342px";
			
				var iframe=document.createElement("iframe");
				iframe.width=45;
				iframe.height=25;
				iframe.style.border=0;
				iframe.frameBorder="0";
				iframe.scrolling="no";
				iframe.src="about:blank";
				
				var e2=document.createElement("div");
				e2.style.width=45+"px";
				e2.style.height=25+"px";
				e2.style.background="#C0C0C0";
				e2.title="正在加载..点击关闭";
				
				setInterval(function(){
					var con=e2.innerHTML;
					con.length<5?e2.innerHTML=con+".":e2.innerHTML=".";
				},1000);
				
				e2.onclick=function(){
					S_IFRAME.hideLoaddingDiv();
					S_IFRAME.hideIFrame("s_win");
				};
				
				if (iframe.attachEvent){
					iframe.attachEvent("onload", function(){iframe.contentWindow.document.body.appendChild(e2);});
				} else {
					iframe.onload = function(){iframe.contentWindow.document.body.appendChild(e2);};
				}
						
				e.appendChild(iframe);
				this.loaddingDiv=e;
				document.body.appendChild(e);
				
			} else {
				this.loaddingDiv.style.visibility="visible";
			}
	    },
		
	    hideLoaddingDiv:function(){
				if(this.loaddingDiv)
				this.loaddingDiv.style.visibility="hidden";
	    },
		
	    loadIFrame:function(id, url, s_type, w, h){
	   		
      		this.showLoaddingDiv();
      		var ifr = this.createIFrame(w, h, url, "s_win_IFrame");
	        ifr.allowtransparency = "true";
	        ifr.style.float = "left";
	       
	        var parentNode = document.getElementById("s_win");
	        parentNode.innerHTML="<div style='width:524px;magin:0px;padding:0px;'><div id='e1' style='float:left;'></div><div id='e2' style='height:20px;float:left;'></div></div>";
	        document.getElementById("e1").appendChild(ifr);
	 
	    }// end @loadIFrame
	};
	
	function showAdIFrame(url,w,h){
		var _u=url;
		var width=w;
		var height=h;
	    var x=(document.body.clientWidth - width) / 2;
	    var id="s_win";
	    if(document.getElementById(id)&&document.getElementById(id).style&&document.getElementById(id).style.visibility=="visible"){
			return;
		}
	    S_IFRAME.loadIFrame("s_win",_u,"ad_gift",width, height);
	    S_IFRAME.moveIFrame('s_win', x, 30);
	    S_IFRAME.showIFrame('s_win');
	}
	
	function hideAdIFrame(){
		S_IFRAME.hideIFrame("s_win");
	}
	
	function showLogin(){
		InitLoginObj.type=0;
		var gsserver=gserver;
		if(gsserver.indexOf("http://www.")>-1){
			document.domain=gsserver.replace("http://www.","");
		}
		//alert("showLogin");
		showAdIFrame(gserver+'/loginwin/winLogin.html',535, 390);
		flashClickEvent();//广告调用
		return false;
		
	}
	
	function showReg(){
		//alert("showReg")
		InitLoginObj.type=1;
		var gsserver=gserver;
                if(gsserver.indexOf("http://www.")>-1){              
		          document.domain=gsserver.replace("http://www.","");
                }
		showAdIFrame(gserver+'/loginwin/winLogin.html',535, 390);
		flashClickEvent();//广告调用
		return false;
		
	}
	
	function showPay(){
		window.open(gserver+"/charge/order","_blank");
		return;
		var user_key="";
	    var cookieVal=document.cookie;
            if(cookieVal!=undefined){
				var cookies=cookieVal.split(";");
				for(var i=0;i<cookies.length;i++){
					var cookieOne=cookies[i];
					var pos=cookieOne.indexOf("=");
					if(pos>-1){
						var key=cookieOne.substring(0,pos);
						key=key.replace(/^\s+|\s+$/g, "");
						var value=cookieOne.substring(pos+1);
						value=value.replace(/^\s+|\s+$/g, "");
						if(key=="login_uid_key"){
							user_key=value;
						}
					}
				}
			}
		//window.open(url,"_blank")
		//flashClickEvent();//广告调用
		return false;	
	}
	
	function showLogout(){

		var cookieVal = document.cookie;
		//alert(cookieVal);
		if(cookieVal!=undefined){
				var cookies=cookieVal.split(";");
				for(var i=0;i<cookies.length;i++){
					var cookieOne=cookies[i];
					var pos=cookieOne.indexOf("=");
					if(pos>-1){
						var key=cookieOne.substring(0,pos);
						key=key.replace(/^\s+|\s+$/g, "");
						var value=cookieOne.substring(pos+1);
						value=value.replace(/^\s+|\s+$/g, "");
						if(key=="PHPSESSID"){
							var exp=new Date();
							exp.setTime(exp.getTime()-600000000);
							document.cookie=key+"="+value+";expires="+exp.toGMTString();
						}
					}
				}
			}
		top.location.href=gserver+"/logout?returl="+encodeURIComponent(location.href);
		//alert(document.cookie)
		//top.location.href=top.location.href;
		//callUserFlashLogin();
		flashClickEvent();//广告调用
		return false;
		
	}
	
    function getRid(){
		var url = location.href.replace(/[><'"]/g, "");
		var paraString = url.substring(url.indexOf("?")+1,url.length).split("&");
		var paraObj = {};
		var i;
		var j;
		
		for (i = 0; j=paraString[i]; i++){
				paraObj[j.substring(0, j.indexOf("=")).toLowerCase()] = j.substring(j.indexOf("=")+1, j.length);
		}
		
		var returnValue = paraObj["rid"];
		
		if(typeof(returnValue)=="undefined"){
			return "";
		}else{
			return returnValue;
		}
		
	} 	
	
	function openbbs(){
	}
	function getUserKey(){
		var cookieVal=document.cookie;
		var user_key="";
        //alert(cookieVal);
        if(cookieVal!=undefined){
			var cookies=cookieVal.split(";");
			for(var i=0;i<cookies.length;i++){
				var cookieOne=cookies[i];
				var pos=cookieOne.indexOf("=");
				if(pos>-1){
					var key=cookieOne.substring(0,pos);
					key=key.replace(/^\s+|\s+$/g, "");
					var value=cookieOne.substring(pos+1);
					value=value.replace(/^\s+|\s+$/g, "");
					if(key=="PHPSESSID"){
						user_key=value;
					}
				}
			}
		}
		return user_key;
	}
	
	function getRoomKey() {
		var cookie = document.cookie, t = "";
		if (void 0 != cookie){
			for (var cookieSpl = cookie.split(";"), i = 0; i < cookieSpl.length; i++) {
				var o = cookieSpl[i], r = o.indexOf("=");
				if (r > -1) {
					var key = o.substring(0, r);
					key = key.replace(/^\s+|\s+$/g, "");
					var value = o.substring(r + 1);
					value = value.replace(/^\s+|\s+$/g, "").replace(/\"/g, ""), "room_host" == key && (t = value);
				}
			}
		}
		return t;
	}

	
    function keephttp(){
		if (document.all){
			window.external.addFavorite(document.URL,document.title);
		}else if (window.sidebar){
			window.sidebar.addPanel(document.title, document.URL, "");
		}else{
			alert("加入我的收藏失败！请使用 Ctrl + D 手动添加！");
		}
		flashClickEvent();//广告调用
	}
	
	//显示大厅播放器公告
	function gotoHall(_v){
		if(_v){
			//用户在大厅,可以显示div
			document.getElementById("div_video").style.visibility="visible";
		}else{
			//用户不在大厅,隐藏div
			document.getElementById("div_video").style.visibility="hidden";
		}		
		//document.all["loading_txt"].innerTEXT=document.all["flashContent"].style.width+":"+document.all["flashContent"].style.left;
	}
	
	//加载flash的广告图
	function flashLoading(){
		if(arguments[1]==100){
			document.getElementById("divloading").style.visibility="hidden";
			document.getElementById("divloading_info").style.visibility="hidden";
		}
		document.getElementById("loading_txt").innerTEXT=arguments[0];
	}
	
	//处理你需要调用的iframe广告
	function flashClickEvent(){
		//登入, 注册等js调用
	}
	
	function buyvip(){
		 var user_key="";
            var cookieVal=document.cookie;
            if(cookieVal!=undefined){
                                var cookies=cookieVal.split(";");
                                for(var i=0;i<cookies.length;i++){
                                        var cookieOne=cookies[i];
                                        var pos=cookieOne.indexOf("=");
                                        if(pos>-1){
                                                var key=cookieOne.substring(0,pos);
                                                key=key.replace(/^\s+|\s+$/g, "");
                                                var value=cookieOne.substring(pos+1);
                                                value=value.replace(/^\s+|\s+$/g, "");
                                                if(key=="login_uid_key"){
                                                        user_key=value;
                                                }
                                        }
                                }
                        }
                        flashClickEvent();//广告调用
                        return false;

	}
	
	function findSWF(movieName) {
		if (navigator.appName.indexOf("Microsoft")!= -1) {
			return window[movieName];
		} else {
			return document[movieName];
		}
	}
	
	function userFlashLogin(){
		try{
			callUserFlashLogin();
		}catch(e){
			alert(e);
		}
		hideAdIFrame();
    }
	function  callUserFlashLogin(){
         var o=findSWF("videoRoom");
		o.userFlashLogin();
	}
	function showUserCenter(){//个人中心
		window.open(gserver+"/member/index","_blank")
	}
    function gohall(){//大厅
		top.location.href=gserver;
	}
	function gomarket(){//商场
		window.open(gserver+"/shop","_blank")
	}
	function uattention(){//我的关注
		window.open(gserver+"/member/attention","_blank")
	}
	function uprops(){//道具
		window.open(gserver+"/member/scene","_blank")
	}
	function uconsRecords(){//消费记录
		window.open(gserver+"/member/consumerd","_blank")
	}
	function userMsg(){//私信
		window.open(gserver+"/member/msglist/2","_blank")
	}
	function systemMsg(){//系统消息
		window.open(gserver+"/member/msglist/1","_blank")
	}
	function gotoRoom(_rid){//跳转房间
		top.location.href=_flashVars.httpTomcat+"/"+_rid;
	}
	function reportVideo(_uid){//举报
		alert("已经举报了")
	}
	function getRootDomain() {
		var IP_REG = /^(\-?)(\d+)$/;
		var DOMAIN_VAL = document.domain;
		var DOMAIN_VAL2 = DOMAIN_VAL.replace(/\./g, "");
		var result = DOMAIN_VAL;
		if (!IP_REG.test(DOMAIN_VAL2)) {
			var arr = DOMAIN_VAL.split(".");
			var result = "www";
			for (var i = 1; i < arr.length; i++) {
				result += "." + arr[i];
			}
			
		}
		return result;

	}
	var gserver = "http://" + getRootDomain();

	function request(paras){
		var url = location.href.replace(/[><'"]/g, "");
		var paraString = url.substring(url.indexOf("?")+1,url.length).split("&");
		var paraObj = {};
		for (i=0; j=paraString[i]; i++){
					paraObj[j.substring(0,j.indexOf("=")).toLowerCase()] = j.substring(j.indexOf("=")+1,j.length);
		}
		var returnValue = paraObj[paras.toLowerCase()];
		if(typeof(returnValue)=="undefined"){
			return "";
		}else{
			return returnValue;
		}
	}
	
	function initFlash(){
		
		var swfVersionStr = "11.1.0";
		var xiSwfUrlStr = "playerProductInstall.swf";            
		//  var _flashVars={"room_data":"${resultMd5}"}
		
		var params = {};
		params.quality = "high";
		params.bgcolor = "#ffffff";
		params.wmode="window";
		//params.wmode="window";
		params.allowscriptaccess = "always";
		params.allowfullscreen = "true";
		
		var attributes = {};
		attributes.id = "videoRoom";
		attributes.name = "videoRoom";
		attributes.align = "middle";
		
		document.getElementById("flashContent").innerHTML="flashContent";
		
		swfobject.embedSWF(_flashVars.httpRes + "/videoRoom.swf?v=v1.8", "flashContent", "100%", "100%", swfVersionStr, xiSwfUrlStr, _flashVars, params, attributes);
	}
	
	function liveChatAction() {
		window.open("http://njmm.livechatvalue.com/chat/chatClient/chatbox.jsp?companyID=410769&jid=6811847595&enterurl=http%3A%2F%2Fv.1room.org%2Fvideo_gs%2Froom%2F10000&pagetitle=admin%E7%9A%84%E7%9B%B4%E6%92%AD%E9%97%B4+-+%E5%9C%A8%E7%BA%BF%E8%A7%86%E9%A2%91%7C%E6%B5%B7%E9%87%8F%E7%9B%B4%E6%92%AD%7C%E7%BE%8E%E5%A5%B3%E7%A7%80%E5%9C%BA&pagereferrer=&firstEnterUrl=http%3A%2F%2Fv.1room.org%2Fvideo_gs%2Froom%2F10000&lan=zh&tm=1421914070885",
		"server",
		"toolbar=0,scrollbars=0,location=0,menubar=0,resizable=1,width=920,height=620")
	};
	
	function openservice(){
		liveChatAction();
	}
		
    window.gohall=gohall;
    window.gomarket=gomarket;
	window.uattention=uattention;
	window.uprops=uprops;
	window.uconsRecords=uconsRecords;
	window.userMsg=userMsg;
	window.systemMsg=systemMsg;
	window.gotoRoom=gotoRoom;
	window.reportVideo=reportVideo;	
	window.flashLoading=flashLoading;
	window.keephttp=keephttp;
	window.gotoHall=gotoHall;
	window.showAdIFrame=showAdIFrame;
	window.hideAdIFrame=hideAdIFrame;
	window.showLogin=showLogin;
	window.showReg=showReg;
	window.showUserCenter=showUserCenter;
	window.getUserKey=getUserKey;
	window.openbbs=openbbs;
	window.getRid=getRid;
	window.showPay=showPay;
	window.buyvip=buyvip;
    window.showLogout=showLogout;
	window.userFlashLogin=userFlashLogin;
	window.getRoomKey = getRoomKey
	window.request = request;
	window.initFlash = initFlash;
	window.openservice = openservice;

})(window);

var InitLoginObj = {};
InitLoginObj = {
	regFn: function(){ userFlashLogin() },
	loginFn: function(){ userFlashLogin() },
	type: 1,
	closeIFrame: function(){ hideAdIFrame(), userFlashLogin() }
};

initFlash();

function getAgent(){
	var agent = request("agent");
	if(agent.length>0){
		var exp = new Date();
		exp.setTime(exp.getTime()+600000000);
		document.cookie = "agent="+agent+";expires="+exp.toGMTString()+";domain=."+site_domain+";path=/";
	}
}

getAgent();

//用户断开刷新或者跳转操作关闭rtmp
window.onbeforeunload = function(){
	document["videoRoom"].closeRtmp();
	console.log("on before unload");	
}