/**
 * Created by Roger on 2014/11/25.
 */
package com.kingjoy.handler {
/**
 * 模块事件处理的基本类...
 * 把事件传到到这里来统一处理....
 */
public class IEventHandler {
	public var view:VideoMain;

	public function IEventHandler(_view:VideoMain) {
		view = _view;
	}

}
}
