package org.ranapat.flatflash.tools.cache {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.ranapat.flatflash.Settings;
	
	public class CacheObject {
		public var sourceBitmapData:BitmapData;
		public var overExposedBitmapData:BitmapData;
		public var sourceRectangle:Rectangle;
		public var destinationPoint:Point;
		
		public function CacheObject(sourceBitmapData:BitmapData, overExposedBitmapData:BitmapData, sourceRectangle:Rectangle, destinationPoint:Point) {
			this.sourceBitmapData = sourceBitmapData;
			this.overExposedBitmapData = overExposedBitmapData;
			this.sourceRectangle = sourceRectangle;
			this.destinationPoint = destinationPoint;
		}
		
		public function destroy():void {
			if (this.sourceBitmapData) {
				this.sourceBitmapData.dispose();
				this.sourceBitmapData = null;
			}
			if (this.overExposedBitmapData) {
				this.overExposedBitmapData.dispose();
				this.overExposedBitmapData = null;
			}
			this.sourceRectangle = null;
			this.destinationPoint = null;
		}
	}

}