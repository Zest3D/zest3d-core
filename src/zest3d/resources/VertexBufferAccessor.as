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
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.resources.enum.AttributeType;
	import zest3d.resources.enum.AttributeUsageType;
	import zest3d.scenegraph.Visual;
	
	/**
	 * TODO refactor 
	 * WARNING THIS CLASS IS CURRENTLY USE FLOATS AT ALL TIMES
	 * IT IS POSSIBLE TO SET THE DATA TYPE AND SIZE ENTIRELY
	 * CONSIDER THIS.
	 * 
	 * Limits in the AS3 language prevent templates and generics
	 * this is an issue here as we're passing arrays to make up
	 * for this. I decided not to force data types to such things
	 * as float3 and float4, but the arrays are not type safe
	 * and generally considered bad practice.
	 * 
	 * @author Gary Paluk
	 */
	public class VertexBufferAccessor implements IDisposable 
	{
		
		private var _vFormat: VertexFormat;
		private var _vBuffer: VertexBuffer;
		private var _stride: int;
		private var _data: ByteArray;
		
		private var _position: int;
		private var _normal: int;
		private var _tangent: int;
		private var _binormal: int;
		private var _tCoord: Array;
		private var _color: Array;
		private var _blendIndices: int;
		private var _blendWeight: int;
		
		private var _positionChannels: int;
		private var _normalChannels: int;
		private var _tangentChannels: int;
		private var _binormalChannels: int;
		private var _tCoordChannels: Array;
		private var _colorChannels: Array;
		
		private var _positionSize: int;
		private var _normalSize: int;
		private var _tangentSize: int;
		private var _binormalSize: int;
		private var _tCoordSize: Array;
		private var _colorSize: Array;
		
		protected var _isDisposed:Boolean;
		
		public function VertexBufferAccessor( vFormat: VertexFormat, vBuffer: VertexBuffer ) 
		{
			
			_tCoord = [];
			_tCoordChannels = [];
			_color = [];
			_colorChannels = [];
			_tCoordSize = [];
			_colorSize = [];
			
			_data = new ByteArray();
			
			var i: int;
			for ( i = 0; i < VertexFormat.MAX_TCOORD_UNITS; ++i )
			{
				_tCoord[ i ] = 0;
				_tCoordChannels[ i ] = 0;
				_tCoordSize[ i ] = 0;
			}
			
			for ( i = 0; i < VertexFormat.MAX_COLOR_UNITS; ++i )
			{
				_color[ i ] = 0;
				_colorChannels[ i ] = 0;
				_colorSize[ i ] = 0;
			}
			
			applyToData( vFormat, vBuffer );
			
			_isDisposed = true;
		}
		
		public function dispose(): void
		{
			//TODO VertexBufferAccessor::dispose();
			
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function applyToData( vFormat: VertexFormat, vBuffer: VertexBuffer ): void
		{
			_vFormat = vFormat;
			_vBuffer = vBuffer;
			
			initialize();
		}
		
		public function applyToVisual( visual: Visual ): void
		{
			_vFormat = visual.vertexFormat;
			_vBuffer = visual.vertexBuffer;
			
			initialize();
		}
		
		[Inline]
		public final function get data(): ByteArray
		{
			return _data;
		}
		
		[Inline]
		public final function get numVertices(): int
		{
			return _vBuffer.numElements;
		}
		
		[Inline]
		public final function get stride(): int
		{
			return _stride;
		}
		
		
		
		/////////////////////////////////////////////////
		// positions
		/////////////////////////////////////////////////
		[Inline]
		public final function setPositionAt( index: int, data: Array ): void
		{
			/*
			if ( data.length != _positionChannels )
			{
				throw new Error( "position array size does not match position size." );
			}
			*/
			
			_data.position = ( _position + index * _stride );
			for ( var i: int = 0; i < _positionChannels; i++ )
			{
				_data.writeFloat( data[ i ] );
			}
			
		}
		
		[Inline]
		public final function getPositionAt( index: int ): Array
		{
			var data: Array = [];
			
			_data.position = ( _position + index * _stride );
			for ( var i: int = 0; i < _positionChannels; i++ )
			{
				data[ i ] = _data.readFloat();
			}
			return data;
		}
		
		
		[Inline]
		public final function hasPosition(): Boolean
		{
			// TODO fix as at the start of the ByteArray VertexAccessBuffer::hasPosition()
			return true; // WARNING ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		}
		
		[Inline]
		public final function getPositionChannels(): int
		{
			return _positionChannels;
		}
		
		
		
		
		/////////////////////////////////////////////////
		// normals
		/////////////////////////////////////////////////
		[Inline]
		public final function setNormalAt( index: int, data: Array ): void
		{
			/*
			if ( data.length != _normalChannels )
			{
				throw new Error( "normal array size does not match normal size." );
			}
			*/
			_data.position = ( _normal + index * _stride );
			for ( var i: int = 0; i < _normalChannels; i++ )
			{
				_data.writeFloat( data[ i ] );
			}
		}
		
		[Inline]
		public final function getNormalAt( index: int ): Array
		{
			var data: Array = [];
			
			_data.position = ( _normal + index * _stride );
			for ( var i: int = 0; i < _normalChannels; i++ )
			{
				data[ i ] = _data.readFloat();
			}
			return data;
		}
		
		[Inline]
		public final function hasNormal(): Boolean
		{
			return _normal != 0;
		}
		
		[Inline]
		public final function getNormalChannels(): int
		{
			return _normalChannels;
		}
		
		
		
		/////////////////////////////////////////////////
		// tangents
		/////////////////////////////////////////////////
		[Inline]
		public final function setTangentAt( index: int, data: Array ): void
		{/*
			if ( data.length != _tangentChannels )
			{
				throw new Error( "tangents array size does not match tangent size." );
			}
			*/
			_data.position = ( _tangent + index * _stride );
			for ( var i: int = 0; i < _tangentChannels; i++ )
			{
				_data.writeFloat( data[ i ] );
			}
		}
		
		
		[Inline]
		public final function getTangentAt( index: int ): Array
		{
			var data: Array = [];
			
			_data.position = ( _tangent + index * _stride );
			for ( var i: int = 0; i < _tangentChannels; i++ )
			{
				data[ i ] = _data.readFloat();
			}
			return data;
		}
		
		[Inline]
		public final function hasTangent(): Boolean
		{
			return _tangent != 0;
		}
		
		[Inline]
		public final function getTangentChannels(): int
		{
			return _tangentChannels;
		}
		
		
		
		
		
		
		/////////////////////////////////////////////////
		// binormal
		/////////////////////////////////////////////////
		[Inline]
		public final function setBinormalAt( index: int, data: Array ): void
		{/*
			if ( data.length != _binormalChannels )
			{
				throw new Error( "binormal array size does not match binormal size." );
			}
			*/
			_data.position = ( _binormal + index * _stride );
			for ( var i: int = 0; i < _binormalChannels; i++ )
			{
				_data.writeFloat( data[ i ] );
			}
		}
		
		[Inline]
		public final function getBinormalAt( index: int ): Array
		{
			var data: Array = [];
			
			_data.position = ( _binormal + index * _stride );
			for ( var i: int = 0; i < _binormalChannels; i++ )
			{
				data[ i ] = _data.readFloat();
			}
			return data;
		}
		
		[Inline]
		public final function hasBinormal(): Boolean
		{
			return _binormal != 0;
		}
		
		[Inline]
		public final function getBinormalChannels(): int
		{
			return _binormalChannels;
		}
		
		
		
		
		
		/////////////////////////////////////////////////
		// tCoord
		/////////////////////////////////////////////////
		[Inline]
		public final function setTCoordAt( unit: int, index: int, data: Array ): void
		{
			
			// TODO check a way to prevent error throws here
			/*
			if ( data.length != _tCoordChannels[ unit ] )
			{
				throw new Error( "tcoord array size does not match tcoord size." );
			}
			*/
			
			_data.position = ( _tCoord[ unit ] + index * _stride );
			for ( var i: int = 0; i < _tCoordChannels[ unit ]; i++ )
			{
				_data.writeFloat( data[ i ] );
			}
		}
		
		[Inline]
		public final function getTCoordAt( unit: int, index: int ): Array
		{
			var data: Array = [];
			
			_data.position = ( _tCoord[ unit ] + index * _stride );
			for ( var i: int = 0; i < _tCoordChannels[ unit ]; i++ )
			{
				data[ i ] = _data.readFloat();
			}
			return data;
		}
		
		[Inline]
		public final function hasTCoord( unit: int ): Boolean
		{
			return _tCoord[ unit ] != 0;
		}
		
		[Inline]
		public final function getTCoordChannels( unit: int ): int
		{
			return _tCoordChannels[ unit ];
		}
		
		
		
		
		
		
		/////////////////////////////////////////////////
		// color
		/////////////////////////////////////////////////
		[Inline]
		public final function setColorAt( unit: int, index: int, data: Array ): void
		{/*
			if ( data.length != _colorChannels[ unit ] )
			{
				throw new Error( "tangents array size does not match tangent size." );
			}
			*/
			_data.position = ( _color[ unit ] + index * _stride );
			for ( var i: int = 0; i < _colorChannels[ unit ]; i++ )
			{
				_data.writeFloat( data[ i ] );
			}
		}
		
		[Inline]
		public final function getColorAt( unit: int, index: int ): Array
		{
			var data: Array = [];
			
			_data.position = ( _color[ unit ] + index * _stride );
			for ( var i: int = 0; i < _colorChannels[ unit ]; i++ )
			{
				data[ i ] = _data.readFloat();
			}
			return data;
		}
		
		[Inline]
		public final function hasColor( unit: int ): Boolean
		{
			return _color[ unit ] != 0;
		}
		
		[Inline]
		public final function getColorChannels( unit: int ): int
		{
			return _colorChannels[ unit ];
		}
		
		
		
		
		
		/////////////////////////////////////////////////
		// blend indices
		/////////////////////////////////////////////////
		[Inline]
		public final function setBlendIndicesAt( index: int, data: Number ): void
		{
			_data.position = ( _blendIndices + index * _stride );
			_data.writeFloat( data );
		}
		
		[Inline]
		public final function getBlendIndicesAt( index: int ): Number
		{
			_data.position = ( _blendIndices + index * _stride );
			return _data.readFloat();
		}
		
		[Inline]
		public final function hasBlendIndices( ): Boolean
		{
			return _blendIndices != 0;
		}
		
		
		
		
		/////////////////////////////////////////////////
		// blend weight
		/////////////////////////////////////////////////
		[Inline]
		public final function setBlendWeightAt( index: int, data: Number ): void
		{
			_data.position = ( _blendWeight + index * _stride );
			_data.writeFloat( data );
		}
		
		[Inline]
		public final function getBlendWeightAt( index: int ): Number
		{
			_data.position = ( _blendWeight + index * _stride );
			return _data.readFloat();
		}
		
		[Inline]
		public final function hasBlendWeight( ): Boolean
		{
			return _blendWeight != 0;
		}
		
		
		
		
		
		
		private function initialize(): void
		{
			_stride = _vFormat.stride;
			_data = _vBuffer.data;
			
			var baseType: int = AttributeUsageType.NONE.index;
			var type: AttributeType;
			
			// position
			var index: int = _vFormat.getIndex( AttributeUsageType.POSITION );
			if ( index >= 0 )
			{
				_position = _vFormat.getOffset( index );
				type = _vFormat.getAttributeType( index );
				_positionChannels = type.index - baseType;
				// _positionSize = VertexFormat.getComponentSize( _vFormat.getAttributeType( index ) );
				
				if ( _positionChannels > 4 )
				{
					_positionChannels = 0;
				}
			}
			else
			{
				_position = 0;
				_positionChannels = 0;
			}
			
			// normal
			index = _vFormat.getIndex( AttributeUsageType.NORMAL );
			if ( index >= 0 )
			{
				_normal = _vFormat.getOffset( index );
				type = _vFormat.getAttributeType( index );
				_normalChannels = type.index - baseType;
				if ( _normalChannels > 4 )
				{
					_normalChannels = 0;
				}
			}
			else
			{
				_normal = 0;
				_normalChannels = 0;
			}
			
			// tangent
			index = _vFormat.getIndex( AttributeUsageType.TANGENT );
			if ( index >= 0 )
			{
				_tangent = _vFormat.getOffset( index );
				type = _vFormat.getAttributeType( index );
				_tangentChannels = type.index - baseType;
				
				if ( _tangentChannels > 4 )
				{
					_tangentChannels = 0;
				}
			}
			else
			{
				_tangent = 0;
				_tangentChannels = 0;
			}
			
			
			
			// binormal
			index = _vFormat.getIndex( AttributeUsageType.BINORMAL );
			if ( index >= 0 )
			{
				_binormal = _vFormat.getOffset( index );
				type = _vFormat.getAttributeType( index );
				_binormalChannels = type.index - baseType;
				if ( _binormalChannels > 4 )
				{
					_binormalChannels = 0;
				}
			}
			else
			{
				_binormal = 0;
				_binormalChannels = 0;
			}
			
			
			
			var unit: uint;
			for ( unit = 0; unit < VertexFormat.MAX_TCOORD_UNITS; ++unit )
			{
				index = _vFormat.getIndex( AttributeUsageType.TEXCOORD, unit );
				if ( index >= 0 )
				{
					_tCoord[ unit ] = _vFormat.getOffset( index );
					type = _vFormat.getAttributeType( index );
					_tCoordChannels[ unit ] = type.index - baseType;
					if ( _tCoordChannels[ unit ] > 4 )
					{
						_tCoordChannels[ unit ] = 0;
					}
				}
				else
				{
					_tCoord[ unit ] = 0;
					_tCoordChannels[ unit ] = 0;
				}
			}
			
			
			
			
			for (unit = 0; unit < VertexFormat.MAX_COLOR_UNITS; ++unit )
			{
				index = _vFormat.getIndex( AttributeUsageType.COLOR, unit );
				if ( index >= 0 )
				{
					_color[ unit ] = _vFormat.getOffset( index );
					type = _vFormat.getAttributeType( index );
					_colorChannels[ unit ] = type.index - baseType;
					if ( _colorChannels[ unit ] > 4 )
					{
						_colorChannels[ unit ] = 0;
					}
				}
				else
				{
					_color[ unit ] = 0;
					_colorChannels[ unit ] = 0;
				}
			}
			
			
			
			// blend indices
			index = _vFormat.getIndex( AttributeUsageType.BLENDINDICES );
			if ( index >= 0 )
			{
				_blendIndices = _vFormat.getOffset( index );
			}
			else
			{
				_blendIndices = 0;
			}
			
			
			index = _vFormat.getIndex( AttributeUsageType.BLENDWEIGHT );
			if ( index >= 0 )
			{
				_blendWeight = _vFormat.getOffset( index );
			}
			else
			{
				_blendWeight = 0;
			}
			
		}
		
		
		
	}

}