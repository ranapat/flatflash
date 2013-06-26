package net.peakgames.components.flatflash.tools.joiners {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class JoinResult {
		public var bitmapData:BitmapData;
		public var regions:Vector.<Region>;
		
		public function JoinResult(bitmapData:BitmapData, regions:Vector.<Region>) {
			this.bitmapData = bitmapData;
			this.regions = regions;
		}
		
	}

}