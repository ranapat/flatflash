package org.ranapat.flatflash {
	import flash.events.EventDispatcher;
	
	final public class FlatFlash extends EventDispatcher {
		private static var _allowInstance:Boolean;
		private static var _instance:FlatFlash;
		
		public static function get instance():FlatFlash {
			if (!FlatFlash._instance) {
				FlatFlash._allowInstance = true;
				FlatFlash._instance = new FlatFlash();
				FlatFlash._allowInstance = false;
			}
			return FlatFlash._instance;
		}
		
		public function FlatFlash() {
			if (FlatFlash._allowInstance) {
				//
			} else {
				throw new Error("Use FlatFlash::instance instead.");
			}
		}
		
	}

}