package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.Image;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class DisplayObjectFactory {
		public static function getImageByRegion(spritesheet:BitmapData, spritesheetId:String, region:Region):Image {
			return new Image(spritesheet, spritesheetId, region);
		}
		
		public static function getImageByName(spritesheet:BitmapData, spritesheetId:String, regions:Vector.<Region>, regionName:String):Image {
			var length:uint = regions.length;
			for (var i:uint = 0; i < length; ++i) {
				var tmpRegion:Region = regions[i];
				if (tmpRegion.name == regionName) {
					return DisplayObjectFactory.getImageByRegion(spritesheet, spritesheetId, tmpRegion);
				}
			}
			return null;
		}
	}

}