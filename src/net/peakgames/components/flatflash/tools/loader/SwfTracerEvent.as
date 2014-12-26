package net.peakgames.components.flatflash.tools.loader {
	import flash.events.Event;
	import net.peakgames.components.flatflash.tools.joiners.JoinResult;
	
	public class SwfTracerEvent extends Event {
		public var key:uint;
		public var resultType:String;
		public var result:JoinResult;
		public var fps:uint;
		public var error:Error;
		
		public function SwfTracerEvent(type:String, key:uint, resultType:String, result:JoinResult, fps:uint, error:Error) {
			super(type);
			
			this.key = key;
			this.resultType = resultType;
			this.result = result;
			this.fps = fps;
			this.error = error;
		}
		
	}

}