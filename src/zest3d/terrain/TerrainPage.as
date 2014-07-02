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
package zest3d.terrain 
{
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import zest3d.primitives.StandardMesh;
	import zest3d.resources.VertexBufferAccessor;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.enum.UpdateType;
	import zest3d.scenegraph.TriMesh;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class TerrainPage extends TriMesh implements IDisposable 
	{
		
		protected var _size: int;
		protected var _sizeM1: int;
		protected var _heights: Array;
		protected var _origin: Array;
		protected var _minElevation: Number;
		protected var _maxElevation: Number;
		protected var _spacing: Number;
		protected var _invSpacing: Number;
		protected var _multiplier: Number;
		
		public function TerrainPage( vFormat: VertexFormat, size: int, heights: Array,
								origin:Array, minElevation: Number, maxElevation: Number, spacing: Number ) 
		{
			
			_size = size;
			_sizeM1 = size - 1;
			_heights = heights;
			_origin = origin;
			_minElevation = minElevation;
			_maxElevation = maxElevation;
			_spacing = spacing;
			
			Assert.isTrue( size == 3 || size == 5 || size == 9 || size == 17
					|| size == 33 || size == 65 || size == 129, "Invalid page size." );
			
			_invSpacing = 1 / _spacing;
			_multiplier = (_maxElevation - _minElevation ) / 0xFFFFFF; // TODO WARNING we need to divide based on the bit depth of uint can also use << bitshifting
			
			var ext: Number = _spacing * _sizeM1;
			var mesh: TriMesh = new StandardMesh( vFormat ).rectangle( _size, _size, ext, ext );
			_vFormat = vFormat;
			_vBuffer = mesh.vertexBuffer;
			_iBuffer = mesh.indexBuffer;
			
			super( _vFormat, _vBuffer, _iBuffer );
			
			mesh.dispose();
			mesh = null;
			
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, _vBuffer );
			var numVertices: int = _vBuffer.numElements;
			
			for ( var i: int = 0; i < numVertices; ++i )
			{
				var x: int = i % _size;
				var y: int = i / _size;
				
				vba.setPositionAt( i, [ getX( x ), getY( y ), getHeightAt( i ) ] );
				
			}
			
			updateModelSpace( UpdateType.NORMALS );
			
		}
		
		override public function dispose():void 
		{
			_heights = null;
			_origin = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get size(): int
		{
			return _size;
		}
		
		[Inline]
		public final function get heights(): Array
		{
			return _heights;
		}
		
		[Inline]
		public final function get origin(): Array
		{
			return _origin;
		}
		
		[Inline]
		public final function get minElevation(): Number
		{
			return _minElevation;
		}
		
		[Inline]
		public final function get maxElevation(): Number
		{
			return _maxElevation;
		}
		
		[Inline]
		public final function get spacing(): Number
		{
			return _spacing;
		}
		
		public function getHeight( x: Number, y: Number ): Number
		{
			var xGrid: Number = ( x - _origin[ 0 ] ) * _invSpacing;
			if ( xGrid < 0 || xGrid >= _sizeM1 )
			{
				return Number.MAX_VALUE;
			}
			
			var yGrid: Number = (y - origin[1]) * _invSpacing;
			if ( yGrid < 0 || yGrid >= _sizeM1 )
			{
				return Number.MAX_VALUE;
			}
			
			var fCol:Number = Math.floor( xGrid );
			var iCol: int = int( fCol );
			var fRow: Number = Math.floor( yGrid );
			var iRow: int = int( fCol );
			
			var index: int = iCol + _size * iRow;
			var dx: Number = xGrid - fCol;
			var dy: Number = yGrid - fRow;
			
			var h00: Number = 0;
			var h10: Number = 0;
			var h01: Number = 0;
			var h11: Number = 0;
			var height: Number = 0;
			
			if ( (iCol & 1) == (iRow & 1 ))
			{
				var diff: Number = dx - dy;
				h00 = _minElevation + _multiplier * _heights[ index ];
				h11 = _minElevation + _multiplier * _heights[ index + 1 + _size ];
				if ( diff > 0 )
				{
					h10 = _minElevation + _multiplier * _heights[ index + 1 ];
					height = ( 1 - diff - dy ) * h00 + diff * h10 + dy * h11;
				}
				else
				{
					h01 = _minElevation + _multiplier * _heights[ index + _size ];
					height = ( 1 + diff - dx) * h00 - diff * h01 + dx * h11;
				}
			}
			else
			{
				var sum: Number = dx + dy;
				h10 = _minElevation + _multiplier * _heights[ index + 1];
				h01 = _minElevation + _multiplier * _heights[ index + _size ];
				if ( sum <= 1 )
				{
					h00 = _minElevation + _multiplier * _heights[ index];
					height = (1 - sum) * h00 + dx * h10 + dy * h01;
				}
				else
				{
					h11 = _minElevation + _multiplier * _heights[ index + 1 + _size ];
					height = (sum - 1 ) * h11 + (1 - dy) * h10 + (1 - dx ) * h01;
				}
			}
			return height;
		}
		
		[Inline]
		protected final function getX( x: int ): Number
		{
			return _origin[ 0 ] + _spacing * x;
		}
		
		[Inline]
		protected final function getY( y: int ): Number
		{
			return _origin[ 1 ] + _spacing * y;
		}
		
		[Inline]
		protected final function getHeightAt( index: int ): Number
		{
			return _minElevation + _multiplier * _heights[ index ];
		}
		
	}

}