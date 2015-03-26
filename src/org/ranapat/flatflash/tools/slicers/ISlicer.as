package org.ranapat.flatflash.tools.slicers {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.ranapat.flatflash.DisplayObject;
	import org.ranapat.flatflash.tools.cache.CacheObject;
	import org.ranapat.flatflash.tools.RGBA;
	
	public interface ISlicer {
		function directCopyPixels(
			sourceBitmapData:BitmapData, overExposedBitmapData:BitmapData,
			destination:BitmapData, overExposedDestination:BitmapData,
			sourceRectangle:Rectangle,
			destinationPoint:Point, overExposedDestinationPoint:Point
		):void;
		
		function copyPixels(
			source:DisplayObject,
			destination:BitmapData,
			overExposedDestination:BitmapData, overExposedRGBA:RGBA,
			cacheObject:CacheObject
		):CacheObject;
	}
	
}