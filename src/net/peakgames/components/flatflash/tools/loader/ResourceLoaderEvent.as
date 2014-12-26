package net.peakgames.components.flatflash.tools.loader {
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	public class ResourceLoaderEvent extends Event {
		public static const RESOURCE_COMPLETE:String = "ResourceComplete";
		public static const RESOURCE_FAIL:String = "ResourceFail";
		
		public var id:uint;
		public var postTarget:Object;
		public var applicationDomain:ApplicationDomain;
		public var fps:uint;
		
		public function ResourceLoaderEvent(type:String, id:uint = 0, target:Object = null, applicationDomain:ApplicationDomain = null, fps:uint = 0) {
			super(type);
			
			this.id = id;
			this.postTarget = target;
			this.applicationDomain = applicationDomain;
			this.fps = fps;
		}
		
	}

}