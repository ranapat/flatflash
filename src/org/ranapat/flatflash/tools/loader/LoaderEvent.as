package org.ranapat.flatflash.tools.loader {
	import flash.events.Event;
	import org.ranapat.flatflash.tools.parsers.ParseResult;
	
	public class LoaderEvent extends Event {
		public static const LOAD_COMPLETE:String = "LoadComplete";
		public static const LOAD_FAIL:String = "LoadFail";
		
		public var result:ParseResult;
		
		public function LoaderEvent(type:String, result:ParseResult = null) {
			super(type);
			
			this.result = result;
		}
		
	}

}