package net.peakgames.components.flatflash.tools.parsers {
	
	public class ParserFactory {
		public static function get(type:String, file:String = null):IParser {
			if (type == ParserTypes.TYPE_STARLING) {
				return new StarlingFormat(file);
			} else {
				return null;
			}
		}
		
	}

}