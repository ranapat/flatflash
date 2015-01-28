package org.ranapat.flatflash {
	import flash.display.BitmapData;
	import org.ranapat.flatflash.tools.EngineTypes;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public class MovieClip extends DisplayObject {
		private var _regions:Vector.<Region>;
		private var _raw:Vector.<BitmapData>;
		
		private var _currentFrame:uint;
		private var _playing:Boolean;
		private var _totalFrames:uint;
		
		private var _latestParentTFP:Number;
		private var _hopsBetweenMoves:uint;
		private var _hopEveryNthTime:Number;
		
		private var _fps:int;
		private var _timeDelta:Number;
		private var _previousTimeOffset:uint;
		
		public function MovieClip(...args) {
			super();
			
			this.initialize.apply(this, args);
			
			this._latestParentTFP = 0;
			this._hopsBetweenMoves = 0;
			this._hopEveryNthTime = 0;
		}
		
		override public function initialize(...args):void {
			if (args.length == 2 && args[0] is BitmapData && args[1] is Vector.<Region>) {
				super.initialize(args[0]);
				
				this.fps = -1;
				this._regions = args[1];
				this._totalFrames = this._regions.length;
			} else if (args.length == 1 && args[0] is Vector.<BitmapData>) {
				this.handleInitialized();
				
				this.fps = -1;
				this._raw = args[0];
				this._totalFrames = this._raw.length;
			}
		}
		
		public function get currentFrame():uint {
			return this._currentFrame;
		}
		
		public function set currentFrame(value:uint):void {
			if (
				this.totalFrames > value
				&& value >= 0
			) {
				if (this._regions) {
					this._currentFrame = value;
					
					this.width = this._regions[this._currentFrame].width;
					this.height = this._regions[this._currentFrame].height;
				} else if (this._raw) {
					this._currentFrame = value;
					
					this.width = this._raw[this._currentFrame].width;
					this.height = this._raw[this._currentFrame].height;
				}
			}
		}
		
		public function get totalFrames():uint {
			return this._totalFrames;
		}
		
		public function get playing():Boolean {
			return this._playing;
		}
		
		public function set fps(value:int):void {
			this._fps = value;
			this._timeDelta = this.fps? 1000 / this.fps : 0;
		}
		
		public function get fps():int {
			return this._fps == -1 && this.parent? this.parent.fps : this._fps == -1 && !this.parent? 0 : this._fps;
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
		
		override public function get spritesheet():BitmapData {
			return this._regions? super.spritesheet : this._raw? this._raw[this._currentFrame] : null;
		}
		
		override public function get region():Region {
			return this._regions? this._regions[this._currentFrame] : this._raw? new Region(this.name + "-frame-" + this.currentFrame, 0, 0, this.width, this.height, EngineTypes.TYPE_STARLING) : null;
		}
		
		override public function hop(timer:int):void {
			super.hop(timer);
			
			var timeOffset:uint = timer / this.timeDelta;
			
			var delta:int = this._previousTimeOffset <= timeOffset? (timeOffset - this._previousTimeOffset) : (this.fps - this._previousTimeOffset + timeOffset);
			
			//trace(timer + " .. " + this.timeDelta + " .. " + this._previousTimeOffset + " .. " + timeOffset + " .. " + this.fps + " .. " + delta);
			
			this._previousTimeOffset = timeOffset;
			
			if (this.playing) {
				this.offsetFrames(delta);
			}
		}
		
		override public function get changed():Boolean {
			return this._playing? true : super.changed;
		}
		
		override public function get name():String {
			super.name = !super.name && this._regions && this.totalFrames > this.currentFrame?
				this._regions[this.currentFrame].name : !super.name && this._raw?
					super.name + "-frame-" + this.currentFrame : super.name
			;
			
			return super.name;
		}
		
		private function gotoNextFrame():void {
			this.currentFrame = this._regions || this._raw?
				((this.currentFrame + 1 >= this.totalFrames)? 0 : this.currentFrame + 1)
				: 0
			;
		}
		
		private function gotoPreviousFrame():void {
			this.currentFrame = this._regions || this._raw?
				(this.currentFrame > 0? this.currentFrame - 1 : this.totalFrames)
				: 0
			;
		}
		
		private function offsetFrames(offset:int):void {
			var frame:uint = this.currentFrame + offset;
			this.currentFrame = frame < 0? this.totalFrames - frame : frame >= this.totalFrames? frame - this.totalFrames : frame;
		}
		
		private function get timeDelta():Number {
			return this._fps == -1? (1000 / this.fps) : this._timeDelta;
		}
	}

}