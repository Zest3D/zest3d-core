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
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
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
			
			initWorker();
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
			var max0: int;
			var max1: int;
			_numTotalBytes = 0;
			
			if ( _format == TextureFormat.DXT1 )
			{
				for ( level = 0; level < _numLevels; ++level )
				{
					max0 = dim0 / 4;
					if ( max0 < 1 )
					{
						max0 = 1;
					}
					max1 = dim1 / 4;
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
				max0 = dim0 / 4;
				if ( max0 < 1 )
				{
					max0 = 1;
				}
				max1 = dim1 / 4;
				if ( max1 < 1 )
				{
					max1 = 1;
				}
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
		
		
		// TODO move to base class / abstraction
		[Embed(source="../../../../zest3d-examples/src/plugin/examples/worker/ImageWorker.swf", mimeType="application/octet-stream")]
		private var WorkerSWF:Class;
		
		private static var _worker:Worker;
		private var _input:ByteArray = new ByteArray();
		private var _output:ByteArray = new ByteArray();
		private var _bm:MessageChannel;
		private var _mb:MessageChannel;
		
		protected function initWorker():void
		{
			if ( !_worker )
			{
				_worker = WorkerDomain.current.createWorker(new WorkerSWF());
				_bm = _worker.createMessageChannel( Worker.current );
				_mb = Worker.current.createMessageChannel( _worker );
				
				_worker.setSharedProperty( "btm", _bm );
				_worker.setSharedProperty( "mtb", _mb );
				
				_bm.addEventListener( Event.CHANNEL_MESSAGE, onImageProcessingComplete );
				_worker.start();
				
				_input = _bm.receive(true);
				_output = _bm.receive(true);
			}
		}
		
		override protected function onTextureLoadComplete(e:BulkProgressEvent):void 
		{
			_input.length = 0;
			_input.writeBytes( BulkLoader( e.currentTarget ).getContent( _loadPath ) );
			
			_mb.send( "IMAGE READY" );
			//_mb.send( _loadPath );
			
			super.onTextureLoadComplete(e);
		}
		
		private function onImageProcessingComplete(e:Event):void
		{
			if ( _bm.messageAvailable )
			{
				var header:String = _bm.receive();
				//var id:String = _bm.receive();
				
				if( header == "COMPLETE" )
				{
					if ( _bm.messageAvailable )
					{
						_dimension[ 0 ][ 0 ] = _bm.receive();
						_dimension[ 1 ][ 0 ] = _bm.receive();
						
						_data = _output;
						//TODO this is currently hardcoded until we load via mipmaps levels
						Renderer.updateAllTexture2D( this, 0 );
					}
				}
			}
		}
		
		public static function fromATFData( data:ByteArray ):Texture2D
		{
			return Texture.fromATFData( data ) as Texture2D;
		}
	}

}