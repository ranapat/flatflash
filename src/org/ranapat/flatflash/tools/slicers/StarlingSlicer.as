package org.ranapat.flatflash.tools.slicers {
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
			
			var clipped:BitmapData;
			var scaled:BitmapData;
			
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
					scaled = new BitmapData(sourceRegion.width * sourceScaleX, sourceRegion.height * sourceScaleY, true, 0);
					var matrix:Matrix = new Matrix();
					matrix.scale(sourceScaleX, sourceScaleY);
					scaled.draw(clipped, matrix, null, null, null, sourceSmoothing);
					
					clipped = scaled;
					sourceRectangle = new Rectangle(0, 0, scaled.width, scaled.height);
				}
				
				sourceBitmapData = clipped;
			}
			
			destination.copyPixels(
				sourceBitmapData,
				sourceRectangle, destinationPoint,
				null, null, true
			);
			
			if (sourceFilters) {
				var length:uint = sourceFilters.length;
				var rectangle:Rectangle = new Rectangle(destinationPoint.x, destinationPoint.y, sourceRectangle.width, sourceRectangle.height);
				for (var i:uint = 0; i < length; ++i) {
					destination.applyFilter(destination, rectangle, destinationPoint, sourceFilters[i]);
				}
			}
			
			if (clipped) {
				clipped.dispose();
				clipped = null;
			}
			if (scaled) {
				scaled.dispose();
				scaled = null;
			}
		}
	}

}