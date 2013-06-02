package net.peakgames.components.flatflash.tools.parsers {
	public class ParseResult {
		public var path:String;
		public var regions:Vector.<Region>;
		
		public function ParseResult(path:String = null, regions:Vector.<Region> = null) {
			this.path = path;
			this.regions = regions;
		}
		
	}

}