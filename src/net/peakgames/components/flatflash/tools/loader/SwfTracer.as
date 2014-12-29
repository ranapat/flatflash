package net.peakgames.components.flatflash.tools.loader {
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import net.peakgames.components.flatflash.tools.joiners.BitmapDataVectorJoiner;
	
	public class SwfTracer extends EventDispatcher {
		private static const FRAMES_COPY_PER_ITERATION:uint = 500;
		
		public static const TRACE_COMPLETE:String = "traceComplete";
		public static const TRACE_FAIL:String = "traceFail";
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
		private var _currentTracedBitmaps:Vector.<BitmapData>;
		private var _currentTargetPreviousFrame:uint;
		
		private var _totalFramesCopiesThisFrame:uint;
		
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
			} else {
				throw new Error("Use static SwfTracer::instance getter instead");
			}
		}
		
		public function set stage(value:Stage):void {
			this._stage = value;
			
		}

		public function get(applicationDomain:ApplicationDomain, className:String):uint {
			this.enqueue(++this._index, applicationDomain, className);
			this.tryToDequeue();
			
			return this._index;
		}
		
		private function enqueue(key:uint, applicationDomain:ApplicationDomain, className:String):void {
			this._queue.push(new QueueObject(key, applicationDomain, className));
		}
		
		private function tryToDequeue():void {
			if (!this._bussy && this._queue.length > 0) {
				this._bussy = true;
				
				var item:QueueObject = this._queue.shift();
				
				this._currentKey = item.key;

				try {
					var ClassDefinition:Class = item.applicationDomain.getDefinition(item.className) as Class;
					this._currentTraced = new ClassDefinition();
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
						
						this._currentTracedBitmaps.push(tmp);
						
						this.finalizeCurrentTask();
					}
				} catch (e:Error) {
					this.failCurrentTask(e);
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
			this.dispatchEvent(new SwfTracerEvent(SwfTracer.TRACE_COMPLETE, this._currentKey, this._currentType, this._bitmapDataJoiner.toAtlas(this._currentTracedBitmaps), null));
			
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
				
				this._currentTracedBitmaps.push(tmp);
				
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
import flash.system.ApplicationDomain;

class QueueObject {
	public var key:uint;
	public var applicationDomain:ApplicationDomain;
	public var className:String;
	
	public function QueueObject(key:uint, applicationDomain:ApplicationDomain, className:String) {
		this.key = key;
		this.applicationDomain = applicationDomain;
		this.className = className;
	}
	
}