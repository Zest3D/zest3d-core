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
	import plugin.core.errors.IndexOutOfBoundsError;
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import plugin.core.system.object.PluginObject;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.AttributeType;
	import zest3d.resources.enum.AttributeUsageType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class VertexFormat extends PluginObject implements IDisposable 
	{
		
		public static const MAX_ATTRIBUTES: int = 16;
		public static const MAX_TCOORD_UNITS: int = 8;
		public static const MAX_COLOR_UNITS: int = 2;
		
		protected var _numAttributes: int;
		protected var _elements: Array;
		protected var _stride: int;
		
		protected static var msComponentSize: Array = [0, 4, 4, 4, 4, 2, 2, 2, 2, 1, 2, 2, 2];
		protected static var msNumComponents: Array = [0, 1, 2, 3, 4, 1, 2, 3, 4, 4, 1, 2, 4];
		protected static var msTypeSize: Array = [0, 4, 8, 12, 16, 2, 4, 6, 8, 4, 2, 4, 8];
		
		public function VertexFormat( numAttributes: int ) 
		{
			_numAttributes = numAttributes;
			_stride = 0;
			
			_elements = [];
			for ( var i: int = 0; i < MAX_ATTRIBUTES; i++ )
			{
				_elements[ i ] = new VertexElement();
			}
		}
		
		override public function dispose(): void
		{
			Renderer.unbindAllVertexFormat( this );
			
			super.dispose();
		}
		
		
		public static function create( numAttributes: int, ...rest ): VertexFormat
		{
			var vFormat: VertexFormat = new VertexFormat( numAttributes );
			
			var offset: uint = 0;
			var pointer: int = 0;
			for ( var i: int = 0; i < numAttributes; i++ )
			{
				var usage: AttributeUsageType = rest[ pointer++ ];
				var type: AttributeType = rest[ pointer++ ];
				var usageIndex: uint = rest[ pointer++ ];
				vFormat.setAttribute( i, 0, offset, usage, type, usageIndex );
				
				offset += msTypeSize[ type.index ];
			}
			
			vFormat.stride = offset;
			return vFormat;
		}
		
		
		[Inline]
		public static function getComponentSize( type: AttributeType ): int
		{
			return msComponentSize[ type.index ];
		}
		
		[Inline]
		public static function getNumComponents( type: AttributeType ): int
		{
			return msComponentSize[ type.index ];
		}
		
		[Inline]
		public static function getTypeSize( type: AttributeType ): int
		{
			return msTypeSize[ type.index ];
		}
		
		public function setAttribute( attribute: int, streamIndex: uint, offset: uint, usage: AttributeUsageType, type: AttributeType, usageIndex: int ): void
		{
			if ( 0 <= attribute && attribute < _numAttributes )
			{
				var element: VertexElement = _elements[ attribute ];
				element.streamIndex = streamIndex;
				element.offset = offset;
				element.type = type;
				element.usage = usage;
				element.usageIndex = usageIndex;
				return;
			}
			throw new IndexOutOfBoundsError();
		}
		
		public function set stride( stride: int ): void
		{
			Assert.isTrue( stride > 0, "Stride must be positive." );
			_stride = stride;
		}
		
		[Inline]
		public final function get numAttributes(): int
		{
			return _numAttributes;
		}
		
		[Inline]
		public final function getStreamIndex( attribute: int ): uint
		{
			if ( 0 <= attribute && attribute < _numAttributes )
			{
				return _elements[ attribute ].streamIndex;
			}
			throw new IndexOutOfBoundsError();
		}
		
		[Inline]
		public final function getOffset( attribute: int ): uint
		{
			if ( 0 <= attribute && attribute < _numAttributes )
			{
				return _elements[ attribute ].offset;
			}
			throw new IndexOutOfBoundsError();
		}
		
		[Inline]
		public final function getAttributeType( attribute: int ): AttributeType
		{
			if ( 0 <= attribute && attribute < _numAttributes )
			{
				return _elements[ attribute ].type;
			}
			return AttributeType.NONE;
		}
		
		[Inline]
		public final function getAttributeUsage( attribute: int ): AttributeUsageType
		{
			if ( 0 <= attribute && attribute < _numAttributes )
			{
				return _elements[ attribute ].usage;
			}
			return AttributeUsageType.NONE;
		}
		
		[Inline]
		public final function getUsageIndex( attribute: int ): uint
		{
			if ( 0 <= attribute && attribute < _numAttributes )
			{
				return _elements[ attribute ].usageIndex;
			}
			throw new IndexOutOfBoundsError();
		}
		
		public function getAttribute( attribute: int ): VertexElement
		{
			if ( 0 <= attribute && attribute < _numAttributes )
			{
				return _elements[ attribute ];
			}
			throw new IndexOutOfBoundsError();
		}
		
		[Inline]
		public final function get stride(): int
		{
			return _stride;
		}
		
		
		public function getIndex( usage: AttributeUsageType, usageIndex: uint = 0): int
		{
			for ( var i: int = 0; i < _numAttributes; ++i )
			{
				if ( _elements[ i ].usage == usage &&
					 _elements[ i ].usageIndex == usageIndex )
				{
					return i;
				}
			}
			return -1;
		}
		
	}

	
}