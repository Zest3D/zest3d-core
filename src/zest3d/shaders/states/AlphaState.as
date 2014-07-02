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
package zest3d.shaders.states 
{
	import plugin.core.interfaces.IDisposable;
	import zest3d.shaders.enum.CompareMode;
	import zest3d.shaders.enum.DstBlendMode;
	import zest3d.shaders.enum.SrcBlendMode;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class AlphaState implements IDisposable 
	{
		
		public var blendEnabled: Boolean;
		public var srcBlend: SrcBlendMode;
		public var dstBlend: DstBlendMode;
		public var compareEnabled: Boolean;
		public var compare: CompareMode;
		public var reference: Number;
		public var constantColor: Array;
		
		protected var _isDisposed: Boolean;
		
		public function AlphaState() 
		{
			blendEnabled = false;
			srcBlend = SrcBlendMode.SRC_ALPHA;
			dstBlend = DstBlendMode.ONE_MINUS_SRC_ALPHA;
			compareEnabled = false;
			compare = CompareMode.ALWAYS;
			reference = 0;
			constantColor = [0, 0, 0, 0];
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			srcBlend = null;
			dstBlend = null;
			compare = null;
			constantColor = null;
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
	}
	
}