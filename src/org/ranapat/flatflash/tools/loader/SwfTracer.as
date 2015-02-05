package org.ranapat.flatflash.tools.loader {
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import org.ranapat.flatflash.Settings;
	import org.ranapat.flatflash.tools.joiners.BitmapDataVectorJoiner;
	import org.ranapat.flatflash.tools.joiners.JoinResult;
	import org.ranapat.flatflash.tools.Tools;
	
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
		private var _currentTracedClipRectangle:Rectangle;
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

		public function get(_class:Class, identifier:String = null, clipRectangle:Rectangle = null):uint {
			this.enqueue(
				++this._index,
				_class,
				identifier && identifier != Settings.NO_IDENTIFIER? identifier : identifier != Settings.NO_IDENTIFIER? Tools.getFullClassName(_class) + ">><<" + clipRectangle : null,
				clipRectangle
			);
			
			this.tryToDequeue();
			
			return this._index;
		}
		
		private function enqueue(key:uint, _class:Class, identifier:String, clipRectangle:Rectangle):void {
			this._queue[this._queue.length] = new QueueObject(key, _class, identifier, clipRectangle);
		}
		
		private function tryToDequeue():void {
			if (!this._bussy && this._queue.length > 0) {
				this._bussy = true;
				
				var item:QueueObject = this._queue.shift();
				
				this._currentKey = item.key;
				this._currentTracedIdentifier = item.identifier;
				this._currentTracedClipRectangle = item.clipRectangle;
				
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
							
							var offsetX:Number;
							var offsetY:Number;
							var width:Number;
							var height:Number;
							var clipRectangleToDraw:Rectangle;
							
							if (this._currentTracedClipRectangle) {
								offsetX = -1 * this._currentTracedClipRectangle.x;
								offsetY = -1 * this._currentTracedClipRectangle.y;
								
								width = this._currentTracedClipRectangle.width - this._currentTracedClipRectangle.x;
								width = width > this._currentTraced.width + offsetX? this._currentTraced.width + offsetX : width;
								
								height = this._currentTracedClipRectangle.height - this._currentTracedClipRectangle.y;
								height = height > this._currentTraced.height + offsetY? this._currentTraced.height + offsetY : height;
								
								clipRectangleToDraw = new Rectangle(0, 0, width, height);
							} else {
								offsetX = 0;
								offsetY = 0;
								width = this._currentTraced.width;
								height = this._currentTraced.height;
							}
							
							var tmp:BitmapData = new BitmapData(width, height, true, 0);
							tmp.draw(this._currentTraced, new Matrix(1, 0, 0, 1, offsetX, offsetY), null, null, clipRectangleToDraw, false);
							
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
			this.dispatchEvent(new SwfTracerEvent(SwfTracer.TRACE_FAIL, this._currentKey, this._currentType, null, null, e));
			
			this._stage.removeEventListener(Event.ENTER_FRAME, this.handleStageEnterFrame);
			
			this._bussy = false;
			this._currentKey = 0;
			this._currentType = "";
			this._currentTraced = null;
			this._currentTracedIdentifier = "";
			this._currentTracedClipRectangle = null;
			this._currentTracedBitmaps = new Vector.<BitmapData>();
			this._currentTracedBitmaps = null;
			this._currentTargetPreviousFrame = 0;
			
			this.tryToDequeue();
		}
		
		private function finalizeCurrentTask():void {
			var type:String;
			var joined:JoinResult;
			var raw:Vector.<BitmapData>;
			
			if (this._currentTracedIdentifier && this._cache[this._currentTracedIdentifier]) {
				type = this._cache[this._currentTracedIdentifier].type;
				joined = this._cache[this._currentTracedIdentifier].joined;
				raw = this._cache[this._currentTracedIdentifier].raw;
			} else {
				type = this._currentType;
				joined = this._bitmapDataJoiner.toAtlas(this._currentTracedBitmaps);
				raw = joined? null : this._currentTracedBitmaps;
				
				this._cache[this._currentTracedIdentifier] = new CacheObject(type, joined, raw);
			}
			
			this.dispatchEvent(new SwfTracerEvent(SwfTracer.TRACE_COMPLETE, this._currentKey, type, joined, raw, null));
			
			this._stage.removeEventListener(Event.ENTER_FRAME, this.handleStageEnterFrame);
			
			this._bussy = false;
			this._currentKey = 0;
			this._currentType = "";
			this._currentTraced = null;
			this._currentTracedIdentifier = "";
			this._currentTracedClipRectangle = null;
			this._currentTracedBitmaps = new Vector.<BitmapData>();
			this._currentTracedBitmaps = null;
			this._currentTargetPreviousFrame = 0;
			
			this.tryToDequeue();
		}
		
		private function traceMovieClips():void {
			var length:uint = SwfTracer.FRAMES_COPY_PER_ITERATION;
			var movieClip:MovieClip = this._currentTraced as MovieClip;
			var clipRectangle:Rectangle = this._currentTracedClipRectangle;
			
			var offsetX:Number;
			var offsetY:Number;
			var width:Number;
			var height:Number;
			var clipRectangleToDraw:Rectangle;
			
			if (clipRectangle) {
				offsetX = -1 * clipRectangle.x;
				offsetY = -1 * clipRectangle.y;
				
				width = clipRectangle.width - clipRectangle.x;
				width = width > movieClip.width + offsetX? movieClip.width + offsetX : width;
				
				height = clipRectangle.height - clipRectangle.y;
				height = height > movieClip.height + offsetY? movieClip.height + offsetY : height;
				
				clipRectangleToDraw = new Rectangle(0, 0, width, height);
			} else {
				offsetX = 0;
				offsetY = 0;
				width = movieClip.width;
				height = movieClip.height;
			}
			
			while (movieClip.currentFrame <= movieClip.totalFrames && this._currentTargetPreviousFrame != movieClip.currentFrame && this._totalFramesCopiesThisFrame < length) {
				this._currentTargetPreviousFrame = movieClip.currentFrame;
				
				var tmp:BitmapData = new BitmapData(width, height, true, 0);
				tmp.draw(movieClip, new Matrix(1, 0, 0, 1, offsetX, offsetY), null, null, clipRectangleToDraw, false);

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

import flash.display.BitmapData;
import flash.geom.Rectangle;
import org.ranapat.flatflash.tools.joiners.JoinResult;

class QueueObject {
	public var key:uint;
	public var _class:Class;
	public var identifier:String;
	public var clipRectangle:Rectangle;
	
	public function QueueObject(key:uint, _class:Class, identifier:String, clipRectangle:Rectangle) {
		this.key = key;
		this._class = _class;
		this.identifier = identifier;
		this.clipRectangle = clipRectangle;
	}
}

class CacheObject {
	public var type:String;
	public var joined:JoinResult;
	public var raw:Vector.<BitmapData>;
	
	public function CacheObject(type:String, joined:JoinResult, raw:Vector.<BitmapData>) {
		this.type = type;
		this.joined = joined;
		this.raw = raw;
	}
}