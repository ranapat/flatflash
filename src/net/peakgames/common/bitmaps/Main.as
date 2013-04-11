package net.peakgames.common.bitmaps {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer
	
	[SWF(width="1920", height="768", backgroundColor="0x000000", frameRate="24")]
	public class Main extends Sprite {
		private var frames:uint;
		private var startTime:uint;
		
		private var color:uint = 0xff000000;
		private var bitmapData1:BitmapData;
		private var bitmapData2:BitmapData;
		private var sprite:Sprite;
		private var matrix:Matrix;
		private var pic1:Bitmap;
		private var pic2:Bitmap;
		private var _graphics:Graphics;
		private var pic1BitmapData:BitmapData;
		private var pic2BitmapData:BitmapData;
		private var rectangle:Rectangle;
		private var point:Point;
		private var spareBitmap:Bitmap;
		private var spareBitmap2:Bitmap;
		
		[Embed(source="../../../../../assets/img1.png")]
		private var Img1:Class;
		[Embed(source="../../../../../assets/img2.png")]
		private var Img2:Class;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			frames = 0;
			startTime = getTimer();
			bitmapData1 = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
			bitmapData2 = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
			matrix = new Matrix();
			pic1 = new Img1();
			pic2 = new Img2();
			pic1BitmapData = pic1.bitmapData;
			pic2BitmapData = pic2.bitmapData;
			rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			point = new Point();
			point.x = 0;
			point.y = 100;
			
			/*
			sprite = new Sprite();
			sprite.cacheAsBitmap = true;
			_graphics = sprite.graphics;
			_graphics.clear();
			addChild(sprite);
			*/

			spareBitmap = new Bitmap(bitmapData1);
			addChild(spareBitmap);
			
			spareBitmap2 = new Bitmap(bitmapData2);
			addChild(spareBitmap2);
			
			populate(bitmapData2, 100);
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			//stage.fullScreenSourceRect = new Rectangle(0,0,320,240); 
			stage.displayState = StageDisplayState.FULL_SCREEN; 
		}
		
		private function populate(bitmapData:BitmapData, count:uint):void {
			bitmapData.fillRect(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 0x00000000);
			
			for (var i:uint = 0; i < count; ++i) {
				point.x = Math.random() * 1800;
				point.y = Math.random() * 600;
				
				bitmapData.copyPixels(Math.random() > .5? pic1BitmapData : pic2BitmapData, rectangle, point, null, null, true);
			}
			
			//point.x += 10;
			//point.x = point.x > stage.stageWidth? 0 : point.x;
			
			//_graphics.beginBitmapFill(bitmapData, null, false, false);
			//_graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			//_graphics.endFill();
		}
		
		private function handleEnterFrame(e:Event):void {
			var currentTime:Number = (getTimer() - startTime) / 1000;
		  
			populate(bitmapData1, 1000);
			populate(bitmapData2, 1000);
			
			++frames;
			  
			if (currentTime > 1) {
				trace("...... frames " + frames)
				
				startTime = getTimer();
				frames = 0;
			}  			
		}
		
	}
	
}