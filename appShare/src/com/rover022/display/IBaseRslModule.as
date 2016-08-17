/**
 * Created by ws on 2015/8/17.
 */
package com.rover022.display {
import com.rover022.IVideoModule;
import com.rover022.IVideoRoom;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;

public interface IBaseRslModule {
      //��ʾui
      function show():void;
      //�ر�ui
      function hide():void;
      //ģ������
      function dispose():void;

      function resize():void;

      //��ȡview ui
      function get view():DisplayObjectContainer;
    }
}
