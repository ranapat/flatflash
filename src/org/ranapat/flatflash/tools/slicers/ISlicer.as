package org.ranapat.flatflash.tools.slicers {
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public interface ISlicer {
		function copyPixels(
			source:BitmapData, destination:BitmapData,
			sourceRegion:Region, destinationPoint:Point,
			sourceAlpha:Number,
			sourceScaleX:Number, sourceScaleY:Number,
			sourceRotation:Number,
			sourceSmoothing:Boolean,
			sourceFilters:Vector.<BitmapFilter>
		):void;
	}
	
}