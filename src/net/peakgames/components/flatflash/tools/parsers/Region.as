package net.peakgames.components.flatflash.tools.parsers {
	import flash.geom.Rectangle;
	
	public class Region extends Rectangle {
		private var _name:String;
		
		public function Region(name:String, x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0) {
			super(x, y, width, height);
			
			this._name = name;
		}
		
		public function get name():String {
			return _name;
		}
		
	}

}