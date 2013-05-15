package net.peakgames.components.flatflash.tools.parsers {
	public class ParseResult {
		public var path:String;
		public var regions:Vector.<IRegion>;
		
		public function ParseResult(path:String = null, regions:Vector.<IRegion> = null) {
			this.path = path;
			this.regions = regions;
		}
		
	}

}