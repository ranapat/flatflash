package net.peakgames.components.flatflash.tools.parsers {
	
	public class ParserTypes {
		public static const TYPE_UNDEFINED:String = "undefined";
		public static const TYPE_STARLING:String = "starling";
		
		private static const AVAILABLE_TYPES:Vector.<String> = Vector.<String>([
			ParserTypes.TYPE_STARLING
		]);
		
		public static function validate(type:String):String {
			return ParserTypes.AVAILABLE_TYPES.indexOf(type) != -1? type : ParserTypes.TYPE_UNDEFINED;
		}
	}

}