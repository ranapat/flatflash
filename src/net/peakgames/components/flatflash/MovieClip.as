package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class MovieClip extends DisplayObject {
		private var _spritesheetRegions:Vector.<Region>;
		
		private var _fps:uint;
		private var _currentFrame:uint;
		private var _playing:Boolean;
		
		private var _latestParentTFP:Number;
		private var _hopsBetweenMoves:uint;
		private var _hopEveryNthTime:Number;
		
		public function MovieClip(spritesheet:BitmapData = null, spritesheetRegions:Vector.<Region> = null) {
			super(spritesheet);
			
			this._spritesheetRegions = spritesheetRegions;
			
			this._latestParentTFP = 0;
			this._hopsBetweenMoves = 0;
			this._hopEveryNthTime = 0;
		}
		
		override public function get spritesheetRegion():Region {
			return this._spritesheetRegions? this._spritesheetRegions[this._currentFrame] : null;
		}
		
		public function set fps(value:uint):void {
			this._fps = value;
		}
		
		public function get fps():uint {
			return this._fps;
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
		
		override public function hop():void {
			super.hop();
			
			if (this.playing/* && this.shallHopMove*/) {
				this.gotoNextFrame();
			}
		}
		
		override public function get changed():Boolean {
			return this._playing? true : super.changed;
		}
		
		override public function get name():String {
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
		
		private function get shallHopMove():Boolean {
			if (this.parent) {
				if (this.parent.tfp != this._latestParentTFP) {
					this._latestParentTFP = this.parent.tfp;
					this._hopsBetweenMoves = 1;
					
					this._hopEveryNthTime = this.parent.fps / this.currentFPS;
				} else {
					++this._hopsBetweenMoves;
				}
			}
			
			if (this._hopsBetweenMoves / this._hopEveryNthTime > .9) {
				this._hopsBetweenMoves = 0;
				
				//trace(".... allow " + this._hopsBetweenMoves + " .. " + this._hopEveryNthTime + " .. " + this.parent.fps + " .. " + (this._hopsBetweenMoves / this._hopEveryNthTime))
				
				return true;
			} else {
				//trace(".... skip " + this._hopsBetweenMoves + " .. " + this._hopEveryNthTime + " .. this.currentFPS: " + this.currentFPS + " .. this.parent.fps: " + this.parent.fps + " .. " + (this._hopsBetweenMoves / this._hopEveryNthTime))
				
				return false;
			}
		}
		
		private function get currentFPS():uint {
			return this.fps == 0? this.parent.fps : this.fps;
		}
	}

}