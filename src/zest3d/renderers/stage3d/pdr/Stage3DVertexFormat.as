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
package zest3d.renderers.stage3d.pdr {
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.renderers.stage3d.Stage3DMapping;
	import zest3d.renderers.stage3d.Stage3DRenderer;
	import zest3d.renderers.interfaces.IVertexFormat;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.AttributeUsageType;
	import zest3d.resources.VertexFormat;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Stage3DVertexFormat implements IVertexFormat, IDisposable 
	{
		
		private var _stride: int;
		
		private var _hasPosition: Boolean;
		private var _positionChannels: int;
		private var _positionType: String;
		private var _positionOffset: int;
		private var _positionIndex: int;
		
		private var _hasNormal: Boolean;
		private var _normalChannels: int;
		private var _normalType: String;
		private var _normalOffset: int;
		private var _normalIndex: int;
		
		private var _hasTangent: Boolean;
		private var _tangentChannels: int;
		private var _tangentType: String;
		private var _tangentOffset: int;
		private var _tangentIndex: int;
		
		private var _hasBinormal: Boolean;
		private var _binormalChannels: int;
		private var _binormalType: String;
		private var _binormalOffset: int;
		private var _binormalIndex: int;
		
		private var _hasTCoord: Array;
		private var _tCoordChannels: Array;
		private var _tCoordType: Array;
		private var _tCoordOffset: Array;
		private var _tCoordIndex: Array;
		
		private var _hasColor: Array;
		private var _colorChannels: Array;
		private var _colorType: Array;
		private var _colorOffset: Array;
		private var _colorIndex: Array;
		
		private var _hasBlendIndices: Boolean;
		private var _blendIndicesChannels: int;
		private var _blendIndicesType: String;
		private var _blendIndicesOffset: int;
		private var _blendIndicesIndex: int;
		
		private var _hasBlendWeight: Boolean;
		private var _blendWeightChannels: int;
		private var _blendWeightType: String;
		private var _blendWeightOffset: int;
		private var _blendWeightIndex: int;
		
		private var _hasFogCoord: Boolean;
		private var _fogCoordChannels: int;
		private var _fogCoordType: String;
		private var _fogCoordOffset: int;
		private var _fogCoordIndex: int;
		
		private var _hasPSize: Boolean;
		private var _pSizeChannels: int;
		private var _pSizeType: String;
		private var _pSizeOffset: int;
		private var _pSizeIndex: int;
		
		private var _vFormat: VertexFormat;
		
		protected var _isDisposed:Boolean;
		
		public function Stage3DVertexFormat( renderer:Renderer, vFormat: VertexFormat ) 
		{
			
			_stride = vFormat.stride;
			
			var type: int = 0;
			var i: int =  0;
			var unit: int = 0;
			
			_hasTCoord = [];
			_tCoordChannels = [];
			_tCoordType = [];
			_tCoordOffset = [];
			_tCoordIndex = [];
			
			_hasColor = [];
			_colorChannels = [];
			_colorType = [];
			_colorOffset = [];
			_colorIndex = [];
			
			i = vFormat.getIndex( AttributeUsageType.POSITION );
			if ( i >= 0 )
			{
				_hasPosition = true;
				type = vFormat.getAttributeType( i ).index;
				_positionChannels = Stage3DMapping.attributeChannels[ type ];
				_positionType = Stage3DMapping.attributeType[ type ];
				_positionOffset = vFormat.getOffset( i );
				_positionIndex = vFormat.getIndex( AttributeUsageType.POSITION, 0 );
			}
			
			i = vFormat.getIndex( AttributeUsageType.NORMAL );
			if ( i >= 0 )
			{
				_hasNormal = true;
				type = vFormat.getAttributeType( i ).index;
				_normalChannels = Stage3DMapping.attributeChannels[ type ];
				_normalType = Stage3DMapping.attributeType[ type ];
				_normalOffset = vFormat.getOffset( i );
				_normalIndex = vFormat.getIndex( AttributeUsageType.NORMAL, 0 );
			}
			
			i = vFormat.getIndex( AttributeUsageType.TANGENT );
			if ( i >= 0 )
			{
				_hasTangent = true;
				type = vFormat.getAttributeType( i ).index;
				_tangentChannels = Stage3DMapping.attributeChannels[ type ];
				_tangentType = Stage3DMapping.attributeType[ type ];
				_tangentOffset = vFormat.getOffset( i );
				_tangentIndex = vFormat.getIndex( AttributeUsageType.TANGENT, 0 );
			}
			
			i = vFormat.getIndex( AttributeUsageType.BINORMAL );
			if ( i >= 0 )
			{
				_hasBinormal = true;
				type = vFormat.getAttributeType( i ).index;
				_binormalChannels = Stage3DMapping.attributeChannels[ type ];
				_binormalType = Stage3DMapping.attributeType[ type ];
				_binormalOffset = vFormat.getOffset( i );
				_binormalIndex = vFormat.getIndex( AttributeUsageType.BINORMAL, 0 );
			}
			
			for ( unit = 0; unit < VertexFormat.MAX_TCOORD_UNITS; ++unit )
			{
				i = vFormat.getIndex( AttributeUsageType.TEXCOORD, unit );
				if ( i >= 0 )
				{
					_hasTCoord[ unit ] = true;
					type = vFormat.getAttributeType( i ).index;
					_tCoordChannels[ unit ] = Stage3DMapping.attributeChannels[ type ];
					_tCoordType[ unit ] = Stage3DMapping.attributeType[ type ];
					_tCoordOffset[ unit ] = vFormat.getOffset( i );
					_tCoordIndex[ unit ] = vFormat.getIndex( AttributeUsageType.TEXCOORD, unit );
				}
			}
			
			for ( unit = 0; unit < VertexFormat.MAX_COLOR_UNITS; ++unit )
			{
				i = vFormat.getIndex( AttributeUsageType.COLOR, unit );
				if ( i >= 0 )
				{
					_hasColor[ unit ] = true;
					type = vFormat.getAttributeType( i ).index;
					_colorChannels[ unit ] = Stage3DMapping.attributeChannels[ type ];
					_colorType[ unit ] = Stage3DMapping.attributeType[ type ];
					_colorOffset[ unit ] = vFormat.getOffset( i );
					_colorIndex[ unit ] = vFormat.getIndex( AttributeUsageType.COLOR, unit );
				}
			}
			
			i = vFormat.getIndex( AttributeUsageType.BLENDINDICES );
			if ( i >= 0 )
			{
				_hasBlendIndices = true;
				type = vFormat.getAttributeType( i ).index;
				_blendIndicesChannels = Stage3DMapping.attributeChannels[ type ];
				_blendIndicesType = Stage3DMapping.attributeType[ type ];
				_blendIndicesOffset = vFormat.getOffset( i );
				_blendIndicesIndex = vFormat.getIndex( AttributeUsageType.BLENDINDICES, 0 );
			}
			
			i = vFormat.getIndex( AttributeUsageType.BLENDWEIGHT );
			if ( i >= 0 )
			{
				_hasBlendWeight = true;
				type = vFormat.getAttributeType( i ).index;
				_blendWeightChannels = Stage3DMapping.attributeChannels[ type ];
				_blendWeightType = Stage3DMapping.attributeType[ type ];
				_blendWeightOffset = vFormat.getOffset( i );
				_blendWeightIndex = vFormat.getIndex( AttributeUsageType.BLENDWEIGHT, 0 );
			}
			
			i = vFormat.getIndex( AttributeUsageType.FOGCOORD );
			if ( i >= 0 )
			{
				_hasFogCoord = true;
				type = vFormat.getAttributeType( i ).index;
				_fogCoordChannels = Stage3DMapping.attributeChannels[ type ];
				_fogCoordType = Stage3DMapping.attributeType[ type ];
				_fogCoordOffset = vFormat.getOffset( i );
				_fogCoordIndex = vFormat.getIndex( AttributeUsageType.FOGCOORD, 0 );
			}
			
			i = vFormat.getIndex( AttributeUsageType.PSIZE );
			if ( i >= 0 )
			{
				_hasPSize = true;
				type = vFormat.getAttributeType( i ).index;
				_pSizeChannels = Stage3DMapping.attributeChannels[ type ];
				_pSizeType = Stage3DMapping.attributeType[ type ];
				_pSizeOffset = vFormat.getOffset( i );
				_pSizeIndex = vFormat.getIndex( AttributeUsageType.PSIZE, 0 );
			}
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_vFormat.dispose();
			_vFormat = null;
			
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function enable( renderer: Renderer): void
		{
			var agalRenderer: Stage3DRenderer = renderer as Stage3DRenderer;
			var context: Context3D = agalRenderer.data.context
			var buffer: VertexBuffer3D = Stage3DVertexBuffer.currentVBuffer;
			
			if ( _hasPosition )
			{
				context.setVertexBufferAt( _positionIndex, buffer, _positionOffset/4, _positionType );
			}
			
			if ( _hasNormal )
			{
				context.setVertexBufferAt( _normalIndex, buffer, _normalOffset/4, _normalType );
			}
			
			if ( _hasTangent )
			{
				context.setVertexBufferAt( _tangentIndex, buffer, _tangentOffset/4, _tangentType );
			}
			
			if ( _hasBinormal )
			{
				context.setVertexBufferAt( _binormalIndex, buffer, _binormalOffset/4, _binormalType );
			}
			
			
			var unit: int = 0;
			for ( unit = 0; unit < VertexFormat.MAX_TCOORD_UNITS; ++unit )
			{
				if ( _hasTCoord[ unit ] )
				{
					context.setVertexBufferAt( _tCoordIndex[ unit ], buffer, _tCoordOffset[ unit ]/4, _tCoordType[ unit ] );
				}
			}
			
			for ( unit = 0; unit < VertexFormat.MAX_COLOR_UNITS; ++unit )
			{
				if ( _hasColor[ unit ] )
				{
					context.setVertexBufferAt( _colorIndex[ unit ], buffer, _colorOffset[ unit ]/4, _colorType[ unit ] );
				}
			}
			
		}
		
		public function disable( renderer: Renderer ): void
		{
			
			var agalRenderer: Stage3DRenderer = renderer as Stage3DRenderer;
			var context: Context3D = agalRenderer.data.context;
			
			//TODO check here
			if ( _hasPosition )
			{
				context.setVertexBufferAt( _positionIndex, null );
			}
			
			if ( _hasNormal )
			{
				context.setVertexBufferAt( _normalIndex, null );
			}
			
			if ( _hasTangent )
			{
				context.setVertexBufferAt( _tangentIndex, null );
			}
			
			if ( _hasBinormal )
			{
				context.setVertexBufferAt( _binormalIndex, null );
			}
			
			var unit: int;
			for ( unit = 0; unit < VertexFormat.MAX_TCOORD_UNITS; ++unit )
			{
				if ( _hasTCoord[ unit ] )
				{
					context.setVertexBufferAt( _tCoordIndex[ unit ], null );
				}
			}
			
			for ( unit = 0; unit < VertexFormat.MAX_COLOR_UNITS; ++unit )
			{
				if ( _hasColor[ unit ] )
				{
					context.setVertexBufferAt( _colorIndex[ unit ], null );
				}
			}
			
			if ( _hasBlendIndices )
			{
				context.setVertexBufferAt( _blendIndicesIndex, null );
			}
			
			if ( _hasBlendWeight )
			{
				context.setVertexBufferAt( _blendWeightIndex, null );
			}
			
			if ( _hasFogCoord )
			{
				context.setVertexBufferAt( _fogCoordIndex, null );
			}
			
			if ( _hasPSize )
			{
				context.setVertexBufferAt( _pSizeIndex, null );
			}
		}
	}
}