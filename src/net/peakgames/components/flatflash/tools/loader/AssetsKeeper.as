package net.peakgames.components.flatflash.tools.loader {
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	public class AssetsKeeper {
		private static var _instance:AssetsKeeper;
		private static var _allowInstance:Boolean;
		
		private var _storage:Dictionary;
		
		public static function get instance():AssetsKeeper {
			if (!AssetsKeeper._instance) {
				AssetsKeeper._allowInstance = true;
				AssetsKeeper._instance = new AssetsKeeper();
				AssetsKeeper._allowInstance = false;
			}
			
			return AssetsKeeper._instance;
		}
		
		public function AssetsKeeper() {
			if (AssetsKeeper._allowInstance) {
				this._storage = new Dictionary();
			} else {
				throw new Error("Use static AssetsKeeper::instance getter instead");
			}
		}
		
		public function get uniqueKey():String {
			var now:Date = new Date();
			return "AssetsKeeper::" + now.toUTCString() + "::" + Math.random();
		}
		
		public function keep(value:*, key:String = null):String {
			key = key? key : this.uniqueKey;
			
			this._storage[key] = value;
			
			return key;
		}
		
		public function remove(key:String):void {
			this._storage[key] = null;
			delete this._storage[key];
		}
		
		public function removeAll():void {
			this._storage = new Dictionary();
			this._storage = null;
			
			this._storage = new Dictionary();
		}
		
	}

}