package org.ranapat.flatflash.examples {
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import org.ranapat.flatflash.DisplayObject;
	import org.ranapat.flatflash.DisplayObjectContainer;
	import org.ranapat.flatflash.DisplayObjectFactory;
	import org.ranapat.flatflash.MovieClip;
	import org.ranapat.flatflash.tools.Tools;
	
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	
	
	public class DiceRollAnimation extends org.ranapat.flatflash.DisplayObjectContainer {
		private var diceTurnMyAnimation1:org.ranapat.flatflash.MovieClip;
		private var diceTurnMyAnimation2:org.ranapat.flatflash.MovieClip;
		private var diceTurnMyAnimation3:org.ranapat.flatflash.MovieClip;
		private var diceTurnMyAnimation4:org.ranapat.flatflash.MovieClip;
		private var diceTurnOpponentAnimation1:org.ranapat.flatflash.MovieClip;
		private var diceTurnOpponentAnimation2:org.ranapat.flatflash.MovieClip;
		private var diceTurnOpponentAnimation3:org.ranapat.flatflash.MovieClip;
		private var diceTurnOpponentAnimation4:org.ranapat.flatflash.MovieClip;
		private var diceStill1:org.ranapat.flatflash.MovieClip;
		private var diceStill2:org.ranapat.flatflash.MovieClip;
		private var diceStill3:org.ranapat.flatflash.MovieClip;
		private var diceStill4:org.ranapat.flatflash.MovieClip;
		private var diceTurnSideAnimation1:org.ranapat.flatflash.MovieClip;
		private var diceTurnSideAnimation2:org.ranapat.flatflash.MovieClip;
		private var diceTurnSideAnimation3:org.ranapat.flatflash.MovieClip;
		private var diceTurnSideAnimation4:org.ranapat.flatflash.MovieClip;
		
		private var applicationDomain:ApplicationDomain;
		
		private var tracedValues:Vector.<Vector.<TracedDiceObjects>>;
		private var _tracedValuesPlayIndex:uint;
		
		private var _initialized:Boolean;
		private var _playing:Boolean;
		
		private var _ranges:Dictionary;
		private var _playFrom:uint;
		private var _playTo:uint;
		
		private var _timeDelta:Number;
		private var _previousTimeOffset:uint;
		private var _startTime:int;
		
		private var _dice1:uint;
		private var _dice2:uint;
		private var _dice3:uint;
		private var _dice4:uint;
		
		private var soundMovieClip:flash.display.MovieClip;
		private var soundMovieClipName:String;
		
		private var _scaleFactor:Number;
		private var _originalWidth:Number;
		private var _originalHeight:Number;
		
		private var _innerScale:Number;
		
		public function DiceRollAnimation() {
			super();
			
			this.fps = 40;
			this._scaleFactor = 1;
			this._originalWidth = -1;
			this._originalHeight = -1;
			this._innerScale = 1;
			this.instantSizeChangeRecreate = false;
		}
		
		override public function set fps(value:int):void {
			super.fps = value;
			this._timeDelta = this.fps? 1000 / this.fps : 0;
		}
		
		public function set sound(value:String):void {
			this.soundMovieClipName = value;
			
			if (this.applicationDomain) {
				this.soundMovieClip = new (this.applicationDomain.getDefinition(this.soundMovieClipName) as Class)();
				this.soundMovieClip.stop();
			}
		}
		
		public function get sound():String {
			return this.soundMovieClipName;
		}
		
		public function set scaleFactor(value:Number):void {
			this._scaleFactor = value;
			
			if (this._originalWidth > 0 && this._originalHeight > 0) {
				this.width = this._originalWidth * this._scaleFactor;
				this.height = this._originalHeight * this._scaleFactor;
				
				this.recreateBitmapData();
			}
		}
		
		public function get scaleFactor():Number {
			return this._scaleFactor;
		}
		
		public function set innerScale(value:Number):void {
			this._innerScale = value;
			
			this.scaleFactor = value;
			this.scaleX = this.scaleY = 1 / value;
		}
		
		public function get innerScale():Number {
			return this._innerScale;
		}
		
		public function record(applicationDomain:ApplicationDomain, variation:String):void {
			this.removeAllChildren();
			
			this.applicationDomain = applicationDomain;
			
			this._ranges = new Dictionary();
			this.tracedValues = new Vector.<Vector.<TracedDiceObjects>>();
			
			var toRecord:flash.display.MovieClip = new (applicationDomain.getDefinition("DiceAnimations") as Class)();
			toRecord.gotoAndStop(1);
			
			var previousFrame:uint = 1;
			var previousLabel:String;
			var currentFrameStartIndex:uint;
			do {
				if (!previousLabel) {
					currentFrameStartIndex = toRecord.currentFrame - 1;
					previousLabel = toRecord.currentLabel;
				} else if (previousLabel != toRecord.currentLabel) {
					this.addRange(previousLabel, currentFrameStartIndex, toRecord.currentFrame - 2);
					
					currentFrameStartIndex = toRecord.currentFrame - 1;
					previousLabel = toRecord.currentLabel;
				}
				previousFrame = toRecord.currentFrame;
				this.walkThru(toRecord.currentFrame - 1, toRecord);
				toRecord.nextFrame();
				
			} while (toRecord.currentFrame != previousFrame);
			if (toRecord.currentFrame == previousFrame) {
				this.addRange(previousLabel, currentFrameStartIndex, toRecord.currentFrame - 2);
			}
			
			toRecord = null;
			
			var DiceTurnMyAnimation:Class = applicationDomain.getDefinition(variation + "DiceTurnMyAnimation") as Class;
			var DiceTurnOpponentAnimation:Class = applicationDomain.getDefinition(variation + "DiceTurnOpponentAnimation") as Class;
			var DiceStill:Class = applicationDomain.getDefinition(variation + "DiceStill") as Class;
			var DiceTurnSideAnimation:Class = applicationDomain.getDefinition(variation + "DiceTurnSideAnimation") as Class;
			
			this.diceTurnMyAnimation1 = DisplayObjectFactory.movieClipFromSWF(DiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
			this.diceTurnMyAnimation2 = DisplayObjectFactory.movieClipFromSWF(DiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
			this.diceTurnMyAnimation3 = DisplayObjectFactory.movieClipFromSWF(DiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
			this.diceTurnMyAnimation4 = DisplayObjectFactory.movieClipFromSWF(DiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
			this.diceTurnOpponentAnimation1 = DisplayObjectFactory.movieClipFromSWF(DiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
			this.diceTurnOpponentAnimation2 = DisplayObjectFactory.movieClipFromSWF(DiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
			this.diceTurnOpponentAnimation3 = DisplayObjectFactory.movieClipFromSWF(DiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
			this.diceTurnOpponentAnimation4 = DisplayObjectFactory.movieClipFromSWF(DiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
			this.diceStill1 = DisplayObjectFactory.movieClipFromSWF(DiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
			this.diceStill2 = DisplayObjectFactory.movieClipFromSWF(DiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
			this.diceStill3 = DisplayObjectFactory.movieClipFromSWF(DiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
			this.diceStill4 = DisplayObjectFactory.movieClipFromSWF(DiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
			this.diceTurnSideAnimation1 = DisplayObjectFactory.movieClipFromSWF(DiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
			this.diceTurnSideAnimation2 = DisplayObjectFactory.movieClipFromSWF(DiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
			this.diceTurnSideAnimation3 = DisplayObjectFactory.movieClipFromSWF(DiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
			this.diceTurnSideAnimation4 = DisplayObjectFactory.movieClipFromSWF(DiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
			
			this.diceTurnMyAnimation1.play();
			this.diceTurnMyAnimation2.play();
			this.diceTurnMyAnimation3.play();
			this.diceTurnMyAnimation4.play();
			this.diceTurnOpponentAnimation1.play();
			this.diceTurnOpponentAnimation2.play();
			this.diceTurnOpponentAnimation3.play();
			this.diceTurnOpponentAnimation4.play();
			this.diceStill1.gotoAndStop(0);
			this.diceStill2.gotoAndStop(0);
			this.diceStill3.gotoAndStop(0);
			this.diceStill4.gotoAndStop(0);
			this.diceTurnSideAnimation1.play();
			this.diceTurnSideAnimation2.play();
			this.diceTurnSideAnimation3.play();
			this.diceTurnSideAnimation4.play();
			
			this.addChild(this.diceTurnMyAnimation1);
			this.addChild(this.diceTurnMyAnimation2);
			this.addChild(this.diceTurnMyAnimation3);
			this.addChild(this.diceTurnMyAnimation4);
			this.addChild(this.diceTurnOpponentAnimation1);
			this.addChild(this.diceTurnOpponentAnimation2);
			this.addChild(this.diceTurnOpponentAnimation3);
			this.addChild(this.diceTurnOpponentAnimation4);
			this.addChild(this.diceStill1);
			this.addChild(this.diceStill2);
			this.addChild(this.diceStill3);
			this.addChild(this.diceStill4);
			this.addChild(this.diceTurnSideAnimation1);
			this.addChild(this.diceTurnSideAnimation2);
			this.addChild(this.diceTurnSideAnimation3);
			this.addChild(this.diceTurnSideAnimation4);
			
			this._initialized = true;
		}
		
		override public function redraw():void {
			if (this.stage && this._initialized && this._playing) {
				this._tracedValuesPlayIndex = this._tracedValuesPlayIndex > this._playTo? this._playTo : this._tracedValuesPlayIndex;
				this.applyDiceAnimation(this._tracedValuesPlayIndex);
				super.redraw();
				
				if (this._tracedValuesPlayIndex < this._playTo) {
					var currentTime:int = getTimer();
					var timer:int = currentTime - this._startTime;
					var timeOffset:uint = timer / this.timeDelta;
					var delta:int = this._previousTimeOffset <= timeOffset? (timeOffset - this._previousTimeOffset) : (this.fps - this._previousTimeOffset + timeOffset);
					
					this._previousTimeOffset = timeOffset;
					this._tracedValuesPlayIndex = this.currentFrame + delta;
				} else {
					this._playing = false;
					if (this.soundMovieClip) {
						this.soundMovieClip.stop();
					}
				}
			}
		}
		
		public function addRange(range:String, from:uint, to:uint):void {
			this._ranges[range] = new RangeObject(from, to);
		}
		
		public function play(range:String, dice1:uint, dice2:uint, dice3:uint, dice4:uint):void {
			if (this._ranges[range]) {
				this._playing = true;
				
				this._dice1 = dice1;
				this._dice2 = dice2;
				this._dice3 = dice3;
				this._dice4 = dice4;
				
				var rangeObject:RangeObject = this._ranges[range];
				
				this._playFrom = rangeObject.from;
				this._playTo = rangeObject.to;
				
				this._tracedValuesPlayIndex = this._playFrom;
				
				this._startTime = getTimer();
				this._previousTimeOffset = 0;
				
				if (this.soundMovieClip) {
					this.soundMovieClip.gotoAndPlay(this._tracedValuesPlayIndex);
				}
			}
		}
		
		public function stop():void {
			this._playing = false;
			if (this.soundMovieClip) {
				this.soundMovieClip.stop();
			}
		}
		
		override protected function get isChanged():Boolean {
			return this._playing;
		}
		
		override protected function handleAddedToStage():void {
			this._originalWidth = this.width;
			this._originalHeight = this.height;
			
			this.innerScale = this.innerScale;
		}
		
		private function applyDiceAnimation(frame:uint):void {
			var vector:Vector.<TracedDiceObjects> = this.tracedValues[frame];
			var length:uint = vector.length;
			
			var dicesTurnIndexMy:uint;
			var dicesTurnIndexOpponent:uint;
			var dicesStillIndex:uint;
			var dicesSideIndex:uint;
			
			var dice:org.ranapat.flatflash.MovieClip;
			for (var i:uint = 0; i < length; ++i) {
				dice = null;
				
				var tracedDiceObject:TracedDiceObjects = vector[i];
				var className:String = tracedDiceObject.className;
				var diceVisible:Boolean = true;
				if (
					tracedDiceObject.name == "dice1"
					|| tracedDiceObject.name == "dice2"
					|| tracedDiceObject.name == "dice3"
					|| tracedDiceObject.name == "dice4"
				) {
					diceVisible = this["_" + tracedDiceObject.name] > 0;
				}
				if (className == "WhiteDiceTurnMyAnimation") {
					dice = this["diceTurnMyAnimation" + ++dicesTurnIndexMy];
				} else if (className == "WhiteDiceTurnOpponentAnimation") {
					dice = this["diceTurnOpponentAnimation" + ++dicesTurnIndexOpponent];
				} else if (className == "WhiteDiceStill") {
					dice = this["diceStill" + ++dicesStillIndex];
					dice.gotoAndStop(this["_" + tracedDiceObject.name] - 1);
				} else if (className == "WhiteDiceTurnSideAnimation") {
					dice = this["diceTurnSideAnimation" + ++dicesSideIndex];
				}
				
				if (dice) {
					dice.visible = diceVisible;
					dice.x = tracedDiceObject.x * this.scaleFactor;
					dice.y = tracedDiceObject.y * this.scaleFactor;
					dice.scaleX = tracedDiceObject.scaleX * this.scaleFactor;
					dice.scaleY = tracedDiceObject.scaleY * this.scaleFactor;
					dice.filters = tracedDiceObject.filters;
				}
			}
			
			while (dicesTurnIndexMy < 4) {
				this["diceTurnMyAnimation" + ++dicesTurnIndexMy].visible = false;
			}
			while (dicesTurnIndexOpponent < 4) {
				this["diceTurnOpponentAnimation" + ++dicesTurnIndexOpponent].visible = false;
			}
			while (dicesStillIndex < 4) {
				this["diceStill" + ++dicesStillIndex].visible = false;
			}
			while (dicesSideIndex < 4) {
				this["diceTurnSideAnimation" + ++dicesSideIndex].visible = false;
			}
		}
		
		private function walkThru(frame:uint, object:flash.display.DisplayObjectContainer):void {
			var length:uint = object.numChildren;
			
			var located:Boolean;
			for (var i:uint = 0; i < length; ++i) {
				var tmp:flash.display.DisplayObject = object.getChildAt(i);
				if (tmp) {
					located = false;
					
					var className:String = Tools.getFullClassName(tmp);
					if (className == "WhiteDiceTurnMyAnimation") {
						located = true;
					} else if (className == "WhiteDiceTurnOpponentAnimation") {
						located = true;
					} else if (className == "WhiteDiceStill") {
						located = true;
					} else if (className == "WhiteDiceTurnSideAnimation") {
						located = true;
					}
					
					if (located) {
						while (this.tracedValues.length <= frame) {
							this.tracedValues[this.tracedValues.length] = new Vector.<TracedDiceObjects>();
						}
						this.tracedValues[frame][this.tracedValues[frame].length] = new TracedDiceObjects(
							tmp.name.replace("_moving_", "").replace("_still_", "").replace("_prim_", "").replace("_spinning_", ""),
							className,
							tmp.x, tmp.y,
							tmp.scaleX, tmp.scaleY,
							tmp.filters
						);
					}
				}
			}
		}
		
		private function get currentFrame():uint {
			return this._playing? this._tracedValuesPlayIndex : 0;
		}
		
		private function get totalFrames():uint {
			return this._playing? this._playTo : 0;
		}
		
		private function get timeDelta():Number {
			return this.fps == -1? (1000 / this.fps) : this._timeDelta;
		}
		
	}

}

class TracedDiceObjects {
	public var name:String;
	public var className:String;
	public var x:Number;
	public var y:Number;
	public var scaleX:Number;
	public var scaleY:Number;
	public var filters:Array;
	
	public function TracedDiceObjects(name:String, className:String, x:Number, y:Number, scaleX:Number, scaleY:Number, filters:Array) {
		this.name = name
		this.className = className
		this.x = x;
		this.y = y;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.filters = filters;
	}
}

class RangeObject {
	public var from:uint;
	public var to:uint;
	
	public function RangeObject(from:uint, to:uint):void {
		this.from = from;
		this.to = to;
	}
}