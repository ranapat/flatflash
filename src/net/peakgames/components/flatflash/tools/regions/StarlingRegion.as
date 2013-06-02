package net.peakgames.components.flatflash.tools.regions {
	import flash.geom.Rectangle;
	import net.peakgames.components.flatflash.tools.EngineTypes;
	
	public class StarlingRegion extends Region {
		public var frameX:Number = 0;
		public var frameY:Number = 0;
		public var frameWidth:Number = 0;
		public var frameHeight:Number = 0;
		
		public function StarlingRegion(
			name:String,
			x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0,
			frameX:Number = 0, frameY:Number = 0, frameWidth:Number = 0, frameHeight:Number = 0
		) {
			super(name, x, y, width, height);
			
			this._type = EngineTypes.TYPE_STARLING;
			
			this.frameX = frameX;
			this.frameY = frameY;
			this.frameWidth = frameWidth;
			this.frameHeight = frameHeight;
		}
	}

}