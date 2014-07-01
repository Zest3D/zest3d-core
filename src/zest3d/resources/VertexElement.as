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
package zest3d.resources 
{
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.resources.enum.AttributeType;
	import zest3d.resources.enum.AttributeUsageType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class VertexElement implements IDisposable 
	{
		
		public var streamIndex: uint;
		public var offset: uint;
		public var type: AttributeType;
		public var usage: AttributeUsageType;
		public var usageIndex: uint;
		
		protected var _isDisposed:Boolean;
		
		public function VertexElement() 
		{
			streamIndex = 0;
			offset = 0;
			type = AttributeType.NONE;
			usage = AttributeUsageType.NONE;
			usageIndex = 0;
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			type = null;
			usage = null;
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
	}

}