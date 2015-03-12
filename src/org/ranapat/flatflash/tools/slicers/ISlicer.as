package org.ranapat.flatflash.tools.slicers {
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.ranapat.flatflash.tools.cache.CacheObject;
	import org.ranapat.flatflash.tools.regions.Region;
	import org.ranapat.flatflash.tools.RGBA;
	
	public interface ISlicer {
		function directCopyPixels(
			sourceBitmapData:BitmapData, overExposedBitmapData:BitmapData,
			destination:BitmapData, overExposedDestination:BitmapData,
			sourceRectangle:Rectangle, destinationPoint:Point
		):void;
		
		function copyPixels(
			source:BitmapData,
			destination:BitmapData,
			overExposedDestination:BitmapData, overExposedRGBA:RGBA,
			sourceRegion:Region, destinationPoint:Point,
			sourceAnchorX:Number, sourceAnchorY:Number,
			sourceAlpha:Number,
			sourceScaleX:Number, sourceScaleY:Number,
			sourceSkewX:Number, sourceSkewY:Number,
			sourceRotation:Number,
			sourceSmoothing:Boolean,
			sourceFilters:Vector.<BitmapFilter>
		):CacheObject;
	}
	
}