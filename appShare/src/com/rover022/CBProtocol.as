/**
 * Created by Administrator on 2015/4/30.
 */
package com.rover022 {
public class CBProtocol {
	/**
	 * 安全沙箱
	 */
	public static const crossDomain:int           = 843;
	/**
	 * socket登陆成功
	 */
	public static const connectSuccess:int        = 200;
	/**
	 * socket登陆失败
	 */
	public static const connectFail:int           = 400;
	/**
	 * 多处登录
	 */
	public static const errorTwoLogon:int         = 500;
	/**
	 * 多处登录
	 */
	public static const closeRtmp:int             = 501;
	/**
	 * ping
	 */
	public static const ping:int                  = 9999;
	/**
	 * 退出游戏
	 */
	public static const exit:int                  = 1005;
	/**
	 * 连接socket
	 */
	public static const getKey:int                = 10000;
	/**
	 * 连接socket
	 */
	public static const login:int                 = 10001;
	/**
	 * 房间信息
	 */
	public static const roomInfo:int              = 10002;
	/**
	 * 模式
	 */
	public static const roomBoard:int             = 10003;
	/**
	 * 模式
	 */
	public static const roomOptionChange:int      = 10005;
	/**
	 * 用户信息改变 费用改变
	 */
	public static const moneyChange:int           = 10008;
	/**
	 *  用户信息改变 费用改变
	 */
	public static const moneyChange2:int          = 10009;
	/**
	 * 玩家列表
	 */
	public static const listUser:int              = 11001;
	/**
	 * 进入房间时贵族信息
	 */
	public static const onEnterRoom_VIP_10013:int = 10013;
	/**
	 * 进入房间
	 */
	public static const onEnterRoom:int           = 11002;
	/**
	 * 退出房间
	 */
	public static const onOutRoom:int             = 11003;
	/**
	 * 查询获取更多用户
	 */
	public static const onGetMoreUserInfor:int    = 11004;
	public static const addManger:int             = 11006;
	public static const removeManger:int          = 11007;

	public static const listManger:int            = 11008;
	/**
	 * 踢出房间
	 */
	public static const kickOut:int               = 18005;
	/**
	 * 主播下播推荐其他房间id
	 */
	public static const featureRoom:int           = 12006;
	/**
	 * 还剩多少时间可以聊天d
	 */
	public static const pushFobTime:int           = 12007;
	/**
	 * 邀请主播一对一
	 */
	public static const userInviteVideo:int       = 13001;
	/**
	 * 拒绝用户一对一请求
	 */
	public static const rejUserInviteVideo:int    = 13004;
	/**
	 * 座位
	 */
	public static const listSeat:int              = 14001;
	/**
	 * 抢座位
	 */
	public static const seatActionGetSeat:int     = 14002;
	/**
	 * 本场排名
	 */
	public static const getKtvOrder:int           = 15001;
	/**
	 * 增量更新本场排名
	 */
	public static const pushKtvOrder:int          = 15002;
	/**
	 * 本场单个礼物数量
	 */
	public static const listNumGift:int           = 16001;
	/**
	 * 车位
	 */
	public static const listCar:int               = 17001;
	/**
	 * 增加管理员
	 */
	public static const addManage:int             = 11006;
	/**
	 * 删除管理员
	 */
	public static const delManage:int             = 11007;
	/**
	 * 管理员列表
	 */
	public static const listManage:int            = 11008;
	/**
	 * 麦序
	 */
	public static const songActionListPlay_20001:int    = 20001;
	/**
	 * 上麦
	 */
	public static const startTalkPlay_20002:int         = 20002;
	/**
	 * 下麦
	 */
	public static const stopTalkPlay_20003:int          = 20003;
	/**
	 * 电影flv
	 */
	public static const playFlv:int               = 21001;
	/**
	 * 申请连麦
	 */
	public static const applyContactMic:int       = 23001;
	/**
	 * 同意申请连麦
	 */
	public static const reApplyContactMic:int     = 23002;
	/**
	 * 同申请连麦
	 */
	public static const pushApplyContactMic:int   = 23003;
	/**
	 * 放弃连麦
	 */
	public static const faildContactMic:int       = 23004;
	/**
	 * 放弃连麦
	 */
	public static const deleteContactMic:int      = 23005;
	/**
	 * 聊天
	 */
	public static const publicMessage:int         = 30001;
	/**
	 * 聊天
	 */
	public static const systemPublicMessage:int   = 30003;
	/**
	 * 礼物
	 */
	public static const sendGift:int              = 40001;
	/**
	 * 豪华礼物
	 */
	public static const richGift_40003:int        = 40003;
	/**
	 * 主播房间列表
	 */
	public static const listAutor:int             = 50001;
	/**
	 * 主播房间列表
	 */
	public static const onListUserChange:int      = 50002;
	/**
	 * 	//房间人数情况
	 */
	public static const userListNum_50007:int      = 50007;

	/**
	 * listRtmpRoom 主播列表
	 */
	public static const listRtmpRoom_80001:int    = 80001;
	/**通知用户rtmp 播放服务器列表 */
	public static const rtmp_client_80002:int     = 80002; //

	/**
	 * 错误消息提示
	 */
	public static const pushErrorMethod:int       = 15555;
	/**获取主播预约列表人数 */
	public static const list_dateUsers_50005:int  = 50005;
	/**获取魅力之星排行 */
	public static const list_start_15004:int      = 15004; //获取魅力之星排行
	/**金屋藏娇 */
	public static const list_Active_15006:int     = 15006; //金屋藏娇
	/**多礼物活动通用*/
	public static const list_Active_15007:int     = 15007; //
	/**获取消息条数：{cmd:50006,uid:} 返回：{letter:私信条数，news:消息条数} */
	public static const msg_notice_50006:int      = 50006;
	/**进入房间限制*/
	public static const enterRoomLimit_10011:int  = 10011;
	/**开启关闭限制*/
	public static const enterRoomLimit_10012:int  = 10012;
	public static const getSignActivity_24001:int = 24001;
	//15001
	public static const RankMonyDay_15005:int     = 15005;
	public static const comboGift_40002:int       = 40002;
	//vip贵族开通
	public static const VIP_OPEN_18001:int        = 18001;
	//获取贵宾席位 列表
	public static const VIP_LIST_18002:int        = 18002;
	public static const enterRoomLimit_10014:int  = 10014;
		//抽奖
	public static const activeCj_62001:int  = 62001;
}
}
