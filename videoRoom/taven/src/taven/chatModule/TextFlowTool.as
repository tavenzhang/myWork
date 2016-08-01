/**
 * Created by Administrator on 2015/4/13.
 */
package taven.chatModule {
import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.InlineGraphicElement;
import flashx.textLayout.elements.LinkElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.FlowElementMouseEvent;
import flashx.textLayout.events.StatusChangeEvent;

public class TextFlowTool {

    //public static var pool_TextFlow:ObjectPool = new ObjectPool(TextFlow);
    //public static var pool_Span:ObjectPool = new ObjectPool(SpanElement);
    //public static var pool_Link:ObjectPool = new ObjectPool(LinkElement);
    //public static var pool_Paragraph:ObjectPool = new ObjectPool(ParagraphElement);
    //public static var pool_Graphic:ObjectPool = new ObjectPool(InlineGraphicElement);

    public static var fontClass:String = "宋体";
    public static var fontSize:uint = 12;

//    public static function resetEelement(elemet:FlowElement):void {
//        if (!elemet)
//            return;
//        //  count++;
//        if (elemet is TextFlow) {
//            var textFlow:TextFlow = elemet as TextFlow;
//
//            textFlow.interactionManager = null;
//            pool_TextFlow.recycle(elemet);
//            while (textFlow.numChildren > 0) {
//                resetEelement(textFlow.getChildAt(0));
//                textFlow.removeChildAt(0);
//            }
//        }
//        else if (elemet is SpanElement) {
//            var span:SpanElement = elemet as SpanElement;
//            span.text = "";
//            pool_Span.recycle(elemet);
//        }
//        else if (elemet is LinkElement) {
//            var link:LinkElement = elemet as LinkElement;
//            pool_Link.recycle(link);
//            while (link.numChildren > 0) {
//                resetEelement(link.getChildAt(0));
//                link.removeChildAt(0);
//            }
//
//        }
//        else if (elemet is ParagraphElement) {
//            var pan:ParagraphElement = elemet as ParagraphElement;
//            pan.paddingBottom = 0;
//            pan.paddingLeft = 0;
//
//            pool_Paragraph.recycle(pan);
//            while (pan.numChildren > 0) {
//                resetEelement(pan.getChildAt(0));
//                pan.removeChildAt(0);
//            }
//
//        }
//        else if (elemet is InlineGraphicElement) {
//            var inlineGraphicElement:InlineGraphicElement = elemet as InlineGraphicElement;
//            inlineGraphicElement.source = "";
//            pool_Graphic.recycle(inlineGraphicElement);
//        }
//    }

    public static function buildTextFlow():TextFlow {
        var textFlow:TextFlow = new TextFlow;
        textFlow.interactionManager = new SelectionManager();
        if (textFlow.hasEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE)) {
            textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, arguments.callee);
        }
        textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, function (e:StatusChangeEvent):void {
            textFlow.flowComposer.updateAllControllers();
        });
        return textFlow;
    }


    public static function buildSpanElement(text:String, color:int = 0xFFFFFF, func:Function = null, data:Object = null):FlowElement {
        var span:SpanElement;
        span = new SpanElement;
        span.text = text;
        span.fontFamily = fontClass;
        span.fontSize = fontSize;
        span.color = color;

        if (func) {
            var _loc_3:LinkElement = new  LinkElement;
            _loc_3.addEventListener(FlowElementMouseEvent.CLICK, function (e:FlowElementMouseEvent):void {
                trace("buildSpanElement");
                func.call(null, data);
            });
            _loc_3.addChild(span);
            return _loc_3;
        } else {
            return span;
        }
    }

    public static function buildLinkElement(text:String, color:int = 0xFFFFFF, func:Function = null, data:Object = null):FlowElement {

        var _loc_3:LinkElement = new    LinkElement;
        var span:SpanElement = new   SpanElement;
        span = new SpanElement;
        span.text = text;
        span.fontFamily = fontClass;
        span.fontSize = fontSize;
        span.color = color;
        _loc_3.addChild(span);
        if (_loc_3.hasEventListener(FlowElementMouseEvent.CLICK)) {
            _loc_3.removeEventListener(FlowElementMouseEvent.CLICK, arguments.callee);
        }
        if (func) {
            _loc_3.addEventListener(FlowElementMouseEvent.CLICK, function (e:FlowElementMouseEvent):void {
                func.call(null, data);
            });
        }
        return _loc_3;
    }

    /**
     * 段落
     * @return
     */
    public static function buildParagraphElement(src:String = "", color:int = 0xFFFFFF):ParagraphElement {
        var pan:ParagraphElement = new ParagraphElement;
        if (src != "") {
            var ju:FlowElement = buildSpanElement(src, color);
            pan.addChild(ju);
        }
        return pan;
    }


    public static function buildInlineGraphicElement(soure:* = null):InlineGraphicElement {
        var inlineGraphicElement:InlineGraphicElement = new InlineGraphicElement;
        if (soure != "" && soure != null) {
            inlineGraphicElement.width = undefined
            inlineGraphicElement.height = undefined;
            inlineGraphicElement.source = soure;
            inlineGraphicElement.paddingBottom = 0;
        }
        return inlineGraphicElement;
    }

    public static function formartMessgaeWords(msg:String, contion:ParagraphElement, color:uint = 0xFFFFFF):void {
        var array:Array = [];
        var backUp:String = msg;
        var i:int = msg.indexOf("{/");
        if (msg.indexOf("{/") > -1) {
            //先存取前面字符{前面部分
            var font:String = msg.substr(0, i);
            contion.addChild(TextFlowTool.buildSpanElement(font, color));
            var face:String = msg.substr(i + 1, 3);
            var imageUrl:String = ChatRoomModule.faceArr[face];
            if (imageUrl != null) {
                var ing:InlineGraphicElement = TextFlowTool.buildInlineGraphicElement(imageUrl);
                contion.addChild(ing);
                //后续处理
                backUp = msg.substr(i + 5);
                //递归处理
                formartMessgaeWords(backUp, contion, color);

            }
        }
        else {
            contion.addChild(TextFlowTool.buildSpanElement(msg, color));
        }
    }


    public static function getElementArrayFromWords(msg:String):Array {
        var array:Array = [];
        var backUp:String = msg;
        for (var i:int = 0; i < msg.length; i++) {
            var _s:String = msg.charAt(i);
            if (_s == "/") {

                var face:String = msg.substr(i, 3);
                var imageUrl:String = ChatRoomModule.faceArr[face];
                if (imageUrl != null) {
                    var ing:InlineGraphicElement = TextFlowTool.buildInlineGraphicElement(imageUrl);
                    var font:String = msg.substr(0, i);

                    array.push(TextFlowTool.buildSpanElement(font));
                    array.push(ing);
                    //后续处理
                    backUp = msg.substr(i + 3);
                    i += 2;
                }
            }
        }
        if (backUp.length > 0) {
            array.push(TextFlowTool.buildSpanElement(backUp));
        }
        return array;
    }
}
}
