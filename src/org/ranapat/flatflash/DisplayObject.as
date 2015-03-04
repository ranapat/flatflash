package org.ranapat.flatflash {
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public class DisplayObject {
		private var _x:Number;
		private var _y:Number;
		private var _anchorX:Number;
		private var _anchorY:Number;
		private var _depth:Number;
		private var _width:Number;
		private var _height:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _scale:Number;
		private var _rotation:Number;
		private var _alpha:Number;
		private var _smoothing:Boolean;
		private var _visible:Boolean;
		private var _filters:Vector.<BitmapFilter>;
		
		private var _initialized:Boolean;
		private var _initializedCallbackHolder:Dictionary;
		
		private var _mouseEventCallbackHolder:Dictionary;
		
		private var _beforeDrawCallbackHolder:Dictionary;
		private var _afterDrawCallbackHolder:Dictionary;
		
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
			this._beforeDrawCallbackHolder = new Dictionary(true);
			this._afterDrawCallbackHolder = new Dictionary(true);
			
			this.anchorX = 0;
			this.anchorY = 0;
			this.x = 0;
			this.y = 0;
			this.width = 0;
			this.height = 0;
			this.depth = -1;
			this.scaleX = 1;
			this.scaleY = 1;
			this.rotation = 0;
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
		
		public function set anchorX(value:Number):void {
			this._anchorX = value;
		}
		
		public function get anchorX():Number {
			return this._anchorX;
		}
		
		public function set anchorY(value:Number):void {
			this._anchorY = value;
		}
		
		public function get anchorY():Number {
			return this._anchorY;
		}
		
		public function get x():Number {
			return this._x - this._anchorX;
		}
		
		public function set y(value:Number):void {
			this._y = value;
			
			this.markChanged();
		}
		
		public function get y():Number {
			return this._y - this._anchorY;
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
			return this._width;
		}
		
		public function get drawnWidth():Number {
			return this._width * this._scaleX;
		}
		
		public function set height(value:Number):void {
			this._height = value;
			
			this.markChanged();
		}
		
		public function get height():Number {
			return this._height;
		}
		
		public function get drawnHeight():Number {
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
		
		public function set rotation(value:Number):void {
			this._rotation = value;
			
			this.markChanged();
		}
		
		public function get rotation():Number {
			return this._rotation;
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
		
		public function set filters(value:Array):void {
			var length:uint = value.length;
			this._filters = new Vector.<BitmapFilter>();
			
			for (var i:uint = 0; i < length; ++i) {
				if (value[i] is BitmapFilter) {
					this._filters[this._filters.length] = value[i];
				}
			}
		}
		
		public function get filters():Array {
			var result:Array = [];
			var length:uint = this._filters.length;
			
			for (var i:uint = 0; i < length; ++i) {
				result[result.length] = this._filters[i];
			}
			
			return result;
		}
		
		public function get filtersVector():Vector.<BitmapFilter> {
			return this._filters;
		}
		
		public function hop(timer:int):void {
			this._changed = false;
		}
		
		public function beforeDraw():void {
			this.walkCallbackHolder(this._beforeDrawCallbackHolder);
		}
		
		public function afterDraw():void {
			this.walkCallbackHolder(this._afterDrawCallbackHolder);
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
			this.addToCallbackHolder(this._initializedCallbackHolder, object, callback, parameters);
		}
		
		public function onInitializeRemove(object:Object, callback:Function = null):void {
			this.removeFromCallbackHolder(this._initializedCallbackHolder, object, callback);
		}
		
		public function onMouseEvent(object:Object, callback:Function, parameters:Array = null):void {
			this.addToCallbackHolder(this._mouseEventCallbackHolder, object, callback, parameters);
		}
		
		public function onMouseEventRemove(object:Object, callback:Function = null):void {
			this.removeFromCallbackHolder(this._mouseEventCallbackHolder, object, callback);
		}
		
		public function onBeforeDraw(object:Object, callback:Function, parameters:Array = null):void {
			this.addToCallbackHolder(this._beforeDrawCallbackHolder, object, callback, parameters);
		}
		
		public function onBeforeDrawRemove(object:Object, callback:Function = null):void {
			this.removeFromCallbackHolder(this._beforeDrawCallbackHolder, object, callback);
		}
		
		public function onAfterDraw(object:Object, callback:Function, parameters:Array = null):void {
			this.addToCallbackHolder(this._afterDrawCallbackHolder, object, callback, parameters);
		}
		
		public function onAfterDrawRemove(object:Object, callback:Function = null):void {
			this.removeFromCallbackHolder(this._afterDrawCallbackHolder, object, callback);
		}
		
		protected function addToCallbackHolder(callbackHolder:Dictionary, object:Object, callback:Function, parameters:Array):void {
			if (callbackHolder[object] == null) {
				callbackHolder[object] = new Vector.<CallbackObject>();
			}
			(callbackHolder[object] as Vector.<CallbackObject>).push(new CallbackObject(
				callback, parameters
			));
		}
		
		protected function removeFromCallbackHolder(callbackHolder:Dictionary, object:Object, callback:Function):void {
			if (callbackHolder[object]) {
				if (callback == null) {
					callbackHolder[object] = null;
					delete callbackHolder[object];
				} else {
					var vector:Vector.<CallbackObject> = callbackHolder[object];
					var length:uint = vector.length;
					for (var i:uint = 0; i < length; ++i) {
						var callbackObject:CallbackObject = vector[i];
						if (callbackObject.callback == callback) {
							vector.splice(i, 1);
							break;
						}
					}
				}
			}
		}
		
		protected function walkCallbackHolder(callbackHolder:Dictionary, extraParameters:Array = null):void {
			for (var object:Object in callbackHolder) {
				var vector:Vector.<CallbackObject> = callbackHolder[object];
				if (vector) {
					var length:uint = vector.length;
					for (var i:uint = 0; i < length; ++i) {
						var callbackObject:CallbackObject = vector[i];
						callbackObject.callback.apply(null, extraParameters? callbackObject.parameters.concat(extraParameters) : callbackObject.parameters);
					}
				}
			}
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

			this.walkCallbackHolder(this._initializedCallbackHolder);
		}
		
		protected function handleMouseEvent(e:MouseEvent):void {
			this.walkCallbackHolder(this._mouseEventCallbackHolder, [ e ]);
		}
		
		protected function handleAddedToContainer():void {
			//
		}
		
		protected function handleRemovedFromContainer():void {
			//
		}
	}

}

class CallbackObject {
	public var callback:Function;
	public var parameters:Array;
	
	public function CallbackObject(callback:Function, parameters:Array) {
		this.callback = callback;
		this.parameters = parameters? parameters : [];
	}
}