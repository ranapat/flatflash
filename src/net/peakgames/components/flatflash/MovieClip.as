package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class MovieClip extends DisplayObject {
		private var _spritesheetRegions:Vector.<Region>;
		
		private var _currentFrame:uint;
		private var _playing:Boolean;
		private var _totalFrames:uint;
		
		private var _latestParentTFP:Number;
		private var _hopsBetweenMoves:uint;
		private var _hopEveryNthTime:Number;
		
		private var _fps:uint;
		private var _timeDelta:Number;
		private var _previousTimeOffset:uint;
		
		public function MovieClip(spritesheet:BitmapData = null, spritesheetRegions:Vector.<Region> = null) {
			super(spritesheet);
			
			this._spritesheetRegions = spritesheetRegions;
			this._totalFrames = spritesheetRegions.length;
			
			this._latestParentTFP = 0;
			this._hopsBetweenMoves = 0;
			this._hopEveryNthTime = 0;
		}
		
		override public function get spritesheetRegion():Region {
			return this._spritesheetRegions? this._spritesheetRegions[this._currentFrame] : null;
		}
		
		public function get currentFrame():uint {
			return this._currentFrame;
		}
		
		public function set currentFrame(value:uint):void {
			if (
				this._spritesheetRegions
				&& this.totalFrames > value
				&& value >= 0
			) {
				this._currentFrame = value;
				
				this.width = this._spritesheetRegions[this._currentFrame].width;
				this.height = this._spritesheetRegions[this._currentFrame].height;
			}
		}
		
		public function get totalFrames():uint {
			return this._totalFrames;
		}
		
		public function get playing():Boolean {
			return this._playing;
		}
		
		public function set fps(value:uint):void {
			this._fps = value;
			this._timeDelta = 1000 / value;
		}
		
		public function get fps():uint {
			return this._fps;
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
		
		override public function hop(timer:int):void {
			super.hop(timer);
			
			var timeOffset:uint = timer / this._timeDelta;
			
			var delta:int = this._previousTimeOffset <= timeOffset? (timeOffset - this._previousTimeOffset) : (this.fps - this._previousTimeOffset + timeOffset);
			
			//trace(timer + " .. " + this._timeDelta + " .. " + this._previousTimeOffset + " .. " + timeOffset + " .. " + this.fps + " .. " + delta);
			
			this._previousTimeOffset = timeOffset;
			
			
			
			if (this.playing) {
				this.offsetFrames(delta);
			}
		}
		
		override public function get changed():Boolean {
			return this._playing? true : super.changed;
		}
		
		override public function get name():String {
			super.name = !super.name && this._spritesheetRegions && this.totalFrames > this.currentFrame?
				this._spritesheetRegions[this.currentFrame].name : super.name;
			
			return super.name;
		}
		
		private function gotoNextFrame():void {
			this.currentFrame = this._spritesheetRegions?
				((this.currentFrame + 1 >= this.totalFrames)? 0 : this.currentFrame + 1)
				: 0
			;
		}
		
		private function gotoPreviousFrame():void {
			this.currentFrame = this._spritesheetRegions?
				(this.currentFrame > 0? this.currentFrame - 1 : this.totalFrames)
				: 0
			;
		}
		
		private function offsetFrames(offset:int):void {
			var frame:uint = this.currentFrame + offset;
			this.currentFrame = frame < 0? this.totalFrames - frame : frame >= this.totalFrames? frame - this.totalFrames : frame;
		}
	}

}