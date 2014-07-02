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
package zest3d.primitives 
{
	import flash.utils.ByteArray;
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.AVector;
	import plugin.math.base.MathHelper;
	import zest3d.datatypes.Transform;
	import zest3d.resources.enum.AttributeType;
	import zest3d.resources.enum.AttributeUsageType;
	import zest3d.resources.enum.BufferUsageType;
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexBufferAccessor;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.enum.UpdateType;
	import zest3d.scenegraph.TriMesh;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class StandardMesh implements IDisposable 
	{
		
		protected static const MAX_UNITS: int = VertexFormat.MAX_TCOORD_UNITS;
		
		protected var _vFormat: VertexFormat;
		protected var _transform: Transform;
		
		protected var _isStatic: Boolean;
		protected var _inside: Boolean;
		protected var _hasNormals: Boolean;
		
		protected var _hasTCoords: Array;
		
		protected var _usage: BufferUsageType;
		
		private var _isDisposed:Boolean;
		
		public function StandardMesh( vFormat: VertexFormat, isStatic: Boolean = true, inside: Boolean = false, transform: Transform = null ) 
		{
			
			_vFormat = vFormat;
			_isStatic = isStatic;
			_inside = inside;
			_hasNormals = false;
			_hasTCoords = [];
			
			//TODO check that this should default to the identity transform
			if ( transform )
			{
				_transform = transform;
			}
			else
			{
				_transform = Transform.IDENTITY;
			}
			
			_usage = isStatic ? BufferUsageType.STATIC : BufferUsageType.DYNAMIC;
			
			var posIndex: int = _vFormat.getIndex( AttributeUsageType.POSITION );
			Assert.isTrue( posIndex == 0, "Positions must be in 0" );
			
			var posType: AttributeType = _vFormat.getAttributeType( posIndex );
			Assert.isTrue( posType == AttributeType.FLOAT3, "Positions must be 3-tuples of floats." );
			
			var norIndex: int = _vFormat.getIndex( AttributeUsageType.NORMAL );
			if ( norIndex >= 0 )
			{
				var norType: AttributeType = _vFormat.getAttributeType( norIndex );
				
				if ( norType == AttributeType.FLOAT3 )
				{
					_hasNormals = true;
				}
			}
			
			for ( var unit: int = 0; unit < MAX_UNITS; ++unit )
			{
				_hasTCoords[ unit ] = false;
				
				var tcdIndex: int = _vFormat.getIndex( AttributeUsageType.TEXCOORD, unit );
				if ( tcdIndex >= 0 )
				{
					var tcdType: AttributeType = vFormat.getAttributeType( tcdIndex );
					
					if ( tcdType == AttributeType.FLOAT2 )
					{
						_hasTCoords[ unit ] = true;
					}
				}
			}
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_vFormat.dispose();
			
			_vFormat = null;
			_usage = null;
			_hasTCoords = null;
			
			if ( _transform )
			{
				_transform.dispose();
				_transform = null;
			}
			
			_isDisposed = true;
		}
		
		/**
		 * cylinder
		 */
		public function cylinder( axisSamples: int, radialSamples: int, radius: Number, height: Number, open: Boolean ): TriMesh
		{
			var mesh: TriMesh;
			var unit: int;
			var tCoord: Array = [];
			
			var numVertices: int;
			var vBuffer: VertexBuffer;
			var vba: VertexBufferAccessor;
			
			if ( open )
			{
				numVertices = axisSamples * (radialSamples + 1);
				var numTriangles: int = 2 * (axisSamples - 1) * radialSamples;
				var numIndices: int = 3 * numTriangles;
				var stride: int = _vFormat.stride;
				
				vBuffer = new VertexBuffer( numVertices, stride, _usage );
				vba = new VertexBufferAccessor( _vFormat, vBuffer );
				
				// generate geometry
				var invRS: Number = 1 / radialSamples;
				var invASm1: Number = 1 / (axisSamples - 1);
				var halfHeight: Number = 0.5 * height;
				
				var r: int;
				var a: int;
				var aStart: int;
				var i: int;
				
				var cs: Vector.<Number> = new Vector.<Number>( radialSamples + 1 );
				var sn: Vector.<Number> = new Vector.<Number>( radialSamples + 1 );
				for ( r = 0; r < radialSamples; ++r )
				{
					var angle: Number = MathHelper.TWO_PI * invRS  * r;
					cs[ r ] = Math.cos( angle );
					sn[ r ] = Math.sin( angle );
				}
				cs[ radialSamples ] = cs[ 0 ];
				sn[ radialSamples ] = sn[ 0 ];
				
				// generate the cylinder
				for ( a = 0, i = 0; a < axisSamples; ++a )
				{
					var axisFraction: Number = a * invASm1;
					var z: Number = -halfHeight + height * axisFraction;
					
					var sliceCenter: APoint = new APoint( 0, 0, z );
					
					var save: int = i;
					for ( r = 0; r < radialSamples; ++r )
					{
						var radialFraction: Number = r * invRS;
						var normal: AVector = new AVector( cs[ r ], sn[ r ], 0 );
						
						var sCenterRadNor: APoint = sliceCenter.addAVector( normal.scale( radius ) );
						vba.setPositionAt( i, [ sCenterRadNor.x, sCenterRadNor.y, sCenterRadNor.z ] );
						
						if ( _hasNormals )
						{
							if ( _inside )
							{
								vba.setNormalAt( i, [ -normal.x, -normal.y, -normal.z ] );
							}
							else
							{
								vba.setNormalAt( i, [ normal.x, normal.y, normal.z ] );
							}
						}
						
						tCoord = [ radialFraction, axisFraction ];
						for ( unit = 0; unit < MAX_UNITS; ++unit )
						{
							if ( _hasTCoords[ unit ] )
							{
								vba.setTCoordAt( unit, i, tCoord );
							}
						}
						
						++i;
					}
					
					vba.setPositionAt( i, vba.getPositionAt( save ) );
					if ( _hasNormals )
					{
						vba.setNormalAt( i, vba.getNormalAt( save ) );
					}
					
					tCoord = [ 1, axisFraction ];
					for ( unit = 0; unit < MAX_UNITS; ++unit )
					{
						if ( _hasTCoords[ unit ] )
						{
							vba.setTCoordAt( 0, i, tCoord );
						}
					}
					
					++i;
				}
				transformData( vba );
				
				var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
				var indices: int;
				for ( a = 0, aStart = 0; a < axisSamples - 1; ++a )
				{
					var i0: int = aStart;
					var i1: int = i0 +  1;
					aStart += radialSamples + 1;
					var i2: int = aStart;
					var i3: int = i2 + 1;
					
					for ( i = 0; i < radialSamples; ++i, indices += 6 )
					{
						if ( _inside )
						{
							iBuffer.setIndexAt( indices + 0, i0++ );
							iBuffer.setIndexAt( indices + 1, i2 );
							iBuffer.setIndexAt( indices + 2, i1 );
							iBuffer.setIndexAt( indices + 3, i1++ );
							iBuffer.setIndexAt( indices + 4, i2++ );
							iBuffer.setIndexAt( indices + 5, i3++ );
						}
						else
						{
							iBuffer.setIndexAt( indices + 0, i0++ );
							iBuffer.setIndexAt( indices + 1, i1 );
							iBuffer.setIndexAt( indices + 2, i2 );
							iBuffer.setIndexAt( indices + 3, i1++ );
							iBuffer.setIndexAt( indices + 4, i3++ );
							iBuffer.setIndexAt( indices + 5, i2++ );
						}
					}
				}
				
				cs = null;
				sn = null;
				
				mesh = new TriMesh( _vFormat, vBuffer, iBuffer );
			}
			else
			{
				mesh = sphere( axisSamples, radialSamples, radius );
				vBuffer = mesh.vertexBuffer;
				numVertices = vBuffer.numElements;
				
				vba = new VertexBufferAccessor( _vFormat,  vBuffer );
				
				// flatten at the poles
				var hDiv2: Number = 0.5 * height;
				
				var numVertM2: int = numVertices - 2;
				var southPole: Array = vba.getPositionAt( numVertM2 );
				southPole[ 2 ] = -hDiv2;
				vba.setPositionAt( numVertM2, southPole );
				
				var numVertM1: int = numVertices - 1;
				var northPole: Array = vba.getPositionAt( numVertM1 );
				northPole[ 2 ] = +hDiv2;
				vba.setPositionAt( numVertM1, northPole );
				
				var zFactor: Number = 2 / ( axisSamples - 1 );
				var tmp0: Number = radius * ( -1 + zFactor );
				var tmp1: Number = 1 / ( radius * ( 1 - zFactor ) );
				
				for ( var j: int = 0; j < numVertices - 2; ++j )
				{
					var pos: Array = vba.getPositionAt( j );
					pos[ 2 ] = hDiv2 * ( -1 + tmp1 * (pos[2] - tmp0 ) );
					var adjust: Number = radius * ( 1 / Math.sqrt( pos[0] * pos[0] + pos[ 1 ] * pos[1] ));
					pos[ 0 ] *= adjust;
					pos[ 1 ] *= adjust;
					
					vba.setPositionAt( j, pos );
				}
				
				transformData( vba );
				
				if ( _hasNormals )
				{
					mesh.updateModelSpace( UpdateType.NORMALS );
				}
			}
			
			var maxDist: Number = Math.sqrt( radius * radius + height * height );
			mesh.modelBound.center = APoint.ORIGIN;
			mesh.modelBound.radius = maxDist;
			
			return mesh;
		}
		
		/**
		 * disk
		 */
		public function disk( shellSamples: int, radialSamples: int, radius: Number ): TriMesh
		{
			var rsm1: int = radialSamples - 1;
			var ssm1: int = shellSamples - 1;
			var numVertices: int = 1 + radialSamples * ssm1;
			var numTriangles: int = radialSamples * ( 2 * ssm1 - 1 );
			var numIndices: int = 3 * numTriangles;
			var stride: int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices, stride, _usage );
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			
			// generate geometry
			vba.setPositionAt( 0, [ 0, 0, 0 ] );
			if ( _hasNormals )
			{
				vba.setNormalAt( 0, [ 0, 0, 1 ] );
			}
			
			var tCoord: Array = [ 0.5, 0.5 ];
			var unit: int;
			for ( unit = 0; unit < MAX_UNITS; ++unit )
			{
				if ( _hasTCoords[ unit ] )
				{
					vba.setTCoordAt( unit, 0, tCoord );
				}
			}
			
			var invSSm1: Number = 1 / ssm1;
			var invRS: Number = 1 / radialSamples;
			for ( var r: int = 0; r < radialSamples; ++r )
			{
				var angle: Number = MathHelper.TWO_PI * invRS * r;
				var cs: Number = Math.cos( angle );
				var sn: Number = Math.sin( angle );
				var radial: AVector = new AVector( cs, sn, 0 );
				
				for ( var s: int = 1; s < shellSamples; ++s )
				{
					var fraction: Number = invSSm1 * s;
					var fracRadial: AVector = radial.scale( fraction );
					var i: int = s + ssm1 * r;
					
					var radMulFrac: AVector = fracRadial.scale( radius );
					
					vba.setPositionAt( i, [ radMulFrac.x, radMulFrac.y, radMulFrac.z ] );
					if ( _hasNormals )
					{
						vba.setNormalAt( i, [ 0, 0, 1 ] );
					}
					
					tCoord[ 0 ] = 0.5 + 0.5 * fracRadial.x;
					tCoord[ 1 ] = 0.5 + 0.5 * fracRadial.y;
					for ( unit = 0; unit < MAX_UNITS; ++unit )
					{
						if ( _hasTCoords[ unit ] )
						{
							vba.setTCoordAt( unit, i, tCoord );
						}
					}
				}
			}
			transformData( vba );
			
			// generate indices
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			
			var indices: int;
			var r0: int;
			var r1: int;
			var t: int;
			for ( r0 = rsm1, r1 = 0, t = 0; r1 < radialSamples; r0 = r1++ )
			{
				iBuffer.setIndexAt( indices + 0, 0 );
				iBuffer.setIndexAt( indices + 1, 1 + ssm1 * r0 );
				iBuffer.setIndexAt( indices + 2, 1 + ssm1 * r1 );
				indices += 3;
				++t;
				for ( s = 1; s < ssm1; ++s, indices += 6 )
				{
					var i00: int = s + ssm1 * r0;
					var i01: int = s + ssm1 * r1;
					var i10: int = i00 + 1;
					var i11: int = i01 + 1;
					
					iBuffer.setIndexAt( indices + 0, i00 );
					iBuffer.setIndexAt( indices + 1, i10 );
					iBuffer.setIndexAt( indices + 2, i11 );
					iBuffer.setIndexAt( indices + 3, i00 );
					iBuffer.setIndexAt( indices + 4, i11 );
					iBuffer.setIndexAt( indices + 5, i01 );
					
					t += 2;
				}
			}
			
			return new TriMesh( _vFormat, vBuffer, iBuffer );
		}
		
		/**
		 * icosahedron
		 */
		public function icosahedron(): TriMesh
		{
			var goldenRatio: Number = 0.5 * ( 1 + Math.sqrt( 5 ) );
			var invRoot: Number = 1 / Math.sqrt( 1 + goldenRatio * goldenRatio );
			var u: Number = goldenRatio * invRoot;
			var v: Number = invRoot;
			
			var numVertices: int = 12;
			var numTriangles: int = 20;
			var numIndices: int = 3 * numTriangles;
			var stride: int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices, stride, _usage );
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			
			// generate geometry
			vba.setPositionAt( 0, [ u, v, 0 ] );
			vba.setPositionAt( 1, [-u, v, 0 ] );
			vba.setPositionAt( 2, [ u, -v,0 ] );
			vba.setPositionAt( 3, [-u, -v,0 ] );
			vba.setPositionAt( 4, [ v, 0, u ] );
			vba.setPositionAt( 5, [ v, 0, -u ] );
			vba.setPositionAt( 6, [-v, 0,  u ] );
			vba.setPositionAt( 7, [-v, 0, -u ] );
			vba.setPositionAt( 8, [ 0,  u, v ] );
			vba.setPositionAt( 9, [ 0, -u, v ] );
			vba.setPositionAt( 10, [ 0,  u, -v ] );
			vba.setPositionAt( 11, [ 0, -u, -v ] );
			
			createPlatonicNormals( vba );
			createPlatonicUVs( vba );
			transformData( vba );
			
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			iBuffer.setIndexAt( 0, 0 );
			iBuffer.setIndexAt( 1, 8 );
			iBuffer.setIndexAt( 2, 4 );
			iBuffer.setIndexAt( 3, 0 );
			iBuffer.setIndexAt( 4, 5 );
			iBuffer.setIndexAt( 5, 10 );
			iBuffer.setIndexAt( 6, 2 );
			iBuffer.setIndexAt( 7, 4 );
			iBuffer.setIndexAt( 8, 9 );
			iBuffer.setIndexAt( 9,  2 );
			iBuffer.setIndexAt( 10, 11 );
			iBuffer.setIndexAt( 11, 5 );
			iBuffer.setIndexAt( 12, 1 );
			iBuffer.setIndexAt( 13, 6 );
			iBuffer.setIndexAt( 14, 8 );
			iBuffer.setIndexAt( 15, 1 );
			iBuffer.setIndexAt( 16, 10 );
			iBuffer.setIndexAt( 17, 7 );
			iBuffer.setIndexAt( 18, 3 );
			iBuffer.setIndexAt( 19, 9 );
			iBuffer.setIndexAt( 20, 6 );
			iBuffer.setIndexAt( 21, 3 );
			iBuffer.setIndexAt( 22, 7 );
			iBuffer.setIndexAt( 23, 11 );
			iBuffer.setIndexAt( 24, 0 );
			iBuffer.setIndexAt( 25, 10 );
			iBuffer.setIndexAt( 26, 8 );
			iBuffer.setIndexAt( 27, 1 );
			iBuffer.setIndexAt( 28,  8 );
			iBuffer.setIndexAt( 29, 10 );
			iBuffer.setIndexAt( 30, 2 );
			iBuffer.setIndexAt( 31, 9 );
			iBuffer.setIndexAt( 32, 11 );
			iBuffer.setIndexAt( 33, 3 );
			iBuffer.setIndexAt( 34, 11 );
			iBuffer.setIndexAt( 35, 9  );
			iBuffer.setIndexAt( 36, 4 );
			iBuffer.setIndexAt( 37, 2 );
			iBuffer.setIndexAt( 38, 0 );
			iBuffer.setIndexAt( 39,5 );
			iBuffer.setIndexAt( 40, 0 );
			iBuffer.setIndexAt( 41, 2 );
			iBuffer.setIndexAt( 42, 6 );
			iBuffer.setIndexAt( 43, 1 );
			iBuffer.setIndexAt( 44, 3 );
			iBuffer.setIndexAt( 45, 7 );
			iBuffer.setIndexAt( 46, 3 );
			iBuffer.setIndexAt( 47, 1 );
			iBuffer.setIndexAt( 48, 8 );
			iBuffer.setIndexAt( 49, 6 );
			iBuffer.setIndexAt( 50, 4 );
			iBuffer.setIndexAt( 51, 9 );
			iBuffer.setIndexAt( 52, 4 );
			iBuffer.setIndexAt( 53, 6 );
			iBuffer.setIndexAt( 54, 10 );
			iBuffer.setIndexAt( 55, 5 );
			iBuffer.setIndexAt( 56, 7 );
			iBuffer.setIndexAt( 57, 11 );
			iBuffer.setIndexAt( 58, 7 );
			iBuffer.setIndexAt( 59, 5 );
			
			if ( _inside )
			{
				reverseTriangleOrder( numTriangles, iBuffer.data );
			}
			
			return new TriMesh( _vFormat, vBuffer, iBuffer );
		}
		
		
		/**
		 * dodecahedron
		 */
		public function dodecahedron(): TriMesh
		{
			var a: Number = 1 / Math.sqrt( 3 );
			var b: Number = Math.sqrt( (3 - Math.sqrt(5) ) / 6 );
			var c: Number = Math.sqrt( (3 + Math.sqrt(5) ) / 6 );
			
			var numVertices: int = 20;
			var numTriangles: int = 36;
			var numIndices: int = 3 * numTriangles;
			var stride: int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices,  stride, _usage );
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			
			vba.setPositionAt( 0, [  a, a, a ] );
			vba.setPositionAt( 1, [  a, a,-a ] );
			vba.setPositionAt( 2, [  a,-a, a ] );
			vba.setPositionAt( 3, [  a,-a,-a ] );
			vba.setPositionAt( 4, [ -a, a, a ] );
			vba.setPositionAt( 5, [ -a, a,-a ] );
			vba.setPositionAt( 6, [ -a,-a, a ] );
			vba.setPositionAt( 7, [ -a,-a,-a ] );
			vba.setPositionAt( 8, [  b,  c, 0 ] );
			vba.setPositionAt( 9, [ -b,  c, 0 ] );
			vba.setPositionAt(10, [  b, -c, 0 ] );
			vba.setPositionAt(11, [ -b, -c, 0 ] );
			vba.setPositionAt(12, [  c, 0,  b ] );
			vba.setPositionAt(13, [  c, 0, -b ] );
			vba.setPositionAt(14, [ -c, 0,  b ] );
			vba.setPositionAt(15, [ -c, 0, -b ] );
			vba.setPositionAt(16, [ 0,  b,  c ] );
			vba.setPositionAt(17, [ 0, -b,  c ] );
			vba.setPositionAt(18, [ 0,  b, -c ] );
			vba.setPositionAt(19, [ 0, -b, -c ] );
			
			createPlatonicNormals( vba );
			createPlatonicUVs( vba );
			transformData( vba );
			
			// generate indices
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			iBuffer.setIndexAt( 0, 0 );
			iBuffer.setIndexAt( 1, 8 );
			iBuffer.setIndexAt( 2, 9 );
			iBuffer.setIndexAt( 3, 0 );
			iBuffer.setIndexAt( 4, 9 );
			iBuffer.setIndexAt( 5, 4 );
			iBuffer.setIndexAt( 6, 0 );
			iBuffer.setIndexAt( 7, 4 );
			iBuffer.setIndexAt( 8, 16 );
			iBuffer.setIndexAt( 9, 0 );
			iBuffer.setIndexAt( 10, 12 );
			iBuffer.setIndexAt( 11, 13 );
			iBuffer.setIndexAt( 12, 0 );
			iBuffer.setIndexAt( 13, 13 );
			iBuffer.setIndexAt( 14, 1 );
			iBuffer.setIndexAt( 15, 0 );
			iBuffer.setIndexAt( 16, 1 );
			iBuffer.setIndexAt( 17, 8 );
			iBuffer.setIndexAt( 18, 0 );
			iBuffer.setIndexAt( 19, 16 );
			iBuffer.setIndexAt( 20, 17 );
			iBuffer.setIndexAt( 21, 0 );
			iBuffer.setIndexAt( 22, 17 );
			iBuffer.setIndexAt( 23, 2 );
			iBuffer.setIndexAt( 24, 0 );
			iBuffer.setIndexAt( 25, 2 );
			iBuffer.setIndexAt( 26, 12 );
			iBuffer.setIndexAt( 27, 8 );
			iBuffer.setIndexAt( 28, 1 );
			iBuffer.setIndexAt( 29, 18 );
			iBuffer.setIndexAt( 30, 8 );
			iBuffer.setIndexAt( 31, 18 );
			iBuffer.setIndexAt( 32, 5 );
			iBuffer.setIndexAt( 33, 8 );
			iBuffer.setIndexAt( 34, 5 );
			iBuffer.setIndexAt( 35, 9 );
			iBuffer.setIndexAt( 36, 12 );
			iBuffer.setIndexAt( 37, 2 );
			iBuffer.setIndexAt( 38, 10 );
			iBuffer.setIndexAt( 39, 12 );
			iBuffer.setIndexAt( 40, 10 );
			iBuffer.setIndexAt( 41, 3 );
			iBuffer.setIndexAt( 42, 12 );
			iBuffer.setIndexAt( 43, 3 );
			iBuffer.setIndexAt( 44, 13 );
			iBuffer.setIndexAt( 45, 16 );
			iBuffer.setIndexAt( 46, 4 );
			iBuffer.setIndexAt( 47, 14 );
			iBuffer.setIndexAt( 48, 16 );
			iBuffer.setIndexAt( 49, 14 );
			iBuffer.setIndexAt( 50, 6 );
			iBuffer.setIndexAt( 51, 16 );
			iBuffer.setIndexAt( 52, 6 );
			iBuffer.setIndexAt( 53, 17 );
			iBuffer.setIndexAt( 54, 9 );
			iBuffer.setIndexAt( 55, 5 );
			iBuffer.setIndexAt( 56, 15 );
			iBuffer.setIndexAt( 57, 9 );
			iBuffer.setIndexAt( 58, 15 );
			iBuffer.setIndexAt( 59, 14 );
			iBuffer.setIndexAt( 60, 9 );
			iBuffer.setIndexAt( 61, 14 );
			iBuffer.setIndexAt( 62, 4 );
			iBuffer.setIndexAt( 63, 6 );
			iBuffer.setIndexAt( 64, 11 );
			iBuffer.setIndexAt( 65, 10 );
			iBuffer.setIndexAt( 66, 6 );
			iBuffer.setIndexAt( 67, 10 );
			iBuffer.setIndexAt( 68, 2 );
			iBuffer.setIndexAt( 69, 6 );
			iBuffer.setIndexAt( 70, 2 );
			iBuffer.setIndexAt( 71, 17 );
			iBuffer.setIndexAt( 72, 3 );
			iBuffer.setIndexAt( 73, 19 );
			iBuffer.setIndexAt( 74, 18 );
			iBuffer.setIndexAt( 75, 3 );
			iBuffer.setIndexAt( 76, 18 );
			iBuffer.setIndexAt( 77, 1 );
			iBuffer.setIndexAt( 78, 3 );
			iBuffer.setIndexAt( 79, 1 );
			iBuffer.setIndexAt( 80, 13 );
			iBuffer.setIndexAt( 81, 7 );
			iBuffer.setIndexAt( 82, 15 );
			iBuffer.setIndexAt( 83, 5 );
			iBuffer.setIndexAt( 84, 7 );
			iBuffer.setIndexAt( 85, 5 );
			iBuffer.setIndexAt( 86, 18 );
			iBuffer.setIndexAt( 87, 7 );
			iBuffer.setIndexAt( 88, 18 );
			iBuffer.setIndexAt( 89, 19 );
			iBuffer.setIndexAt( 90, 7 );
			iBuffer.setIndexAt( 91, 11 );
			iBuffer.setIndexAt( 92, 6 );
			iBuffer.setIndexAt( 93, 7 );
			iBuffer.setIndexAt( 94, 6 );
			iBuffer.setIndexAt( 95, 14 );
			iBuffer.setIndexAt( 96, 7 );
			iBuffer.setIndexAt( 97, 14 );
			iBuffer.setIndexAt( 98, 15 );
			iBuffer.setIndexAt( 99, 7 );
			iBuffer.setIndexAt( 100, 19 );
			iBuffer.setIndexAt( 101, 3 );
			iBuffer.setIndexAt( 102, 7 );
			iBuffer.setIndexAt( 103, 3 );
			iBuffer.setIndexAt( 104, 10 );
			iBuffer.setIndexAt( 105, 7 );
			iBuffer.setIndexAt( 106, 10 );
			iBuffer.setIndexAt( 107, 11 );
			
			if ( _inside )
			{
				reverseTriangleOrder( numTriangles, iBuffer.data );
			}
			
			return new TriMesh( _vFormat, vBuffer, iBuffer );
		}
		
		/**
		 * rectangle
		 */
		public function rectangle( xSamples: int, ySamples: int, xExtent: Number, yExtent: Number ): TriMesh
		{
			var numVertices: int = xSamples * ySamples;
			var numTriangles: int = 2 * (xSamples - 1) * (ySamples - 1);
			var numIndices: int = 3 * numTriangles;
			var stride:int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices, stride, _usage );
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			
			// generate geometry
			var inv0: Number = 1 / ( xSamples - 1 );
			var inv1: Number = 1 / ( ySamples - 1 );
			var u: Number=0;
			var v: Number=0;
			var x: Number=0;
			var y: Number=0;
			
			var i: int;
			var i0: int;
			var i1: int;
			
			for ( i1 = 0, i = 0; i1 < ySamples;++i1)
			{
				v = i1 * inv1;
				y = (2 * v - 1) * yExtent;
				for ( i0 = 0; i0 < xSamples; ++i0, ++i )
				{
					u = i0 * inv0;
					x = (2 * u - 1) * xExtent;
					vba.setPositionAt( i, [ x, y, 0 ] );
					
					if ( _hasNormals )
					{
						vba.setNormalAt( i, [ 0, 0, 1 ] );
					}
					
					var tCoord: Array = [ u, v ];
					for ( var unit: int = 0; unit < MAX_UNITS; ++unit )
					{
						if ( _hasTCoords[ unit ] )
						{
							vba.setTCoordAt( unit, i, tCoord );
						}
					}
				}
			}
			transformData( vba );
			
			// generate indices
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			
			var v0: int;
			var v1: int;
			var v2: int;
			var v3: int;
			var pointer: int;
			for ( i1 = 0; i1 < ySamples - 1; ++i1 )
			{
				for ( i0 = 0; i0 < xSamples -1; ++i0 )
				{
					v0 = i0 + xSamples * i1;
					v1 = v0 + 1;
					v2 = v1 + xSamples;
					v3 = v0 + xSamples;
					
					iBuffer.setIndexAt( pointer++, v0 );
					iBuffer.setIndexAt( pointer++, v1 );
					iBuffer.setIndexAt( pointer++, v2 );
					iBuffer.setIndexAt( pointer++, v0 );
					iBuffer.setIndexAt( pointer++, v2 );
					iBuffer.setIndexAt( pointer++, v3 );
				}
			}
			return new TriMesh( _vFormat, vBuffer, iBuffer );
		}
		
		/**
		 * octahedron
		 */
		public function octahedron(): TriMesh
		{
			var numVertices: int = 6;
			var numTriangles: int = 8;
			var numIndices: int = 3 * numTriangles;
			var stride: int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices, stride, _usage );
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			
			vba.setPositionAt( 0, [ 1, 0, 0 ] );
			vba.setPositionAt( 1, [-1, 0, 0 ] );
			vba.setPositionAt( 2, [ 0, 1, 0 ] );
			vba.setPositionAt( 3, [ 0,-1, 0 ] );
			vba.setPositionAt( 4, [ 0, 0, 1 ] );
			vba.setPositionAt( 5, [ 0, 0, -1 ] );
			
			createPlatonicNormals( vba );
			createPlatonicUVs( vba );
			transformData( vba );
			
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			iBuffer.setIndexAt( 0, 4 );
			iBuffer.setIndexAt( 1, 0 );
			iBuffer.setIndexAt( 2, 2 );
			iBuffer.setIndexAt( 3, 4 );
			iBuffer.setIndexAt( 4, 2 );
			iBuffer.setIndexAt( 5, 1 );
			iBuffer.setIndexAt( 6, 4 );
			iBuffer.setIndexAt( 7, 1 );
			iBuffer.setIndexAt( 8, 3 );
			iBuffer.setIndexAt( 9, 4 );
			iBuffer.setIndexAt( 10, 3 );
			iBuffer.setIndexAt( 11, 0 );
			iBuffer.setIndexAt( 12, 5 );
			iBuffer.setIndexAt( 13, 2 );
			iBuffer.setIndexAt( 14, 0 );
			iBuffer.setIndexAt( 15, 5 );
			iBuffer.setIndexAt( 16, 1 );
			iBuffer.setIndexAt( 17, 2 );
			iBuffer.setIndexAt( 18, 5 );
			iBuffer.setIndexAt( 19, 3 );
			iBuffer.setIndexAt( 20, 1 );
			iBuffer.setIndexAt( 21, 5 );
			iBuffer.setIndexAt( 22, 0 );
			iBuffer.setIndexAt( 23, 3 );
			
			if ( _inside )
			{
				reverseTriangleOrder( numTriangles, iBuffer.data );
			}
			
			return new TriMesh( _vFormat, vBuffer, iBuffer );
		}
		
		/**
		 * hexahedron
		 */
		public function hexahedron(): TriMesh
		{
			var fSqrtThird: Number = Math.sqrt( 1 / 3 );
			
			var numVertices: int = 8;
			var numTriangles: int = 12;
			var numIndices: int = 3 * numTriangles;
			var stride: int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices, stride, _usage );
			
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			
			// generate geometry
			vba.setPositionAt( 0, [-fSqrtThird, -fSqrtThird, -fSqrtThird] );
			vba.setPositionAt( 1, [ fSqrtThird, -fSqrtThird, -fSqrtThird] );
			vba.setPositionAt( 2, [ fSqrtThird,  fSqrtThird, -fSqrtThird] );
			vba.setPositionAt( 3, [-fSqrtThird,  fSqrtThird, -fSqrtThird] );
			vba.setPositionAt( 4, [-fSqrtThird, -fSqrtThird,  fSqrtThird] );
			vba.setPositionAt( 5, [ fSqrtThird, -fSqrtThird,  fSqrtThird] );
			vba.setPositionAt( 6, [ fSqrtThird,  fSqrtThird,  fSqrtThird] );
			vba.setPositionAt( 7, [-fSqrtThird,  fSqrtThird,  fSqrtThird] );
			
			createPlatonicNormals( vba );
			createPlatonicUVs( vba );
			transformData( vba );
			
			// generate indices
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			iBuffer.setIndexAt( 0, 0 );
			iBuffer.setIndexAt( 1, 3 );
			iBuffer.setIndexAt( 2, 2 );
			iBuffer.setIndexAt( 3, 0 );
			iBuffer.setIndexAt( 4, 2 );
			iBuffer.setIndexAt( 5, 1 );
			iBuffer.setIndexAt( 6, 0 );
			iBuffer.setIndexAt( 7, 1 );
			iBuffer.setIndexAt( 8, 5 );
			iBuffer.setIndexAt( 9, 0 );
			iBuffer.setIndexAt( 10, 5 );
			iBuffer.setIndexAt( 11, 4 );
			iBuffer.setIndexAt( 12, 0 );
			iBuffer.setIndexAt( 13, 4 );
			iBuffer.setIndexAt( 14, 7 );
			iBuffer.setIndexAt( 15, 0 );
			iBuffer.setIndexAt( 16, 7 );
			iBuffer.setIndexAt( 17,3 );
			iBuffer.setIndexAt( 18, 6 );
			iBuffer.setIndexAt( 19, 5 );
			iBuffer.setIndexAt( 20, 1 );
			iBuffer.setIndexAt( 21, 6 );
			iBuffer.setIndexAt( 22, 1 );
			iBuffer.setIndexAt( 23, 2 );
			iBuffer.setIndexAt( 24, 6 );
			iBuffer.setIndexAt( 25, 2 );
			iBuffer.setIndexAt( 26, 3 );
			iBuffer.setIndexAt( 27, 6 );
			iBuffer.setIndexAt( 28, 3 );
			iBuffer.setIndexAt( 29, 7 );
			iBuffer.setIndexAt( 30, 6 );
			iBuffer.setIndexAt( 31, 7 );
			iBuffer.setIndexAt( 32, 4 );
			iBuffer.setIndexAt( 33, 6 );
			iBuffer.setIndexAt( 34, 4 );
			iBuffer.setIndexAt( 35, 5 );
			
			if ( _inside )
			{
				reverseTriangleOrder( numTriangles, iBuffer.data );
			}
			
			return new TriMesh( _vFormat, vBuffer, iBuffer );
		}
		
		/**
		 * tetrahedron
		 */
		public function tetrahedron(): TriMesh
		{
			var fSqrt2Div3: Number = Math.sqrt( 2 ) / 3;
			var fSqrt6Div3: Number = Math.sqrt( 6 ) / 3;
			var fOneThird: Number = 1 / 3;
			
			var numVertices: int = 4;
			var numTriangles: int = 4;
			var numIndices: int = 3 * numTriangles;
			var stride: int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices, stride, _usage );
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			
			// generate geometry
			vba.setPositionAt( 0, [ 0, 0, 1 ] );
			vba.setPositionAt( 1, [ 2 * fSqrt2Div3, 0, -fOneThird ] );
			vba.setPositionAt( 2, [ -fSqrt2Div3, fSqrt6Div3, -fOneThird ] );
			vba.setPositionAt( 3, [ -fSqrt2Div3, - fSqrt6Div3,  -fOneThird ] );
			
			createPlatonicNormals( vba );
			createPlatonicUVs( vba );
			transformData( vba );
			
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			iBuffer.setIndexAt( 0, 0 );
			iBuffer.setIndexAt( 1, 1 );
			iBuffer.setIndexAt( 2, 2 );
			iBuffer.setIndexAt( 3, 0 );
			iBuffer.setIndexAt( 4, 2 );
			iBuffer.setIndexAt( 5, 3 );
			iBuffer.setIndexAt( 6, 0 );
			iBuffer.setIndexAt( 7, 3 );
			iBuffer.setIndexAt( 8, 1 );
			iBuffer.setIndexAt( 9, 1 );
			iBuffer.setIndexAt( 10, 3 );
			iBuffer.setIndexAt( 11, 2 );
			
			if ( _inside )
			{
				reverseTriangleOrder( numTriangles, iBuffer.data );
			}
			
			return new TriMesh( _vFormat, vBuffer, iBuffer );
		}
		
		/**
		 * box
		 */
		public function box( xExtent: Number, yExtent: Number, zExtent: Number ): TriMesh
		{
			var numVertices: int = 8;
			var numTriangles: int = 12;
			var numIndices: int = 3 * numTriangles;
			var stride: int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices, stride, _usage );
			
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			vba.setPositionAt( 0, [ -xExtent, -yExtent, -zExtent ] );
			vba.setPositionAt( 1, [ +xExtent, -yExtent, -zExtent ] );
			vba.setPositionAt( 2, [ +xExtent, +yExtent, -zExtent ] );
			vba.setPositionAt( 3, [ -xExtent, +yExtent, -zExtent ] );
			vba.setPositionAt( 4, [ -xExtent, -yExtent, +zExtent ] );
			vba.setPositionAt( 5, [ +xExtent, -yExtent, +zExtent ] );
			vba.setPositionAt( 6, [ +xExtent, +yExtent, +zExtent ] );
			vba.setPositionAt( 7, [ -xExtent, +yExtent, +zExtent ] );
			
			for ( var unit: int = 0; unit < MAX_UNITS; ++unit )
			{
				if ( _hasTCoords[ unit ] )
				{
					vba.setTCoordAt( unit, 0, [ 0.25, 0.75 ] );
					vba.setTCoordAt( unit, 1, [ 0.75, 0.75 ] );
					vba.setTCoordAt( unit, 2, [ 0.75, 0.25 ] );
					vba.setTCoordAt( unit, 3, [ 0.25, 0.25 ] );
					
					vba.setTCoordAt( unit, 4, [ 0, 1 ] );
					vba.setTCoordAt( unit, 5, [ 1, 1 ] );
					vba.setTCoordAt( unit, 6, [ 1, 0 ] );
					vba.setTCoordAt( unit, 7, [ 0, 0 ] );
					
				}
			}
			
			transformData( vba );
			
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			var indices: ByteArray = iBuffer.data;
			indices.position = 0;
			
			indices.writeShort( 0 );
			indices.writeShort( 2 );
			indices.writeShort( 1 );
			
			indices.writeShort( 0 );
			indices.writeShort( 3 );
			indices.writeShort( 2 );
			
			indices.writeShort( 0 );
			indices.writeShort( 1 );
			indices.writeShort( 5 );
			
			indices.writeShort( 0 );
			indices.writeShort( 5 );
			indices.writeShort( 4 );
			
			indices.writeShort( 0 );
			indices.writeShort( 4 );
			indices.writeShort( 7 );
			
			indices.writeShort( 0 );
			indices.writeShort( 7 );
			indices.writeShort( 3 );
			
			indices.writeShort( 6 );
			indices.writeShort( 4 );
			indices.writeShort( 5 );
			
			indices.writeShort( 6 );
			indices.writeShort( 7 );
			indices.writeShort( 4 );
			
			indices.writeShort( 6 );
			indices.writeShort( 5 );
			indices.writeShort( 1 );
			
			indices.writeShort( 6 );
			indices.writeShort( 1 );
			indices.writeShort( 2 );
			
			indices.writeShort( 6 );
			indices.writeShort( 2 );
			indices.writeShort( 3 );
			
			indices.writeShort( 6 );
			indices.writeShort( 3 );
			indices.writeShort( 7 );
			
			if ( _inside )
			{
				reverseTriangleOrder( numTriangles, indices );
			}
			
			var mesh: TriMesh = new TriMesh( _vFormat, vBuffer, iBuffer );
			if ( _hasNormals )
			{
				mesh.updateModelSpace( UpdateType.NORMALS );
			}
			
			return mesh;
		}
		
		
		/**
		 * sphere
		 */
		public function sphere( zSamples: int, radialSamples: int, radius: Number ): TriMesh
		{
			var zsm1: int = zSamples - 1;
			var zsm2: int = zSamples - 2;
			var zsm3: int = zSamples - 3;
			
			var rsp1: int = radialSamples + 1;
			var numVertices: int = zsm2 * rsp1 + 2;
			var numTriangles: int = 2 * zsm2 * radialSamples;
			var numIndices: int = 3 * numTriangles;
			var stride: int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices, stride, _usage );
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			
			var invRS: Number = 1 / radialSamples;
			var zFactor: Number = 2 / zsm1;
			var r: int;
			var z: int;
			var zStart: int;
			var i: int;
			var unit: int;
			var tCoord: Array = [];
			
			var sn:Vector.<Number> = new Vector.<Number>( rsp1, true );
			var cs:Vector.<Number> = new Vector.<Number>( rsp1, true );
			for ( r = 0; r < radialSamples; ++r )
			{
				var angle:Number = MathHelper.TWO_PI * invRS * r;
				cs[ r ] = Math.cos( angle );
				sn[ r ] = Math.sin( angle );
			}
			sn[ radialSamples ] = sn[ 0 ];
			cs[ radialSamples ] = cs[ 0 ];
			
			for ( z = 1, i = 0; z < zsm1; ++z )
			{
				var zFraction: Number = -1 + zFactor * z;
				var zValue: Number = radius * zFraction;
				
				var sliceCenter: APoint = new APoint( 0, 0, zValue );
				
				var sliceRadius: Number = Math.sqrt( Math.abs( radius * radius - zValue * zValue ) );
				
				var normal: AVector;
				var save: int = i;
				for ( r = 0; r < radialSamples; ++r )
				{
					var radialFraction: Number = r * invRS;
					var radial: AVector = new AVector( cs[r], sn[r], 0 );
					
					
					var position: APoint = sliceCenter.addAVector( radial.scale( sliceRadius ) );
					
					vba.setPositionAt( i, position.toTuple() );
					
					if ( _hasNormals )
					{
						normal = new AVector( position.x, position.y, position.z );
						normal.normalize();
						if ( _inside )
						{
							normal.negateEq();
							vba.setNormalAt( i, normal.toTuple() );
						}
						else
						{
							vba.setNormalAt( i, normal.toTuple() );
						}
						
					}
					
					tCoord[ 0 ] = radialFraction;
					tCoord[ 1 ] = 0.5 * (zFraction + 1);
					for ( unit = 0; unit < MAX_UNITS; ++unit )
					{
						if ( _hasTCoords[ unit ] )
						{
							vba.setTCoordAt( unit, i, tCoord );
						}
					}
					++i;
				}
				
				vba.setPositionAt( i, vba.getPositionAt( save ) );
				if ( _hasNormals )
				{
					vba.setNormalAt( i, vba.getNormalAt( save ) );
				}
				
				tCoord[ 0 ] = 1;
				tCoord[ 1 ] = 0.5 * (zFraction + 1);
				for ( unit = 0; unit < MAX_UNITS; ++unit )
				{
					if ( _hasTCoords[ unit ] )
					{
						vba.setTCoordAt( unit, i, tCoord );
					}
				}
				++i;
			}
			
			// south pole
			vba.setPositionAt( i, [ 0, 0, -radius ] );
			if ( _hasNormals )
			{
				if ( _inside )
				{
					vba.setNormalAt( i, [ 0, 0, 1 ] );
				}
				else
				{
					vba.setNormalAt( i, [ 0, 0, -1 ] );
				}
			}
			
			tCoord = [ 0.5, 0.5 ];
			for ( unit = 0; unit < MAX_UNITS; ++unit )
			{
				if ( _hasTCoords[ unit ] )
				{
					vba.setTCoordAt( unit, i, tCoord );
				}
			}
			
			++i
			
			// north pole
			vba.setPositionAt( i, [ 0, 0, radius ] );
			if ( _hasNormals )
			{
				if ( _inside )
				{
					vba.setNormalAt( i, [ 0, 0, -1 ] );
				}
				else
				{
					vba.setNormalAt( i, [ 0, 0, 1 ] );
				}
			}
			
			tCoord = [ 0.5, 1 ];
			for ( unit = 0; unit < MAX_UNITS; ++unit )
			{
				if ( _hasTCoords[ unit ] )
				{
					vba.setTCoordAt( unit, i, tCoord );
				}
			}
			++i;
			
			transformData( vba );
			
			// indices
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			var posOffset: int = 0;
			for ( z = 0, zStart = 0; z < zsm3; ++z )
			{
				var i0: int = zStart;
				var i1: int = i0 + 1;
				zStart += rsp1;
				var i2: int = zStart;
				var i3: int = i2 + 1;
				for ( i = 0; i < radialSamples; ++i, posOffset += 6 )
				{
					if ( _inside )
					{
						iBuffer.setIndexAt( posOffset + 0, i0++ );
						iBuffer.setIndexAt( posOffset + 1, i2 );
						iBuffer.setIndexAt( posOffset + 2, i1 );
						iBuffer.setIndexAt( posOffset + 3, i1++ );
						iBuffer.setIndexAt( posOffset + 4, i2++ );
						iBuffer.setIndexAt( posOffset + 5, i3++ );
					}
					else
					{
						iBuffer.setIndexAt( posOffset + 0, i0++ );
						iBuffer.setIndexAt( posOffset + 1, i1 );
						iBuffer.setIndexAt( posOffset + 2, i2 );
						iBuffer.setIndexAt( posOffset + 3, i1++ );
						iBuffer.setIndexAt( posOffset + 4, i3++ );
						iBuffer.setIndexAt( posOffset + 5, i2++ );
					}
				}
			}
			
			// south pole tris
			var numVerticesM2: int = numVertices - 2;
			for ( i = 0; i < radialSamples; ++i, posOffset += 3 )
			{
				if ( _inside )
				{
					iBuffer.setIndexAt( posOffset + 0, i );
					iBuffer.setIndexAt( posOffset + 1, i + 1 );
					iBuffer.setIndexAt( posOffset + 2, numVerticesM2 );
				}
				else
				{
					iBuffer.setIndexAt( posOffset + 0, i );
					iBuffer.setIndexAt( posOffset + 1, numVerticesM2 );
					iBuffer.setIndexAt( posOffset + 2, i + 1 );
				}
			}
			
			// north pole tris
			var numVerticesM1: int = numVertices - 1;
			var offset: int = zsm3 * rsp1;
			for ( i = 0; i < radialSamples; ++i, posOffset += 3 )
			{
				if ( _inside )
				{
					iBuffer.setIndexAt( posOffset + 0, i + offset );
					iBuffer.setIndexAt( posOffset + 1, numVerticesM1 );
					iBuffer.setIndexAt( posOffset + 2, i + 1 + offset );
				}
				else
				{
					iBuffer.setIndexAt( posOffset + 0, i + offset );
					iBuffer.setIndexAt( posOffset + 1, i + 1 + offset );
					iBuffer.setIndexAt( posOffset + 2, numVerticesM1 );
				}
			}
			
			cs = null;
			sn = null;
			
			var mesh: TriMesh = new TriMesh( _vFormat, vBuffer, iBuffer );
			mesh.modelBound.center = APoint.ORIGIN;
			mesh.modelBound.radius = radius;
			
			return mesh;
		}
		
		public function torus( circleSamples: int, radialSamples: int, outerRadius: Number, innerRadius: Number ): TriMesh
		{
			var numVertices: int = (circleSamples + 1) * (radialSamples + 1);
			var numTriangles: int = 2 * circleSamples * radialSamples;
			var numIndices: int = 3 * numTriangles;
			var stride: int = _vFormat.stride;
			
			var vBuffer: VertexBuffer = new VertexBuffer( numVertices, stride, _usage )
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, vBuffer );
			
			// generate geometry
			var invCS: Number = 1 / circleSamples;
			var invRS: Number = 1 / radialSamples;
			var c: int;
			var r: int;
			var i: int;
			var unit: int;
			var tCoord: Array = [];
			
			// generate the cylinder
			for ( c = 0, i = 0; c < circleSamples; ++c )
			{
				var circleFraction: Number = c * invCS;
				var theta: Number = MathHelper.TWO_PI * circleFraction;
				var cosTheta: Number = Math.cos( theta );
				var sinTheta: Number = Math.sin( theta );
				
				var radial: AVector = new AVector( cosTheta, sinTheta, 0 );
				var torusMiddle: AVector = radial.scale( outerRadius );
				
				var save: int = i;
				for ( r = 0; r < radialSamples; ++r )
				{
					var radialFraction: Number = r * invRS;
					var phi: Number = MathHelper.TWO_PI * radialFraction;
					var cosPhi: Number = Math.cos( phi );
					var sinPhi: Number = Math.sin( phi );
					
					var normal: AVector = AVector.UNIT_Z.scale( sinPhi ).add( radial.scale( cosPhi ) );
					
					var tMidRadNormal: AVector = torusMiddle.add( normal.scale( innerRadius ) );
					
					vba.setPositionAt( i, [ tMidRadNormal.x, tMidRadNormal.y, tMidRadNormal.z ] );
					if ( _hasNormals )
					{
						if ( _inside )
						{
							vba.setNormalAt( i, [ -normal.x, -normal.y, -normal.z ] );
						}
						else
						{
							vba.setNormalAt( i, [ normal.x, normal.y, normal.z ] );
						}
						
					}
					
					
					
					tCoord = [ radialFraction, circleFraction ]
					for ( unit = 0; unit < MAX_UNITS; ++unit )
					{
						if ( _hasTCoords[ unit ] )
						{
							vba.setTCoordAt( unit, i, tCoord );
						}
					}
					
					++i;
				}
				
				vba.setPositionAt( i, vba.getPositionAt( save ) );
				if ( _hasNormals )
				{
					vba.setNormalAt( i, vba.getNormalAt( save ) );
				}
				
				tCoord = [ 1, circleFraction ];
				for ( unit = 0; unit < MAX_UNITS; ++unit )
				{
					if ( _hasTCoords[ unit ] )
					{
						vba.setTCoordAt( unit, i, tCoord );
					}
				}
				
				++i;
			}
			
			// duplicate the cylinder ends to form a torus
			for ( r = 0; r <= radialSamples; ++r, ++i )
			{
				vba.setPositionAt( i, vba.getPositionAt( r ) );
				if ( _hasNormals )
				{
					vba.setNormalAt( i, vba.getNormalAt( r ) );
				}
				
				for ( unit = 0; unit < MAX_UNITS; ++unit )
				{
					if ( _hasTCoords )
					{
						vba.setTCoordAt( unit, i, [ vba.getTCoordAt( unit, r )[ 0 ], 1 ] );
					}
				}
			}
			
			transformData( vba );
			
			// generate indices
			var iBuffer: IndexBuffer = new IndexBuffer( numIndices, 2, _usage );
			var indices: int = 0;
			var cStart: int = 0;
			for ( c = 0; c < circleSamples; ++c )
			{
				var i0: int = cStart;
				var i1: int = i0 + 1;
				cStart += radialSamples + 1;
				var i2: int = cStart;
				var i3: int = i2 + 1;
				
				for ( i = 0; i < radialSamples; ++i, indices += 6 )
				{
					if ( _inside )
					{
						iBuffer.setIndexAt( indices + 0, i0++ );
						iBuffer.setIndexAt( indices + 1, i1 );
						iBuffer.setIndexAt( indices + 2, i2 );
						iBuffer.setIndexAt( indices + 3, i1++ );
						iBuffer.setIndexAt( indices + 4, i3++ );
						iBuffer.setIndexAt( indices + 5, i2++ );
					}
					else
					{
						iBuffer.setIndexAt( indices + 0, i0++ );
						iBuffer.setIndexAt( indices + 1, i2 );
						iBuffer.setIndexAt( indices + 2, i1 );
						iBuffer.setIndexAt( indices + 3, i1++ );
						iBuffer.setIndexAt( indices + 4, i2++ );
						iBuffer.setIndexAt( indices + 5, i3++ );
					}
				}
			}
			
			var mesh: TriMesh = new TriMesh( _vFormat, vBuffer, iBuffer );
			mesh.modelBound.center = APoint.ORIGIN;
			mesh.modelBound.radius = outerRadius;
			
			return mesh;
		}
		
		
		public function get transform(): Transform
		{
			return _transform;
		}
		
		public function set transform( transform: Transform ): void
		{
			_transform = transform;
		}
		
		[Inline]
		public final function get isDisposed():Boolean 
		{
			return _isDisposed;
		}
		
		protected function transformData( vba: VertexBufferAccessor): void
		{
			if ( _transform.isIdentity )
			{
				return;
			}
			
			var numVertices: int = vba.numVertices;
			var i: int;
			
			for ( i = 0; i < numVertices; ++i )
			{
				var position: APoint = APoint.fromTuple( vba.getPositionAt( i ) );
				var transPos: APoint = _transform.multiplyAPoint( position );
				
				vba.setPositionAt( i, transPos.toTuple() );
			}
			
			if ( _hasNormals )
			{
				for ( i = 0; i < numVertices; ++i )
				{
					var normal: AVector = AVector.fromTuple( vba.getNormalAt( i ) );
					normal.normalize();
					vba.setNormalAt( i, normal.toTuple() );
				}
			}
			
		}
		
		protected function reverseTriangleOrder( numTriangles: int, indices: ByteArray ): void
		{
			for( var i: int = 0; i < numTriangles; ++i )
			{
				var j1: int = (3 * i + 1) << 1;
				var j2: int = (j1 + 2);
				
				indices.position = j1;
				var save: int = indices.readShort();
				
				indices.position = j2;
				var save2: int = indices.readShort();
				
				indices.position = j1;
				indices.writeShort( save2 );
				
				indices.position = j2;
				indices.writeShort( save );
				
				/*
				var save: int = indices[ j1 ];
				indices[ j1 ] = indices[ j2 ];
				indices[ j2 ] = save;
				*/
			}
		}
		
		protected function createPlatonicNormals( vba: VertexBufferAccessor ): void
		{
			//TODO check against the source, Plato was good..if he's this good then seriously, dude!!
			if ( _hasNormals )
			{
				var numVertices: int = vba.numVertices;
				for ( var i: int = 0; i < numVertices; ++i )
				{
					vba.setNormalAt( i, vba.getPositionAt( i ) );
				}
			}
		}
		
		protected function createPlatonicUVs( vba: VertexBufferAccessor ): void
		{
			for ( var unit: int = 0; unit < MAX_UNITS; ++unit )
			{
				if ( _hasTCoords[ unit ] )
				{
					var numVertices: int = vba.numVertices;
					for ( var i: int = 0; i < numVertices; ++i )
					{
						var position: Array = vba.getPositionAt( i );
						var tcoord: Array = [];
						
						if ( Math.abs( position[ 2 ] ) < 1 )
						{
							tcoord[ 0 ] = 0.5 * ( 1 + Math.atan2( position[ 1 ], position[ 0 ] ) * MathHelper.INV_PI );
						}
						else
						{
							tcoord[ 0 ] = 0.5;
						}
						tcoord[ 1 ] = Math.acos( position[ 2 ] ) * MathHelper.INV_PI;
						
						vba.setTCoordAt( unit, i, tcoord );
					}
				}
			}
		}
		
		
	}

}