package org.ranapat.flatflash.tools.slicers {
	import org.ranapat.flatflash.tools.EngineTypes;
	
	final public class SlicerFactory {
		
		public static function get(type:String):ISlicer {
			if (type == EngineTypes.TYPE_STARLING) {
				return new StarlingSlicer();
			} else {
				return null;
			}			
		}
	}

}