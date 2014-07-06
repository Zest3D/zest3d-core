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
	//import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import cmodule.zaail.CLibInit;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import plugin.image.zaail.ZaaILInterface;
	import plugin.math.base.BitHacks;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.BufferUsageType;
	import zest3d.resources.enum.TextureFormat;
	import zest3d.resources.enum.TextureType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Texture2D extends TextureBase implements IDisposable 
	{
		
		public function Texture2D( format: TextureFormat, dimension0: int = 64, dimension1: int = 64, numLevels: int = 1 ) 
		{
			super( format, TextureType.TEXTURE_2D, BufferUsageType.TEXTURE, numLevels );
			
			Assert.isTrue( dimension0 > 0, "Dimension0 must be positive." );
			Assert.isTrue( dimension1 > 0, "Dimension1 must be positive." );
			
			_dimension[ 0 ][ 0 ] = dimension0;
			_dimension[ 1 ][ 0 ] = dimension1;
			
			var logDim0: uint = BitHacks.logOfPowerTwoUint( uint( dimension0 ) );
			var logDim1: uint = BitHacks.logOfPowerTwoUint( uint( dimension1 ) );
			
			var maxLevels: int = int( ( logDim0 > - logDim1 ? logDim0 + 1 : logDim1 + 1 ) );
			
			if ( numLevels == 0)
			{
				_numLevels = maxLevels;
			}
			else if ( numLevels <= maxLevels )
			{
				_numLevels = numLevels;
			}
			else
			{
				throw new Error( "Invalid number of levels." );
			}
			
			computeNumLevelBytes();
			_data = new ByteArray();
			_data.endian = Endian.LITTLE_ENDIAN;
			_data.length = _numTotalBytes;
		}
		
		override public function dispose():void 
		{
			Renderer.unbindAllTexture2D( this );
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
			throw new Error( "generateMipmaps not yet implemented" );
			
			/*
			var logDim0: uint = BitHacks.logOfPowerTwoUint( _dimension[0][0] );
			var logDim1: uint = BitHacks.logOfPowerTwoUint( _dimension[1][0] );
			var maxLevels:int = ( logDim0 >= logDim1 ? logDim0 + 1 : logDim1 + 1 );
			var retainBindings:Boolean = true;
			
			if ( _numLevels != maxLevels )
			{
				retainBindings = false;
				Renderer.unbindAllTexture2D( this );
				_numLevels = maxLevels;
				computeNumLevelBytes();
				
				var newData:ByteArray = new ByteArray();
				newData.length = _numLevelBytes[0];
				_data = newData;
			}
			
			// temporary storage
			var rgba
			*/
		}
		
		public function get hasMipmaps(): Boolean
		{
			var logDim0: uint = BitHacks.logOfPowerTwoUint( _dimension[0][0] );
			var logDim1: uint = BitHacks.logOfPowerTwoUint( _dimension[1][0] );
			
			var maxLevels: int = ( logDim0 >= logDim1 ? logDim0 + 1 : logDim1 + 1 );
			
			return _numLevels == maxLevels;
		}
		/*
		public function getDataAt( level: int ): ByteArray
		{
			
		}
		*/
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
					_numLevelBytes[ level ] = 16 * max0 * max1;
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
			}
			else
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
			}
			
			_levelOffsets[ 0 ] = 0;
			for ( level = 0; level < _numLevels - 1; ++level )
			{
				_levelOffsets[level+1] = _levelOffsets[level] + _numLevelBytes[level];
			}
		}
		
		override protected function onTextureLoadComplete(e:BulkProgressEvent):void 
		{
			var loader:CLibInit = new CLibInit();
			var lib:Object = loader.init();
			
			var fileContents:ByteArray = BulkLoader( e.currentTarget ).getContent( _loadPath );
			fileContents.endian = Endian.BIG_ENDIAN
			
			var output:ByteArray = new ByteArray();
			loader.supplyFile(_loadPath, fileContents);
			
			lib.ilInit();
			lib.ilOriginFunc(ZaaILInterface.IL_ORIGIN_UPPER_LEFT);
			lib.ilEnable(ZaaILInterface.IL_ORIGIN_SET);
			
			if(lib.ilLoadImage(_loadPath) != 1)
			{
				trace("Could not load the selected image", "Error Loading Image");
			}
			
			var width:int = lib.ilGetInteger(ZaaILInterface.IL_IMAGE_WIDTH);
			var height:int = lib.ilGetInteger(ZaaILInterface.IL_IMAGE_HEIGHT);
			var depth:int = lib.ilGetInteger(ZaaILInterface.IL_IMAGE_DEPTH);
			lib.ilGetPixels(0, 0, 0, width, height, depth, output);
			
			_data = output;
			
			_dimension[ 0 ][ 0 ] = width;
			_dimension[ 1 ][ 0 ] = height;
			
			super.onTextureLoadComplete(e);
			Renderer.updateAllTexture2D( this, 0 ); //TODO this is currently hardcoded until we load via mipmaps levels
		}
		
		public static function fromATFData( data:ByteArray ):Texture2D
		{
			return Texture.fromATFData( data ) as Texture2D;
		}
	}

}