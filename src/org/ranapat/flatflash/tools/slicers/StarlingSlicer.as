package org.ranapat.flatflash.tools.slicers {
	import flash.display.BitmapData;
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
			sourceSmoothing:Boolean
		):void {
			if (sourceAlpha == 0 || sourceScaleX == 0 || sourceScaleY == 0) return;
			
			var sourceBitmapData:BitmapData = source;
			var sourceRectangle:Rectangle = sourceRegion.sliceRectangle;
			
			if (
				sourceAlpha != 1
				|| sourceScaleX != 1 || sourceScaleY != 1
			) {
				var clipped:BitmapData = new BitmapData(sourceRectangle.width, sourceRectangle.height, true);
				clipped.copyPixels(source, sourceRectangle, new Point(0, 0), null, null, false);
				sourceRectangle = new Rectangle(0, 0, sourceRectangle.width, sourceRectangle.height);
				
				if (sourceAlpha != 1) {
					this._colorTransform.alphaMultiplier = sourceAlpha;
					clipped.colorTransform(sourceRectangle, this._colorTransform);
				}
				if (sourceScaleX != 1 || sourceScaleY != 1) {
					var result:BitmapData = new BitmapData(sourceRegion.width * sourceScaleX, sourceRegion.height * sourceScaleY, true, 0);
					var matrix:Matrix = new Matrix();
					matrix.scale(sourceScaleX, sourceScaleY);
					result.draw(clipped, matrix, null, null, null, sourceSmoothing);
					
					clipped = result;
					sourceRectangle = new Rectangle(0, 0, result.width, result.height);
				}
				
				sourceBitmapData = clipped;
			}
			
			destination.copyPixels(
				sourceBitmapData,
				sourceRectangle, destinationPoint,
				null, null, true
			);
		}
	}

}