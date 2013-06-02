package net.peakgames.components.flatflash.tools.loader {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	import flash.system.ApplicationDomain;
	
	[Event(name = "ResourceComplete", type = "net.peakgames.components.flatflash.tools.loader.ResourceLoaderEvent")]
	[Event(name = "ResourceFail", type = "net.peakgames.components.flatflash.tools.loader.ResourceLoaderEvent")]
	public class ResourceLoader extends EventDispatcher {
		public static const LOADING:uint = 0;
		public static const COMPLETE:uint = 1;
		public static const ERROR:uint = 2;
		public static const TIMEOUT:uint = 3;
		
		private static const TIMEOUT_INTERVAL:int = 60 * 1000;
		
		private static var _instance:ResourceLoader;
		private static var _allowInstance:Boolean;
		private static var _instances:uint = 0;
		
		private var timeoutTimer:Timer;
		private var loader:Loader;
		private var queue:Vector.<String>;
		
		public var progress:Vector.<uint>;
		
		public static function get instance():ResourceLoader {
			if (!ResourceLoader._instance) {
				ResourceLoader._allowInstance = true;
				ResourceLoader._instance = new ResourceLoader();
				ResourceLoader._allowInstance = false;
			}
			++ResourceLoader._instances;
			
			return ResourceLoader._instance;
		}
		
		public function ResourceLoader() {
			if (ResourceLoader._allowInstance) {
				this.timeoutTimer = new Timer(ResourceLoader.TIMEOUT_INTERVAL, 1);
				this.timeoutTimer.addEventListener(TimerEvent.TIMER, this.handleTimeoutTimer, false, 0, true);
				
				this.queue = new Vector.<String>();
				
				this.loader = new Loader();
				this.loader.addEventListener(Event.COMPLETE, this.handleLoaderComplete, false, 0, true);
				this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.handleLoaderComplete, false, 0, true);
				this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.handleLoaderError, false, 0, true);
				this.loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, this.handleLoaderError, false, 0, true);
				this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.handleLoaderError, false, 0, true);
				this.loader.contentLoaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, this.handleLoaderError, false, 0, true);
				
				this.progress = new Vector.<uint>();
			} else {
				throw new Error("Use static ResourceLoader::instance getter instead");
			}
		}
		
		public function destroy():void {
			--ResourceLoader._instances;
			
			if (ResourceLoader._instances == 0) {
				this.timeoutTimer.removeEventListener(TimerEvent.TIMER, this.handleTimeoutTimer);
				this.timeoutTimer.stop();
				this.timeoutTimer = null;
				
				this.loader.removeEventListener(Event.COMPLETE, this.handleLoaderComplete);
				this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.handleLoaderComplete);
				this.loader.removeEventListener(IOErrorEvent.IO_ERROR, this.handleLoaderError);
				this.loader.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, this.handleLoaderError);
				this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.handleLoaderError);
				this.loader.contentLoaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, this.handleLoaderError);
				
				if (this.loader.content) {
					this.loader.unloadAndStop(true);
				} else {
					this.loader.close();
				}
				this.loader = null;
				
				this.queue = new Vector.<String>();
				this.queue = null;
				
				this.progress = new Vector.<uint>();
				this.progress = null;
				
				ResourceLoader._instance = null;
			}
		}
		
		public function load(url:String):int {
			this.queue.push(url);
			this.tryLoadNext();
			
			return this.progress.length + this.queue.length - 1;
		}
		
		private function tryLoadNext():void {
			if (!this.timeoutTimer.running) {
				this.loadNext();
			}
		}
		
		private function loadNext():void {
			var tmp:String = this.queue.shift();
			if (tmp) {
				this.timeoutTimer.reset();
				this.timeoutTimer.start();
				
				this.progress.push(ResourceLoader.LOADING);
				this.loader.load(
					new URLRequest(tmp),
					new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain))
				);
			}
		}
		
		private function handleTimeoutTimer(e:TimerEvent):void {
			var length:uint = this.progress.length;
			
			this.progress[this.progress.length - 1] = ResourceLoader.TIMEOUT;
			this.tryLoadNext();
			
			this.dispatchEvent(new ResourceLoaderEvent(
				ResourceLoaderEvent.RESOURCE_FAIL,
				length - 1
			));
		}
		
		private function handleLoaderComplete(e:Event):void {
			var length:uint = this.progress.length;
			
			this.progress[this.progress.length - 1] = ResourceLoader.COMPLETE;
			this.timeoutTimer.stop();
			this.tryLoadNext();
			
			this.dispatchEvent(new ResourceLoaderEvent(
				ResourceLoaderEvent.RESOURCE_COMPLETE,
				length - 1,
				e.target,
				e.target.applicationDomain
			));
		}
		
		private function handleLoaderError(e:IOErrorEvent):void {
			var length:uint = this.progress.length;
			
			this.progress[this.progress.length - 1] = ResourceLoader.ERROR;
			this.timeoutTimer.stop();
			this.tryLoadNext();
			
			this.dispatchEvent(new ResourceLoaderEvent(
				ResourceLoaderEvent.RESOURCE_FAIL,
				length - 1
			));
		}
		
	}

}