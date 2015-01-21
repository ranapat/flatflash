package org.ranapat.flatflash.tools.slicers {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public class StarlingSlicer implements ISlicer {
		
		public function copyPixels(
			source:BitmapData, destination:BitmapData,
			sourceRegion:Region, destinationPoint:Point,
			alphaBitmapData:BitmapData = null, alphaPoint:Point = null,
			mergeAlpha:Boolean = true
		):void {
			destination.copyPixels(
				source,
				sourceRegion.sliceRectangle, destinationPoint,
				alphaBitmapData, alphaPoint, mergeAlpha
			);
		}
	}

}