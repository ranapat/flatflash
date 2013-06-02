package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.DisplayObject;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class Image extends DisplayObject {
		public function Image(spritesheet:BitmapData = null, spritesheetId:String = null, spritesheetRegion:Region = null) {
			super(spritesheet, spritesheetId, spritesheetRegion);
			
			this.width = spritesheetRegion.width;
			this.height = spritesheetRegion.height;
		}
	}

}