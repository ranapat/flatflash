package net.peakgames.common.bitmaps {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.PressAndTapGestureEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.getTimer
	import net.peakgames.components.flatflash.DisplayObjectContainer;
	import net.peakgames.components.flatflash.Image;
	import net.peakgames.components.flatflash.tools.EngineTypes;
	import net.peakgames.components.flatflash.tools.loader.AssetsKeeper;
	import net.peakgames.components.flatflash.tools.loader.AssetsLoader;
	import net.peakgames.components.flatflash.tools.loader.LoaderEvent;
	import net.peakgames.components.flatflash.tools.parsers.IParser;
	import net.peakgames.components.flatflash.tools.parsers.IParser;
	import net.peakgames.components.flatflash.tools.parsers.ParseEvent;
	import net.peakgames.components.flatflash.tools.parsers.ParseResult;
	import net.peakgames.components.flatflash.tools.parsers.StarlingFormat;
	import net.peakgames.components.flatflash.tools.slicers.ISlicer;
	import net.peakgames.components.flatflash.tools.slicers.SlicerFactory;
	
	[SWF(width="640", height="480", backgroundColor="0x000000", frameRate="59")]
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
		
		private var slicesIndex:uint;
		
		private var parser:IParser;
		
		private var assetsLoader:AssetsLoader;
		
		private var parseResult:ParseResult;
		private var slicer:ISlicer;
		
		private var doc:DisplayObjectContainer;
		private var i1:Image;
		private var i2:Image;
		
		private var tf:TextField;
		
		[Embed(source="../../../../../assets/img1.png")]
		private var Img1:Class;
		[Embed(source="../../../../../assets/img2.png")]
		private var Img2:Class;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			
		}
		
		private function handleKeyDown(e:KeyboardEvent):void {
			trace("............ " + e.keyCode)
			if (this.i1) {
				if (e.keyCode == Keyboard.LEFT) {
					this.i1.x -= 10;
				} else if (e.keyCode == Keyboard.RIGHT) {
					this.i1.x += 10;
				} else if (e.keyCode == Keyboard.DOWN) {
					this.i1.y += 10;
				} else if (e.keyCode == Keyboard.UP) {
					this.i1.y -= 10;
				}
			}
		}
		
		private function init(e:Event = null):void {
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			this.assetsLoader = new AssetsLoader(EngineTypes.TYPE_STARLING, "../assets/Untitled-2.xml", "../assets/");
			this.assetsLoader.addEventListener(LoaderEvent.LOAD_COMPLETE, this.handleAssetsLoaderComplete);
			this.assetsLoader.addEventListener(LoaderEvent.LOAD_FAIL, this.handleAssetsLoaderFail);
			
			doSomething2();
			
			this.tf = new TextField();
			this.tf.textColor = 0xffffff;
			this.addChild(this.tf);
		}
		
		private function handleAssetsLoaderComplete(e:LoaderEvent):void {
			trace("............ loaded :: " + e.result.type + " .. " + e.result.bitmapData)
			trace("+++ " + e.result.regions)
			
			var spritesheetId:String = AssetsKeeper.instance.keep(e.result.bitmapData);
			trace("???????????? " + spritesheetId);
			
			this.parseResult = e.result;
			this.slicer = SlicerFactory.get(e.result.type);
			
			this.doc = new DisplayObjectContainer();
			this.addChild(this.doc);
			
			this.i1 = new Image(e.result.bitmapData, spritesheetId, e.result.regions[0]);
			this.doc.addChild(this.i1);
		}
		
		private function handleAssetsLoaderFail(e:LoaderEvent):void {
			
		}
		
		private function doSomething2():void {
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
			
			//populate(bitmapData2, 100);
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			//stage.fullScreenSourceRect = new Rectangle(0,0,320,240); 
			stage.displayState = StageDisplayState.FULL_SCREEN; 	
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
		}
		
		private function populate(bitmapData:BitmapData, count:uint):void {
			bitmapData.fillRect(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 0x00000000);
			
			for (var i:uint = 0; i < count; ++i) {
				//point.x = Math.random() * 500;
				//point.y = Math.random() * 300;
				
				bitmapData.copyPixels(Math.random() > .5? pic1BitmapData : pic2BitmapData, rectangle, point, null, null, true);
			}
			
			//point.x += 10;
			//point.x = point.x > stage.stageWidth? 0 : point.x;
			
			//_graphics.beginBitmapFill(bitmapData, null, false, false);
			//_graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			//_graphics.endFill();
		}
		
		private function populateFromSlices(bitmapData:BitmapData):void {
			if (this.parseResult) {
				bitmapData.lock();
				
				bitmapData.fillRect(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 0x00000000);
				
				for (var p:uint = 0; p < 1; ++p ) {
					for (var i:uint = 0; i < 6; ++i ) {
						this.point.x = i * 100 + p;
						for (var j:uint = 0; j < 4; ++j ) {
							this.point.y = j * 100 + p;
							
							this.slicer.copyPixels(
								this.parseResult.bitmapData, bitmapData,
								this.parseResult.regions[slicesIndex], this.point
							);
						}
					}
				}
				
				slicesIndex = slicesIndex < this.parseResult.regions.length - 1? ++slicesIndex : 0;
				
				bitmapData.unlock();
			}
			/*
			if (slices) {
				bitmapData.fillRect(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 0x00000000);
				
				for (var p:uint = 0; p < 16; ++p ) {
					for (var i:uint = 0; i < 6; ++i ) {
						point.x = i * 100 + p;
						for (var j:uint = 0; j < 4; ++j ) {
							point.y = j * 100 + p;
							
							var region:BitmapDataRegion = BitmapDataRegion(slices[slicesIndex]);
							bitmapData.copyPixels(region.bitmapData, region.bitmapDataRectangle, point, null, null, true);
						}
					}
				}
				
				slicesIndex = slicesIndex < slices.length - 1? ++slicesIndex : 0;
			}
			*/

		}
		
		private function handleEnterFrame(e:Event):void {
			var currentTime:Number = (getTimer() - startTime) / 1000;
		  
			//populate(bitmapData2, 1);
			//populate(bitmapData2, 1000);
			populateFromSlices(bitmapData1);
			if (this.i1) {
				if (this.i1.x > this.stage.stageWidth) {
					this.i1.x = 0;
				} else {
					this.i1.x += 1;
				}
				if (this.i1.y > this.stage.stageHeight) {
					this.i1.y = 0;
				} else {
					this.i1.y += 1;
				}
			}
			
			++frames;
			  
			if (currentTime > 1) {
				trace("...... frames " + frames)
				this.tf.text = frames.toString();
				
				startTime = getTimer();
				frames = 0;
			}  			
		}
		
	}
	
}