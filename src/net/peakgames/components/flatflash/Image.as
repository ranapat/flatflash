package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.DisplayObject;
	
	public class Image extends DisplayObject {
		private var _bitmapData:BitmapData;
		
		public function Image(bitmapData:BitmapData) {
			super();
			
			this._bitmapData = bitmapData;
		}
		
		public function get bitmapData():BitmapData {
			return this._bitmapData;
		}
		
	}

}