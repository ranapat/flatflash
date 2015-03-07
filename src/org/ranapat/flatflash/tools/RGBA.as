package org.ranapat.flatflash.tools {
	
	public class RGBA {
		public var r:uint;
		public var g:uint;
		public var b:uint;
		public var a:uint;
		
		public function RGBA(r:uint, g:uint, b:uint, a:uint) {
			this.r = r;
			this.g = g;
			this.b = b;
			this.a = a;
		}
		
		public function clone():RGBA {
			return new RGBA(this.r, this.g, this.b, this.a);
		}
		
		public function equals(object:RGBA):Boolean {
			return this.r == object.r
				&& this.g == object.g
				&& this.b == object.b
				&& this.a == object.a
			;
		}
		
		public function get rgb():uint {
			return ( ( this.r << 16 ) | ( this.g << 8 ) | this.b );
		}
		
	}

}