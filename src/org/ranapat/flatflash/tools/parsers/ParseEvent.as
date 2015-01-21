package org.ranapat.flatflash.tools.parsers {
	import flash.events.Event;
	
	public class ParseEvent extends Event {
		public static const PARSE_COMPLETE:String = "ParseComplete";
		public static const PARSE_FAIL:String = "ParseFail";
		
		public var result:ParseResult;
		
		public function ParseEvent(type:String, result:ParseResult = null) {
			super(type);
			
			this.result = result;
		}
		
	}

}