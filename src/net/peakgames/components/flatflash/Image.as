package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.DisplayObject;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class Image extends DisplayObject {
		private var _spritesheetRegion:Region;
		
		public function Image(spritesheet:BitmapData = null, spritesheetRegion:Region = null) {
			super(spritesheet);
			
			this._spritesheetRegion = spritesheetRegion;
			
			this.name = spritesheetRegion.name;
			
			this.width = spritesheetRegion.width;
			this.height = spritesheetRegion.height;
		}
		
		override public function get spritesheetRegion():Region {
			return this._spritesheetRegion;
		}
	}

}