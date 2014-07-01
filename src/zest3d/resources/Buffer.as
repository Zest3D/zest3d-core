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
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.object.PluginObject;
	import zest3d.resources.enum.BufferUsageType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Buffer extends PluginObject implements IDisposable 
	{
		
		protected var _numElements: int;
		protected var _elementSize: int;
		protected var _usage: BufferUsageType;
		protected var _numBytes: int;
		protected var _data: ByteArray;
		
		public function Buffer( numElements: int, elementSize: int, usage: BufferUsageType ) 
		{
			_numElements = numElements;
			_elementSize = elementSize;
			_usage = usage;
			_numBytes = numElements * elementSize;
			
			_data = new ByteArray( );
			_data.endian = Endian.LITTLE_ENDIAN;
			_data.length = _numBytes;
			
			_isDisposed = false;
		}
		
		override public function dispose(): void
		{
			_data.length = 0;
			_data = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get numElements(): int
		{
			return _numElements;
		}
		
		[Inline]
		public final function get elementSize():int
		{
			return _elementSize;
		}
		
		[Inline]
		public final function get usage(): BufferUsageType
		{
			return _usage;
		}
		
		[Inline]
		public final function set numElements( numElements: int ): void
		{
			_numElements = numElements;
		}
		
		[Inline]
		public final function get numBytes(): int
		{
			return _numBytes;
		}
		
		[Inline]
		public final function get data():ByteArray
		{
			return _data;
		}
		
	}

}