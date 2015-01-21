package org.ranapat.flatflash.tools.parsers {
	import flash.events.IEventDispatcher;
	
	[Event(name = "ParseComplete", type = "org.ranapat.flatflash.tools.parsers.ParseEvent")]
	[Event(name = "ParseFail", type = "org.ranapat.flatflash.tools.parsers.ParseEvent")]
	public interface IParser extends IEventDispatcher {
		function destroy():void;
		function parse(file:String):void;
	}
	
}