package net.peakgames.components.flatflash.tools.slicer {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.peakgames.components.flatflash.tools.parsers.BitmapDataRegion;
	
	public class ImageSlicer {
		public static function slice(source:BitmapData, regions:Vector.<BitmapDataRegion>):void {
			var length:uint = regions.length;
			var point:Point = new Point();
			var region:BitmapDataRegion;
			for (var i:uint = 0; i < length; ++i) {
				region = regions[i];
				region.bitmapData.copyPixels(source, region, point);
			}
		}
		
	}

}