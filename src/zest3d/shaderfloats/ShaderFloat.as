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
package zest3d.shaderfloats 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Visual;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class ShaderFloat implements IDisposable 
	{
		
		protected var _numElements: int;
		protected var _data: ByteArray;
		protected var _allowUpdater: Boolean;
		protected var _isDisposed:Boolean;
		
		public function ShaderFloat( numRegisters: int ) 
		{
			_allowUpdater = false;
			this.numRegisters = numRegisters;
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_data = null;
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function set numRegisters( numRegisters: int ): void
		{
			Assert.isTrue( numRegisters > 0, "Number of registers must be positive." );
			
			_numElements = 4 * numRegisters;
			_data = new ByteArray();
			_data.endian = Endian.LITTLE_ENDIAN;
		}
		
		[Inline]
		public final function get numRegisters(): int
		{
			return int( _numElements / 4 );
		}
		
		[Inline]
		public final function get data(): ByteArray
		{
			return _data;
		}
		
		public function setRegister( index: int, data: Array ): void
		{
			Assert.isTrue( 0 <= index && index < _numElements / 4, "Invalid register" );
			
			_data.position = ( (index * 4) * 4 );
			var offset: int = 0;
			_data.writeFloat( data[ offset++ ] );
			_data.writeFloat( data[ offset++ ] );
			_data.writeFloat( data[ offset++ ] );
			_data.writeFloat( data[ offset++ ] );
		}
		
		public function setRegisters( data: Array ): void
		{
			_data.position = 0;
			var offset: int = 0;
			_data.writeFloat( data[ offset++ ] );
		}
		
		public function getRegister( index: int ): Array
		{
			Assert.isTrue( 0 <= index && index < _numElements / 4, "Invalid register" );
			
			_data.position = ( (index * 4) * 4 );
			return [ _data.readFloat(),
					 _data.readFloat(),
					 _data.readFloat(),
					 _data.readFloat() ];
		}
		
		public function getRegisters( ): Array 
		{
			_data.position = 0;
			var out: Array = [];
			for ( var i: int = 0; i < _numElements; ++i )
			{
				out[ i ] = _data.readFloat();
			}
			return out;
		}
		
		[Inline]
		public final function enableUpdater(): void
		{
			_allowUpdater = true;
		}
		
		[Inline]
		public final function disableUpdater(): void
		{
			_allowUpdater = false;
		}
		
		[Inline]
		public final function allowUpdater(): Boolean
		{
			return _allowUpdater;
		}
		
		// virtual
		public function update( visual: Visual, camera: Camera ): void
		{
			throw new Error( "ShaderFloat::update must be overridden." );
		}
		
	}

}