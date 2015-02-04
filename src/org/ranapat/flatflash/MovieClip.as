package org.ranapat.flatflash {
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import org.ranapat.flatflash.tools.EngineTypes;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public class MovieClip extends DisplayObject {
		private var _regions:Vector.<Region>;
		private var _raw:Vector.<BitmapData>;
		private var _compressed:Vector.<ByteArray>;
		
		private var _currentFrame:uint;
		private var _playing:Boolean;
		private var _totalFrames:uint;
		
		private var _latestParentTFP:Number;
		private var _hopsBetweenMoves:uint;
		private var _hopEveryNthTime:Number;

		private var _loops:int;
		private var _totalLoops:uint;
		private var _fps:int;
		private var _timeDelta:Number;
		private var _previousTimeOffset:uint;
		
		private var _loopLimitReached:Boolean;
		private var _loopLimitReachedCallbackHolder:Dictionary;
		
		public function MovieClip(...args) {
			super();
			
			this._loopLimitReachedCallbackHolder = new Dictionary(true);
			
			this.fps = -1;
			this.loops = -1;
			
			this.initialize.apply(this, args);
			
			this._latestParentTFP = 0;
			this._hopsBetweenMoves = 0;
			this._hopEveryNthTime = 0;
		}
		
		override public function initialize(...args):void {
			if (args.length == 2 && args[0] is BitmapData && args[1] is Vector.<Region>) {
				this._regions = args[1];
				this._totalFrames = this._regions.length;
				
				super.initialize(args[0]);
			} else if (args.length == 1 && args[0] is Vector.<BitmapData> && (args[0] as Vector.<BitmapData>).length > 0) {
				this._raw = args[0];
				this._totalFrames = this._raw.length;
				
				this.handleInitialized();
			} else if (args.length == 3 && args[0] is Vector.<ByteArray> && (args[0] as Vector.<ByteArray>).length > 0 && args[1] is Number && args[2] is Number) {
				this._compressed = args[0];
				this._totalFrames = this._compressed.length;
				
				this.width = args[1];
				this.height = args[2];
				
				this.handleInitialized();
			}
			
			this.currentFrame = 0;
		}
		
		public function get currentFrame():uint {
			return this._currentFrame;
		}
		
		public function set currentFrame(value:uint):void {
			if (
				this.totalFrames > value
				&& value >= 0
				&& (this._regions || this._raw || this._compressed)
			) {
				if (this._regions) {
					this._currentFrame = value;
					
					this.width = this._regions[this._currentFrame].width;
					this.height = this._regions[this._currentFrame].height;
				} else if (this._raw) {
					this._currentFrame = value;
					
					this.width = this._raw[this._currentFrame].width;
					this.height = this._raw[this._currentFrame].height;
				} else if (this._compressed) {
					this._currentFrame = value;
				}
			}
		}
		
		public function get totalFrames():uint {
			return this._totalFrames;
		}
		
		public function get playing():Boolean {
			return this._playing;
		}
		
		public function set loops(value:int):void {
			this._loops = value < 0? -1 : value;
			this._totalLoops = 0;
			this._loopLimitReached = false;
		}
		
		public function get loops():int {
			return this._loops;
		}
		
		public function set fps(value:int):void {
			this._fps = value;
			this._timeDelta = this.fps? 1000 / this.fps : 0;
		}
		
		public function get fps():int {
			return this._fps == -1 && this.parent? this.parent.fps : this._fps == -1 && !this.parent? 0 : this._fps;
		}
		
		public function play(loops:int = -1):void {
			this.markChanged();
			this._playing = true;
			this.loops = loops;
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
		
		public function onLoopLimitReached(object:Object, callback:Function, parameters:Array = null):void {
			this.addToCallbackHolder(this._loopLimitReachedCallbackHolder, object, callback, parameters);
		}
		
		public function onLoopLimitReachedRemove(object:Object, callback:Function = null):void {
			this.removeFromCallbackHolder(this._loopLimitReachedCallbackHolder, object, callback);
		}
		
		override public function get spritesheet():BitmapData {
			if (this._regions) {
				return super.spritesheet;
			} else if (this._raw) {
				return this._raw[this._currentFrame];
			} else if (this._compressed) {
				var bitmapData:BitmapData = new BitmapData(this.width, this.height, true, 0);
				var byteArray:ByteArray = new ByteArray();
				byteArray.writeBytes(this._compressed[this._currentFrame]);
				byteArray.inflate();
				bitmapData.setPixels(new Rectangle(0, 0, this.width, this.height), byteArray);
				return bitmapData;
			} else {
				return null;
			}
		}
		
		override public function get region():Region {
			if (this._regions) {
				return this._regions[this._currentFrame];
			} else if (this._raw) {
				return new Region(this.name, 0, 0, this.width, this.height, EngineTypes.TYPE_STARLING);
			} else if (this._compressed) {
				return new Region(this.name, 0, 0, this.width, this.height, EngineTypes.TYPE_STARLING);
			} else {
				return null;
			}
		}
		
		override public function hop(timer:int):void {
			if (this.playing) {
				var timeOffset:uint = timer / this.timeDelta;
				var delta:int = this._previousTimeOffset <= timeOffset? (timeOffset - this._previousTimeOffset) : (this.fps - this._previousTimeOffset + timeOffset);
				this._previousTimeOffset = timeOffset;
			
				var frame:uint = this.currentFrame + delta;
				var nextFrame:uint = frame < 0? this.totalFrames - frame : frame >= this.totalFrames? frame - this.totalFrames : frame;
				
				if (
					nextFrame < this.currentFrame
					&& this.loops != -1
					&& this.loops <= ++this._totalLoops
				) {
					this.gotoAndStop(this.totalFrames - 1);
					this._loopLimitReached = true;
				} else {
					this.currentFrame = nextFrame;
				}
			}
			
			super.hop(timer);
		}
		
		override public function get changed():Boolean {
			return this._playing? true : super.changed;
		}
		
		override public function get name():String {
			if (!super.name && this._regions && this.totalFrames > this.currentFrame) {
				return this._regions[this.currentFrame].name;
			} else if (!super.name && this._raw) {
				return "raw-frame-" + this.currentFrame;
			} else if (!super.name && this._compressed) {
				return "compressed-frame-" + this.currentFrame;
			} else {
				return super.name;
			}
		}
		
		override public function afterDraw():void {
			super.afterDraw();
			
			if (this._loopLimitReached) {
				this.walkCallbackHolder(this._loopLimitReachedCallbackHolder);
				
				this._loopLimitReached = false;
			}
		}
		
		private function gotoNextFrame():void {
			this.currentFrame = this._regions || this._raw || this._compressed?
				((this.currentFrame + 1 >= this.totalFrames)? 0 : this.currentFrame + 1)
				: 0
			;
		}
		
		private function gotoPreviousFrame():void {
			this.currentFrame = this._regions || this._raw || this._compressed?
				(this.currentFrame > 0? this.currentFrame - 1 : this.totalFrames)
				: 0
			;
		}
		
		private function get timeDelta():Number {
			return this._fps == -1? (1000 / this.fps) : this._timeDelta;
		}
	}

}