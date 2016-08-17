package com.rover022.tool {
import com.junkbyte.console.Cc;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.Dictionary;
import flash.utils.Timer;

/**
 * @Content
 * @Author Ever
 * @E-mail: ever@kingjoy.co
 * @Version 1.0.0
 * @Date：2015-4-22 下午1:38:09
 */
public class SensitiveWordFilter {
    //关键字数组
    private static var dirtyArr:Array;
    //模糊关键字数组
    private static var blurArr:Array;
    //存储关键字的字典 类别
    private static var dirtyDec:Dictionary;
    //根节点
    public static var treeRoot:TreeNode;
    /**是否让其他用户看到发言
     * true:能看到
     * false:不能看到
     * */
    public static var canSend:Boolean = true;

    /**存储要过滤的关键字
     * 传过来的字符串
     * 1：整句
     * 2：单词
     * ["33|2","22|1"] */
    public static function setDirtyWords(dObj:Object):void {
        //dObj.ret = -100;
        // dObj.ret = 1;
        //dObj.kw = "ID|2||大丑逼|2||你麻痹|2||澳门威尼斯|2||训管|2||线上赌搏|2||名字|2||恋夜|2||资料|2||丑B|2||妈B|2||傻逼|2||昵称|2||扣B表演包射|2||球球|2||WEIXIN|2||招募|2||扣B|2||露脸|2||.ne|1||大琇女|2||.bar|1||.cc|1||yangjian|2||6房|2||91视频|2||腾讯|2||⑼⑶⑵⑵⑻|2||裸聊|2||Ⅸ|2||Ⅷ|2||Ⅵ|2||Ⅳ|2||大秀|2||tta00|2||Ⅻ|2||TTA00|2||Ⅹ|2||78专秀|2||傻比|2||尼玛|2||你妈|2||婊子|2||扣扣|2||巡查|2||3|2||微信|2||繁星|2||酷狗|2||yy|2||蝙蝠侠|2||金B|2||GT|1||伍|2||陆|2||叁|2||肆|2||壹|2||贰|2||招聘女客服|2||奇乐|2||jb|2||JB|2||玖|2||柒|2||捌|2||6间房|2||你.妈.的|2||逼逼|2||lianxiu|2||tvxiu|2||suikoo|2||系统提示|2||看眯眯摳|2||三|2||拾|2||零|2||大琇女摳|2||恋夜|1||四|2||五|2||恋秀|1||歪歪|2||走私|2||招聘主播|1||鸡巴|2||秀站|2||斗鱼|1||秀站日结月上万|2||企鹅|2||六|2||九|2||znqxd.com|2||垃圾网站|2||骗钱的|2||中视娱乐|2||看B秀|2||咖啡秀|2||六间房|2||悠秀|2||KK|2||新浪秀场|2||我秀|2||裙秀|1||YY|2||珠宝销售|2||waiwai|2||六房|2||⑸|2||等于|2||⑷|2||⑶|2||⑵|2||⑺|2||⑹|2||v信|2||⑨|2||⑴|2||⑦|2||⑧|2||①|2||❾❾❻❹|2||③|2||②|2||❾❻|2||⑤|2||❾❾|2||④|2||❹❷|2||❻❹|2||⑥|2||❾❻❹|2||企俄|2||企|2||200元=|2||鸡婆|2||群秀|2||quxincao|2||私下秀|2||q|1||Q|1||咯女摳摳|2||草泥马|2||操你妈|2||我操|2||㈡|2||❼|2||❻|2||8千钻送贵族|2||㈠|2||❽|2||⑼|2||❶|2||❸|2||❺|2||骚逼|2||骚|2||⑻|2||日结|2||长期租|1||卖号|1||看逼|2||破解|2||破限|2||煞笔|2||试看|2||大綉女摳|2||扣|2||破县|2||大綉女|2||看逼加摳|2||要的加|1||租|2||租凭|2||㈧|2||㈨|2||㈥|2||㈦|2||Ⅲ|2||Ⅰ|2||抠抠|2||Ⅱ|2||㈣|2||㈤|2||㈢|2||把长期出租|1||sb|1||SB|1||妓女|2||裸女扣|1||招|2||歪|2||y y|2||共享|2||微 信|2||❾|2||❹|2||❷|2||❾❾❻❹❷|2||售|2||租售|2||租售无限制号|2||为信|2||企 鹅|2";
        if (dObj.ret == 1) {
            dirtyArr = [];
            blurArr = [];
            dirtyDec = new Dictionary();
            //trace(JSON.stringify(dObj.kw));
            var arr:Array = dObj.kw.split("||");
            for each(var str:String in arr) {
                var tArr:Array = str.split("|");
                if (tArr[0] == "")
                    continue;
                dirtyDec[tArr[0]] = tArr[1];
                if (tArr[1] == 1)
                    blurArr.push(tArr[0]);
                dirtyArr.push(tArr[0]);
            }
            regSensitiveWords(dirtyArr);
        }
    }

    /**获取关键字*/
    public static function getDirtyWords():Array {
        return dirtyArr;
    }

    /**通过某个关键字，获取替换状态*/
    public static function getDirtyState(str:String):int {
        return int(dirtyDec[str]);
    }

    /**这是一个预处理步骤，生成敏感词索引树，功耗大于查找时使用的方法，但只在程序开始时调用一次*/
    public static function regSensitiveWords(words:Array):void {
        treeRoot = new TreeNode();
        treeRoot.value = "";
        var words_len:int = words.length;
        for (var i:int = 0; i < words_len; i++) {
            var word:String = words[i];
            var len:int = word.length;
            var curNode:TreeNode = treeRoot;
            for (var c:int = 0; c < len; c++) {
                var char:String = word.charAt(c);
                var tmp:TreeNode = curNode.getChild(char);
                if (tmp)
                    curNode = tmp;
                else
                    curNode = curNode.addChild(char);
            }
            curNode.isEnd = true;
        }
    }

    /**
     * 替换敏感词汇
     * */
    public static function validAndReplaceSensitiveWord(chatWords:String):String {
        if (blurArr == null) {
            return chatWords;
        }
        canSend = false;
        if (!canSend) {
            canSend = true;
            for (var i:int = 0, len:int = blurArr.length; i < len; i++) {
                var validWords:String = chatWords;//复制一个副本  因为下面需要slice
                var blurItemString:String = blurArr[i];
                var blurStrLength:int = blurItemString.length;
                var count:int = 0;
                var index:int = 0;
                while (index < blurStrLength) {
                    //是否包含模糊字符
                    var tempIndex:int = validWords.indexOf(blurItemString.charAt(index));
                    if (tempIndex == -1)
                        break;
                    else
                        count++;
                    validWords = validWords.slice(tempIndex + 1);
                    index++;
                }
                if (count >= blurStrLength) {
                    canSend = false;
                    break;
                }
            }
        }
        //进行2类关键字替换
        if (canSend) {
            var char:String;
            var curTree:TreeNode = treeRoot; //从跟结点开始
            var childTree:TreeNode;
            var curEndWordTree:TreeNode;
            var dirtyWord:String;
            var charIndex:int = 0;//循环索引
            var charLength:int = chatWords.length;
            var startIndexTag:int = -1;
            var endIndexTag:int = -1;
            while (charIndex < charLength) {
                char = chatWords.charAt(charIndex);
                //5月17日增加逻辑
                if (char == "{") {
                    var endF:String = chatWords.charAt(charIndex + 4);
                    if (endF == "}") {
                        charIndex += 4;
                        trace("是表情跳过");
                        continue;
                    }
                }
                //
                childTree = curTree.getChild(char);
                if (childTree) //如果根树开始匹配
                {
                    if (childTree.isEnd) {
                        curEndWordTree = childTree;
                        endIndexTag = charIndex;
                        if ((charLength - 1) == charIndex)//如果已经是最后一个字符了直接替换 否则会因为charIndex增加退出循环
                        {
                            if (curEndWordTree) {
                                dirtyWord = curEndWordTree.getFullWord();
                                if (getDirtyState(dirtyWord) != 1) {
                                    chatWords = chatWords.replace(dirtyWord, getReplaceWord(dirtyWord.length));
                                }
                            }
                        }
                    }
                    if (startIndexTag == -1) {
                        startIndexTag = charIndex;
                    }
                    curTree = childTree;
                    charIndex++;
                }
                else //开启下一轮比较
                {
                    if (curEndWordTree)//如果之前有遍历到词尾，则替换该词尾所在的敏感词
                    {
                        dirtyWord = curEndWordTree.getFullWord();
                        if (getDirtyState(dirtyWord) != 1) {
                            chatWords = chatWords.replace(dirtyWord, getReplaceWord(dirtyWord.length));
                        }
                        charIndex = endIndexTag;
                    }
                    else if (curTree != treeRoot)//如果之前有遍历到敏感词非词尾，匹配部分未完全匹配，则设置循环索引为敏感词词首索引
                    {
                        charIndex = startIndexTag;
                        startIndexTag = -1;
                    }
                    //重置到敏感词根目录
                    curTree = treeRoot;
                    curEndWordTree = null;
                    charIndex++;
                }
            }
        }
        return chatWords;
    }

    /**
     *判断是否包含敏感词
     * @param dirtyWords
     * @return
     *
     */
    public static function containsBadWords(dirtyWords:String):Boolean {
        var char:String;
        var curTree:TreeNode = treeRoot;
        var childTree:TreeNode;
        var curEndWordTree:TreeNode;
        var dirtyWord:String;
        var c:int = 0;//循环索引
        var endIndex:int = 0;//词尾索引
        var headIndex:int = -1;//敏感词词首索引
        while (c < dirtyWords.length) {
            char = dirtyWords.charAt(c);
            childTree = curTree.getChild(char);
            if (childTree)//在树中遍历
            {
                if (childTree.isEnd) {
                    curEndWordTree = childTree;
                    endIndex = c;
                }
                if (headIndex == -1) {
                    headIndex = c;
                }
                curTree = childTree;
                c++;
            }
            else//跳出树的遍历
            {
                if (curEndWordTree)//如果之前有遍历到词尾，则替换该词尾所在的敏感词，然后设置循环索引为该词尾索引
                {
                    dirtyWord = curEndWordTree.getFullWord();
                    dirtyWords = dirtyWords.replace(dirtyWord, getReplaceWord(dirtyWord.length));
                    c = endIndex;
                    return true;
                }
                else if (curTree != treeRoot)//如果之前有遍历到敏感词非词尾，匹配部分未完全匹配，则设置循环索引为敏感词词首索引
                {
                    c = headIndex;
                    headIndex = -1;
                }
                curTree = treeRoot;
                curEndWordTree = null;
                c++;
            }
        }
        //循环结束时，如果最后一个字符满足敏感词词尾条件，此时满足条件，但未执行替换，在这里补加
        if (curEndWordTree) {
            return true;
            dirtyWord = curEndWordTree.getFullWord();
            dirtyWords = dirtyWords.replace(dirtyWord, getReplaceWord(dirtyWord.length));
        }
        return false;
    }

    private static function getReplaceWord(len:uint):String {
        var replaceWord:String = "";
        for (var i:uint = 0; i < len; i++) {
            replaceWord += "*";
        }
        return replaceWord;
    }

    public function SensitiveWordFilter() {
    }

    public static function init(url:String):void {
        var timer:Timer = new Timer(300000, 0);
        timer.addEventListener(TimerEvent.TIMER, onTimerHandle);
        timer.start();
        var _burl:String = url;
        var urlLoader:URLLoader = new URLLoader();
        var urlreques:URLRequest = new URLRequest(_burl + "/video_gs/kw?time=" + Math.random());
        urlLoader.addEventListener(Event.COMPLETE, onDataHandle);
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandle);
        function onIOErrorHandle(e:Event):void {
        }

        function onTimerHandle(e:TimerEvent):void {
            if (urlLoader && urlreques)
                urlLoader.load(urlreques)
        }

        function onDataHandle(e:Event):void {
            var data:String = urlLoader.data;
            data = decodeURIComponent(data);
           // Cc.log("dairty world : " + urlLoader.data);
            //trace("关键字过来了:", data);
            try {
//                data='{"ret":1,"msg":"","kw":"ID|2||大丑逼|2||你麻痹|2||澳门威尼斯|2||线上赌搏|2||恋夜|2||丑B|2||妈B|2||傻逼|2||99642|2||扣B表演包射|2||1556277661|2||98|2||球球|2||WEIXIN|2||招募|2||2663384622|2||扣B|2||露脸|2||.ne|1||8585|2||大琇女|2||.bar|1||uj96.|2||3四七|2||看眯眯摳|2||.cc|1||九8|2||九8二九6|2||yangjian|2||九6|2||645699642|2||⑼⑶⑵|2||6房|2||91视频|2||⑵|2||1805238686|2||⑻|2||腾讯|2||9⒊|2||⑼⑶⑵⑵⑻|2||⒉|2||裸聊|2||⒏|2||9⒊⒉⒉⒏|2||大秀|2||20658|2||78专秀|2||98296|2||⒐⒐⒍⒋2|1||傻比|2||尼玛|2||你妈|2||婊子|2||扣扣|2||裸女扣B表演可试看保证激情射|2||微信|2||繁星|2||酷狗|2||yy|2||蝙蝠侠|2||金B|2||GT|1||招聘女客服|2||奇乐|2||jb|2||JB|2||招靓女主播520|2||6间房|2||你.妈.的|2||逼逼|2||lianxiu|2||tvxiu|2||93228|2||suikoo|2||93|2||228|2||322|2||系统提示|2||恋夜|1||恋秀|1||歪歪|2||走私|2||招聘主播|1||鸡巴|2||秀站|2||斗鱼|1||秀站日结月上万|2||企鹅|2||znqxd.com|2||垃圾网站|2||骗钱的|2||9158|2||中视娱乐|2||看B秀|2||咖啡秀|2||六间房|2||悠秀|2||KK|2||新浪秀场|2||我秀|2||裙秀|1||YY|2||珠宝销售|2||waiwai|2||六房|2||6707|2||等于|2||748|2||707|2||4870|2||v信|2||00=8千钻送贵族-先给东西-加我79251182|2||四八七零|2||六七零七|2||❾❾❻❹|2||❾❻|2||❾❾|2||❹❷|2||❻❹|2||❾❻❹|2||67074870|2||企俄|2||企|2||200元=|2||鸡婆|2||群秀|2||quxincao|2||私下秀|2||q|1||Q|1||三四七一|2||咯女摳摳|2||草泥马|2||/|2||http|2||操你妈|2||cc|2||我操|2||com|2||79251182|2||8千钻送贵族|2||7925|2||骚逼|2||骚|2||net|2||co|2||www.|2||.com|2||日结|2||长期租|1||卖号|1||看逼|2||破解|2||破限|2||煞笔|2||试看|2||大綉女摳|2||扣|2||三四七|2||破县|2||大綉女|2||看逼加摳|2||186|2||18627662235|2||824849493|2||要的加|1||租|2||租凭|2||2235|2||2766|2||抠抠|2||把长期出租|1||九八二九六|2||645五|2||sb|1||SB|1||妓女|2||⒐⒐⒍42|2||88484|1||裸女扣|1||招|2||歪|2||y+y|2||共享|2||微+信|2||❾|2||❻|2||❹|2||❷|2||❾❾❻❹❷|2||售|2||租售|2||租售无限制号|2||为信|2||企+鹅|2||⒍|2||⒐|2||⒐⒐⒍|2||⒋|2"}'
                var obj:Object = JSON.parse(data);
                SensitiveWordFilter.setDirtyWords(obj);
            }
            catch (e:Error) {
            }
        }

        onTimerHandle(null);
    }
}
}