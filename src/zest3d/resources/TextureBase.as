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
	//import br.com.stimuli.loading.BulkLoader;
	//import br.com.stimuli.loading.BulkProgressEvent;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.resources.enum.BufferUsageType;
	import zest3d.resources.enum.TextureFormat;
	import zest3d.resources.enum.TextureType;
	
	/*
	/// @eventType	br.com.stimuli.loading.BulkProgressEvent
	[Event(name = "progress", type = "br.com.stimuli.loading.BulkProgressEvent")]
	
	/// @eventType	br.com.stimuli.loading.BulkProgressEvent
	[Event(name = "complete", type = "br.com.stimuli.loading.BulkProgressEvent")]
	
	/// @eventType	flash.events.ErrorEvent
	[Event(name = "error", type = "flash.events.ErrorEvent")]
	*/
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class TextureBase extends EventDispatcher implements IDisposable 
	{
		
		//private var _loader: BulkLoader;
		
		public static const MAX_USER_FIELDS: int = 8;
		public static const MAX_MIPMAP_LEVELS: int = 16;
		
		public static const msNumDimensions: Array = [ 2, 3, 2 ];
		public static const msPixelSize: Array = [ 24, 32, 24, 24, 24, null, null, null, null, null, 32, 24, 16, 16 ]; //TODO check the last 3 pixel depths againa Adobes specs
		public static const msMipmapable: Array = [ false, false, false, false, false, null, null, null, null, null, true, true, true, true, true ];
		
		
		
		protected var _format: TextureFormat;
		protected var _type: TextureType;
		protected var _usage: BufferUsageType;
		protected var _numLevels: int;
		
		protected var _numDimensions: int;
		protected var _dimension: Array; // multi-dim 3
		protected var _numLevelBytes: Array;
		protected var _numTotalBytes: int;
		protected var _levelOffsets: Array;
		
		protected var _userField: Array;
		
		protected var _data: ByteArray;
		protected var _isDisposed:Boolean;
		
		// TODO consider convertTo and convertFrom ... SLOW / possible?
		
		public function TextureBase( format: TextureFormat, type: TextureType, usage: BufferUsageType, numLevels: int ) 
		{
			_format = format;
			_type = type;
			_usage = usage;
			_numLevels = numLevels;
			
			_numDimensions = msNumDimensions[ _type ];
			_numTotalBytes = 0;
			_data = new ByteArray();
			_data.endian = Endian.LITTLE_ENDIAN;
			
			_dimension = [];
			_dimension[ 0 ] = [];
			_dimension[ 1 ] = [];
			_dimension[ 2 ] = [];
			
			_numLevelBytes = [];
			_levelOffsets = [];
			
			for ( var level: int = 0; level < MAX_MIPMAP_LEVELS; ++level )
			{
				_dimension[ 0 ][ level ] = 0;
				_dimension[ 1 ][ level ] = 0;
				_dimension[ 2 ][ level ] = 0;
				_numLevelBytes[ level ] = 0;
				_levelOffsets[ level ] = 0;
			}
			
			_userField = [];
			for ( var i: int = 0; i < MAX_USER_FIELDS; ++i )
			{
				_userField[ i ] = 0;
			}
			
			_isDisposed = false;
		}
		
		// TODO this is temporary for testing to be removed.
		[Inline]
		public final function set data( value: ByteArray ): void
		{
			_data = value;
		}
		
		public function dispose(): void
		{
			_dimension = null;
			_numLevelBytes = null;
			_levelOffsets = null;
			_userField = null;
			
			_data = null;
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		/*
		private var _loadPath: String;
		public function load( path: String ): void
		{
			_loadPath = path;
			
			if ( !_loader )
			{
				_loader = new BulkLoader( _loadPath, 1, 1 );
				_loader.addEventListener( ErrorEvent.ERROR, errorHandler );
				_loader.addEventListener( BulkLoader.PROGRESS, progressHandler );
				_loader.addEventListener( BulkLoader.COMPLETE, completeHandler );
			}
			
			_loader.add( path );
			_loader.start();
		}
		
		protected function onTextureLoadComplete( e: BulkProgressEvent ): void
		{
			var bitmap: Bitmap = BulkLoader( e.currentTarget ).getContent( _loadPath );
			_data = bitmap.bitmapData.getPixels( new Rectangle( 0, 0, bitmap.width, bitmap.height ) );
			_numTotalBytes = _data.length;
			
			dispatchEvent(e.clone());
		}
		
		
		
		private function errorHandler( e: ErrorEvent ): void
		{
			dispatchEvent( e.clone() );
		}
		
		private function progressHandler( e: BulkProgressEvent ): void
		{
			dispatchEvent( e.clone() );
		}
		*/
		
		[Inline]
		public final function get format(): TextureFormat
		{
			return _format;
		}
		
		[Inline]
		public final function get textureType(): TextureType
		{
			return _type;
		}
		
		[Inline]
		public final function get usage(): BufferUsageType
		{
			return _usage;
		}
		
		[Inline]
		public final function get numLevels(): int
		{
			return _numLevels;
		}
		
		[Inline]
		public final function get numDimensions(): int
		{
			return msNumDimensions[ _type ];
		}
		
		[Inline]
		public final function getDimension( index: int, level: int ): int
		{
			return _dimension[ index ][ level ];
		}
		
		[Inline]
		public final function getNumLevelBytes( level: int ): int
		{
			return _numLevelBytes[ level ];
		}
		
		[Inline]
		public final function get numTotalBytes(): int
		{
			return _numTotalBytes;
		}
		
		[Inline]
		public final function getLevelOffset( level: int ): int
		{
			return _levelOffsets[ level ]
		}
		
		[Inline]
		public final function get pixelSize(): int
		{
			return msPixelSize[ _format ];
		}
		
		[Inline]
		public static function getPixelSize( tFormat: TextureFormat ): int
		{
			return msPixelSize[ tFormat.index ];
		}
		
		[Inline]
		public final function get isCompressed(): Boolean
		{
			return ( _format == TextureFormat.DXT1 ||
					 _format == TextureFormat.DXT5 ||
					 _format == TextureFormat.ETC1 ||
					 _format == TextureFormat.PVRTC ||
					 _format == TextureFormat.RGBA );
		}
		
		[Inline]
		public final function get isMipmapable(): Boolean
		{
			return msMipmapable[ _format ];
		}
		
		[Inline]
		public final function get data(): ByteArray
		{
			return _data;
		}
		
		[Inline]
		public final function setUserField( index: int, userField: int ): void
		{
			_userField[ index ] = userField;
		}
		
		[Inline]
		public final function getUserField( index: int ): int
		{
			return _userField[ index ];
		}
	}

}