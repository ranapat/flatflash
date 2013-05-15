package net.peakgames.components.flatflash.tools.parsers {
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class BitmapDataRegion extends Rectangle implements IRegion {
		public var name:String;
		public var bitmapData:BitmapData;
		
		public function BitmapDataRegion(x:Number, y:Number, width:Number, height:Number, name:String) {
			super(x, y, width, height);
			
			this.name = name;
			this.bitmapData = new BitmapData(width, height, true, 0x000000);
		}
		
		public function get bitmapDataRectangle():Rectangle {
			return new Rectangle(0, 0, this.width, this.height);
		}
		
	}

}