package org.ranapat.flatflash {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import org.ranapat.flatflash.tools.cache.CacheHolder;
	import org.ranapat.flatflash.tools.cache.CacheObject;
	import org.ranapat.flatflash.tools.RGBA;
	import org.ranapat.flatflash.tools.slicers.ISlicer;
	import org.ranapat.flatflash.tools.slicers.SlicerFactory;
	
	public class DisplayObjectContainer extends Bitmap {
		private var render:uint;
		
		private var _numChildren:uint;
		private var children:Vector.<DisplayObject>;
		
		private var latestSlicer:ISlicer;
		private var latestSlicerType:String;
		
		private var _mouseEnabled:Boolean;
		private var _fps:int;
		private var _cfps:uint;
		
		private var startTime:int;
		private var frames:uint;
		private var loopTimeout:uint;
		
		private var _width:Number;
		private var _height:Number;
		
		private var __changed:uint;
		private var __mouseListenersSet:Boolean;
		private var __mouseEnabled:Dictionary;
		private var __toReorder:Boolean;
		
		private var _mouseMaskNextColor:RGBA;
		private var _mouseEventsBitmapData:BitmapData;
		
		private var cacheHolder:CacheHolder;
		
		protected var instantSizeChangeRecreate:Boolean;
		
		public function DisplayObjectContainer(render:uint = 0) {
			this.render = render == Settings.RENDER_TYPE_NOT_SET? Settings.RENDER_TYPE_ENTER_FRAME : render == Settings.RENDER_TYPE_ENTER_FRAME? Settings.RENDER_TYPE_ENTER_FRAME : Settings.RENDER_TYPE_LOOP;
			
			this._fps = -1;
			
			this._width = -1;
			this._height = -1;
			
			this.instantSizeChangeRecreate = true;
			
			this.children = new Vector.<DisplayObject>();
			this.__mouseEnabled = new Dictionary(true);
			
			this._mouseMaskNextColor = new RGBA(0, 0, 0, 255);
			
			this.cacheHolder = new CacheHolder();
			
			this.addEventListener(Event.ADDED_TO_STAGE, this._handleAddedToStage, false, 0, true);
		}
		
		public function destroy():void {
			var length:uint = this.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				this.children[i].parent = null;
			}
			
			this.children = new Vector.<DisplayObject>();
			
			this.latestSlicer = null;
			this.latestSlicerType = null;
			
			this.cacheHolder.destroy();
			this.cacheHolder = null;
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this._handleAddedToStage);
		}
		
		public function addChild(child:DisplayObject):DisplayObject {
			if (child) {
				child.depth = child.depth == -1? this.numChildren : child.depth;
				child.parent = this;
				
				this.children[this.numChildren] = child;
				++this._numChildren;
				this.__changed += child.changed? 1 : 0;
				this.__toReorder = true;
				if (child.mouseEnabled && !this.__mouseEnabled[child]) {
					this.__mouseEnabled[child] = new MouseEnabledObject(false, this.mouseMaskNextColor);
				}
			}
			
			return child;
		}
		
		public function removeChild(child:DisplayObject):DisplayObject {
			if (child) {
				var index:uint = this.children.indexOf(child);
				if (index != -1) {
					return this.removeChildAt(index);
				}
			}
			
			return null;
		}
		
		public function removeChildAt(index:uint):DisplayObject {
			if (index >= 0 && index < this.numChildren) {
				var child:DisplayObject = this.children[index];
				
				this.children.splice(index, 1);
				--this._numChildren;
					
				child.parent = null;
				
				this.__mouseEnabled[child] = null;
				delete this.__mouseEnabled[child];
				
				this.cacheHolder.remove(child);
				
				++this.__changed;
				
				return child;
			}
			
			return null;
		}
		
		public function removeAllChildren():Vector.<DisplayObject> {
			var result:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			while (this.numChildren > 0) {
				result[result.length] = this.removeChildAt(0);
			}
			
			return result;
		}
		
		public function swapChildren(childA:DisplayObject, childB:DisplayObject):void {
			if (childA && childB) {
				var tmp:Number = childA.depth;
				childA.depth = childB.depth;
				childB.depth = tmp;
				
				this.reorder();
			}
		}
		
		public function reorder():void {
			this.__toReorder = true;
		}
		
		public function getChildAt(index:uint):DisplayObject {
			return index >= 0 && index < this.numChildren? this.children[index] : null;
		}
		
		public function getChildByName(name:String):DisplayObject {
			var length:uint = this.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				var child:DisplayObject = this.children[i];
				if (child.name == name) {
					return this.getChildAt(i);
				}
			}
			return null;
		}
		
		public function redraw():void {
			if (this.stage && this.bitmapData && this.isChanged) {
				this.__changed = 0;
				
				if (this.__toReorder) {
					this.children = this.reorderedChildren;
					this.__toReorder = false;
				}
				
				var bitmapData:BitmapData = this.bitmapData;
				var mouseEventsBitmapData:BitmapData = this._mouseEventsBitmapData;
				var latestSlicer:ISlicer = this.latestSlicer;
				var latestSlicerType:String = this.latestSlicerType;
				
				bitmapData.lock();
				mouseEventsBitmapData.lock();
				
				bitmapData.fillRect(bitmapData.rect, 0);
				mouseEventsBitmapData.fillRect(mouseEventsBitmapData.rect, 0);
				
				var children:Vector.<DisplayObject> = this.children;
				var length:uint = this.numChildren;
				var displayObject:DisplayObject;
				var mouseEnabledObject:MouseEnabledObject;
				
				var initiallyChanged:Boolean;
				var cacheObject:CacheObject;
				var processFullCopy:Boolean;
				
				for (var i:uint = 0; i < length; ++i) {
					displayObject = children[i];
					initiallyChanged = displayObject.changed;
					displayObject.hop(getTimer() - this.startTime);
					this.__changed += displayObject.visible && displayObject.changed? 1 : 0;
					
					mouseEnabledObject = this.__mouseEnabled[displayObject];
					
					if (displayObject.visible && displayObject.region) {
						if (latestSlicerType != displayObject.region.type) {
							latestSlicerType = displayObject.region.type;
							latestSlicer = SlicerFactory.get(latestSlicerType);
						}
						
						try {
							displayObject.beforeDraw();
							
							processFullCopy = true;
							if (!initiallyChanged) {
								cacheObject = this.cacheHolder.get(displayObject);
								if (cacheObject) {
									processFullCopy = false;
									
									latestSlicer.directCopyPixels(
										cacheObject.sourceBitmapData,
										mouseEnabledObject != null? cacheObject.overExposedBitmapData : null,
										bitmapData,
										mouseEnabledObject != null? mouseEventsBitmapData : null,
										cacheObject.sourceRectangle,
										cacheObject.destinationPoint, cacheObject.overExposedDestinationPoint
									);
								}
							}
							
							if (processFullCopy) {
								this.cacheHolder.add(displayObject, latestSlicer.copyPixels(
									displayObject,
									bitmapData,
									mouseEnabledObject != null? mouseEventsBitmapData : null,
									mouseEnabledObject != null? mouseEnabledObject.rgba : null,
									mouseEnabledObject != null && displayObject.shadowMode? this.cacheHolder.get(displayObject) : null
								));
							}
							
							displayObject.afterDraw();
						} catch (e:Error) {
							//
						}
					}
				}
				
				if (this.latestSlicerType != latestSlicerType) {
					this.latestSlicer = latestSlicer;
					this.latestSlicerType = latestSlicerType;
				}
				
				bitmapData.unlock();
				mouseEventsBitmapData.unlock();
			}
		}
		
		public function get numChildren():uint {
			return this._numChildren;
			//return this.children.length;
		}
		
		public function set mouseEnabled(value:Boolean):void {
			if (this.stage && value && !this.__mouseListenersSet) {
				this.stage.addEventListener(MouseEvent.CLICK, this.handleClick, false, 0, true);
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove, false, 0, true);
				this.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown, false, 0, true);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp, false, 0, true);
				
				this.__mouseListenersSet = true;
			} else if (this.stage && !value && this.__mouseListenersSet) {
				this.stage.removeEventListener(MouseEvent.CLICK, this.handleClick);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
				this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown);
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp);
				
				this.__mouseListenersSet = false;
			}
			
			this._mouseEnabled = value;
		}
		
		public function get mouseEnabled():Boolean {
			return this._mouseEnabled;
		}
		
		public function set fps(value:int):void {
			this._fps = value < 0? 0 : value;
		}
		
		public function get fps():int {
			return this._fps > 0? this._fps : 0;
		}
		
		public function get cfps():uint {
			return this._cfps;
		}
		
		override public function set width(value:Number):void {
			this._width = value;
			
			if (this.instantSizeChangeRecreate) {
				this.recreateBitmapData();
			}
		}
		
		override public function get width():Number {
			return this._width;
		}
		
		override public function set height(value:Number):void {
			this._height = value;
			
			if (this.instantSizeChangeRecreate) {
				this.recreateBitmapData();
			}
		}
		
		override public function get height():Number {
			return this._height;
		}
		
		public function childChanged():void {
			++this.__changed;
		}
		
		public function childMouseEnabledChanged(child:DisplayObject):void {
			if (child.mouseEnabled && !this.__mouseEnabled[child]) {
				if (child.shadowMode) {
					var cacheObject:CacheObject = this.cacheHolder.get(child);
					if (cacheObject) {
						this.__mouseEnabled[child] = new MouseEnabledObject(false, cacheObject.rgba);
					} else {
						this.__mouseEnabled[child] = new MouseEnabledObject(false, this.mouseMaskNextColor);
					}
				} else {
					this.__mouseEnabled[child] = new MouseEnabledObject(false, this.mouseMaskNextColor);
				}
			} else if (!child.mouseEnabled && this.__mouseEnabled[child]) {
				this.__mouseEnabled[child] = null;
				delete this.__mouseEnabled[child];
			}
		}
		
		protected function get isChanged():Boolean {
			return this.__changed > 0;
		}
		
		protected function recreateBitmapData():void {
			if (this._width > 0 && this._height > 0) {
				if (this.bitmapData) {
					this.bitmapData.dispose();
					this.bitmapData = null;
				}
				if (this._mouseEventsBitmapData) {
					this._mouseEventsBitmapData.dispose();
					this._mouseEventsBitmapData = null;
				}
				this.bitmapData = new BitmapData(this._width, this._height, true, 0x0);
				this._mouseEventsBitmapData = new BitmapData(this._width, this._height, true, 0x0);
			}
		}
		
		private function get reorderedChildren():Vector.<DisplayObject> {
			this.children = this.children.sort(this.sortByZ);
			
			return this.children;
		}
		
		private function get mouseMaskNextColor():RGBA {
			var mouseEnabled:Dictionary = this.__mouseEnabled;
			var _child:Object;
			var unique:Boolean;
			do {
				this.updateNextMouseMaskNextColor();
				unique = true;
				for (_child in mouseEnabled) {
					if ((mouseEnabled[_child] as MouseEnabledObject).rgba.equals(this._mouseMaskNextColor)) {
						unique = false;
						break;
					}
				}
			} while (!unique);
			
			return this._mouseMaskNextColor.clone();
		}
		
		private function sortByZ(objA:DisplayObject, objB:DisplayObject):int {
			if (objA && !objB) {
				return 1;
			} else if (!objA && objB) {
				return -1;
			} else if (!objA && !objB) {
				return 1;
			} else if (objA.depth > objB.depth) {
				return 1;
			} else if (objA.depth < objB.depth) {
				return -1;
			} else {
				return 1;
			}
		}
		
		private function loop():void {
			this.calculateFPS();
			
			this.loopTimeout = setTimeout(this.loop, 1000 / this.fps);
			
			this.redraw();
		}
		
		private function initFPSCounter():void {
			this.startTime = getTimer();
			this.frames = 1;
			this._cfps = this.fps;
		}
		
		private function calculateFPS():void {
			if ((getTimer() - this.startTime) / 1000 > 1) {
				this._cfps = this.frames;
				this.startTime = getTimer();
				this.frames = 1;
			} else {
				++this.frames;
			}
		}
		
		private function loopChildrenForMouseEvent(e:MouseEvent):void {
			var stagePoint:Point = new Point(e.stageX, e.stageY);
			var point:Point = this.globalToLocal(stagePoint);
			
			var pixel:uint = this._mouseEventsBitmapData.getPixel(point.x, point.y);
			var mouseEnabled:Dictionary = this.__mouseEnabled;
			var _child:Object;
			var child:DisplayObject;
			var mouseEnabledObject:MouseEnabledObject;
			var tasksTodo:uint;
			for (_child in mouseEnabled) {
				child = _child as DisplayObject;
				mouseEnabledObject = mouseEnabled[child];
				if (pixel == mouseEnabledObject.rgba.rgb) {
					if (!mouseEnabledObject.hovered) {
						mouseEnabledObject.hovered = true;
						child.mouseEvent(new MouseEvent(
							MouseEvent.MOUSE_OVER,
							e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta
						));
						
					}
					child.mouseEvent(e);
						
					++tasksTodo;
				} else if (mouseEnabledObject.hovered) {
					mouseEnabledObject.hovered = false;
					child.mouseEvent(new MouseEvent(
						MouseEvent.MOUSE_OUT,
						e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta
					));
					++tasksTodo;
				}
				if (tasksTodo >= 2) {
					break;
				}
			}
		}
		
		private function updateNextMouseMaskNextColor():void {
			this._mouseMaskNextColor.r += 1;
			if (this._mouseMaskNextColor.r > 255) {
				this._mouseMaskNextColor.r = 0;
				this._mouseMaskNextColor.g += 1;
				if (this._mouseMaskNextColor.g > 255) {
					this._mouseMaskNextColor.g = 0;
					this._mouseMaskNextColor.b += 1;
					if (this._mouseMaskNextColor.b > 255) {
						this._mouseMaskNextColor.b = 0;
					}
				}
			}
		}
		
		private function handleClick(e:MouseEvent):void {
			this.loopChildrenForMouseEvent(e);
		}
		
		private function handleMouseMove(e:MouseEvent):void {
			this.loopChildrenForMouseEvent(e);
		}
		
		private function handleMouseDown(e:MouseEvent):void {
			this.loopChildrenForMouseEvent(e);
		}
		
		private function handleMouseUp(e:MouseEvent):void {
			this.loopChildrenForMouseEvent(e);
		}
		
		private function handleEnterFrame(e:Event):void {
			this.calculateFPS();
			
			this.redraw();
		}
		
		private function _handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this._handleAddedToStage);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, this._handleRemovedFromStage, false, 0, true);
			
			this.mouseEnabled = this.mouseEnabled;
			this._fps = this._fps == -1? this.stage.frameRate : this._fps;
			
			this.initFPSCounter();
			
			if (this.render == Settings.RENDER_TYPE_ENTER_FRAME) {
				this.addEventListener(Event.ENTER_FRAME, this.handleEnterFrame, false, 0, true);
			} else if (this.render == Settings.RENDER_TYPE_LOOP) {
				this.loopTimeout = setTimeout(this.loop, 1000 / this.fps);
			}
			
			this._width = this._width == -1? this.stage.stageWidth : this._width;
			this._height = this._height == -1? this.stage.stageHeight : this._height;
			this.recreateBitmapData();
			
			this.handleAddedToStage();
		}
		
		private function _handleRemovedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this._handleRemovedFromStage);
			
			this.addEventListener(Event.ADDED_TO_STAGE, this._handleAddedToStage, false, 0, true);
			
			this.mouseEnabled = false;
			
			if (this.render == Settings.RENDER_TYPE_ENTER_FRAME) {
				this.removeEventListener(Event.ENTER_FRAME, this.handleEnterFrame);
			}
			
			this.latestSlicer = null;
			this.latestSlicerType = null;
			
			this.bitmapData.dispose();
			this.bitmapData = null;
			
			this._mouseEventsBitmapData.dispose();
			this._mouseEventsBitmapData = null;
			
			clearTimeout(this.loopTimeout);
			this.loopTimeout = 0;
			
			this.handleRemovedFromStage();
		}
		
		protected function handleAddedToStage():void {
			//
		}
		
		protected function handleRemovedFromStage():void {
			//
		}
	}

}
import org.ranapat.flatflash.tools.RGBA;

class MouseEnabledObject {
	public var hovered:Boolean;
	public var rgba:RGBA;
	
	public function MouseEnabledObject(hovered:Boolean, rgba:RGBA) {
		this.hovered = hovered
		this.rgba = rgba;
	}
}