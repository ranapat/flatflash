package org.ranapat.flatflash.tools.regions {
	import flash.geom.Rectangle;
	import org.ranapat.flatflash.tools.EngineTypes;
	
	public class Region extends Rectangle {
		protected var _type:String;
		private var _name:String;
		
		public function Region(name:String, x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0, type:String = EngineTypes.TYPE_UNDEFINED) {
			super(x, y, width, height);
			
			this._type = type;
			this._name = name;
		}
		
		public function get type():String {
			return this._type;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get sliceRectangle():Rectangle {
			return this;
		}
		
	}

}