/**
 * Plugin.IO - http://www.plugin.io
 * Copyright (c) 2013
 *
 * Geometric Tools, LLC
 * Copyright (c) 1998-2012
 * 
 * Distributed under the Boost Software License, Version 1.0.
 * http://www.boost.org/LICENSE_1_0.txt
 */
package zest3d.resources.enum 
{
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class TextureFormat 
	{
		
		public static const DXT1: TextureFormat = new TextureFormat( "DXT1", 0 );
		public static const DXT5: TextureFormat = new TextureFormat( "DXT5", 1 );
		public static const ETC1: TextureFormat = new TextureFormat( "ETC1", 2 );
		public static const PVRTC: TextureFormat = new TextureFormat( "PVRTC", 3 );
		public static const RGBA: TextureFormat = new TextureFormat( "RGBA", 4 );
		
		public static const RGBA8888: TextureFormat = new TextureFormat( "RGBA8888", 10 );
		public static const RGB888: TextureFormat = new TextureFormat( "RGB888", 11 );
		public static const RGB565: TextureFormat = new TextureFormat( "RGB565", 12 );
		public static const RGBA4444: TextureFormat = new TextureFormat( "RGBA4444", 13 );
		public static const R16G16B16A16: TextureFormat = new TextureFormat( "R16G16B16A16", 13 );
		
		protected var _type: String;
		protected var _index: int;
		public function TextureFormat( type: String, index: int ) 
		{
			_type = type;
			_index = index;
		}
		
		public function get type():String 
		{
			return _type;
		}
		
		public function get index():int 
		{
			return _index;
		}
		
	}

}