package org.ranapat.flatflash.tools.slicers {
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.ranapat.flatflash.Settings;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public class StarlingSlicer implements ISlicer {
		private var _colorTransform:ColorTransform;
		
		public function StarlingSlicer() {
			this._colorTransform = new ColorTransform();
		}
		
		public function copyPixels(
			source:BitmapData, destination:BitmapData,
			sourceRegion:Region, destinationPoint:Point,
			sourceAlpha:Number,
			sourceScaleX:Number, sourceScaleY:Number,
			sourceSmoothing:Boolean,
			sourceFilters:Vector.<BitmapFilter>
		):void {
			if (sourceAlpha == 0 || sourceScaleX == 0 || sourceScaleY == 0) return;
			
			var sourceBitmapData:BitmapData = source;
			var sourceRectangle:Rectangle = sourceRegion.sliceRectangle;
			var destinationPointToApply:Point = destinationPoint;
			
			var i:uint;
			
			var clipped:BitmapData;
			var scaled:BitmapData;
			var filtered:BitmapData;
			
			if (
				sourceAlpha != 1
				|| sourceScaleX != 1 || sourceScaleY != 1
			) {
				clipped = new BitmapData(sourceRectangle.width, sourceRectangle.height, true, 0);
				clipped.copyPixels(source, sourceRectangle, new Point(0, 0), null, null, true);
				sourceRectangle = new Rectangle(0, 0, sourceRectangle.width, sourceRectangle.height);
				
				if (sourceAlpha != 1) {
					this._colorTransform.alphaMultiplier = sourceAlpha;
					clipped.colorTransform(sourceRectangle, this._colorTransform);
				}
				if (sourceScaleX != 1 || sourceScaleY != 1) {
					scaled = new BitmapData(sourceRectangle.width * sourceScaleX, sourceRectangle.height * sourceScaleY, true, 0);
					var matrix:Matrix = new Matrix();
					matrix.scale(sourceScaleX, sourceScaleY);
					scaled.draw(clipped, matrix, null, null, null, sourceSmoothing);
					
					clipped = scaled;
					sourceRectangle = new Rectangle(0, 0, scaled.width, scaled.height);
				}
				
				sourceBitmapData = clipped;
			}

			if (sourceFilters && sourceFilters.length > 0)  {
				filtered = new BitmapData(
					sourceRectangle.width + 2 * Settings.FILTER_MARGIN_DELTA_CUT,
					sourceRectangle.height + 2 * Settings.FILTER_MARGIN_DELTA_CUT,
					true, 0
				);
				filtered.copyPixels(sourceBitmapData, sourceRectangle, new Point(Settings.FILTER_MARGIN_DELTA_CUT, Settings.FILTER_MARGIN_DELTA_CUT), null, null, false);
				
				var filtersRectangle:Rectangle = new Rectangle(0, 0, filtered.width, filtered.height);
				var filtersPoint:Point = new Point(0, 0);
				var sourceFiltersLength:uint = sourceFilters.length;
				for (i = 0; i < sourceFiltersLength; ++i) {
					filtered.applyFilter(filtered, filtersRectangle, filtersPoint, sourceFilters[i]);
				}
				
				sourceBitmapData = filtered;
				sourceRectangle = new Rectangle(0, 0, filtered.width, filtered.height);
				destinationPointToApply = new Point(destinationPointToApply.x - Settings.FILTER_MARGIN_DELTA_CUT, destinationPointToApply.y - Settings.FILTER_MARGIN_DELTA_CUT);
			}
			
			destination.copyPixels(
				sourceBitmapData,
				sourceRectangle, destinationPointToApply,
				null, null, true
			);
			
			if (clipped) {
				clipped.dispose();
				clipped = null;
			}
			if (scaled) {
				scaled.dispose();
				scaled = null;
			}
			if (filtered) {
				filtered.dispose();
				filtered = null;
			}
		}
	}

}