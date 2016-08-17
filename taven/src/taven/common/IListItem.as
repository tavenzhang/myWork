package taven.common
{
import flash.display.DisplayObject;

public interface IListItem
	{
		function  set data(value:*):void;
		function  get data():*;
			
		function  get view():DisplayObject;
		
		function get select():Boolean;
	
		function set select(value:Boolean):void;
	
	}
}