package org.ranapat.flatflash {
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public class DisplayObject {
		private var _x:Number;
		private var _y:Number;
		private var _depth:Number;
		private var _width:Number;
		private var _height:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _scale:Number;
		private var _alpha:Number;
		private var _smoothing:Boolean;
		private var _visible:Boolean;
		
		private var _initialized:Boolean;
		private var _initializedCallbackHolder:Dictionary;
		private var _initializedCallbackParameters:Array;
		
		private var _mouseEventCallbackHolder:Dictionary;
		
		private var _mouseEnabled:Boolean;
		
		private var _name:String;
		
		private var _changed:Boolean;
		
		private var _parent:DisplayObjectContainer;
		private var _weakHolder:Dictionary;
		private var _strongHolder:BitmapData;
		
		public function DisplayObject(...args) {
			this._weakHolder = new Dictionary(true);
			this._strongHolder = null;
			
			this._initializedCallbackHolder = new Dictionary(true);
			this._mouseEventCallbackHolder = new Dictionary(true);
			
			this.scaleX = 1;
			this.scaleY = 1;
			this.scale = 1;
			this.alpha = 1;
			this.visible = true;
			this.smoothing = true;
			
			this.initialize.apply(this, args);
			
			this.markChanged();
		}
		
		public function initialize(...args):void {
			if (args.length == 1 && args[0] is BitmapData) {
				this._weakHolder[args[0]] = 1;
				
				this.handleInitialized();
			}
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
			
			if (this.parent) {
				this.parent.reorder();
			}
			
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
			return this._width * this._scaleX;
		}
		
		public function set height(value:Number):void {
			this._height = value;
			
			this.markChanged();
		}
		
		public function get height():Number {
			return this._height * this._scaleY;
		}
		
		public function set scaleX(value:Number):void {
			this._scaleX = value < 0? 0 : value;
			
			this.markChanged();
		}
		
		public function get scaleX():Number {
			return this._scaleX;
		}
		
		public function set scaleY(value:Number):void {
			this._scaleY = value < 0? 0 : value;
			
			this.markChanged();
		}
		
		public function get scaleY():Number {
			return this._scaleY;
		}
		
		public function set scale(value:Number):void {
			this.scaleX = value;
			this.scaleY = value;
			this._scale = value;
		}
		
		public function get scale():Number {
			return this._scale;
		}
		
		public function set alpha(value:Number):void {
			this._alpha = value < 0? 0 : value > 1? 1 : value;
			
			this.markChanged();
		}
		
		public function get alpha():Number {
			return this._alpha;
		}
		
		public function set smoothing(value:Boolean):void {
			this._smoothing = value;
		}
		
		public function get smoothing():Boolean {
			return this._smoothing;
		}
		
		public function set visible(value:Boolean):void {
			this._visible = value;
			
			this.markChanged();
		}
		
		public function get visible():Boolean {
			return this._visible;
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
			
			if (value) {
				this.handleAddedToContainer();
			} else {
				this.handleRemovedFromContainer();
			}
		}
		
		public function get parent():DisplayObjectContainer {
			return this._parent;
		}
		
		public function set mouseEnabled(value:Boolean):void {
			this._mouseEnabled = value;
			if (this.parent) {
				this.parent.childMouseEnabledChanged(this);
			}
		}
		
		public function get mouseEnabled():Boolean {
			return this._mouseEnabled;
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
		
		public function hop(timer:int):void {
			this._changed = false;
		}
		
		public function get spritesheet():BitmapData {
			for (var spritesheet:* in this._weakHolder) {
				return BitmapData(spritesheet);
			}
			return null;
		}
		
		public function get region():Region {
			return null;
		}
		
		public function get initialized():Boolean {
			return this._initialized;
		}
		
		public function set keepSpritesheet(value:Boolean):void {
			this._strongHolder = value? this.spritesheet : null;
		}
		
		public function mouseEvent(value:MouseEvent):void {
			this.handleMouseEvent(value);
		}
		
		public function onInitialize(object:Object, callback:Function, parameters:Array = null):void {
			this._initializedCallbackHolder[object] = callback;
			this._initializedCallbackParameters = parameters;
		}
		
		public function onMouseEvent(object:Object, callback:Function):void {
			this._mouseEventCallbackHolder[object] = callback;
		}
		
		private function get onInitializeCallback():Function {
			for (var i:* in this._initializedCallbackHolder) {
				if (this._initializedCallbackHolder[i] is Function) {
					return this._initializedCallbackHolder[i] as Function;
				}
			}
			
			return null;
		}
		
		private function get onMouseEventCallback():Function {
			for (var i:* in this._mouseEventCallbackHolder) {
				if (this._mouseEventCallbackHolder[i] is Function) {
					return this._mouseEventCallbackHolder[i] as Function;
				}
			}
			
			return null;
		}

		protected function markChanged():void {
			var previousChanged:Boolean = this.changed;
			this._changed = true;
			
			if (!previousChanged && this.visible && this.parent) {
				this.parent.childChanged();
			}
		}
		
		protected function handleInitialized():void {
			this._initialized = true;
			
			if (this.onInitializeCallback != null) {
				this.onInitializeCallback.apply(null, this._initializedCallbackParameters);
			}
		}
		
		protected function handleMouseEvent(e:MouseEvent):void {
			if (this.onMouseEventCallback != null) {
				this.onMouseEventCallback.apply(null, [ e ]);
			}
		}
		
		protected function handleAddedToContainer():void {
			//
		}
		
		protected function handleRemovedFromContainer():void {
			//
		}
	}

}