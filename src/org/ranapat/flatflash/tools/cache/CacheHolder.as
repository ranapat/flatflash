package org.ranapat.flatflash.tools.cache {
	import flash.utils.Dictionary;
	import org.ranapat.flatflash.DisplayObject;
	
	public class CacheHolder {
		private var dictionary:Dictionary;
		
		public function CacheHolder() {
			this.dictionary = new Dictionary();
		}
		
		public function add(displayObject:DisplayObject, cacheObject:CacheObject):void {
			this.remove(displayObject);
			
			this.dictionary[displayObject] = cacheObject;
		}
		
		public function remove(displayObject:DisplayObject):void {
			var cacheObject:CacheObject = this.dictionary[displayObject];
			if (cacheObject) {
				cacheObject.destroy();
				cacheObject = null;
				
				this.dictionary[displayObject] = null;
				delete this.dictionary[displayObject];
			}
		}
		
		public function get(displayObject:DisplayObject):CacheObject {
			return this.dictionary[displayObject];
		}
		
		public function destroy():void {
			for (var _displayObject:* in this.dictionary) {
				this.remove(_displayObject as DisplayObject);
			}
		}
		
	}

}