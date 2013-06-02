package net.peakgames.components.flatflash.tools {
	public class EngineTypes {
		public static const TYPE_UNDEFINED:String = "undefined";
		public static const TYPE_STARLING:String = "starling";
		
		private static const AVAILABLE_TYPES:Vector.<String> = Vector.<String>([
			EngineTypes.TYPE_STARLING
		]);
		
		public static function validate(type:String):String {
			return EngineTypes.AVAILABLE_TYPES.indexOf(type) != -1? type : EngineTypes.TYPE_UNDEFINED;
		}
	}

}