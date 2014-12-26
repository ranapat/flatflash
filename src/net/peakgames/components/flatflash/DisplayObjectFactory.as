package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.Image;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class DisplayObjectFactory {
		
		public static function getImageByRegion(spritesheet:BitmapData, region:Region):Image {
			return new Image(spritesheet, region);
		}
		
		public static function getImageByName(spritesheet:BitmapData, regions:Vector.<Region>, regionName:String):Image {
			var length:uint = regions.length;
			for (var i:uint = 0; i < length; ++i) {
				var tmpRegion:Region = regions[i];
				if (tmpRegion.name == regionName) {
					return DisplayObjectFactory.getImageByRegion(spritesheet, tmpRegion);
				}
			}
			return null;
		}
		
		public static function getMovieClipFromAll(spritesheet:BitmapData, regions:Vector.<Region>):MovieClip {
			return new MovieClip(spritesheet, regions);
		}
		
		public static function getMovieClipByMinMaxIndexes(spritesheet:BitmapData, regions:Vector.<Region>, minIndex:uint, maxIndex:uint):MovieClip {
			return new MovieClip(spritesheet, regions.slice(minIndex, maxIndex));
		}
		
		public static function getMovieClipByName(spritesheet:BitmapData, regions:Vector.<Region>, name:String):MovieClip {
			var regionsToPick:Vector.<Region> = new Vector.<Region>();
			var length:uint = regions.length;
			for (var i:uint = 0; i < length; ++i) {
				var region:Region = regions[i];
				if (region.name.indexOf(name) != -1) {
					regionsToPick.push(region);
				}
			}
			
			return new MovieClip(spritesheet, regionsToPick);
		}
		
		public static function getMovieClipByMinMaxNames(spritesheet:BitmapData, regions:Vector.<Region>, minName:String, maxName:String):MovieClip {
			var regionsToPick:Vector.<Region> = new Vector.<Region>();
			var length:uint = regions.length;
			for (var i:uint = 0; i < length; ++i) {
				var region:Region = regions[i];
				if (region.name >= minName && region.name <= maxName) {
					regionsToPick.push(region);
				}
			}
			
			return new MovieClip(spritesheet, regionsToPick);
		}
	}

}