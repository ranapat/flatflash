package org.ranapat.flatflash {
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
		
		private var children:Vector.<DisplayObject>;
		
		private var latestSlicer:ISlicer;
		private var latestSlicerType:String;
		
		private var _fps:uint;
		private var _cfps:uint;
		
		private var startTime:int;
		private var frames:uint;
		private var loopTimeout:uint;
		
		private var __changed:uint;
		private var __mouseEnabled:Dictionary;
		
		public function DisplayObjectContainer(render:uint = 0) {
			this.render = render == Settings.RENDER_TYPE_NOT_SET? Settings.RENDER_TYPE_ENTER_FRAME : render == Settings.RENDER_TYPE_ENTER_FRAME? Settings.RENDER_TYPE_ENTER_FRAME : Settings.RENDER_TYPE_LOOP;
			
			this.children = new Vector.<DisplayObject>();
			this.__mouseEnabled = new Dictionary(true);
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage, false, 0, true);
		}
		
		public function destroy():void {
			var length:uint = this.children.length;
			for (var i:uint = 0; i < length; ++i) {
				this.children[i].parent = null;
			}
			
			this.children = new Vector.<DisplayObject>();
			
			this.latestSlicer = null;
			this.latestSlicerType = null;
		}
		
		public function addChild(child:DisplayObject):void {
			if (child) {
				child.x = isNaN(child.x)? 0 : child.x;
				child.y = isNaN(child.y)? 0 : child.y;
				child.depth = this.children.length;
				child.parent = this;
				
				this.children[this.children.length] = child;
				this.__changed += child.changed? 1 : 0;
				if (child.mouseEnabled) {
					this.__mouseEnabled[child] = 1;
				}
			}
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
					
				child.parent = null;
				
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
			this.children = this.reorderedChildren;
		}
		
		public function getChildAt(index:uint):DisplayObject {
			return index >= 0 && index < this.children.length? this.children[index] : null;
		}
		
		public function getChildByName(name:String):DisplayObject {
			var length:uint = this.children.length;
			for (var i:uint = 0; i < length; ++i) {
				var child:DisplayObject = this.children[i];
				if (child.name == name) {
					return this.getChildAt(i);
				}
			}
			return null;
		}
		
		public function redraw():void {
			if (this.stage && this.bitmapData && this.__changed > 0) {
				this.__changed = 0;
				
				var bitmapData:BitmapData = this.bitmapData;
				var latestSlicer:ISlicer = this.latestSlicer;
				var latestSlicerType:String = this.latestSlicerType;
				
				bitmapData.lock();
				
				bitmapData.fillRect(bitmapData.rect, 0);
				
				var children:Vector.<DisplayObject> = this.children;
				var length:uint = this.children.length;
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
							latestSlicer.copyPixels(
								displayObject.spritesheet, bitmapData,
								displayObject.region, displayObject.position,
								displayObject.alpha,
								displayObject.scaleX, displayObject.scaleY,
								displayObject.smoothing
							);
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
			return this.children.length;
		}
		
		public function set fps(value:uint):void {
			this._fps = value;
		}
		
		public function get fps():uint {
			return this._fps;
		}
		
		public function get cfps():uint {
			return this._cfps;
		}
		
		public function childChanged():void {
			++this.__changed;
		}
		
		public function childMouseEnabledChanged(child:DisplayObject):void {
			if (child.mouseEnabled) {
				this.__mouseEnabled[child] = 1;
			} else {
				delete this.__mouseEnabled[child];
			}
		}
		
		private function get reorderedChildren():Vector.<DisplayObject> {
			this.children = this.children.sort(this.sortByZ);
			
			return this.children;
		}
		
		private function sortByZ(objA:DisplayObject, objB:DisplayObject):int {
			if (objA.depth > objB.depth) {
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
				if (
					child
					&& x >= child.x
					&& y >= child.y
					&& x <= child.x + child.width
					&& y <= child.y + child.height
				) {
					child.mouseEvent(e);
				}
				
			}
		}
		
		private function handleClick(e:MouseEvent):void {
			var x:Number = e.stageX - this.x;
			var y:Number = e.stageY - this.y;
			
			this.loopChildrenForMouseEvent(x, y, e);
		}
		
		private function handleMouseMove(e:MouseEvent):void {
			var x:Number = e.stageX - this.x;
			var y:Number = e.stageY - this.y;
			
			this.loopChildrenForMouseEvent(x, y, e);
		}
		
		private function handleMouseDown(e:MouseEvent):void {
			var x:Number = e.stageX - this.x;
			var y:Number = e.stageY - this.y;
			
			this.loopChildrenForMouseEvent(x, y, e);
		}
		
		private function handleMouseUp(e:MouseEvent):void {
			var x:Number = e.stageX - this.x;
			var y:Number = e.stageY - this.y;
			
			this.loopChildrenForMouseEvent(x, y, e);
		}
		
		private function handleEnterFrame(e:Event):void {
			this.calculateFPS();
			
			this.redraw();
		}
		
		private function handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage, false, 0, true);
			
			this.stage.addEventListener(MouseEvent.CLICK, this.handleClick, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp, false, 0, true);
			
			this.fps = this.stage.frameRate;
			
			this.initFPSCounter();
			
			if (this.render == Settings.RENDER_TYPE_ENTER_FRAME) {
				this.addEventListener(Event.ENTER_FRAME, this.handleEnterFrame, false, 0, true);
			} else if (this.render == Settings.RENDER_TYPE_LOOP) {
				this.loopTimeout = setTimeout(this.loop, 1000 / this.fps);
			}
			
			this.bitmapData = new BitmapData(this.stage.stageWidth, this.stage.stageHeight, true, 0);
		}
		
		private function handleRemovedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage);
			
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
		}
	}

}