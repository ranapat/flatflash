package org.ranapat.flatflash.tools.parsers {
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.xml.XMLNode;
	import org.ranapat.flatflash.tools.EngineTypes;
	import org.ranapat.flatflash.tools.regions.Region;
	import org.ranapat.flatflash.tools.regions.StarlingRegion;
	
	public class StarlingFormat extends EventDispatcher implements IParser {
		private var xml:XML;
		private var loader:URLLoader;
		
		public function StarlingFormat(file:String = null) {
			if (file) {
				this.parse(file);
			}
		}
		
		public function destroy():void {
			this.removeLoader();
		}
		
		public function parse(file:String):void {
			this.removeLoader();
			
			try {
				this.loader = new URLLoader();
				this.loader.addEventListener(Event.COMPLETE, this.handleLoaderComplete);
				this.loader.addEventListener(ProgressEvent.PROGRESS, this.handleLoaderProgress);
				this.loader.addEventListener(Event.OPEN, this.handleLoaderOpen);
				this.loader.addEventListener(ErrorEvent.ERROR, this.handleLoaderError)
				this.loader.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.handleLoaderError);
				this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleLoaderError);
				this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.handleLoaderError);
			
				this.loader.load(new URLRequest(file));
			} catch (e:Error) {
				this.handleLoaderError(null);
			}
		}
		
		private function removeLoader():void {
			if (this.loader) {
				this.loader.removeEventListener(ProgressEvent.PROGRESS, this.handleLoaderProgress);
				this.loader.removeEventListener(Event.COMPLETE, this.handleLoaderComplete);
				this.loader.removeEventListener(Event.OPEN, this.handleLoaderOpen);
				this.loader.removeEventListener(ErrorEvent.ERROR, this.handleLoaderError);
				this.loader.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, this.handleLoaderError);
				this.loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleLoaderError);
				this.loader.removeEventListener(IOErrorEvent.IO_ERROR, this.handleLoaderError);
				
				this.loader.close();
				this.loader = null;
			}
		}
		
		private function handleLoaderProgress(e:ProgressEvent):void {
		}
		
		private function handleLoaderComplete(e:Event):void {
			var result:ParseResult = new ParseResult(EngineTypes.TYPE_STARLING);
			var regions:Vector.<StarlingRegion> = new Vector.<StarlingRegion>();
			
			var xml:XML = new XML(this.loader.data);
			result.path = xml.@imagePath;
			for each (var subTexture:XML in xml.SubTexture) {
				regions[regions.length] = new StarlingRegion(
					subTexture.@name,
					Number(subTexture.@x), Number(subTexture.@y), Number(subTexture.@width), Number(subTexture.@height),
					Number(subTexture.@frameX), Number(subTexture.@frameY), Number(subTexture.@frameWidth), Number(subTexture.@frameHeight)
				);
			}
			
			result.regions = Vector.<Region>(regions);
			
			this.dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, result));
			
			this.removeLoader();
 		}
		
		private function handleLoaderOpen(e:Event):void {
		}
		
		private function handleLoaderError(e:Event):void {
			this.dispatchEvent(new ParseEvent(ParseEvent.PARSE_FAIL));
			
			this.removeLoader();
		}
		
	}

}