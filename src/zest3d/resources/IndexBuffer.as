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
	import plugin.core.interfaces.IDisposable;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.BufferUsageType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class IndexBuffer extends Buffer implements IDisposable 
	{
		
		protected var _offset: int;
		
		public function IndexBuffer( numIndices: int, elementSize: int, usage: BufferUsageType = null ) 
		{
			usage ||= BufferUsageType.STATIC;
			
			super( numIndices, elementSize, usage )
			_offset = 0;
		}
		
		public function setIndexAt( index: int, value: uint ): void
		{
			_data.position = index * _elementSize;
			_data.writeShort( value );
		}
		
		override public function dispose():void 
		{
			Renderer.unbindAllIndexBuffer( this );
			super.dispose();
		}
		
		[Inline]
		public final function set offset( offset: int ): void
		{
			if ( offset >= 0 )
			{
				_offset = offset;
				return;
			}
			throw new ArgumentError( "The offset must be positive." );
		}
		
	}

}