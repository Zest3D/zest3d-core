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
package zest3d.shaders.enum 
{
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class SamplerFilterType 
	{
		
		public static const NONE: SamplerFilterType = new SamplerFilterType( "none", 0 );
		public static const NEAREST: SamplerFilterType = new SamplerFilterType( "nearest", 1 );
		public static const LINEAR: SamplerFilterType = new SamplerFilterType( "linear", 2 );
		//public static const NEAREST_NEAREST: SamplerFilterType = new SamplerFilterType( "nearestNearest", 3 );
		//public static const NEAREST_LINEAR: SamplerFilterType = new SamplerFilterType( "nearestLinear", 4 );
		//public static const LINEAR_NEAREST: SamplerFilterType = new SamplerFilterType( "linearNearest", 5 );
		//public static const LINEAR_LINEAR: SamplerFilterType = new SamplerFilterType( "linearLinear", 6 );
		
		public static const QUANTITY: int = 3;
		
		protected var _type: String;
		protected var _index: int;
		public function SamplerFilterType( type: String, index: int ) 
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
		
		public static function toVector(): Vector.<SamplerFilterType>
		{
			return Vector.<SamplerFilterType>
			([
				//NONE,
				NEAREST,
				LINEAR//,
				//NEAREST_NEAREST,
				//NEAREST_LINEAR,
				//LINEAR_NEAREST,
				//LINEAR_LINEAR
			]);
		}
	}

}