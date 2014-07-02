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
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.BufferUsageType;
	import zest3d.resources.enum.TextureFormat;
	import zest3d.resources.enum.TextureType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class TextureRectangle extends TextureBase implements IDisposable 
	{
		
		public function TextureRectangle( format: TextureFormat, dimension0: int, dimension1: int, usage: BufferUsageType = null ) 
		{
			usage ||= BufferUsageType.TEXTURE;
			super( format, TextureType.TEXTURE_RECTANGLE, usage, 0 );
			
			Assert.isTrue( dimension0 > 0, "Dimension0 must be positive." );
			Assert.isTrue( dimension1 > 0, "Dimension1 must be positive." );
			
			_dimension[ 0 ][ 0 ] = dimension0;
			_dimension[ 1 ][ 0 ] = dimension1;
			
			_numLevels = 0;
			
			computeNumLevelBytes();
			_data = new ByteArray();
			_data.endian = Endian.LITTLE_ENDIAN;
			_data.length = _numTotalBytes;
		}
		
		override public function dispose():void 
		{
			Renderer.unbindAllTextureRectangle( this );
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
		
		public function get hasMipmaps(): Boolean
		{
			return false;
		}
		
		protected function computeNumLevelBytes(): void
		{
			var dim0: int = _dimension[0][0];
			var dim1: int = _dimension[1][0];
			var level: int;
			_numTotalBytes = 0;
			
			if ( _format == TextureFormat.DXT1 )
			{
				for ( level = 0; level < _numLevels; ++level )
				{
					var max0: int = dim0 / 4;
					if ( max0 < 1 )
					{
						max0 = 1;
					}
					var max1: int = dim1 / 4;
					if ( max1 < 1 )
					{
						max1 = 1;
					}
					
					_numLevelBytes[ level ] = 8 * max0 * max1;
					_numTotalBytes += _numLevelBytes[ level ];
					_dimension[ 0 ][ level ] = dim0;
					_dimension[ 1 ][ level ] = dim1;
					_dimension[ 2 ][ level ] = 1;
					
					if ( dim0 > 1 )
					{
						dim0 >>= 1;
					}
					if ( dim1 > 1 )
					{
						dim1 >>= 1;
					}
				}
			}
			else if ( _format == TextureFormat.DXT5 )
			{
				for ( level = 0; level < _numLevels; ++level )
				{
					_numLevelBytes[ level ] = msPixelSize[ _format.index ] * dim0 * dim1;
					_numTotalBytes += _numLevelBytes[ level ];
					_dimension[0][level] = dim0;
					_dimension[1][level] = dim1;
					_dimension[2][level] = 1;
					
					if ( dim0 > 1 )
					{
						dim0 >>= 1;
					}
					if ( dim1 > 1 )
					{
						dim1 >>= 1;
					}
				}
				
				_levelOffsets[ 0 ] = 0;
				for ( level = 0; level < _numLevels - 1; ++level )
				{
					_levelOffsets[level+1] = _levelOffsets[level] + _numLevelBytes[level];
				}
			}
		}
		
		public static function fromByteArray( data:ByteArray ):TextureRectangle
		{
			return Texture.fromByteArray( data ) as TextureRectangle;
		}
	}

}