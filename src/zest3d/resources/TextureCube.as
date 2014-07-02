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
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import plugin.math.base.BitHacks;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.BufferUsageType;
	import zest3d.resources.enum.TextureFormat;
	import zest3d.resources.enum.TextureType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class TextureCube extends TextureBase implements IDisposable 
	{
		
		public function TextureCube( format: TextureFormat, dimension: int, numLevels: int, usage: BufferUsageType = null ) 
		{
			usage ||= BufferUsageType.TEXTURE;
			super( format, TextureType.TEXTURE_CUBE, usage, numLevels );

			Assert.isTrue( dimension > 0, "Dimension must be positive" );
			_dimension[0][0] = dimension;
			_dimension[1][0] = dimension;

			var logDim: uint = BitHacks.logOfPowerTwoUint( uint( dimension ) );
			var maxLevels: int = int( logDim ) + 1;

			if ( numLevels == 0 )
			{
				_numLevels = maxLevels;
			}
			else if ( numLevels <= maxLevels )
			{
				_numLevels = numLevels;
			}
			else
			{
				Assert.isTrue( false, "Invalid number of levels." );
			}

			//computeNumLevelBytes();
			_data = new ByteArray();
			_data.endian = Endian.LITTLE_ENDIAN;
			_data.length = _numTotalBytes;
		}
		
		override public function dispose():void 
		{
			Renderer.unbindAllTextureCube( this );
			super.dispose();
		}
		
		[Inline]
		public final function get width(): int
		{
			return getDimension( 0, 0 );
		}

		[Inline]
		public final function get height(): int
		{
			return getDimension( 1, 0 );
		}

		public function generateMipmaps(): void
		{
			throw new Error( "TextureCube::generateMipmaps() is currently unsupported" );
		}

		public function get hasMipmaps(): Boolean
		{
			/*
			var logDim: uint = BitHacks.logOfPowerTwoUint( uint( dimension ) );
			var maxLevels: int = int( logDim ) + 1;
			
			return _numLevels == maxLevels;
			*/
			return false; //TODO implement mipmap checks
		}

		//TODO return face and level
		/*
		override public function get data( face: int, level: int ): ByteArray
		{
			return _data;
		}
		*/

		protected function computeNumLevelBytes(): void
		{
			throw new Error( "TextureCube::computeNumLevelBytes() is currently unsupported" );
		}
		
		public static function fromByteArray( data:ByteArray ):TextureCube
		{
			return Texture.fromByteArray( data ) as TextureCube;
		}
	}

}