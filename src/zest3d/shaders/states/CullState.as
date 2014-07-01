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
	import io.plugin.core.interfaces.IDisposable;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class CullState implements IDisposable 
	{
		
		public var enabled: Boolean;
		public var ccwOrder: Boolean;
		
		protected var _isDisposed: Boolean;
		
		public function CullState() 
		{
			enabled = true;
			ccwOrder = true;
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
	}

}