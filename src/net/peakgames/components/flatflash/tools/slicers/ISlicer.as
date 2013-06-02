package net.peakgames.components.flatflash.tools.slicers {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public interface ISlicer {
		function copyPixels(
			source:BitmapData, destination:BitmapData,
			sourceRegion:Region, destinationPoint:Point,
			alphaBitmapData:BitmapData = null, alphaPoint:Point = null,
			mergeAlpha:Boolean = true
		):void;
	}
	
}