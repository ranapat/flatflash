package org.ranapat.flatflash.tools.parsers {
	import org.ranapat.flatflash.tools.EngineTypes;
	
	final public class ParserFactory {
		
		public static function get(type:String, file:String = null):IParser {
			if (type == EngineTypes.TYPE_STARLING) {
				return new StarlingFormat(file);
			} else {
				return null;
			}
		}
		
	}

}