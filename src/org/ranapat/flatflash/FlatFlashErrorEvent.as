package org.ranapat.flatflash {
	import flash.events.Event;
	
	final public class FlatFlashErrorEvent extends Event {
		public static const CREATE_BITMAP_CANVAS_ERROR:String = "CreateBitmapCanvasError";
		
		public function FlatFlashErrorEvent(type:String) {
			super(type);
		}
		
	}

}