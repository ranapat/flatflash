package org.ranapat.flatflash.tools.loader {
	import flash.display.BitmapData;
	import flash.events.Event;
	import org.ranapat.flatflash.tools.joiners.JoinResult;
	
	public class SwfTracerEvent extends Event {
		public var key:uint;
		public var resultType:String;
		public var result:JoinResult;
		public var raw:Vector.<BitmapData>;
		public var error:Error;
		
		public function SwfTracerEvent(type:String, key:uint, resultType:String, result:JoinResult, raw:Vector.<BitmapData>, error:Error) {
			super(type);
			
			this.key = key;
			this.resultType = resultType;
			this.result = result;
			this.raw = raw;
			
			this.error = error;
		}
		
	}

}