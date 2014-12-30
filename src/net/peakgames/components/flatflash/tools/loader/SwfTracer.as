package net.peakgames.components.flatflash.tools.loader {
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import net.peakgames.components.flatflash.Settings;
	import net.peakgames.components.flatflash.tools.joiners.BitmapDataVectorJoiner;
	import net.peakgames.components.flatflash.tools.joiners.JoinResult;
	import net.peakgames.components.flatflash.tools.Tools;
	
	public class SwfTracer extends EventDispatcher {
		private static const FRAMES_COPY_PER_ITERATION:uint = 500;
		
		public static const TRACE_COMPLETE:String = "swfTracerTraceComplete";
		public static const TRACE_FAIL:String = "swfTracerTraceFail";
		
		public static const TYPE_SPRITE:String = "sprite";
		public static const TYPE_MOVIE_CLIP:String = "movieClip";
		
		private static var _instance:SwfTracer;
		private static var _allowInstance:Boolean;
		
		private var _stage:Stage;
		
		private var _index:uint;
		private var _bussy:Boolean;
		private var _queue:Vector.<QueueObject>;
		private var _bitmapDataJoiner:BitmapDataVectorJoiner;
		
		private var _currentKey:uint;
		private var _currentType:String;
		private var _currentTraced:DisplayObjectContainer;
		private var _currentTracedIdentifier:String;
		private var _currentTracedBitmaps:Vector.<BitmapData>;
		private var _currentTargetPreviousFrame:uint;
		private var _currentTargetFrameMultiplier:Number;
		private var _currentTargetFrameMultiplierSkip:Number;
		
		private var _totalFramesCopiesThisFrame:uint;
		
		private var _cache:Dictionary;
		
		public static function get instance():SwfTracer {
			if (!SwfTracer._instance) {
				SwfTracer._allowInstance = true;
				SwfTracer._instance = new SwfTracer();
				SwfTracer._allowInstance = false;
			}
			
			return SwfTracer._instance;
		}
		
		public function SwfTracer() {
			if (SwfTracer._allowInstance) {
				this._index = 0;
				this._bussy = false;
				
				this._queue = new Vector.<QueueObject>();
				
				this._bitmapDataJoiner = new BitmapDataVectorJoiner();
				
				this._totalFramesCopiesThisFrame = 0;
				this._currentTargetPreviousFrame = 0;
				
				this._cache = new Dictionary(true);
			} else {
				throw new Error("Use static SwfTracer::instance getter instead");
			}
		}
		
		public function set stage(value:Stage):void {
			this._stage = value;
			
		}

		public function get(_class:Class, identifier:String = null):uint {
			this.enqueue(
				++this._index,
				_class,
				identifier && identifier != Settings.NO_IDENTIFIER? identifier : identifier != Settings.NO_IDENTIFIER? Tools.getFullClassName(_class) : null
			);
			
			this.tryToDequeue();
			
			return this._index;
		}
		
		private function enqueue(key:uint, _class:Class, identifier:String):void {
			this._queue[this._queue.length] = new QueueObject(key, _class, identifier);
		}
		
		private function tryToDequeue():void {
			if (!this._bussy && this._queue.length > 0) {
				this._bussy = true;
				
				var item:QueueObject = this._queue.shift();
				
				this._currentKey = item.key;
				this._currentTracedIdentifier = item.identifier;
				
				if (this._currentTracedIdentifier && this._cache[this._currentTracedIdentifier]) {
					this.finalizeCurrentTask();
				} else {
					try {
						this._currentTraced = new item._class;
						this._currentTracedBitmaps = new Vector.<BitmapData>();
						
						if (this._currentTraced is MovieClip) {
							this._currentType = SwfTracer.TYPE_MOVIE_CLIP;
							this._currentTargetPreviousFrame = 0;
							
							(this._currentTraced as MovieClip).gotoAndStop(1);
							this._stage.addEventListener(Event.ENTER_FRAME, this.handleStageEnterFrame, false, 0, true);
							
							this.traceMovieClips();
						} else if (this._currentTraced is Sprite) {
							this._currentType = SwfTracer.TYPE_SPRITE;
							
							var tmp:BitmapData = new BitmapData(this._currentTraced.width, this._currentTraced.height, true, 0);
							tmp.draw(this._currentTraced);
							
							this._currentTracedBitmaps[this._currentTracedBitmaps.length] = tmp;
							
							this.finalizeCurrentTask();
						}
					} catch (e:Error) {
						this.failCurrentTask(e);
					}
				}
			}
		}
		
		private function failCurrentTask(e:Error):void {
			this.dispatchEvent(new SwfTracerEvent(SwfTracer.TRACE_FAIL, this._currentKey, this._currentType, null, e));
			
			this._stage.removeEventListener(Event.ENTER_FRAME, this.handleStageEnterFrame);
			
			this._bussy = false;
			this._currentKey = 0;
			this._currentType = "";
			this._currentTraced = null;
			this._currentTracedBitmaps = new Vector.<BitmapData>();
			this._currentTracedBitmaps = null;
			this._currentTargetPreviousFrame = 0;
			
			this.tryToDequeue();
		}
		
		private function finalizeCurrentTask():void {
			var type:String;
			var joined:JoinResult;
			
			if (this._currentTracedIdentifier && this._cache[this._currentTracedIdentifier]) {
				type = this._cache[this._currentTracedIdentifier].type;
				joined = this._cache[this._currentTracedIdentifier].joined;
			} else {
				type = this._currentType;
				joined = this._bitmapDataJoiner.toAtlas(this._currentTracedBitmaps);
				
				this._cache[this._currentTracedIdentifier] = new CacheObject(type, joined);
			}
			
			this.dispatchEvent(new SwfTracerEvent(SwfTracer.TRACE_COMPLETE, this._currentKey, type, joined, null));
			
			this._stage.removeEventListener(Event.ENTER_FRAME, this.handleStageEnterFrame);
			
			this._bussy = false;
			this._currentKey = 0;
			this._currentType = "";
			this._currentTraced = null;
			this._currentTracedBitmaps = new Vector.<BitmapData>();
			this._currentTracedBitmaps = null;
			this._currentTargetPreviousFrame = 0;
			
			this.tryToDequeue();
		}
		
		private function traceMovieClips():void {
			var length:uint = SwfTracer.FRAMES_COPY_PER_ITERATION;
			var movieClip:MovieClip = this._currentTraced as MovieClip;
			
			while (movieClip.currentFrame <= movieClip.totalFrames && this._currentTargetPreviousFrame != movieClip.currentFrame && this._totalFramesCopiesThisFrame < length) {
				this._currentTargetPreviousFrame = movieClip.currentFrame;
				
				var tmp:BitmapData = new BitmapData(movieClip.width, movieClip.height, true, 0);
				tmp.draw(movieClip);

				var multiplier:Number;
				
				this._currentTracedBitmaps[this._currentTracedBitmaps.length] = tmp;
				
				movieClip.nextFrame();
				
				++this._totalFramesCopiesThisFrame;
			}
			
			if (movieClip.currentFrame == movieClip.totalFrames) {
				this.finalizeCurrentTask();
			}
		}
		
		private function handleStageEnterFrame(e:Event):void {
			this._totalFramesCopiesThisFrame = 0;
			
			this.traceMovieClips();
		}
		
	}

}

import net.peakgames.components.flatflash.tools.joiners.JoinResult;

class QueueObject {
	public var key:uint;
	public var _class:Class;
	public var identifier:String;
	
	public function QueueObject(key:uint, _class:Class, identifier:String) {
		this.key = key;
		this._class = _class;
		this.identifier = identifier;
	}
	
}

class CacheObject {
	public var type:String;
	public var joined:JoinResult;
	
	public function CacheObject(type:String, joined:JoinResult) {
		this.type = type;
		this.joined = joined;
	}
}