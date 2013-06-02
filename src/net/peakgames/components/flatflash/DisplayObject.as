package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class DisplayObject {
		private var _weakHolder:Dictionary;
		
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		private var _width:Number;
		private var _height:Number;
		private var _changed:Boolean;
		
		private var _parent:DisplayObject;
		
		public function DisplayObject(spritesheet:BitmapData = null) {
			this._weakHolder = new Dictionary(true);
			
			this.spritesheet = spritesheet;
		}
		
		public function set x(value:Number):void {
			this._x = value;
			this._changed = true;
		}
		public function get x():Number {
			return this._x;
		}
		
		public function set y(value:Number):void {
			this._y = value;
			this._changed = true;
		}
		public function get y():Number {
			return this._y;
		}
		
		public function set z(value:Number):void {
			this._z = value;
			this._changed = true;
		}
		public function get z():Number {
			return this._z;
		}
		
		public function set width(value:Number):void {
			this._width = value;
			this._changed = true;
		}
		public function get width():Number {
			return this._width;
		}
		
		public function set height(value:Number):void {
			this._height = value;
			this._changed = true;
		}
		public function get height():Number {
			return this._height;
		}
		
		public function get changed():Boolean {
			return this._changed;
		}
		
		public function set parent(value:DisplayObject):void {
			this._parent = value;
		}
		public function get parent():DisplayObject {
			return this._parent;
		}
		
		public function get bitmapData():BitmapData {
			return null;
		}
		
		public function get rectangle():Rectangle {
			return new Rectangle(0, 0, this.width, this.height);
		}
		
		public function get position():Point {
			return new Point(this.x, this.y);
		}
		
		public function hop():void {
			this._changed = false;
		}
		
		protected function get spritesheet():BitmapData {
			for (var spritesheet:Object in this._weakHolder) {
				return spritesheet;
			}
			return null;
		}
		
		protected function set spritesheet(value:BitmapData):void {
			this._weakHolder[value] = 1;
		}
		
	}

}