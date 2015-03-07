package org.ranapat.flatflash.examples {
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.PressAndTapGestureEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import org.ranapat.flatflash.Button;
	import org.ranapat.flatflash.Settings;
	import org.ranapat.flatflash.tools.loader.SwfTracer;
	import org.ranapat.flatflash.tools.loader.SwfTracerEvent;
	import org.ranapat.flatflash.tools.Tools;
	
	import net.hires.debug.Stats;
	
	import org.ranapat.flatflash.DisplayObject;
	import org.ranapat.flatflash.DisplayObjectContainer;
	import org.ranapat.flatflash.DisplayObjectFactory;
	import org.ranapat.flatflash.Image;
	import org.ranapat.flatflash.MovieClip;
	
	import org.ranapat.flatflash.tools.EngineTypes;
	import org.ranapat.flatflash.tools.joiners.BitmapDataVectorJoiner;
	import org.ranapat.flatflash.tools.joiners.JoinResult;
	import org.ranapat.flatflash.tools.loader.AssetsKeeper;
	import org.ranapat.flatflash.tools.loader.AtlasLoader;
	import org.ranapat.flatflash.tools.loader.LoaderEvent;
	import org.ranapat.flatflash.tools.loader.ResourceLoader;
	import org.ranapat.flatflash.tools.loader.ResourceLoaderEvent;
	import org.ranapat.flatflash.tools.math.RectangleSize;
	import org.ranapat.flatflash.tools.math.RectangleSizeCalculator;
	import org.ranapat.flatflash.tools.parsers.IParser;
	import org.ranapat.flatflash.tools.parsers.IParser;
	import org.ranapat.flatflash.tools.parsers.ParseEvent;
	import org.ranapat.flatflash.tools.parsers.ParseResult;
	import org.ranapat.flatflash.tools.parsers.StarlingFormat;
	import org.ranapat.flatflash.tools.slicers.ISlicer;
	import org.ranapat.flatflash.tools.slicers.SlicerFactory;
	
	[SWF(width="760", height="830", backgroundColor="0xFFFFFF", frameRate="24")]
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
		
		private var atlasLoader:AtlasLoader;
		
		private var parseResult:ParseResult;
		private var slicer:ISlicer;
		
		private var doc:DisplayObjectContainer;
		private var i1:MovieClip;
		private var i2:MovieClip;
		
		private var i3:Image;
		
		private var carousel:Carousel;
		
		private var tf:TextField;
		
		private var recorder:MovieClip;
		
		private var loadRequestId:int = -1;
		private var loadRequestId2:int = -1;
		
		private var diceRollAnimationWhite:DiceRollAnimation;
		private var diceRollAnimationBlack:DiceRollAnimation;
		
		[Embed(source="../../../../../assets/img1.png")]
		private var Img1:Class;
		[Embed(source="../../../../../assets/img2.png")]
		private var Img2:Class;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			
		}
		
		private function handleKeyDown(e:KeyboardEvent):void {
			//trace("............ " + e.keyCode)
			if (this.i1) {
				if (e.keyCode == Keyboard.LEFT) {
					this.i1.mouseEnabled = false;
					this.i1.x -= 10;
				} else if (e.keyCode == Keyboard.RIGHT) {
					this.i1.mouseEnabled = true;
					this.i1.x += 10;
				} else if (e.keyCode == Keyboard.DOWN) {
					this.i1.mouseEnabled = false;
					this.i1.y += 10;
				} else if (e.keyCode == Keyboard.UP) {
					this.i1.mouseEnabled = true;
					this.i1.y -= 10;
				} else if (e.keyCode == Keyboard.SPACE) {
					//
				} else if (e.keyCode == Keyboard.PAGE_UP) {
					this.i1.alpha += .05;
				} else if (e.keyCode == Keyboard.PAGE_DOWN) {
					this.i1.alpha -= .05;
				} else if (e.keyCode == Keyboard.HOME) {
					this.i1.scale -= .05;
				} else if (e.keyCode == Keyboard.END) {
					this.i1.scale += .05;
				} else if (e.keyCode == Keyboard.A) {
					this.doc.visible = false;
				} else if (e.keyCode == Keyboard.B) {
					this.doc.visible = true;
				} else if (e.keyCode == Keyboard.C) {
					DisplayObjectFactory.startRecording(this.doc, new Rectangle(0, 0, 200, 200));
				} else if (e.keyCode == Keyboard.D) {
					recorder = DisplayObjectFactory.stopRecording(this.doc);
					//this.doc.addChild(recorder);
					recorder.x = 10;
					recorder.y = -10;
					recorder.fps = 240;
					recorder.play();
				} else if (e.keyCode == Keyboard.E) {
					this.doc.removeChild(recorder);
					recorder = null;
				} else if (e.keyCode == Keyboard.O) {
					angleLeft(1);
					offsetByAngle();
				} else if (e.keyCode == Keyboard.P) {
					angleRight(1);
					offsetByAngle();
				} else if (e.keyCode == Keyboard.F) {
					this.carousel.left();
				} else if (e.keyCode == Keyboard.G) {
					this.carousel.right();
				} else if (e.keyCode == Keyboard.K) {
					this.i1.stop();
				} else if (e.keyCode == Keyboard.L) {
					this.i1.play();
				} else if (e.keyCode == Keyboard.M) {
					++this._tracedValuesPlayIndex;
					this.applyDiceAnimation(this._tracedValuesPlayIndex);
					
					trace(".............." + this._tracedValuesPlayIndex)
				} else if (e.keyCode == Keyboard.N) {
					--this._tracedValuesPlayIndex;
					this.applyDiceAnimation(this._tracedValuesPlayIndex);
					
					trace(".............." + this._tracedValuesPlayIndex)
				} else if (e.keyCode == 49) {
					diceRollAnimationWhite.play("dice_anm_01", 0, 1, 1, 0)
					diceRollAnimationBlack.play("dice_anm_01", 0, 1, 1, 0)
				} else if (e.keyCode == 50) {
					diceRollAnimationWhite.play("dice_anm_02", 0, 0, 3, 4)
					diceRollAnimationBlack.play("dice_anm_02", 1, 2, 0, 0)
				} else if (e.keyCode == 51) {
					diceRollAnimationWhite.play("dice_anm_03", 1, 0, 0, 4)
					diceRollAnimationBlack.play("dice_anm_03", 0, 2, 3, 0)
				} else if (e.keyCode == 52) {
					diceRollAnimationWhite.play("dice_anm_04", 0, 0, 3, 4)
					diceRollAnimationBlack.play("dice_anm_04", 1, 2, 0, 0)
				} else if (e.keyCode == 53) {
					diceRollAnimationWhite.play("dice_anm_05", 1, 2, 0, 0)
					diceRollAnimationBlack.play("dice_anm_05", 0, 0, 3, 4)
				}
			}
			
			
			if (this.i2) {
				if (e.keyCode == Keyboard.SPACE) {
					this.i2.stop();
				} else if (e.keyCode == Keyboard.ENTER) {
					this.i2.play();
				} else if (e.keyCode == Keyboard.F1) {
					this.i2.gotoAndPlay(10);
				} else if (e.keyCode == Keyboard.F2) {
					this.i2.gotoAndStop(300);
				}
			}
		}
		
		private function init(e:Event = null):void {
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			//this.atlasLoader = new AtlasLoader(EngineTypes.TYPE_STARLING, "../assets/Untitled-2.xml", "../assets/");
			//this.atlasLoader = new AtlasLoader(EngineTypes.TYPE_STARLING, "../assets/ATLAS/atlas.xml", "../assets/ATLAS/");
			this.atlasLoader = new AtlasLoader(EngineTypes.TYPE_STARLING, "../assets/Untitled-1.xml", "../assets/");
			this.atlasLoader.addEventListener(LoaderEvent.LOAD_COMPLETE, this.handleAtlasLoaderComplete);
			this.atlasLoader.addEventListener(LoaderEvent.LOAD_FAIL, this.handleAtlasLoaderFail);
			
			doSomething2();
			
			this.tf = new TextField();
			this.tf.textColor = 0xffffff;
			this.tf.x = 100
			this.addChild(this.tf);
			
			var loader:ResourceLoader = ResourceLoader.instance;
			loader.addEventListener(ResourceLoaderEvent.RESOURCE_COMPLETE, this.handleResourceLoaderComplete);
			
			addChild(new Stats());
		}
		
		private var initialSize:Rectangle = new Rectangle(0, 0, 418, 252);
		private var initialPoint:Point = new Point(500, 500);
		private var radius:uint = 150;
		private var latestAngle:int = 0;
		private function angleLeft(step:int):void {
			latestAngle += step;
			latestAngle = latestAngle > 90? 90 : latestAngle;
		}
		private function angleRight(step:int):void {
			latestAngle -= step;
			latestAngle = latestAngle < -90? -90 : latestAngle;
		}
		private function offsetByAngle():void {
			var angleRadians:Number = latestAngle * Math.PI / 180;
			i3.x = initialPoint.x - radius * Math.sin(angleRadians);
			
			var depth:Number = Math.cos(angleRadians);
			
			i3.alpha = .6 + .4 * depth;
			i3.scaleX = i3.scaleY = .6 + .4 * depth;
			
			i3.y = initialPoint.y + (initialSize.height - i3.height) / 2;
			trace(i3.y + " .. " + initialPoint.y + " .. " +  initialSize.height + " .. " + i3.height);
			
			trace(latestAngle + " .. " + angleRadians + " .. " + i3.x + " .. " + depth + " .. " + i3.height + " .. " + i3.width);
		}
		
		private var _ClassDefinition:Class;
		private function handleResourceLoaderComplete(e:ResourceLoaderEvent):void {
			if (e.id == loadRequestId) {
				if (e.applicationDomain) {
					SwfTracer.instance.stage = this.stage;
					
					for (var i:uint = 1; i <= 0; ++i) {
						var m1:MovieClip = DisplayObjectFactory.movieClipFromSWF(e.applicationDomain.getDefinition("Test_Serhat_1") as Class);
						m1.fps = e.fps;
						m1.x = 400 + i * 100;
						m1.y = 400;
						//this.doc.addChild(m1);
						m1.play();
						
						var i1:Image = DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Test_Image_2") as Class);
						i1.x = 400 + i * 100;
						i1.y = 600;
						//this.doc.addChild(i1);
					}
					
					/*
					SwfTracer.instance.stage = this.stage;
					SwfTracer.instance.addEventListener(SwfTracer.TRACE_COMPLETE, this.handleSwfTracerComplete, false, 0, true);
					SwfTracer.instance.addEventListener(SwfTracer.TRACE_FAIL, this.handleSwfTracerFail, false, 0, true);
					
					trace("target fps is " + e.fps)
					
					SwfTracer.instance.get(e.applicationDomain.getDefinition("Item_8_Animation") as Class);
					for (var i:uint = 1; i <= 160; ++i) {
						SwfTracer.instance.get(e.applicationDomain.getDefinition("FixedAnimationSequence") as Class);
					}
					*/
					
					
					
					//return;
					var ClassDefinition:Class = e.applicationDomain.getDefinition("Test_Serhat_2") as Class;
					//var ClassDefinition:Class = e.applicationDomain.getDefinition("Test_Serhat_1") as Class;
					//var ClassDefinition:Class = e.applicationDomain.getDefinition("Test_Resize_Animation") as Class;
					//var ClassDefinition:Class = e.applicationDomain.getDefinition("Item_8_Animation") as Class;
					_ClassDefinition = ClassDefinition;
					//var ClassDefinition:Class = e.applicationDomain.getDefinition("Test_Serhat_1") as Class;

					/*
					for (var j:uint = 0; j < 1; ++j) {
						for (var i:uint = 0; i < 200; ++i) {
							tt = new ClassDefinition();
							tt.x = 200 + j * 100 + i;
							tt.y = 200 + i;
							
							this.addChild(tt);
							//tt.gotoAndStop(1);
							tt.play();
							
							//ttt = new Vector.<BitmapData>();
							
							//tt.addEventListener(Event.ENTER_FRAME, this.handleTTEnterFrame);
						}
					}
					*/
					
					this.i1 = DisplayObjectFactory.movieClipFromSWF(ClassDefinition);
					this.i1.play(1);
					this.i1.mouseEnabled = true;
					this.i1.fps = 1024;
					this.i1.onBeforeDraw(this, this.beforeDrawI1);
					this.i1.onAfterDraw(this, this.afterDrawI1);
					this.i1.onLoopLimitReached(this, this.loopLimitReachedI1, [ "test" ]);
					this.i1.onInitialize(this, this.onInitializeI1);
					this.i1.onInitialize(this, this.onInitializeI1Another, [ "test", this.i1 ]);
					this.i1.onMouseEvent(this, this.onMouseEventI1);
					this.i1.onInitializeRemove(this, this.onInitializeI1);
					this.i1.onAfterDrawRemove(this, this.afterDrawI1);
					this.i1.onBeforeDrawRemove(this, this.beforeDrawI1);
					this.i1.onLoopLimitReachedRemove(this, this.loopLimitReachedI1);
					//this.doc.addChild(this.i1);
					
					//this.doc.addChild(DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image1") as Class, "ffffff", new Rectangle(100, 100, 200, 200))).alpha = .5;
					
					
					var b:Button = new Button(
						DisplayObjectFactory.movieClipFromSWF(e.applicationDomain.getDefinition("BigClip") as Class, null, new Rectangle(0, 0, 100, 100)),
						//DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image1") as Class, null, new Rectangle(200, 100, 300, 200)),
						DisplayObjectFactory.movieClipFromSWF(e.applicationDomain.getDefinition("BigClip") as Class, null, new Rectangle(0, 110, 100, 210)),
						DisplayObjectFactory.movieClipFromSWF(e.applicationDomain.getDefinition("BigClip") as Class, null, new Rectangle(110, 0, 210, 100)),
						//DisplayObjectFactory.movieClipFromSWF(e.applicationDomain.getDefinition("BigClip") as Class, null, new Rectangle(110, 110, 210, 210))
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image1") as Class, null, new Rectangle(200, 100, 300, 200))
						
					);
					b.x = 600;
					b.y = 100;
					b.mouseEnabled = true;
					//this.doc.addChild(b);
					
					tt = new ClassDefinition();
					tt.x = 200;
					tt.y = 200;
					
					this.addChild(tt);
					tt.gotoAndStop(1);
					
					ttt = new Vector.<BitmapData>();
					
					tt.addEventListener(Event.ENTER_FRAME, this.handleTTEnterFrame);
					
					
					
					var iiimage:Image = DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image1") as Class, null, new Rectangle(200, 100, 300, 200));
					this.doc.addChild(iiimage);
					iiimage.x = 300;
					iiimage.y = 100;
					iiimage.anchorX = 50;
					iiimage.anchorY = 50;
					iiimage.mouseEnabled = true;
					iiimage.onMouseEvent(this, this.handleIIImageMouseEvents, [ iiimage ]);
					iiimage.alpha = .1
					
					var iiimage2:Image = DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image1") as Class, null, new Rectangle(200, 100, 300, 200));
					this.doc.addChild(iiimage2);
					iiimage2.x = 400;
					iiimage2.y = 200;
					iiimage2.anchorX = 50;
					iiimage2.anchorY = 50;
					iiimage2.mouseEnabled = true;
					iiimage2.onMouseEvent(this, this.handleIIImageMouseEvents, [ iiimage2 ]);
					iiimage2.alpha = .1
					
					
					i3 = DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image1") as Class);
					//this.doc.addChild(i3);
					i3.x = 500;
					i3.y = 500;
					i3.visible = false;
					
					//this.doc.visible = false;
					
					this.carousel = new Carousel();
					this.carousel.initialPoint = new Point(265, 0);
					this.carousel.initialSize = new Rectangle(0, 0, 418, 252);
					this.carousel.items = Vector.<DisplayObject>([
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image1") as Class),
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image2") as Class),
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image3") as Class),
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image4") as Class),
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image5") as Class),
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image6") as Class),
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image7") as Class),
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image8") as Class),
						DisplayObjectFactory.imageFromSWF(e.applicationDomain.getDefinition("Image9") as Class)
					]);
					//this.addChild(this.carousel);
					this.carousel.x = 400;
					this.carousel.y = 400;
					
					
					
					/*
					for (var i:uint = 0; i < 500; ++i) {
						tt = new ClassDefinition();
						tt.x = 200 + i;
						tt.y = 200 + i;
						
						this.addChild(tt);
					}
					*/
				}
				
				
			} else if (e.id == loadRequestId2) {
				return;
				diceRollAnimationWhite = new DiceRollAnimation();
				diceRollAnimationWhite.record(e.applicationDomain, "White");
				diceRollAnimationWhite.sound = "DiceAnimationsSound24FPS";
				this.addChild(diceRollAnimationWhite);
				//diceRollAnimationWhite.scaleFactor = 2;
				//diceRollAnimationWhite.scaleX = 2;
				//diceRollAnimationWhite.scaleY = 2;
				diceRollAnimationWhite.x -= 400;
				
				//diceRollAnimationWhite.innerScale = 5;
				
				//diceRollAnimationWhite.scaleX = .5;
				//diceRollAnimationWhite.scaleY = .5;
				
				trace(diceRollAnimationWhite.width)
				
				//diceRollAnimationWhite.y += 100;
				
				diceRollAnimationBlack = new DiceRollAnimation();
				diceRollAnimationBlack.record(e.applicationDomain, "White");
				//diceRollAnimationBlack.x += 700;
				diceRollAnimationBlack.x -= 400;
				diceRollAnimationBlack.y += 100;
				//diceRollAnimationBlack.scaleX = 2;
				//diceRollAnimationBlack.scaleY = 2;
				//diceRollAnimationBlack.innerScale = 2;
				this.addChild(diceRollAnimationBlack);
				
				
				trace(diceRollAnimationBlack.width)
				
				//var _cc:Class = e.applicationDomain.getDefinition("TestDices1") as Class;
				var WhiteDiceTurnMyAnimation:Class = e.applicationDomain.getDefinition("WhiteDiceTurnMyAnimation") as Class;
				var WhiteDiceTurnOpponentAnimation:Class = e.applicationDomain.getDefinition("WhiteDiceTurnOpponentAnimation") as Class;
				var WhiteDiceStill:Class = e.applicationDomain.getDefinition("WhiteDiceStill") as Class;
				var WhiteDiceTurnSideAnimation:Class = e.applicationDomain.getDefinition("WhiteDiceTurnSideAnimation") as Class;
				
				var BlackDiceTurnMyAnimation:Class = e.applicationDomain.getDefinition("BlackDiceTurnMyAnimation") as Class;
				var BlackDiceTurnOpponentAnimation:Class = e.applicationDomain.getDefinition("BlackDiceTurnOpponentAnimation") as Class;
				var BlackDiceStill:Class = e.applicationDomain.getDefinition("BlackDiceStill") as Class;
				var BlackDiceTurnSideAnimation:Class = e.applicationDomain.getDefinition("BlackDiceTurnSideAnimation") as Class;
				
				var j:uint;
				
				if (false) {
					diceTurnMyAnimation1 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnMyAnimation2 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnMyAnimation3 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnMyAnimation4 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnOpponentAnimation1 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnOpponentAnimation2 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnOpponentAnimation3 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnOpponentAnimation4 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceStill1 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
					diceStill2 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
					diceStill3 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
					diceStill4 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
					diceTurnSideAnimation1 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
					diceTurnSideAnimation2 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
					diceTurnSideAnimation3 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
					diceTurnSideAnimation4 = DisplayObjectFactory.movieClipFromSWF(WhiteDiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
				} else {
					diceTurnMyAnimation1 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnMyAnimation2 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnMyAnimation3 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnMyAnimation4 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnMyAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnOpponentAnimation1 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnOpponentAnimation2 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnOpponentAnimation3 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceTurnOpponentAnimation4 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnOpponentAnimation, null, new Rectangle(-15, -16, 15, 16));
					diceStill1 = DisplayObjectFactory.movieClipFromSWF(BlackDiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
					diceStill2 = DisplayObjectFactory.movieClipFromSWF(BlackDiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
					diceStill3 = DisplayObjectFactory.movieClipFromSWF(BlackDiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
					diceStill4 = DisplayObjectFactory.movieClipFromSWF(BlackDiceStill, null, new Rectangle( -15, -16, 15, 16 + 14));
					diceTurnSideAnimation1 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
					diceTurnSideAnimation2 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
					diceTurnSideAnimation3 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
					diceTurnSideAnimation4 = DisplayObjectFactory.movieClipFromSWF(BlackDiceTurnSideAnimation, null, new Rectangle( -15, -16, 15, 16));
				}
				
				diceTurnMyAnimation1.play();
				diceTurnMyAnimation2.play();
				diceTurnMyAnimation3.play();
				diceTurnMyAnimation4.play();
				diceTurnOpponentAnimation1.play();
				diceTurnOpponentAnimation2.play();
				diceTurnOpponentAnimation3.play();
				diceTurnOpponentAnimation4.play();
				diceStill1.gotoAndStop(0);
				diceStill2.gotoAndStop(1);
				diceStill3.gotoAndStop(2);
				diceStill4.gotoAndStop(3);
				diceTurnSideAnimation1.play();
				diceTurnSideAnimation2.play();
				diceTurnSideAnimation3.play();
				diceTurnSideAnimation4.play();
				
				this.doc.addChild(diceTurnMyAnimation1);
				this.doc.addChild(diceTurnMyAnimation2);
				this.doc.addChild(diceTurnMyAnimation3);
				this.doc.addChild(diceTurnMyAnimation4);
				this.doc.addChild(diceTurnOpponentAnimation1);
				this.doc.addChild(diceTurnOpponentAnimation2);
				this.doc.addChild(diceTurnOpponentAnimation3);
				this.doc.addChild(diceTurnOpponentAnimation4);
				this.doc.addChild(diceStill1);
				this.doc.addChild(diceStill2);
				this.doc.addChild(diceStill3);
				this.doc.addChild(diceStill4);
				this.doc.addChild(diceTurnSideAnimation1);
				this.doc.addChild(diceTurnSideAnimation2);
				this.doc.addChild(diceTurnSideAnimation3);
				this.doc.addChild(diceTurnSideAnimation4);
				
				this.tracedValues = new Vector.<Vector.<TracedDiceObjects>>();
				
				var _ccc:flash.display.MovieClip = new (e.applicationDomain.getDefinition("DiceAnimations") as Class)();
				_ccc.gotoAndStop(1);
				
				var previousFrame:uint = 1;
				do {
					previousFrame = _ccc.currentFrame;
					walkThru(_ccc.currentFrame - 1, _ccc);
					_ccc.nextFrame();
					
				} while (_ccc.currentFrame != previousFrame);
				//_ccc = null;
				
				_ccc.x = 113;
				_ccc.y = 113;
				//_ccc.alpha = .4;
				addChild(_ccc);
				_ccc.play();
				swapChildren(_ccc, this.doc)
				
				//addEventListener(Event.ENTER_FRAME, handlePlayDiceEnterFrame);
			}
		}
		
		private function handleIIImageMouseEvents(image:Image, e:MouseEvent):void {
			if (e.type == MouseEvent.MOUSE_OVER) {
				image.alpha = .5;
			} else if (e.type == MouseEvent.MOUSE_OUT) {
				image.alpha = 1;
			} else if (e.type == MouseEvent.CLICK) {
				image.rotation += 10;
				image.scale += .1
				
			}
		}
		
		private function handlePlayDiceEnterFrame(e:Event):void {
			this.applyDiceAnimation(this._tracedValuesPlayIndex);
			++this._tracedValuesPlayIndex;
			this._tracedValuesPlayIndex = this._tracedValuesPlayIndex >= this.tracedValues.length? 0 : this._tracedValuesPlayIndex;
		}
		
		private function applyDiceAnimation(frame:uint):void {
			var vector:Vector.<TracedDiceObjects> = this.tracedValues[frame];
			var length:uint = vector.length;
			
			var dicesTurnIndexMy:uint;
			var dicesTurnIndexOpponent:uint;
			var dicesStillIndex:uint;
			var dicesSideIndex:uint;
			
			var dice:MovieClip;
			for (var i:uint = 0; i < length; ++i) {
				dice = null;
				
				var tracedDiceObject:TracedDiceObjects = vector[i];
				var className:String = tracedDiceObject.className;
				if (className == "WhiteDiceTurnMyAnimation") {
					dice = this["diceTurnMyAnimation" + ++dicesTurnIndexMy];
				} else if (className == "WhiteDiceTurnOpponentAnimation") {
					dice = this["diceTurnOpponentAnimation" + ++dicesTurnIndexOpponent];
				} else if (className == "WhiteDiceStill") {
					dice = this["diceStill" + ++dicesStillIndex];
				} else if (className == "WhiteDiceTurnSideAnimation") {
					dice = this["diceTurnSideAnimation" + ++dicesSideIndex];
				}
				
				if (dice) {
					dice.visible = true;
					dice.x = /*707 + */tracedDiceObject.x;
					dice.y = /*497 + */tracedDiceObject.y;
					dice.scaleX = tracedDiceObject.scaleX;
					dice.scaleY = tracedDiceObject.scaleY;
					dice.filters = tracedDiceObject.filters;
				}
			}
			
			while (dicesTurnIndexMy < 4) {
				this["diceTurnMyAnimation" + ++dicesTurnIndexMy].visible = false;
			}
			while (dicesTurnIndexOpponent < 4) {
				this["diceTurnOpponentAnimation" + ++dicesTurnIndexOpponent].visible = false;
			}
			while (dicesStillIndex < 4) {
				this["diceStill" + ++dicesStillIndex].visible = false;
			}
			while (dicesSideIndex < 4) {
				this["diceTurnSideAnimation" + ++dicesSideIndex].visible = false;
			}
		}
		
		private var diceTurnMyAnimation1:MovieClip;
		private var diceTurnMyAnimation2:MovieClip;
		private var diceTurnMyAnimation3:MovieClip;
		private var diceTurnMyAnimation4:MovieClip;
		private var diceTurnOpponentAnimation1:MovieClip;
		private var diceTurnOpponentAnimation2:MovieClip;
		private var diceTurnOpponentAnimation3:MovieClip;
		private var diceTurnOpponentAnimation4:MovieClip;
		private var diceStill1:MovieClip;
		private var diceStill2:MovieClip;
		private var diceStill3:MovieClip;
		private var diceStill4:MovieClip;
		private var diceTurnSideAnimation1:MovieClip;
		private var diceTurnSideAnimation2:MovieClip;
		private var diceTurnSideAnimation3:MovieClip;
		private var diceTurnSideAnimation4:MovieClip;
		
		private var tracedValues:Vector.<Vector.<TracedDiceObjects>>;
		private var _tracedValuesPlayIndex:uint;
		
		private function walkThru(frame:uint, object:flash.display.DisplayObjectContainer):void {
			var length:uint = object.numChildren;
			
			var located:Boolean;
			for (var i:uint = 0; i < length; ++i) {
				var tmp:flash.display.DisplayObject = object.getChildAt(i);
				if (tmp) {
					//dice = null;
					located = false;
					
					var className:String = Tools.getFullClassName(tmp);
					if (className == "WhiteDiceTurnMyAnimation") {
						located = true;
					} else if (className == "WhiteDiceTurnOpponentAnimation") {
						located = true;
					} else if (className == "WhiteDiceStill") {
						located = true;
					} else if (className == "WhiteDiceTurnSideAnimation") {
						located = true;
					}
					
					if (located) {
						while (this.tracedValues.length <= frame) {
							this.tracedValues[this.tracedValues.length] = new Vector.<TracedDiceObjects>();
						}
						this.tracedValues[frame][this.tracedValues[frame].length] = new TracedDiceObjects(
							className,
							tmp.x, tmp.y,
							tmp.scaleX, tmp.scaleY,
							tmp.filters
						);
					}
				}
			}
		}
		
		private function beforeDrawI1():void {
			trace("before draw we have here")
		}
		
		private function afterDrawI1():void {
			trace("after draw we have here")
		}
		
		private function loopLimitReachedI1(...args):void {
			trace("we reach the limit " + i1.currentFrame + " .. " + args.length + " .. " + args);
		}
		
		private function handleSwfTracerFail(e:SwfTracerEvent):void 
		{
			trace("trace failed.... " + e.key + " .. " + e.resultType + " .. " + e.error + " .. ")
		}
		
		private function onInitializeI1():void {
			trace("our i1 is initialized")
		}
		
		private function onInitializeI1Another(...args):void {
			trace("our i1 is initialized another " + args.length + " .. " + args)
		}
		
		private function onMouseEventI1(e:MouseEvent):void {
			trace("our i1 has mouse event " + e)
		}
		
		private var totalLoaded:uint;
		private var yOffset:uint;
		private var fps:uint = 0;
		private function handleSwfTracerComplete(e:SwfTracerEvent):void {
			//trace("trace complete.... " + e.key + " .. " + e.resultType + " .. " + e.error + " .. " + totalLoaded + " .. " + yOffset)
			
			/**/
			if (e.resultType == SwfTracer.TYPE_MOVIE_CLIP) {
				var newMovie:MovieClip = new MovieClip(e.result.bitmapData, e.result.regions);
				newMovie.fps = ++this.fps;
				newMovie.keepSpritesheet = true;
				newMovie.x = 400 + (100 * totalLoaded);
				newMovie.y = 200 + yOffset;
				newMovie.play();
				this.doc.addChild(newMovie);
			} else if (e.resultType == SwfTracer.TYPE_SPRITE) {
				var newImage:Image = new Image(e.result.bitmapData, e.result.regions[0]);
				newImage.keepSpritesheet = true;
				newImage.x = 400 + (100 * totalLoaded);
				newImage.y = 200 + yOffset;
				this.doc.addChild(newImage);
			}
			
			++totalLoaded;
			if (totalLoaded > 14) {
				totalLoaded = 0;
				yOffset += 80;
			}
			/**/
		}
		
		private var tt:flash.display.MovieClip;
		
		private var ttt:Vector.<BitmapData>;
		private var frame:uint = 0;
		private function handleTTEnterFrame(e:Event):void {
			var clip:flash.display.MovieClip = e.target as flash.display.MovieClip;
			
			if (clip.currentFrame <= clip.totalFrames) {
				if (frame != clip.currentFrame) {
					frame = clip.currentFrame;
				
					var tttt:BitmapData = new BitmapData(clip.width, clip.height, true, 0);
					tttt.draw(clip);
					
					this.doc.bitmapData.copyPixels(tttt, new Rectangle(0, 0, tttt.width, tttt.height), new Point(0, 200), null, null, true);
					
					ttt.push(tttt);
					
					clip.nextFrame();
				} else {
					clip.removeEventListener(Event.ENTER_FRAME, this.handleTTEnterFrame);
				
					trace("total frames... " + ttt.length)
					
					var tt:BitmapDataVectorJoiner = new BitmapDataVectorJoiner();
					var f:JoinResult = tt.toAtlas(ttt);
					if (f) {
						trace(f.bitmapData)
						trace(f.regions)
						
						AssetsKeeper.instance.keep(f.bitmapData);
						
						var newMovie:MovieClip = new MovieClip(f.bitmapData, f.regions);
						newMovie.x = 400;
						newMovie.y = 200;
						newMovie.play();
						this.doc.addChild(newMovie);
					}
					
					
					/**/
					for (var i:uint = 0; i < 0; ++i) {
						//trace("..........")
						//var newMovieN:MovieClip = new MovieClip(f.bitmapData, f.regions);
						//newMovieN.keepSpritesheet = true;
						//newMovieN.x = 400 + i;
						//newMovieN.y = 200 + i;
						//newMovieN.play();
						//this.doc.addChild(newMovieN);
						
						if (i % 2 == 0 || i % 3 == 0 || i % 4 == 0) {
							//this.doc.removeChild(newMovieN);
						}
						
						var newnewMovieN:flash.display.MovieClip = new _ClassDefinition();
						newnewMovieN.x = 600 + i;
						newnewMovieN.y = 200 + i;
						newnewMovieN.play();
						this.addChild(newnewMovieN);
					}
					/**/
					trace("count after cleanup is " + this.doc.numChildren)
					
					/*
					for (var i:uint = 0; i < 750; ++i) {
						//trace("..........")
						var newMovieN:MovieClip = new MovieClip(f.bitmapData, f.regions);
						newMovieN.x = 800 + i;
						newMovieN.y = 200 + i;
						newMovieN.play();
						this.doc.addChild(newMovieN);
					}
					for (var i:uint = 0; i < 750; ++i) {
						//trace("..........")
						var newMovieN:MovieClip = new MovieClip(f.bitmapData, f.regions);
						newMovieN.x = 100 + i;
						newMovieN.y = 200 + i;
						newMovieN.play();
						this.doc.addChild(newMovieN);
					}
					for (var i:uint = 0; i < 750; ++i) {
						//trace("..........")
						var newMovieN:MovieClip = new MovieClip(f.bitmapData, f.regions);
						newMovieN.x = 200 + i;
						newMovieN.y = 200 + i;
						newMovieN.play();
						this.doc.addChild(newMovieN);
					}
					for (var i:uint = 0; i < 750; ++i) {
						//trace("..........")
						var newMovieN:MovieClip = new MovieClip(f.bitmapData, f.regions);
						newMovieN.x = 300 + i;
						newMovieN.y = 200 + i;
						newMovieN.play();
						this.doc.addChild(newMovieN);
					}
					*/
				}
			}
		}
		
		private function handleAtlasLoaderComplete(e:LoaderEvent):void {
			AssetsKeeper.instance.keep(e.result.bitmapData);
			
			this.parseResult = e.result;
			this.slicer = SlicerFactory.get(e.result.type);
		
			this.doc = new DisplayObjectContainer(1);
			this.doc.x = 100;
			this.doc.y = 100;
			this.addChild(this.doc);
			
			//this.i1 = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
			//this.i1 = DisplayObjectFactory.getImageByRegion(e.result.bitmapData, e.result.regions[10]);
			//this.i1 = DisplayObjectFactory.getImageByName(e.result.bitmapData, e.result.regions, "Item_8_Animation0010")
			//(this.i1 as MovieClip).play();
			//(this.i1 as MovieClip).currentFrame = 1;
			//(this.i1 as MovieClip).fps = 12;
			//this.i1.mouseEnabled = true;
			//this.doc.addChild(this.i1);
			//this.i1.mouseEnabled = true;
			
			//this.i2 = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
			//this.i2 = DisplayObjectFactory.getMovieClipByMinMaxIndexes(e.result.bitmapData, e.result.regions, 1, 3);
			//this.i2 = DisplayObjectFactory.getMovieClipByMinMaxNames(e.result.bitmapData, e.result.regions, "Item_8_Animation0000", "Item_8_Animation0020");
			//this.doc.addChild(this.i2);
			//this.i2.play();
			
			//this.i2 = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
			//this.i2 = DisplayObjectFactory.getMovieClipByMinMaxIndexes(e.result.bitmapData, e.result.regions, 1, 3);
			//this.i2 = DisplayObjectFactory.getMovieClipByMinMaxNames(e.result.bitmapData, e.result.regions, "Item_8_Animation0000", "Item_8_Animation0020");
			//this.doc.addChild(this.i2);
			//this.i2.play();
			//this.i2.fps = 12;
			
			/*
			var p:uint;
			var tt:MovieClip;
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 2 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 3 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 4 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 4 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 5 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 6 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 5 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 6 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 7 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			for (p = 0; p < 500; ++p) {
				tt = DisplayObjectFactory.getMovieClipFromAll(e.result.bitmapData, e.result.regions);
				tt.x = 8 * 70 + p;
				tt.y = p;
				this.doc.addChild(tt);
				tt.play();
			}
			*/
			
			//this.doc.swapChildren(this.i1, this.i2);
			
			//trace(this.doc.getChildAt(1).name)
		}
		
		private function handleAtlasLoaderFail(e:LoaderEvent):void {
			
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

			//spareBitmap = new Bitmap(bitmapData1);
			//addChild(spareBitmap);
			
			//spareBitmap2 = new Bitmap(bitmapData2);
			//addChild(spareBitmap2);
			
			//populate(bitmapData2, 100);
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			//stage.fullScreenSourceRect = new Rectangle(0,0,1920,1200); 
			stage.displayState = StageDisplayState.FULL_SCREEN; 	
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			
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
			return;
			if (this.parseResult) {
				bitmapData.lock();
				
				bitmapData.fillRect(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 0x00000000);
				
				for (var p:uint = 0; p < 32; ++p ) {
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
		
		private var frameNumber:Number = 0;
		private function handleEnterFrame(e:Event):void {
			var currentTime:Number = (getTimer() - startTime) / 1000;
		  
			//populate(bitmapData2, 1);
			//populate(bitmapData2, 1000);
			//populateFromSlices(bitmapData1);
			/*
			if (this.i1) {
				this.i1.mouseEnabled = false;
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
			*/
			
			if (++frameNumber == 4) {
				var loader:ResourceLoader = ResourceLoader.instance;
				loadRequestId = loader.load("../assets/Untitled-n.swf");
				loadRequestId2 = loader.load("../assets/TestDices.swf");
			}
			
			++frames;
			  
			if (currentTime > 1) {
				//trace("...... frames " + frames)
				//this.tf.text = "frames: " + frames.toString();
				
				startTime = getTimer();
				frames = 0;
			}  			
		}
		
	}
	
}

class TracedDiceObjects {
	public var className:String;
	public var x:Number;
	public var y:Number;
	public var scaleX:Number;
	public var scaleY:Number;
	public var filters:Array;
	
	public function TracedDiceObjects(className:String, x:Number, y:Number, scaleX:Number, scaleY:Number, filters:Array) {
		this.className = className
		this.x = x;
		this.y = y;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.filters = filters;
	}
}