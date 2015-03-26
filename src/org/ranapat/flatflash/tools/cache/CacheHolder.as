package org.ranapat.flatflash.tools.cache {
	import flash.utils.Dictionary;
	import org.ranapat.flatflash.DisplayObject;
	
	public class CacheHolder {
		private var dictionary:Dictionary;
		
		public function CacheHolder() {
			this.dictionary = new Dictionary();
		}
		
		public function add(displayObject:DisplayObject, cacheObject:CacheObject):void {
			if (displayObject.shadowMode && this.dictionary[displayObject]) {
				var _cacheObject:CacheObject = this.dictionary[displayObject] as CacheObject;
				if (_cacheObject.sourceBitmapData) {
					_cacheObject.sourceBitmapData.dispose();
					_cacheObject.sourceBitmapData = null;
				}
				_cacheObject.sourceRectangle = null;
				_cacheObject.destinationPoint = null;
				
				if (cacheObject.overExposedBitmapData) {
					cacheObject.overExposedBitmapData.dispose();
					cacheObject.overExposedBitmapData = null;
				}
				cacheObject.overExposedDestinationPoint = null;
				cacheObject.rgba = null;
				
				_cacheObject.sourceBitmapData = cacheObject.sourceBitmapData;
				_cacheObject.sourceRectangle = cacheObject.sourceRectangle;
				_cacheObject.destinationPoint = cacheObject.destinationPoint;
			} else {
				this.remove(displayObject);
				
				this.dictionary[displayObject] = cacheObject;
			}
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