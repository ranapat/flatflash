package org.ranapat.flatflash {
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.ranapat.flatflash.tools.slicers.ISlicer;
	import org.ranapat.flatflash.tools.slicers.SlicerFactory;
	
	public class DisplayObjectContainer extends Bitmap {
		private var render:uint;
		
		private var _numChildren:uint;
		private var children:Vector.<DisplayObject>;
		
		private var latestSlicer:ISlicer;
		private var latestSlicerType:String;
		
		private var _fps:int;
		private var _cfps:uint;
		
		private var startTime:int;
		private var frames:uint;
		private var loopTimeout:uint;
		
		private var _width:Number;
		private var _height:Number;
		
		private var __changed:uint;
		private var __mouseEnabled:Dictionary;
		private var __toReorder:Boolean;
		
		protected var instantSizeChangeRecreate:Boolean;
		
		public function DisplayObjectContainer(render:uint = 0) {
			this.render = render == Settings.RENDER_TYPE_NOT_SET? Settings.RENDER_TYPE_ENTER_FRAME : render == Settings.RENDER_TYPE_ENTER_FRAME? Settings.RENDER_TYPE_ENTER_FRAME : Settings.RENDER_TYPE_LOOP;
			
			this._fps = -1;
			
			this._width = -1;
			this._height = -1;
			
			this.instantSizeChangeRecreate = true;
			
			this.children = new Vector.<DisplayObject>();
			this.__mouseEnabled = new Dictionary(true);
			
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
					this.__mouseEnabled[child] = new MouseEnabledObject(false);
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
				var latestSlicer:ISlicer = this.latestSlicer;
				var latestSlicerType:String = this.latestSlicerType;
				
				bitmapData.lock();
				
				bitmapData.fillRect(bitmapData.rect, 0);
				
				var children:Vector.<DisplayObject> = this.children;
				var length:uint = this.numChildren;
				var displayObject:DisplayObject;
				for (var i:uint = 0; i < length; ++i) {
					displayObject = children[i];
					displayObject.hop(getTimer() - this.startTime);
					this.__changed += displayObject.visible && displayObject.changed? 1 : 0;
					
					if (displayObject.visible && displayObject.region) {
						if (latestSlicerType != displayObject.region.type) {
							latestSlicerType = displayObject.region.type;
							latestSlicer = SlicerFactory.get(latestSlicerType);
						}
						
						try {
							displayObject.beforeDraw();
							latestSlicer.copyPixels(
								displayObject.spritesheet, bitmapData,
								displayObject.region, displayObject.position,
								displayObject.alpha,
								displayObject.scaleX, displayObject.scaleY,
								displayObject.smoothing,
								displayObject.filtersVector
							);
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
			}
		}
		
		public function get numChildren():uint {
			return this._numChildren;
			//return this.children.length;
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
				this.__mouseEnabled[child] = new MouseEnabledObject(false);
			} else {
				this.__mouseEnabled[child] = null;
				delete this.__mouseEnabled[child];
			}
		}
		
		protected function get isChanged():Boolean {
			return this.__changed > 0;
		}
		
		protected function recreateBitmapData():void {
			this.bitmapData = new BitmapData(this._width, this._height, true, 0);
		}
		
		private function get reorderedChildren():Vector.<DisplayObject> {
			this.children = this.children.sort(this.sortByZ);
			
			return this.children;
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
			if ((getTimer() - startTime) / 1000 > 1) {
				this._cfps = this.frames;
				this.startTime = getTimer();
				this.frames = 1;
			} else {
				++this.frames;
			}
		}
		
		private function loopChildrenForMouseEvent(x:Number, y:Number, e:MouseEvent):void {
			e.localX = x;
			e.localY = y;
			
			var child:DisplayObject;
			for (var _child:Object in this.__mouseEnabled) {
				child = DisplayObject(_child);
				if (child) {
					var mouseEnabledObject:MouseEnabledObject = this.__mouseEnabled[child];
					var hoveredBefore:Boolean = mouseEnabledObject.hovered;
					var hoveredAfter:Boolean = false;
					
					if (
						x >= child.x
						&& y >= child.y
						&& x <= child.x + child.width
						&& y <= child.y + child.height
					) {
						if (!hoveredBefore) {
							child.mouseEvent(new MouseEvent(
								MouseEvent.MOUSE_OVER,
								e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta
							));
						}
						
						child.mouseEvent(e);
						
						hoveredAfter = true;
					} else if (hoveredBefore) {
						hoveredAfter = false;
					}
					
					if (hoveredBefore && !hoveredAfter) {
						child.mouseEvent(new MouseEvent(
							MouseEvent.MOUSE_OUT,
							e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta
						));
					}
					
					this.__mouseEnabled[child].hovered = hoveredAfter;
				}
				
			}
		}
		
		private function handleClick(e:MouseEvent):void {
			var point:Point = this.globalToLocal(new Point(e.currentTarget.mouseX, e.currentTarget.mouseY));
			this.loopChildrenForMouseEvent(point.x, point.y, e);
		}
		
		private function handleMouseMove(e:MouseEvent):void {
			var point:Point = this.globalToLocal(new Point(e.currentTarget.mouseX, e.currentTarget.mouseY));
			this.loopChildrenForMouseEvent(point.x, point.y, e);
		}
		
		private function handleMouseDown(e:MouseEvent):void {
			var point:Point = this.globalToLocal(new Point(e.currentTarget.mouseX, e.currentTarget.mouseY));
			this.loopChildrenForMouseEvent(point.x, point.y, e);
		}
		
		private function handleMouseUp(e:MouseEvent):void {
			var point:Point = this.globalToLocal(new Point(e.currentTarget.mouseX, e.currentTarget.mouseY));
			this.loopChildrenForMouseEvent(point.x, point.y, e);
		}
		
		private function handleEnterFrame(e:Event):void {
			this.calculateFPS();
			
			this.redraw();
		}
		
		private function _handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this._handleAddedToStage);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, this._handleRemovedFromStage, false, 0, true);
			
			this.stage.addEventListener(MouseEvent.CLICK, this.handleClick, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp, false, 0, true);
			
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
			
			this.stage.removeEventListener(MouseEvent.CLICK, this.handleClick);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
			this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp);
			
			if (this.render == Settings.RENDER_TYPE_ENTER_FRAME) {
				this.removeEventListener(Event.ENTER_FRAME, this.handleEnterFrame);
			}
			
			this.latestSlicer = null;
			this.latestSlicerType = null;
			
			this.bitmapData.dispose();
			this.bitmapData = null;
			
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

class MouseEnabledObject {
	public var hovered:Boolean;
	
	public function MouseEnabledObject(hovered:Boolean) {
		this.hovered = hovered
	}
}