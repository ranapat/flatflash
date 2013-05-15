package net.peakgames.components.flatflash {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	public class DisplayObjectContainer extends Bitmap {
		private var children:Vector.<DisplayObject>;
		
		public var backgroundColor:uint;
		
		public function DisplayObjectContainer() {
			this.children = new Vector.<DisplayObject>();
		}
		
		public function destroy():void {
			this.children = new Vector.<DisplayObject>();
			this.children = null;
		}
		
		public function redraw():void {
			if (this.stage && this.shallRedraw) {
				var bitmapData:BitmapData = this.bitmapData;
				
				bitmapData.fillRect(new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight), this.backgroundColor);
				
				var children:Vector.<DisplayObject> = this.reorderedChildren();
				var length:uint = this.children.length;
				var displayObject:DisplayObject;
				for (var i:uint = 0; i < length; ++i) {
					displayObject = children[i];
					displayObject.hop();
					
					bitmapData.copyPixels(displayObject.bitmapData, displayObject.rectangle, displayObject.position, null, null, true);
				}
			}
		}
		
		private function get shallRedraw():Boolean {
			var result:Boolean;
			
			var length:uint = this.children.length;
			for (var i:uint = 0; i < length; ++i) {
				if (this.children[i].changed) {
					result = true;
					break;
				}
			}
			
			return result;
		}
		
		private function reorderedChildren():void {
			this.children = this.children.sort(this.sortByZ);
		}
		
		private function sortByZ(objA:DisplayObject, objB:DisplayObject):uint {
			if (objA.z > objB.z) {
				return 1;
			} else if (objA.z < objB.z) {
				return -1;
			} else {
				return 1;
			}
		}
		
	}

}