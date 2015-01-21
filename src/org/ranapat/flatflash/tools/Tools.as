package org.ranapat.flatflash.tools {
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	final public class Tools {
		
		public static function ensureAbstractClass(instance:Object, _class:Class):void {
			var className:String = getQualifiedClassName(instance);
			if (getDefinitionByName(className) == _class) {
				throw new Error(getQualifiedClassName(_class) + " Class can not be instantiated directly.");
			}
		}
		
		public static function getFullClassName(instance:Object):String {
			return getQualifiedClassName(instance);
		}
		
		public static function shortenClassName(name:String):String {
			return name.substring(name.indexOf("::") + 2, name.length);
		}
		
		public static function getClass(instance:Object):Class {
			var className:String = getQualifiedClassName(instance);
			return getDefinitionByName(className) as Class;
		}

		
	}

}