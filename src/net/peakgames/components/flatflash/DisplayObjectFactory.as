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
		
		public static function getMovieClipFromAll(spritesheet:BitmapData, spritesheetId:String, regions:Vector.<Region>):MovieClip {
			return new MovieClip(spritesheet, spritesheetId, regions);
		}
		
		public static function getMovieClipByMinMaxIndexes(spritesheet:BitmapData, spritesheetId:String, regions:Vector.<Region>, minIndex:uint, maxIndex:uint):MovieClip {
			return new MovieClip(spritesheet, spritesheetId, regions.slice(minIndex, maxIndex));
		}
		
		public static function getMovieClipByMinMaxNames(spritesheet:BitmapData, spritesheetId:String, regions:Vector.<Region>, minName:String, maxName:String):MovieClip {
			var regionsToPick:Vector.<Region> = new Vector.<Region>();
			var length:uint = regions.length;
			for (var i:uint = 0; i < length; ++i) {
				var region:Region = regions[i];
				if (region.name >= minName && region.name <= maxName) {
					regionsToPick.push(region);
				}
			}
			
			return new MovieClip(spritesheet, spritesheetId, regionsToPick);
		}
	}

}