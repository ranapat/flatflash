package net.peakgames.components.flatflash.tools.slicers {
	import net.peakgames.components.flatflash.tools.EngineTypes;
	
	public class SlicerFactory {
		public static function get(type:String):ISlicer {
			if (type == EngineTypes.TYPE_STARLING) {
				return new StarlingSlicer();
			} else {
				return null;
			}			
		}
	}

}