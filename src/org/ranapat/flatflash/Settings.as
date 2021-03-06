package org.ranapat.flatflash {
	
	final public class Settings {
		public static const RENDER_TYPE_NOT_SET:uint = 0;
		public static const RENDER_TYPE_ENTER_FRAME:uint = 1;
		public static const RENDER_TYPE_LOOP:uint = 2;
		
		public static const FILTER_MARGIN_DELTA_CUT:uint = 25;
		
		public static const SKEW_RENDER_OFFSET:uint = 10;
		public static const MATRIX_WIDTH_EXTRA:uint = 5;
		public static const MATRIX_HEIGHT_EXTRA:uint = 5;
		
		public static const NO_IDENTIFIER:String = "__no_identifier__";
		
		public static var SHOW_REDRAWN_RECTANGLES:Boolean = false;
		public static var PREVENT_RENDER_FILTERS:Boolean = false;
	}

}