package net.peakgames.components.flatflash.tools.parsers {
	import flash.events.IEventDispatcher;
	
	[Event(name = "ParseComplete", type = "net.peakgames.components.flatflash.tools.parsers.ParseEvent")]
	[Event(name = "ParseFail", type = "net.peakgames.components.flatflash.tools.parsers.ParseEvent")]
	public interface IParser extends IEventDispatcher {
		function destroy():void;
		function parse(file:String):void;
	}
	
}