package org.ranapat.flatflash.examples {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.ranapat.flatflash.DisplayObject;
	import org.ranapat.flatflash.DisplayObjectContainer;
	
	public class Carousel extends DisplayObjectContainer {
		
		private var _items:Vector.<DisplayObject>;
		private var _object:Vector.<CarouselObject>;
		
		private var _visibleItems:uint;
		private var _initialPoint:Point;
		private var _initialSize:Rectangle;
		
		private var angleDelta:uint;
		private var radius:uint;
		private var minAlpha:Number;
		private var minScale:Number;
		private var angleToHide:Number;
		private var constDegreesToRadians:Number;
		
		public function Carousel() {
			this._items = new Vector.<DisplayObject>();

			this._visibleItems = 3;
			this.radius = 80;
			this.minScale = .9;
			this.minAlpha = .9;
			this.angleToHide = 35;
			this.constDegreesToRadians = Math.PI / 180;
		}
		
		public function set items(value:Vector.<DisplayObject>):void {
			this.removeAllChildren();
			
			if (value.length >= this._visibleItems) {
				this._items = value;
				this._object = new Vector.<CarouselObject>();
				
				this.initialize();
			}
		}
		
		public function get items():Vector.<DisplayObject> {
			return this._items;
		}
		
		public function set initialPoint(value:Point):void {
			this._initialPoint = value;
		}
		
		public function set initialSize(value:Rectangle):void {
			this._initialSize = value;
		}
		
		public function offsetAngle(value:int):void {
			var i:uint;
			var length:uint = this._items.length;
			
			for (i = 0; i < length; ++i) {
				var angle:int = this._object[i].angle;
				var newAngle:int = angle != 180? angle + value : 180;
				var itemToActive:int;
				var itemToActiveSet:Boolean;
				var itemToActiveAngleAtTheSet:int;
				
				if (
					angle <= 90 + this.angleToHide && angle >= -90 - this.angleToHide
					&& (newAngle > 90 + this.angleToHide || newAngle < -90 - this.angleToHide)
				) {
					itemToActiveSet = true;
					itemToActiveAngleAtTheSet = angle;
					if (value > 0) {
						itemToActive = i + this.visibleItems;
					} else {
						itemToActive = i - this.visibleItems;
					}
					itemToActive = itemToActive >= length? itemToActive - length : itemToActive < 0? itemToActive + length : itemToActive;
					angle = 180;
				} else if (angle != 180) {
					angle = newAngle;
				}
				
				this._object[i].angle = angle;
			}
			
			if (itemToActiveSet) {
				this._object[itemToActive].angle = itemToActiveAngleAtTheSet > 0? (itemToActiveAngleAtTheSet - this.visibleItems * this.angleDelta) : (itemToActiveAngleAtTheSet + this.visibleItems * this.angleDelta);
			}
			
			this.invalidate();
		}
		
		private function initialize():void {
			var visibleItems:uint = this.visibleItems;
			
			var angleDelta:uint = 180 / (visibleItems - 1);
			var i:uint;
			var length:uint = this._items.length;
			
			for (i = 0; i < length; ++i) {
				this._object[this._object.length] = new CarouselObject(180, this._items[i]);
			}
			
			this._object[0].angle = 0;
			for (i = 1; i <= (visibleItems - 1) / 2; ++i) {
				this._object[i].angle = -1 * angleDelta * i;
				this._object[length - i].angle = 1 * angleDelta * i;
			}
			
			for (i = 0; i < length; ++i) {
				this.addChild(this._items[i]);
			}
			
			this.invalidate();
			
			this.angleDelta = angleDelta;
		}
		
		private function invalidate():void {
			var i:uint;
			var length:uint = this._items.length;
			
			for (i = 0; i < length; ++i) {
				this.offsetByAngle(i);
			}
		}
		
		private function offsetByAngle(index:uint):void {
			var object:DisplayObject = this._items[index];
			if (object.initialized) {
				var angle:int = this._object[index].angle;
				if (angle != 180) {
					var angleRadians:Number = angle * Math.PI / 180;
					var depth:Number = Math.cos(angleRadians);
					
					object.visible = true;
					object.alpha = this.minAlpha + (1 - this.minAlpha) * depth;
					object.depth = object.alpha;
					object.scale = this.minScale + (1 - this.minScale) * depth;
					object.x = this._initialPoint.x - this.radius * Math.sin(angleRadians) - object.width / 2;
					object.y = this._initialPoint.y + (this._initialSize.height - object.height) / 2;
				} else {
					object.visible = false;
				}
			} else {
				object.onInitialize(this, this.handleObjectInitialized, [ index ]);
			}
		}
		
		private function get visibleItems():uint {
			return this._visibleItems;
		}
		
		private function handleObjectInitialized(index:uint):void {
			this.offsetByAngle(index);
		}
	}

}

import org.ranapat.flatflash.DisplayObject;

class CarouselObject {
	public var angle:int;
	public var displayObject:DisplayObject;
	
	public function CarouselObject(angle:int, displayObject:DisplayObject) {
		this.angle = angle;
		this.displayObject = displayObject;
	}
}