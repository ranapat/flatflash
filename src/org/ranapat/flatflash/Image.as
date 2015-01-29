package org.ranapat.flatflash {
	import flash.display.BitmapData;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public class Image extends DisplayObject {
		private var _region:Region;
		
		public function Image(...args) {
			super();
			
			this.initialize.apply(this, args);
		}
		
		override public function initialize(...args):void {
			if (args.length == 2 && args[0] is BitmapData && args[1] is Region) {
				this._region = args[1];
				
				this.name = this.region.name;
				this.width = this.region.width;
				this.height = this.region.height;
				
				super.initialize(args[0]);
			}
		}
		
		override public function get region():Region {
			return this._region;
		}
	}

}