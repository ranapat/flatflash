package net.peakgames.components.flatflash {
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class MovieClip extends DisplayObject {
		private var _spritesheetRegions:Vector.<Region>;
		
		private var _currentFrame:uint;
		private var _playing:Boolean;
		
		public function MovieClip(spritesheet:BitmapData = null, spritesheetId:String = null, spritesheetRegions:Vector.<Region> = null) {
			super(spritesheet, spritesheetId);
			
			this._spritesheetRegions = spritesheetRegions;
		}
		
		public override function get spritesheetRegion():Region {
			return this._spritesheetRegions? this._spritesheetRegions[this._currentFrame];
		}
		
		public function get currentFrame():uint {
			return this._currentFrame;
		}
		
		public function set currentFrame(value:uint):void {
			this._currentFrame = (
				this._spritesheetRegions
				&& this._spritesheetRegions.length > value
				&& value >= 0)? value : this._currentFrame;
		}
		
		public function get playing():Boolean {
			return this._playing;
		}
		
		public function play():void {
			
		}
		
		public function stop():void {
			
		}
		
		public function gotoAndStop(frame:uint):void {
			
		}
		
		public function gotoAndPlay(frame:uint):void {
			
		}
		
		public function nextFrame():void {
			
		}
		
		public function prevFrame():void {
			
		}
		
		public override function hop():void {
			super.hop();
			
			this._currentFrame
		}
		
		private function gotoNextFrame():void {
			
		}
	}

}