package net.peakgames.components.flatflash.tools.math {
	
	public class RectangleSizeCalculator {
		
		public static function getSize(items:uint):RectangleSize {
			var prevX:uint = 1;
			var prevY:uint = items;
			
			while (prevX < items && prevX < prevY) {
				prevY = items / prevX;
				
				++prevX;
			}
			
			return new RectangleSize(Math.ceil(items / prevY), prevY);
		}
		
	}

}