package net.peakgames.components.flatflash {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import net.peakgames.components.flatflash.tools.slicers.ISlicer;
	import net.peakgames.components.flatflash.tools.slicers.SlicerFactory;
	
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
		
		public function DisplayObjectContainer(render:uint = 0) {
			this.render = render == Settings.RENDER_TYPE_NOT_SET? Settings.RENDER_TYPE_ENTER_FRAME : render == Settings.RENDER_TYPE_ENTER_FRAME? Settings.RENDER_TYPE_ENTER_FRAME : Settings.RENDER_TYPE_LOOP;
			
			this.children = new Vector.<DisplayObject>();
			
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
			}
		}
		
		public function removeChild(child:DisplayObject):void {
			if (child) {
				var index:uint = this.children.indexOf(child);
				if (index != -1) {
					this.children.splice(index, 1);
					
					child.parent = null;
				}
			}
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
			if (this.stage && this.bitmapData && this.shallRedraw) {
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
					
					if (displayObject.region) {
						if (latestSlicerType != displayObject.region.type) {
							latestSlicerType = displayObject.region.type;
							latestSlicer = SlicerFactory.get(latestSlicerType);
						}
						
						try {
							latestSlicer.copyPixels(
								displayObject.spritesheet, bitmapData,
								displayObject.region, displayObject.position
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
		
		private function handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage, false, 0, true);
			
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
			
			if (this.render == Settings.RENDER_TYPE_ENTER_FRAME) {
				this.removeEventListener(Event.ENTER_FRAME, this.handleEnterFrame);
			}
			
			this.latestSlicer = null;
			this.latestSlicerType = null;
			
			this.bitmapData = null;
			
			clearTimeout(this.loopTimeout);
			this.loopTimeout = 0;
		}
		
		private function handleEnterFrame(e:Event):void {
			this.calculateFPS();
			
			this.redraw();
		}
		
	}

}