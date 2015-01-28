package org.ranapat.flatflash {
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import org.ranapat.flatflash.Image;
	import org.ranapat.flatflash.tools.loader.SwfTracer;
	import org.ranapat.flatflash.tools.loader.SwfTracerEvent;
	import org.ranapat.flatflash.tools.regions.Region;
	
	final public class DisplayObjectFactory {
		
		private static var swfGetterInitialized:Boolean;
		private static var swfGetterQueue:Dictionary;
		
		private static var recording:Dictionary;
		
		public static function getImageByRegion(spritesheet:BitmapData, region:Region):Image {
			return new Image(spritesheet, region);
		}
		
		public static function getImageByName(spritesheet:BitmapData, regions:Vector.<Region>, regionName:String):Image {
			var length:uint = regions.length;
			for (var i:uint = 0; i < length; ++i) {
				var tmpRegion:Region = regions[i];
				if (tmpRegion.name == regionName) {
					return DisplayObjectFactory.getImageByRegion(spritesheet, tmpRegion);
				}
			}
			return null;
		}
		
		public static function getMovieClipFromAll(spritesheet:BitmapData, regions:Vector.<Region>):MovieClip {
			return new MovieClip(spritesheet, regions);
		}
		
		public static function getMovieClipByMinMaxIndexes(spritesheet:BitmapData, regions:Vector.<Region>, minIndex:uint, maxIndex:uint):MovieClip {
			return new MovieClip(spritesheet, regions.slice(minIndex, maxIndex));
		}
		
		public static function getMovieClipByName(spritesheet:BitmapData, regions:Vector.<Region>, name:String):MovieClip {
			var regionsToPick:Vector.<Region> = new Vector.<Region>();
			var length:uint = regions.length;
			for (var i:uint = 0; i < length; ++i) {
				var region:Region = regions[i];
				if (region.name.indexOf(name) != -1) {
					regionsToPick[regionsToPick.length] = region;
				}
			}
			
			return new MovieClip(spritesheet, regionsToPick);
		}
		
		public static function getMovieClipByMinMaxNames(spritesheet:BitmapData, regions:Vector.<Region>, minName:String, maxName:String):MovieClip {
			var regionsToPick:Vector.<Region> = new Vector.<Region>();
			var length:uint = regions.length;
			for (var i:uint = 0; i < length; ++i) {
				var region:Region = regions[i];
				if (region.name >= minName && region.name <= maxName) {
					regionsToPick[regionsToPick.length] = region;
				}
			}
			
			return new MovieClip(spritesheet, regionsToPick);
		}
		
		public static function movieClipFromSWF(_class:Class, identifier:String = null):MovieClip {
			DisplayObjectFactory.ensureSWFGetter();
			
			var object:MovieClip = new MovieClip();
			DisplayObjectFactory.swfGetterQueue[object] = -1;
			var key:uint = SwfTracer.instance.get(_class, identifier);
			if (DisplayObjectFactory.swfGetterQueue[object]) {
				DisplayObjectFactory.swfGetterQueue[object] = key;
			}
			
			return object;
		}
		
		public static function imageFromSWF(_class:Class, identifier:String = null):Image {
			DisplayObjectFactory.ensureSWFGetter();
			
			var object:Image = new Image();
			DisplayObjectFactory.swfGetterQueue[object] = -1;
			var key:uint = SwfTracer.instance.get(_class, identifier);
			if (DisplayObjectFactory.swfGetterQueue[object]) {
				DisplayObjectFactory.swfGetterQueue[object] = key;
			}
			
			return object;
		}
		
		public static function startRecording(object:flash.display.DisplayObject, clipRectangle:Rectangle = null):void {
			DisplayObjectFactory.ensureRecording();
			
			DisplayObjectFactory.recording[object] = new RecordingObject(new Vector.<ByteArray>(), clipRectangle);
			object.addEventListener(Event.ENTER_FRAME, DisplayObjectFactory.handleRecondingEnterFrame, false, 0, true);
		}
		
		public static function stopRecording(object:flash.display.DisplayObject):MovieClip {
			if (DisplayObjectFactory.recording && DisplayObjectFactory.recording[object]) {
				object.removeEventListener(Event.ENTER_FRAME, DisplayObjectFactory.handleRecondingEnterFrame);
				
				var vector:Vector.<ByteArray> = DisplayObjectFactory.recording[object].vector;
				var clipRectangle:Rectangle = DisplayObjectFactory.recording[object].clipRectangle;
				
				DisplayObjectFactory.recording[object] = null;
				delete DisplayObjectFactory.recording[object];
				
				return new MovieClip(vector, clipRectangle? clipRectangle.width : object.width, clipRectangle? clipRectangle.width : object.height);
			} else {
				return null;
			}
		}
		
		private static function ensureRecording():void {
			if (!DisplayObjectFactory.recording) {
				DisplayObjectFactory.recording = new Dictionary(true);
			}
		}
		
		private static function ensureSWFGetter():void {
			if (!DisplayObjectFactory.swfGetterInitialized) {
				DisplayObjectFactory.swfGetterInitialized = true;
				DisplayObjectFactory.swfGetterQueue = new Dictionary(true);
				
				SwfTracer.instance.addEventListener(SwfTracer.TRACE_COMPLETE, DisplayObjectFactory.handleSwfTracerComplete, false, 0, true);
				SwfTracer.instance.addEventListener(SwfTracer.TRACE_FAIL, DisplayObjectFactory.handleSwfTracerFail, false, 0, true);
			}
		}
		
		private static function handleSwfTracerComplete(e:SwfTracerEvent):void {
			var object:DisplayObject = DisplayObjectFactory.swfTracerGetObjectByKey(e.key);
			if (object) {
				try {
					if (e.resultType == SwfTracer.TYPE_MOVIE_CLIP) {
						if (e.result) {
							(object as MovieClip).initialize(e.result.bitmapData, e.result.regions);
						} else {
							(object as MovieClip).initialize(e.raw);
						}
					} else if (e.resultType == SwfTracer.TYPE_SPRITE) {
						(object as Image).initialize(e.result.bitmapData, e.result.regions[0]);
					}
					object.keepSpritesheet = true;
				} catch (err:Error) {
					//trace(err)
				}
				
				DisplayObjectFactory.swfGetterQueue[object] = null;
			}
		}
		
		private static function handleSwfTracerFail(e:SwfTracerEvent):void {
			var object:DisplayObject = DisplayObjectFactory.swfTracerGetObjectByKey(e.key);
			if (object) {
				DisplayObjectFactory.swfGetterQueue[object] = null;
			}
		}
		
		private static function swfTracerGetObjectByKey(key:uint):DisplayObject {
			for (var object:* in DisplayObjectFactory.swfGetterQueue) {
				if (DisplayObjectFactory.swfGetterQueue[object] == key || DisplayObjectFactory.swfGetterQueue[object] == -1) {
					return DisplayObject(object);
				}
			}
			return null;
		}
		
		private static function handleRecondingEnterFrame(e:Event):void {
			var object:flash.display.DisplayObject = e.target as flash.display.DisplayObject;
			
			if (DisplayObjectFactory.recording[object]) {
				try {
					
					var vector:Vector.<ByteArray> = DisplayObjectFactory.recording[object].vector;
					var clipRectangle:Rectangle = DisplayObjectFactory.recording[object].clipRectangle;
					
					var tmp:BitmapData = new BitmapData(clipRectangle? clipRectangle.width : object.width, clipRectangle? clipRectangle.height : object.height, true, 0);
					
					tmp.draw(object, null, null, null, clipRectangle, false);
					
					var bytearray:ByteArray = tmp.getPixels(new Rectangle(0, 0, tmp.width, tmp.height));
					bytearray.deflate();
					vector[vector.length] = bytearray;
				} catch (err:Error) {
					//trace(err);
				}
			}
		}
	}

}

import flash.geom.Rectangle;
import flash.utils.ByteArray;

class RecordingObject {
	public var vector:Vector.<ByteArray>;
	public var clipRectangle:Rectangle;
	
	public function RecordingObject(vector:Vector.<ByteArray>, clipRectangle:Rectangle) {
		this.vector = vector;
		this.clipRectangle = clipRectangle;
	}
}