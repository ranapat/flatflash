package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class Image extends DisplayObject {
		private var _region:Region;
		
		public function Image(...args) {
			super();
			
			this.initialize.apply(this, args);
		}
		
		override public function initialize(...args):void {
			if (args.length == 2 && args[0] is BitmapData && args[1] is Region) {
				super.initialize(args[0]);
				
				this._region = args[1];
				
				this.name = this.region.name;
				this.width = this.region.width;
				this.height = this.region.height;
			}
		}
		
		override public function get region():Region {
			return this._region;
		}
	}

}