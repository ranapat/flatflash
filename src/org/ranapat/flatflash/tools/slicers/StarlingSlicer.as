package org.ranapat.flatflash.tools.slicers {
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.ranapat.flatflash.Settings;
	import org.ranapat.flatflash.tools.cache.CacheObject;
	import org.ranapat.flatflash.tools.regions.Region;
	import org.ranapat.flatflash.tools.RGBA;
	
	public class StarlingSlicer implements ISlicer {
		private static const RADIANS_TO_DEGREES:Number = Math.PI / 180;
		
		private var _colorTransform:ColorTransform;
		
		public function StarlingSlicer() {
			this._colorTransform = new ColorTransform();
		}
		
		public function directCopyPixels(
			sourceBitmapData:BitmapData, overExposedBitmapData:BitmapData,
			destination:BitmapData, overExposedDestination:BitmapData,
			sourceRectangle:Rectangle, destinationPoint:Point
		):void {
			if (overExposedBitmapData && overExposedDestination) {
				overExposedDestination.copyPixels(
					overExposedBitmapData,
					new Rectangle(0, 0, overExposedBitmapData.width, overExposedBitmapData.height), destinationPoint,
					null, null, true
				);
			}
			
			destination.copyPixels(
				sourceBitmapData,
				sourceRectangle, destinationPoint,
				null, null, true
			);
		}
		
		public function copyPixels(
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
		):CacheObject {
			if (sourceAlpha == 0 || sourceScaleX == 0 || sourceScaleY == 0) return null;
			
			var result:CacheObject = new CacheObject(null, null, null, null);
			
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
				|| sourceRotation != 0
				|| sourceSkewX != 0 || sourceSkewY != 0
			) {
				clipped = new BitmapData(sourceRectangle.width, sourceRectangle.height, true, 0x0);
				clipped.copyPixels(source, sourceRectangle, new Point(0, 0), null, null, true);
				sourceRectangle = new Rectangle(0, 0, sourceRectangle.width, sourceRectangle.height);
				
				if (sourceAlpha != 1) {
					this._colorTransform.alphaMultiplier = sourceAlpha;
					clipped.colorTransform(sourceRectangle, this._colorTransform);
				}
				if (sourceScaleX != 1 || sourceScaleY != 1 || sourceRotation != 0 || sourceSkewX != 0 || sourceSkewY != 0) {
					var radiansToDegrees:Number = StarlingSlicer.RADIANS_TO_DEGREES;
					var width:Number;
					var height:Number;
					var rotationOffset:Number = 0;
					
					if (sourceRotation != 0) {
						var maxSize:Number = Math.sqrt(sourceRectangle.width * sourceRectangle.width + sourceRectangle.height * sourceRectangle.height);
						var anchorXComponsation:Number = sourceAnchorX < 0? -sourceAnchorX : sourceRectangle.width - sourceAnchorX < 0? sourceAnchorX - sourceRectangle.width : 0;
						var anchorYComponsation:Number = sourceAnchorY < 0? -sourceAnchorY : sourceRectangle.height - sourceAnchorY < 0? sourceAnchorY - sourceRectangle.height : 0;
						var biggerAnchorCompensation:Number = anchorXComponsation > anchorYComponsation? anchorXComponsation : anchorYComponsation;
						maxSize += biggerAnchorCompensation;
						
						width = 2 * maxSize;
						height = 2 * maxSize;
						rotationOffset = maxSize;
					} else {
						width = sourceRectangle.width;
						height = sourceRectangle.height;
					}
					
					width *= sourceScaleX + (sourceSkewX != 0 || sourceSkewY != 0? Settings.SKEW_RENDER_OFFSET : 0);
					height *= sourceScaleY + (sourceSkewX != 0 || sourceSkewY != 0? Settings.SKEW_RENDER_OFFSET : 0);
					
					scaled = new BitmapData(
						width,
						height,
						true, 0x0
					);

					var matrix:Matrix = new Matrix();
					
					if (sourceRotation != 0) {
						matrix.translate(-sourceAnchorX, -sourceAnchorY);
						matrix.rotate(sourceRotation * radiansToDegrees);
						matrix.translate(rotationOffset, rotationOffset);
						
						destinationPointToApply = new Point(destinationPointToApply.x + sourceAnchorX - rotationOffset, destinationPointToApply.y + sourceAnchorY - rotationOffset);
					}
					if (sourceScaleX != 1 || sourceScaleY != 1) {
						matrix.scale(sourceScaleX, sourceScaleY);
						
						destinationPointToApply = new Point(
							destinationPointToApply.x + (sourceRotation != 0? 0 : ((1 - sourceScaleX) * sourceAnchorX)) + (1 - sourceScaleX) * rotationOffset,
							destinationPointToApply.y + (sourceRotation != 0? 0 : ((1 - sourceScaleY) * sourceAnchorY)) + (1 - sourceScaleY) * rotationOffset
						);
					}
					if (sourceSkewX != 0 || sourceSkewY != 0) {
						var offsetWidth:Number = Settings.SKEW_RENDER_OFFSET / 2;
						var offsetHeight:Number = Settings.SKEW_RENDER_OFFSET / 2;
						
						matrix.concat(new Matrix(1, sourceSkewY, sourceSkewX, 1, offsetWidth, offsetHeight));
						destinationPointToApply = new Point(
							destinationPointToApply.x - offsetWidth,
							destinationPointToApply.y - offsetHeight
						);
					}
					
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
					true, 0x0
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
			
			if (overExposedDestination) {
				var overExposedBitmapData:BitmapData = new BitmapData(sourceRectangle.width, sourceRectangle.height, true, 0x0);
				overExposedBitmapData.copyPixels(sourceBitmapData, sourceRectangle, new Point(0, 0), null, null, true);
				overExposedBitmapData.colorTransform(
					sourceRectangle,
					new ColorTransform(
						0, 0, 0, 1,
						overExposedRGBA.r, overExposedRGBA.g, overExposedRGBA.b, overExposedRGBA.a
					)
				);
				overExposedDestination.copyPixels(
					overExposedBitmapData,
					new Rectangle(0, 0, overExposedBitmapData.width, overExposedBitmapData.height), destinationPointToApply,
					null, null, true
				);

				result.overExposedBitmapData = overExposedBitmapData.clone();
				
				overExposedBitmapData.dispose();
				overExposedBitmapData = null;
			}
			
			destination.copyPixels(
				sourceBitmapData,
				sourceRectangle, destinationPointToApply,
				null, null, true
			);
			
			result.sourceBitmapData = sourceBitmapData.clone();
			result.sourceRectangle = sourceRectangle.clone();
			result.destinationPoint = destinationPointToApply.clone();
			
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
			
			return result;
		}
	}

}