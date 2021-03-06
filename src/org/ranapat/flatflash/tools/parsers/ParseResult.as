package org.ranapat.flatflash.tools.parsers {
	import flash.display.BitmapData;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public class ParseResult {
		public var type:String;
		public var path:String;
		public var bitmapData:BitmapData;
		public var regions:Vector.<Region>;
		
		public function ParseResult(type:String, path:String = null, bitmapData:BitmapData = null, regions:Vector.<Region> = null) {
			this.type = type;
			this.path = path;
			this.bitmapData = bitmapData;
			this.regions = regions;
		}
		
	}

}