package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class MovieClip extends DisplayObject {
		private var _spritesheetRegions:Vector.<Region>;
		
		private var _currentFrame:uint;
		private var _playing:Boolean;
		
		public function MovieClip(spritesheet:BitmapData = null, spritesheetRegions:Vector.<Region> = null) {
			super(spritesheet);
			
			this._spritesheetRegions = spritesheetRegions;
		}
		
		public override function get spritesheetRegion():Region {
			return this._spritesheetRegions? this._spritesheetRegions[this._currentFrame] : null;
		}
		
		public function get currentFrame():uint {
			return this._currentFrame;
		}
		
		public function set currentFrame(value:uint):void {
			if (
				this._spritesheetRegions
				&& this._spritesheetRegions.length > value
				&& value >= 0
			) {
				this._currentFrame = value;
				
				this.width = this._spritesheetRegions[this._currentFrame].width;
				this.height = this._spritesheetRegions[this._currentFrame].height;
			}
		}
		
		public function get playing():Boolean {
			return this._playing;
		}
		
		public function play():void {
			this._playing = true;
		}
		
		public function stop():void {
			this._playing = false;
		}
		
		public function gotoAndStop(frame:uint):void {
			this.currentFrame = frame;
			this.stop();
		}
		
		public function gotoAndPlay(frame:uint):void {
			this.currentFrame = frame;
			this.play();
		}
		
		public function nextFrame():void {
			this.gotoNextFrame();
			this.stop();
		}
		
		public function prevFrame():void {
			this.previousFrame();
		}
		
		public function previousFrame():void {
			this.gotoPreviousFrame();
			this.stop();
		}
		
		public override function hop():void {
			super.hop();
			
			if (this.playing) {
				this.gotoNextFrame();
			}
		}
		
		public override function get changed():Boolean {
			return this._playing? true : super.changed;
		}
		
		public override function get name():String {
			super.name = !super.name && this._spritesheetRegions && this._spritesheetRegions.length > this.currentFrame?
				this._spritesheetRegions[this.currentFrame].name : super.name;
			
			return super.name;
		}
		
		private function gotoNextFrame():void {
			this.currentFrame = this._spritesheetRegions?
				((this.currentFrame + 1 >= this._spritesheetRegions.length)? 0 : this.currentFrame + 1)
				: 0
			;
		}
		
		private function gotoPreviousFrame():void {
			this.currentFrame = this._spritesheetRegions?
				(this.currentFrame > 0? this.currentFrame - 1 : this._spritesheetRegions.length)
				: 0
			;
		}
	}

}