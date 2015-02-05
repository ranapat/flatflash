package org.ranapat.flatflash {
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import org.ranapat.flatflash.tools.regions.Region;
	
	public class Button extends DisplayObject {
		private var up:DisplayObject;
		private var hover:DisplayObject;
		private var down:DisplayObject;
		private var hit:DisplayObject;
		
		private var _active:DisplayObject;
		
		public function Button(...args) {
			super();
			
			this.initialize.apply(this, args);
			
			this.mouseEnabled = true;
			this.onMouseEvent(this, this.doHandleMouseEvent);
		}
		
		override public function initialize(...args):void {
			if (args.length > 0 && args.length <= 4) {
				if (args.length == 4 && args[0] is DisplayObject && args[1] is DisplayObject && args[2] is DisplayObject && args[3] is DisplayObject) {
					this.up = args[0];
					this.hover = args[1];
					this.down = args[2];
					this.hit = args[3];
				} else if (args.length == 3 && args[0] is DisplayObject && args[1] is DisplayObject && args[2] is DisplayObject) {
					this.up = args[0];
					this.hover = args[1];
					this.down = args[2];
					this.hit = args[0];
				} else if (args.length == 2 && args[0] is DisplayObject && args[1] is DisplayObject) {
					this.up = args[0];
					this.hover = args[1];
					this.down = args[0];
					this.hit = args[0];
				} else if (args.length == 1 && args[0] is DisplayObject) {
					this.up = args[0];
					this.hover = args[0];
					this.down = args[0];
					this.hit = args[0];
				}
				
				this.active = this.up;
			}
		}
		
		override public function hop(timer:int):void {
			this.active.hop(timer);
		}
		
		override public function get spritesheet():BitmapData {
			return this.active.spritesheet;
		}
		
		override public function get region():Region {
			return this.active.region;
		}
		
		override public function get changed():Boolean {
			return true;
		}
		
		override public function get x():Number {
			return super.x + this.hit.x;
		}
		
		override public function get y():Number {
			return super.y + this.hit.y;
		}
		
		override public function get width():Number {
			return this.hit.width;
		}
		
		override public function get height():Number {
			return this.hit.height;
		}
		
		override protected function handleAddedToContainer():void {
			this.checkActiveAutoRun();
		}
		
		override protected function handleRemovedFromContainer():void {
			//
		}
		
		private function doHandleMouseEvent(e:MouseEvent):void {
			if (e.type == MouseEvent.MOUSE_OVER) {
				this.active = this.hover;
			} else if (e.type == MouseEvent.MOUSE_OUT) {
				this.active = this.up;
			} else if (e.type == MouseEvent.MOUSE_DOWN) {
				this.active = this.down;
			} else if (e.type == MouseEvent.MOUSE_UP) {
				this.active = this.hover;
			}
		}
		
		private function get active():DisplayObject {
			return this._active;
		}
		
		private function set active(value:DisplayObject):void {
			var changed:Boolean = this._active != value;
			var previous:DisplayObject = this.active;
			this._active = value;
			
			if (changed) {
				this.checkPreviousAutoRun(previous);
				this.checkActiveAutoRun();
			}
		}
		
		private function checkPreviousAutoRun(previous:DisplayObject):void {
			if (previous is MovieClip) {
				(previous as MovieClip).gotoAndStop(0);
			}
		}
		
		private function checkActiveAutoRun():void {
			if (this.active is MovieClip && this.parent) {
				(this.active as MovieClip).fps = this.parent.fps;
				(this.active as MovieClip).gotoAndPlay(0);
			}
		}
	}

}