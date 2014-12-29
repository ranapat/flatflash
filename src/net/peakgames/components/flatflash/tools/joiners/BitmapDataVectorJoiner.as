package net.peakgames.components.flatflash.tools.joiners {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.peakgames.components.flatflash.tools.EngineTypes;
	import net.peakgames.components.flatflash.tools.math.RectangleSize;
	import net.peakgames.components.flatflash.tools.math.RectangleSizeCalculator;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class BitmapDataVectorJoiner implements IJoiner {
		private static const MAX_WIDTH:Number = 2000;
		private static const MAX_HEIGHT:Number = 2000;
		
		public function toAtlas(...args):JoinResult {
			var result:JoinResult;
			
			if (args.length == 1 && args[0] is Vector.<BitmapData>) {
				var bitmaps:Vector.<BitmapData> = args[0] as Vector.<BitmapData>;
				if (bitmaps && bitmaps.length) {
					var rectangleSize:RectangleSize = RectangleSizeCalculator.getSize(bitmaps.length);
					
					var width:Number = rectangleSize.columns * bitmaps[0].width;
					var height:Number = rectangleSize.rows * bitmaps[0].height;
					
					if (width < BitmapDataVectorJoiner.MAX_WIDTH && height < BitmapDataVectorJoiner.MAX_HEIGHT) {
						var bitmapData:BitmapData = new BitmapData(rectangleSize.columns * bitmaps[0].width, rectangleSize.rows * bitmaps[0].height, true, 0);
						var regions:Vector.<Region> = new Vector.<Region>();
						
						var tmp:BitmapData;
						var row:uint = 0;
						var column:uint = 0;
						var i:uint;
						var length:uint = bitmaps.length;
						for (i = 0; i < length; ++i) {
							tmp = bitmaps[i];
							bitmapData.copyPixels(
								tmp,
								new Rectangle(0, 0, tmp.width, tmp.height),
								new Point(column * tmp.width, row * tmp.height),
								null, null,
								true
							);
							regions[regions.length] = new Region(
								"region-" + i,
								column * tmp.width, row * tmp.height,
								tmp.width, tmp.height,
								EngineTypes.TYPE_STARLING
							);
							
							if (column < rectangleSize.columns - 1) {
								++column;
							} else {
								column = 0;
								++row;
							}
						}
						
						result = new JoinResult(bitmapData, regions);
					}
				}
			}
			
			return result;
		}
		
	}

}