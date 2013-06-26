package net.peakgames.components.flatflash.tools.loader {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import net.peakgames.components.flatflash.tools.EngineTypes;
	import net.peakgames.components.flatflash.tools.parsers.IParser;
	import net.peakgames.components.flatflash.tools.parsers.ParseEvent;
	import net.peakgames.components.flatflash.tools.parsers.ParseResult;
	import net.peakgames.components.flatflash.tools.parsers.ParserFactory;
	
	[Event(name = "LoadComplete", type = "net.peakgames.components.flatflash.tools.loader.LoaderEvent")]
	[Event(name = "LoadFail", type = "net.peakgames.components.flatflash.tools.loader.LoaderEvent")]
	public class AtlasLoader extends EventDispatcher {
		public var type:String;
		public var config:String;
		public var path:String;
		
		private var parser:IParser;
		private var loader:ResourceLoader;
		private var parseResult:ParseResult;
		
		private var loaderRequestId:uint;
		
		public function AtlasLoader(type:String, config:String, path:String) {
			this.type = EngineTypes.validate(type);
			this.config = config;
			this.path = path;
			
			this.prepapre();
		}
		
		public function destroy():void {
			if (this.parser) {
				this.parser.removeEventListener(ParseEvent.PARSE_COMPLETE, this.handleParserComplete);
				this.parser.removeEventListener(ParseEvent.PARSE_FAIL, this.handleParserFail);
				
				this.parser.destroy();
				
				this.parser = null;
			}
			
			if (this.loader) {
				this.loader.removeEventListener(ResourceLoaderEvent.RESOURCE_COMPLETE, this.handleLoaderComplete);
				this.loader.removeEventListener(ResourceLoaderEvent.RESOURCE_FAIL, this.handleLoaderFail);
				
				this.loader.destroy();
				
				this.loader = null;
			}
		}
		
		private function prepapre():void {
			this.parser = ParserFactory.get(this.type, this.config);
			
			this.parser.addEventListener(ParseEvent.PARSE_COMPLETE, this.handleParserComplete);
			this.parser.addEventListener(ParseEvent.PARSE_FAIL, this.handleParserFail);
		}
		
		private function prepareToDestroyLoadComplete():void {
			this.dispatchEvent(new LoaderEvent(LoaderEvent.LOAD_COMPLETE, this.parseResult));
			
			this.destroy();
		}
		
		private function handleImageBasedAssets(e:ResourceLoaderEvent):void {
			this.parseResult.bitmapData = Bitmap((e.postTarget.loader as Loader).content).bitmapData;
			
			this.prepareToDestroyLoadComplete();
		}
		
		private function handleParserComplete(e:ParseEvent):void {
			this.loader = ResourceLoader.instance;
			
			this.loader.addEventListener(ResourceLoaderEvent.RESOURCE_COMPLETE, this.handleLoaderComplete);
			this.loader.addEventListener(ResourceLoaderEvent.RESOURCE_FAIL, this.handleLoaderFail);
			
			this.parseResult = e.result;
			this.loaderRequestId = this.loader.load(this.path + e.result.path);
		}
		
		private function handleParserFail(e:ParseEvent):void {
			this.dispatchEvent(new LoaderEvent(LoaderEvent.LOAD_FAIL));
			
			this.destroy();
		}
		
		private function handleLoaderComplete(e:ResourceLoaderEvent):void {
			if (
				this.type == EngineTypes.TYPE_STARLING
				&& this.loaderRequestId == e.id
			) {
				this.handleImageBasedAssets(e);
			}
		}
		
		private function handleLoaderFail(e:ResourceLoaderEvent):void {
			this.dispatchEvent(new LoaderEvent(LoaderEvent.LOAD_FAIL));
			
			this.destroy();
		}
		
	}

}