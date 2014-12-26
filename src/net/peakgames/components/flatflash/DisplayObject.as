package net.peakgames.components.flatflash {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import net.peakgames.components.flatflash.tools.Tools;
	import net.peakgames.components.flatflash.tools.regions.Region;
	
	public class DisplayObject {
		private var _x:Number;
		private var _y:Number;
		private var _depth:Number;
		private var _width:Number;
		private var _height:Number;
		private var _name:String;
		private var _changed:Boolean;
		
		private var _parent:DisplayObjectContainer;
		private var _weakHolder:Dictionary;
		private var _strongHolder:BitmapData;
		
		public function DisplayObject(spritesheet:BitmapData = null) {
			Tools.ensureAbstractClass(this, DisplayObject);
			
			this._weakHolder = new Dictionary(true);
			this._weakHolder[spritesheet] = 1;
			
			this._strongHolder = null;
			
			this.markChanged();
		}
		
		public function set x(value:Number):void {
			this._x = value;
			
			this.markChanged();
		}
		public function get x():Number {
			return this._x;
		}
		
		public function set y(value:Number):void {
			this._y = value;
			
			this.markChanged();
		}
		public function get y():Number {
			return this._y;
		}
		
		public function set depth(value:Number):void {
			this._depth = value;
			
			this.markChanged();
		}
		public function get depth():Number {
			return this._depth;
		}
		
		public function set width(value:Number):void {
			this._width = value;
			
			this.markChanged();
		}
		public function get width():Number {
			return this._width;
		}
		
		public function set height(value:Number):void {
			this._height = value;
			
			this.markChanged();
		}
		public function get height():Number {
			return this._height;
		}
		
		public function set name(value:String):void {
			this._name = value;
		}
		
		public function get name():String {
			return this._name;
		}
		
		public function get changed():Boolean {
			return this._changed;
		}
		
		public function set parent(value:DisplayObjectContainer):void {
			this._parent = value;
		}
		
		public function get parent():DisplayObjectContainer {
			return this._parent;
		}
		
		public function get bitmapData():BitmapData {
			return null;
		}
		
		public function get rectangle():Rectangle {
			return new Rectangle(this.x, this.y, this.width, this.height);
		}
		
		public function get position():Point {
			return new Point(this.x, this.y);
		}
		
		public function hop():void {
			this._changed = false;
		}
		
		public function get spritesheet():BitmapData {
			for (var spritesheet:Object in this._weakHolder) {
				return BitmapData(spritesheet);
			}
			return null;
		}
		
		public function get spritesheetRegion():Region {
			return null;
		}
		
		public function set keepSpritesheet(value:Boolean):void {
			this._strongHolder = value? this.spritesheet : null;
		}
		
		protected function markChanged():void {
			this._changed = true;
		}
	}

}