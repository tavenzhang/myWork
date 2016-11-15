/**
 * Created by yvan on 16/6/2.
 */

export function ajax(){
	var ajaxData = {
		type:arguments[0].type || "GET",
		url:arguments[0].url || "",
		async:arguments[0].async || "true",
		data:arguments[0].data || null,
		dataType:arguments[0].dataType || "text",
		contentType:arguments[0].contentType || "application/x-www-form-urlencoded",
		beforeSend:arguments[0].beforeSend || function(){},
		success:arguments[0].success || function(){},
		error:arguments[0].error || function(){}
	};
	ajaxData.beforeSend()
	var xhr = createxmlHttpRequest();
	xhr.responseType=ajaxData.dataType;
	xhr.open(ajaxData.type,ajaxData.url,ajaxData.async);
	xhr.setRequestHeader("Content-Type",ajaxData.contentType);
	xhr.send(convertData(ajaxData.data));
	xhr.onreadystatechange = function() {
		if (xhr.readyState == 4) {
			if(xhr.status == 200){
				ajaxData.success(xhr.response)
			}else{
				ajaxData.error(xhr.status,xhr.response)
			}
		}
	}
}

function createxmlHttpRequest() {
	if (window.ActiveXObject) {
		return new ActiveXObject("Microsoft.XMLHTTP");
	} else if (window.XMLHttpRequest) {
		return new XMLHttpRequest();
	}
}

function convertData(data){
	if( typeof data === 'object' ){
		var convertResult = "" ;
		for(var c in data){
			convertResult+= c + "=" + data[c] + "&";
		}
		convertResult=convertResult.substring(0,convertResult.length-1)
		return convertResult;
	}else{
		return data;
	}
}

/**
 * 设置cookie
 * @param key
 * @param val
 */
export const setCookie = (key,val) => {
	document.cookie = key+"="+val;
};

/**
 * 获取cookie值
 * @param name
 * @returns {*}
 */
export const getCookie  = name => {
	let arr,
		reg=new RegExp("(^| )"+name+"=([^;]*)(;|$)");

	if(arr=document.cookie.match(reg))

		return unescape(arr[2]);
	else
		return null;
};

/**
 * 删除cookie值
 * @param name
 */
export const delCookie = name => {
	let exp = new Date();
	exp.setTime(exp.getTime() - 1);
	let cval=getCookie(name);
	if(cval!=null) document.cookie= name + "="+cval+";expires="+exp.toGMTString();
};

/**
 * 获取token值
 * @param tokenName
 * @returns {*}
 */
export const getToken = (tokenName = "XSRF-TOKEN") => {
	return getCookie(tokenName)
}

/**
 * @description pw编码
 * @type 私有方法
 * @author Young
 * @param string: 编码前的密码
 * @return string: 编码后的密码
 */
export const encode = s => {
	var es = [], c='', ec='';
	s = s.split('');
	for(var i=0, length=s.length; i<length; i++){
		c = s[i];
		ec = encodeURIComponent(c);
		if(ec==c){
			ec = c.charCodeAt().toString(16);
			ec = ('00' + ec).slice(-2);
		}
		es.push(ec);
	}
	return es.join('').replace(/%/g,'').toUpperCase();
}

/**
 * 判断对象是否是空
 * @param obj
 * @returns {boolean}
 */
export const isEmptyObj = obj => {
    for (let name in obj) {
        return false;
    }
    return true;
};

/**
 * 转换含url的字符串
 * @param str
 */
export const changLinkMsg = str => {
	let linkMsg =/@(.+?)@/g.exec(str);
	if(linkMsg) {
		const parms = linkMsg[0].split(" ");
		const text = parms[1].substring(6,parms[1].length-1);
		const link = parms[2].substring(6,parms[2].length-4);
		const strArray = str.split(linkMsg[0]);
		return [...strArray,link,text];
	}
	else {
		return [str];
	}
};

/**
 * 时间戳转日期格式
 * @param time
 * @returns {string}
 */
export const changeDate = time => {
	return new Date(parseInt(time) * 1000).toLocaleString().replace(/:\d{1,2}$/,' ');
};

/**
 * 打印
 */
export const log = (name=null,obj=[]) => {
	if( process.env.NODE_ENV == 'development') {//开发环境
		return console.log(name,obj)
	}
};

/**
 * 获取随机整数
 * @param start
 * @param end
 * @returns {*|number}
 */
export const rnd = (start, end) => {
	return Math.floor(Math.random() * (end - start) + start);
}