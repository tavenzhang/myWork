/**
 * Created by Taven on 2015/8/31.
 */
package control {
public interface IControl {
    function regMsg():void;
    function handleMessgae(data:*):void;
    function dispose():void;
}
}
