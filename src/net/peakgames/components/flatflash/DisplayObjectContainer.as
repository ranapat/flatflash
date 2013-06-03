package net.peakgames.components.flatflash {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import net.peakgames.components.flatflash.tools.slicers.ISlicer;
	import net.peakgames.components.flatflash.tools.slicers.SlicerFactory;
	public class DisplayObjectContainer extends Bitmap {
		private var children:Vector.<DisplayObject>;
		
		private var latestSpritesheet:BitmapData;
		private var latestSpritesheetId:String;
		private var latestSlicer:ISlicer;
		private var latestSlicerType:String;
		
		private var objectsMask:Vector.<uint>;
		
		public function DisplayObjectContainer() {
			this.children = new Vector.<DisplayObject>();
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage, false, 0, true);
			this.addEventListener(Event.ENTER_FRAME, this.handleEnterFrame, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage, false, 0, true);
		}
		
		public function destroy():void {
			this.children = new Vector.<DisplayObject>();
			this.children = null;
		}
		
		public function addChild(child:DisplayObject):void {
			if (child) {
				child.x = isNaN(child.x)? 0 : child.x;
				child.y = isNaN(child.y)? 0 : child.y;
				child.z = this.children.length + 1;
				
				this.children.push(child);
			}
		}
		
		public function swapChildren(childA:DisplayObject, childB:DisplayObject):void {
			if (childA && childB) {
				var tmp:Number = childA.z;
				childA.z = childB.z;
				childB.z = tmp;
				
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
			if (this.stage && this.shallRedraw && this.bitmapData) {
				var bitmapData:BitmapData = this.bitmapData;
				var latestSpritesheet:BitmapData = this.latestSpritesheet;
				var latestSpritesheetId:String = this.latestSpritesheetId;
				var latestSlicer:ISlicer = this.latestSlicer;
				var latestSlicerType:String = this.latestSlicerType;
				
				bitmapData.lock();
				
				bitmapData.fillRect(bitmapData.rect, 0);
				
				this.initializeEmptyMask();
				
				var children:Vector.<DisplayObject> = this.children;
				var length:uint = this.children.length;
				var displayObject:DisplayObject;
				var visibleObjects:Vector.<Boolean> = new Vector.<Boolean>(length, true);
				for (var ii:int = length - 1; ii >= 0; --ii) {
					displayObject = children[ii];
					displayObject.hop();

					if (displayObject.spritesheetRegion) {
						visibleObjects[ii] = this.markObjectInMask(displayObject.rectangle);
					} else {
						visibleObjects[ii] = false;
					}
				}
				
				var countOfDropped:uint = 0;
				
				for (var i:uint = 0; i < length; ++i) {
					displayObject = children[i];
					
					if (displayObject.spritesheetRegion) {
						if (visibleObjects[i]) {
							if (latestSpritesheetId != displayObject.spritesheetId) {
								latestSpritesheet = displayObject.spritesheet;
								latestSpritesheetId = displayObject.spritesheetId;
							}
							
							if (latestSlicerType != displayObject.spritesheetRegion.type) {
								latestSlicerType = displayObject.spritesheetRegion.type;
								latestSlicer = SlicerFactory.get(latestSlicerType);
							}
							
							latestSlicer.copyPixels(
								latestSpritesheet, bitmapData,
								displayObject.spritesheetRegion, displayObject.position
							);
						} else {
							++countOfDropped;
						}
					}
				}
				
				trace(".......... count of dropped " + countOfDropped + " .. " + (length - countOfDropped))
				//this.removeEventListener(Event.ENTER_FRAME, this.handleEnterFrame);
				//return;
				
				if (this.latestSpritesheetId != latestSpritesheetId) {
					this.latestSpritesheet = latestSpritesheet;
					this.latestSpritesheetId = latestSpritesheetId;
				}
				if (this.latestSlicerType != latestSlicerType) {
					this.latestSlicer = latestSlicer;
					this.latestSlicerType = latestSlicerType;
				}
				
				bitmapData.unlock();
			}
		}
		
		private function initializeEmptyMask():void {
			this.objectsMask = new Vector.<uint>(this.stage.stageWidth + this.stage.stageHeight, true);
			/*
			for (var pp:uint = 0; pp < this.stage.stageWidth; ++pp) {
				for (var jj:uint = 0; jj < this.stage.stageHeight; ++jj) {
					//objectsMask[pp + jj] = 0;
				}
			}
			*/
		}
		
		private function markObjectInMask(rectangle:Rectangle):Boolean {
			var visible:Boolean;
			
			var objectsMask:Vector.<uint> = this.objectsMask;
			var objectsMaskLength:uint = objectsMask.length;
			var stageWidth:uint = this.stage.stageWidth;
			var stageHeight:uint = this.stage.stageHeight;
			
			for (var i:uint = int(rectangle.x); rectangle.x + i < stageWidth; ++i) {
				for (var j:uint = int(rectangle.y); rectangle.y + j < stageHeight; ++j) {
					if (!this.objectsMask[rectangle.x + i + rectangle.y + j]) {
						visible = true;
					}
					this.objectsMask[rectangle.x + i + rectangle.y + j] = 1;
				}
			}
			
			return visible;
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
			if (objA.z > objB.z) {
				return 1;
			} else if (objA.z < objB.z) {
				return -1;
			} else {
				return 1;
			}
		}
		
		private function handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			
			this.bitmapData = new BitmapData(this.stage.stageWidth, this.stage.stageHeight, true, 0);
		}
		
		private function handleRemovedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage);
			this.removeEventListener(Event.ENTER_FRAME, this.handleEnterFrame);
			
			this.latestSpritesheet = null;
			this.latestSpritesheetId = null;
			this.latestSlicer = null;
			this.latestSlicerType = null;
			
			this.bitmapData = null;
		}
		
		private function handleEnterFrame(e:Event):void {
			this.redraw();
		}
		
	}

}