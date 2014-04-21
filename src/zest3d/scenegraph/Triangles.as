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
package zest3d.scenegraph 
{
	import flash.utils.getQualifiedClassName;
	import io.plugin.core.errors.AbstractClassError;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import io.plugin.math.algebra.HMatrix;
	import io.plugin.math.base.MathHelper;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.AttributeUsageType;
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexBufferAccessor;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.enum.PrimitiveType;
	import zest3d.scenegraph.enum.UpdateType;
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Triangles extends Visual implements IDisposable 
	{
		
		protected var _vba: VertexBufferAccessor;
		
		public function Triangles( type: PrimitiveType, vFormat: VertexFormat, vBuffer:VertexBuffer, iBuffer:IndexBuffer = null ) 
		{
			super( type, vFormat, vBuffer, iBuffer );
			if ( getQualifiedClassName( this ) == "zest3d.scenegraph::Triangles" )
			{
				throw new AbstractClassError();
			}
			
			_vba = new VertexBufferAccessor( _vFormat, _vBuffer );
		}
		
		override public function dispose():void 
		{
			//TODO Triangles::dispose()
			super.dispose();
		}
		
		// virtual
		public function get numTriangles(): int
		{
			throw new Error( "Method is virtual" );
		}
		
		public function getTriangleAt( index: int, data: Array ): Boolean
		{
			throw new Error( "virtual method must be overridden." );
		}
		
		
		public function getModelTriangleAt( index: int, modelTriangle: Array ): Boolean
		{
			var tri: Array = [];
			
			if ( getTriangleAt( index, tri ) )
			{
				modelTriangle[ 0 ] = _vba.getPositionAt( tri[ 0 ] );
				modelTriangle[ 1 ] = _vba.getPositionAt( tri[ 1 ] );
				modelTriangle[ 2 ] = _vba.getPositionAt( tri[ 2 ] );
				return true;
			}
			return false;
		}
		
		public function getWorldTriangleAt( index: int, worldTriangle: Array ): Boolean
		{
			var modelTriangle: Array = [];
			if ( getModelTriangleAt( index, modelTriangle ) )
			{
				//TODO model point to TEMP
				worldTriangle[ 0 ] = worldTransform.multiplyAPoint( APoint.fromTuple( modelTriangle[ 0 ] )).toTuple();
				worldTriangle[ 1 ] = worldTransform.multiplyAPoint( APoint.fromTuple( modelTriangle[ 1 ] )).toTuple();
				worldTriangle[ 2 ] = worldTransform.multiplyAPoint( APoint.fromTuple( modelTriangle[ 2 ] )).toTuple();
				
				return true;
			}
			return false;
		}
		
		[Inline]
		public final function get numVertices(): int
		{
			return _vBuffer.numElements;
		}
		
		public function getPositionAt( index: int ): Array
		{
			var i: int = _vFormat.getIndex( AttributeUsageType.POSITION );
			if ( i >= 0 )
			{
				var positions: uint = _vFormat.getOffset( i );
				var stride: int = _vFormat.stride;
				
				_vBuffer.data.position = (positions + index * stride);
				return [ _vBuffer.data.readFloat(),
						 _vBuffer.data.readFloat(),
						 _vBuffer.data.readFloat() ];
			}
			throw new Error( "Get position failed." );
		}
		
		//virtual
		override public function updateModelSpace(type:UpdateType):void 
		{
			updateModelBound();
			if ( type == UpdateType.MODEL_BOUND_ONLY )
			{
				return;
			}
			
			if ( _vba.hasNormal() )
			{
				updateModelNormals( _vba );
			}
			
			if ( type != UpdateType.NORMALS )
			{
				if ( _vba.hasTangent() || _vba.hasBinormal() )
				{
					if ( type == UpdateType.USE_GEOMETRY )
					{
						updateModelTangentsUseGeometry( _vba );
					}
					else
					{
						updateModelTangentsUseTCoords( _vba );
					}
				}
			}
			
			Renderer.updateAllVertexBuffer( _vBuffer );
		}
		
		
		private function updateModelNormals( vba: VertexBufferAccessor ): void
		{
			var numVertices: int = vba.numVertices;
			var i: int;
			
			for ( i = 0; i < numVertices; ++i )
			{
				vba.setNormalAt( i, [ 0, 0, 0 ] );
			}
			
			var numTriangles: int = this.numTriangles;
			for ( i = 0; i < numTriangles; ++i )
			{
				var triangle: Array = [];
				if ( !getTriangleAt( i, triangle ) )
				{
					continue;
				}
				
				var posArr0: Array = vba.getPositionAt( triangle[ 0 ] );
				var posArr1: Array = vba.getPositionAt( triangle[ 1 ] );
				var posArr2: Array = vba.getPositionAt( triangle[ 2 ] );
				
				var pos0: APoint = new APoint( posArr0[ 0 ], posArr0[ 1 ], posArr0[ 2 ] );
				var pos1: APoint = new APoint( posArr1[ 0 ], posArr1[ 1 ], posArr1[ 2 ] );
				var pos2: APoint = new APoint( posArr2[ 0 ], posArr2[ 1 ], posArr2[ 2 ] );
				
				var triEdge1: AVector = pos1.subtract( pos0 );
				var triEdge2: AVector = pos2.subtract( pos0 );
				var triNormal: AVector = triEdge1.crossProduct( triEdge2 );
				
				var normal0: Array = vba.getNormalAt( triangle[ 0 ] );
				var normal1: Array = vba.getNormalAt( triangle[ 1 ] );
				var normal2: Array = vba.getNormalAt( triangle[ 2 ] );
				
				// TODO minimize object cration POOL
				var n0: AVector = new AVector( normal0[ 0 ], normal0[ 1 ], normal0[ 2 ] );
				var n1: AVector = new AVector( normal1[ 0 ], normal1[ 1 ], normal1[ 2 ] );
				var n2: AVector = new AVector( normal2[ 0 ], normal2[ 1 ], normal2[ 2 ] );
				
				var out0: AVector = n0.add( triNormal );
				var out1: AVector = n1.add( triNormal );
				var out2: AVector = n2.add( triNormal );
				
				vba.setNormalAt( triangle[ 0 ], [ out0.x, out0.y, out0.z ] );
				vba.setNormalAt( triangle[ 1 ], [ out1.x, out1.y, out1.z ] );
				vba.setNormalAt( triangle[ 2 ], [ out2.x, out2.y, out2.z ] );
				
			}
			
			for ( i = 0; i < numVertices; ++i )
			{
				var normal: Array = vba.getNormalAt( i );
				
				var out: AVector = new AVector( normal[0], normal[1], normal[2] );
				out.normalize();
				
				vba.setNormalAt( i, [ out.x, out.y, out.z ] );
			}
			
		}
		
		
		private function updateModelTangentsUseGeometry( vba: VertexBufferAccessor ): void
		{
			
			var numVertices:int = vba.numVertices;
			var dNormal:Vector.<HMatrix> = new Vector.<HMatrix>( numVertices, true );
			var wwTrn:Vector.<HMatrix> = new Vector.<HMatrix>( numVertices, true );
			var dwTrn:Vector.<HMatrix> = new Vector.<HMatrix>( numVertices, true );
			
			const numTriangles:int = numTriangles;
			var i:int;
			var j:int;
			var row:int;
			var col:int;
			
			for ( i = 0; i < numVertices; ++i )
			{
				dNormal[i] = HMatrix.ZERO;
				wwTrn[i] = HMatrix.ZERO;
				dwTrn[i] = HMatrix.ZERO;
			}
			
			for ( i = 0; i < numTriangles; ++i )
			{
				var v:Array = [];
				if ( !getTriangleAt(i, v))
				{
					continue;
				}
				
				for ( j = 0; j < 3; ++j )
				{
					var v0:int = v[j];
					var v1:int = v[(j + 1) % 3];
					var v2:int = v[(j + 2) % 3];
					
					var pos0:APoint = APoint.fromTuple( vba.getPositionAt( v0 ) );
					var pos1:APoint = APoint.fromTuple( vba.getPositionAt( v1 ) );
					var pos2:APoint = APoint.fromTuple( vba.getPositionAt( v2 ) );
					
					var nor0:AVector = AVector.fromTuple( vba.getNormalAt( v0 ) );
					var nor1:AVector = AVector.fromTuple( vba.getNormalAt( v1 ) );
					var nor2:AVector = AVector.fromTuple( vba.getNormalAt( v2 ) );
					
					var edge:AVector = pos1.subtract( pos0 );
					// edge - edge.Dot(nor0)*nor0;
					var proj:AVector = edge.subtract( nor0.scale( edge.dotProduct( nor0 ) ) );
					var diff:AVector = nor1.subtract( nor0 );
					
					// unrolled
					// row 0, col 0
					wwTrn[v0].m00 += proj.x * proj.x;
					dwTrn[v0].m00 += diff.x * proj.x;
					// row 0, col 1
					wwTrn[v0].m01 += proj.x * proj.y;
					dwTrn[v0].m01 += diff.x * proj.y;
					// row 0, col 2
					wwTrn[v0].m02 += proj.x * proj.z;
					dwTrn[v0].m02 += diff.x * proj.z;
					// row 0, col 3
					wwTrn[v0].m03 += proj.x * proj.w;
					dwTrn[v0].m03 += diff.x * proj.w;
					
					// row 1, col 0
					wwTrn[v0].m10 += proj.y * proj.x;
					dwTrn[v0].m10 += diff.y * proj.x;
					// row 1, col 1
					wwTrn[v0].m11 += proj.y * proj.y;
					dwTrn[v0].m11 += diff.y * proj.y;
					// row 1, col 2
					wwTrn[v0].m12 += proj.y * proj.z;
					dwTrn[v0].m12 += diff.y * proj.z;
					// row 1, col 3
					wwTrn[v0].m13 += proj.y * proj.w;
					dwTrn[v0].m13 += diff.y * proj.w;
					
					// row 2, col 0
					wwTrn[v0].m20 += proj.z * proj.x;
					dwTrn[v0].m20 += diff.z * proj.x;
					// row 2, col 1
					wwTrn[v0].m21 += proj.z * proj.y;
					dwTrn[v0].m21 += diff.z * proj.y;
					// row 2, col 2
					wwTrn[v0].m22 += proj.z * proj.z;
					dwTrn[v0].m22 += diff.z * proj.z;
					// row 2, col 3
					wwTrn[v0].m23 += proj.z * proj.w;
					dwTrn[v0].m23 += diff.z * proj.w;
					
					// row 3, col 0
					wwTrn[v0].m30 += proj.w * proj.x;
					dwTrn[v0].m30 += diff.w * proj.x;
					// row 3, col 1
					wwTrn[v0].m31 += proj.w * proj.y;
					dwTrn[v0].m31 += diff.w * proj.y;
					// row 3, col 2
					wwTrn[v0].m32 += proj.w * proj.z;
					dwTrn[v0].m32 += diff.w * proj.z;
					// row 3, col 3
					wwTrn[v0].m33 += proj.w * proj.w;
					dwTrn[v0].m33 += diff.w * proj.w;
					
					
					edge = pos2.subtract( pos0 );
					proj = edge.subtract( nor0.scale( edge.dotProduct( nor0) ) );
					diff = nor2.subtract( nor0 );
					
					// unrolled
					// row 0, col 0
					wwTrn[v0].m00 += proj.x * proj.x;
					dwTrn[v0].m00 += diff.x * proj.x;
					// row 0, col 1
					wwTrn[v0].m01 += proj.x * proj.y;
					dwTrn[v0].m01 += diff.x * proj.y;
					// row 0, col 2
					wwTrn[v0].m02 += proj.x * proj.z;
					dwTrn[v0].m02 += diff.x * proj.z;
					// row 0, col 3
					wwTrn[v0].m03 += proj.x * proj.w;
					dwTrn[v0].m03 += diff.x * proj.w;
					
					// row 1, col 0
					wwTrn[v0].m10 += proj.y * proj.x;
					dwTrn[v0].m10 += diff.y * proj.x;
					// row 1, col 1
					wwTrn[v0].m11 += proj.y * proj.y;
					dwTrn[v0].m11 += diff.y * proj.y;
					// row 1, col 2
					wwTrn[v0].m12 += proj.y * proj.z;
					dwTrn[v0].m12 += diff.y * proj.z;
					// row 1, col 2
					wwTrn[v0].m13 += proj.y * proj.w;
					dwTrn[v0].m13 += diff.y * proj.w;
					
					// row 2, col 0
					wwTrn[v0].m20 += proj.z * proj.x;
					dwTrn[v0].m20 += diff.z * proj.x;
					// row 2, col 1
					wwTrn[v0].m21 += proj.z * proj.y;
					dwTrn[v0].m21 += diff.z * proj.y;
					// row 2, col 2
					wwTrn[v0].m22 += proj.z * proj.z;
					dwTrn[v0].m22 += diff.z * proj.z;
					// row 2, col 2
					wwTrn[v0].m23 += proj.z * proj.w;
					dwTrn[v0].m23 += diff.z * proj.w;
					
					// row 3, col 0
					wwTrn[v0].m30 += proj.w * proj.x;
					dwTrn[v0].m30 += diff.w * proj.x;
					// row 3, col 1
					wwTrn[v0].m31 += proj.w * proj.y;
					dwTrn[v0].m31 += diff.w * proj.y;
					// row 3, col 2
					wwTrn[v0].m32 += proj.w * proj.z;
					dwTrn[v0].m32 += diff.w * proj.z;
					// row 3, col 2
					wwTrn[v0].m33 += proj.w * proj.w;
					dwTrn[v0].m33 += diff.w * proj.w;
				}
			}
			
			for ( i = 0; i < numVertices; ++i )
			{
				var nor:AVector = AVector.fromTuple( vba.getNormalAt( i ) );
				
				// unrolled
				
				//wwTrn[i][row][col] = 0.5f*wwTrn[i][row][col] + nor[row]*nor[col];
                //dwTrn[i][row][col] *= 0.5f;
				
				//row 0 col 0
				wwTrn[i].m00 = 0.5 * wwTrn[i].m00 + nor.x * nor.x;
				dwTrn[i].m00 *= 0.5;
				
				//row 0 col 1
				wwTrn[i].m01 = 0.5 * wwTrn[i].m01 + nor.x * nor.y;
				dwTrn[i].m01 *= 0.5;
				
				//row 0 col 2
				wwTrn[i].m02 = 0.5 * wwTrn[i].m02 + nor.x * nor.z;
				dwTrn[i].m02 *= 0.5;
				
				//row 0 col 3
				wwTrn[i].m03 = 0.5 * wwTrn[i].m03 + nor.x * nor.w;
				dwTrn[i].m03 *= 0.5;
				
				//row 1 col 0
				wwTrn[i].m10 = 0.5 * wwTrn[i].m10 + nor.y * nor.x;
				dwTrn[i].m10 *= 0.5;
				
				//row 1 col 1
				wwTrn[i].m11 = 0.5 * wwTrn[i].m11 + nor.y * nor.y;
				dwTrn[i].m11 *= 0.5;
				
				//row 1 col 2
				wwTrn[i].m12 = 0.5 * wwTrn[i].m12 + nor.y * nor.z;
				dwTrn[i].m12 *= 0.5;
				
				//row 1 col 3
				wwTrn[i].m13 = 0.5 * wwTrn[i].m13 + nor.y * nor.w;
				dwTrn[i].m13 *= 0.5;
				
				//row 2 col 0
				wwTrn[i].m20 = 0.5 * wwTrn[i].m20 + nor.z * nor.x;
				dwTrn[i].m20 *= 0.5;
				
				//row 2 col 1
				wwTrn[i].m21 = 0.5 * wwTrn[i].m21 + nor.z * nor.y;
				dwTrn[i].m21 *= 0.5;
				
				//row 2 col 2
				wwTrn[i].m22 = 0.5 * wwTrn[i].m22 + nor.z * nor.z;
				dwTrn[i].m22 *= 0.5;
				
				//row 2 col 3
				wwTrn[i].m23 = 0.5 * wwTrn[i].m23 + nor.z * nor.w;
				dwTrn[i].m23 *= 0.5;
				
				//row 3 col 0
				wwTrn[i].m30 = 0.5 * wwTrn[i].m30 + nor.w * nor.x;
				dwTrn[i].m30 *= 0.5;
				
				//row 3 col 1
				wwTrn[i].m31 = 0.5 * wwTrn[i].m31 + nor.w * nor.y;
				dwTrn[i].m31 *= 0.5;
				
				//row 3 col 2
				wwTrn[i].m32 = 0.5 * wwTrn[i].m32 + nor.w * nor.z;
				dwTrn[i].m32 *= 0.5;
				
				//row 3 col 3
				wwTrn[i].m33 = 0.5 * wwTrn[i].m33 + nor.w * nor.w;
				dwTrn[i].m33 *= 0.5;
				
				wwTrn = null;
				dwTrn = null;
				
				for ( i = 0; i < numVertices; ++i )
				{
					var norvec:AVector = AVector.fromTuple( vba.getNormalAt(i) );
					var uvec:AVector = new AVector();
					var vvec:AVector = new AVector();
					AVector.generateComplementBasis( uvec, vvec, norvec );
					
					var s01: Number = uvec.dotProduct( dNormal[i].multiplyAVector( vvec ) );
					var s10: Number = vvec.dotProduct( dNormal[i].multiplyAVector( uvec ) );
					var sAvr: Number = 035 * (s01 + s10);
					
					var smat:Array = [[ uvec.dotProduct( dNormal[i].multiplyAVector( uvec )), sAvr ],
									  [ sAvr, vvec.dotProduct( dNormal[i].multiplyAVector( vvec )) ]];
					
					var trac:Number = smat[0][0] + smat[1][1];
					var det:Number = smat[0][0] * smat[1][1] - smat[0][1] * smat[1][0];
					var discr:Number = trac * trac - 4 * det;
					var rootDiscr:Number = Math.sqrt( Math.abs( discr ) );
					var minCurvature:Number = 0.5 * (trac - rootDiscr);
					//var maxCurvature:Number = 0.5 * (trac + rootDiscr);
					
					var evec0:AVector = new AVector( smat[0][1], minCurvature-smat[0][0], 0 );
					var evec1:AVector = new AVector( minCurvature - smat[1][1], smat[1][0], 0 );
					
					var tanvec:AVector = new AVector();
					var binvec:AVector = new AVector();
					
					if ( evec0.squaredLength >= evec1.squaredLength )
					{
						evec0.normalize();
						tanvec = uvec.scale( evec0.x ).add( vvec.scale( evec0.y ) );
						binvec = norvec.crossProduct( tanvec );
					}
					else
					{
						evec1.normalize();
						tanvec = uvec.scale( evec1.x ).add( vvec.scale( evec1.y ) );
						binvec = norvec.crossProduct( tanvec );
					}
					
					if ( vba.hasTangent() )
					{
						vba.setTangentAt( i, tanvec.toTuple() );
					}
					
					if ( vba.hasBinormal() )
					{
						vba.setBinormalAt( i, binvec.toTuple() );
					}
				}
				
				dNormal = null;
			}
		}
		
		
		private function updateModelTangentsUseTCoords( vba: VertexBufferAccessor ): void
		{
			var numVertices:int = vba.numVertices;
			var hasTangent:Boolean = vba.hasTangent();
			var i:int;
			var k:int;
			
			var p0:APoint = new APoint();
			var p1:APoint = new APoint();
			var p2:APoint = new APoint();
			
			if ( hasTangent )
			{
				for ( i = 0; i < numVertices; ++i )
				{
					vba.setTangentAt( 0, [0, 0, 0] );
				}
			}
			else
			{
				for ( i = 0; i < numVertices; ++i )
				{
					vba.setBinormalAt(i, [0, 0, 0] );
				}
			}
			
			var numTriangles:int = this.numTriangles;
			
			for ( i = 0; i < numTriangles; ++i )
			{
				var v:Array = [];
				if ( !getTriangleAt( i, v ) )
				{
					continue;
				}
				
				var locPosition:Array = [];
				var locNormal:Array = [];
				var locTangent:Array = [];
				var locTCoord:Array = [];
				
				var curr:int;
				for ( curr = 0; curr < 3; ++curr )
				{
					k = v[curr];
					locPosition[curr] = vba.getPositionAt( k );
					locNormal[curr] = vba.getNormalAt( k );
					locTangent[curr] = (hasTangent ? vba.getTangentAt( k ) :
													 vba.getBinormalAt( k ) );
					locTCoord[curr] = vba.getTCoordAt( 0, k );
				}
				
				for ( curr = 0; curr < 3; ++curr )
				{
					var currLocTangent: Array = locTangent[ curr ];
					
					if ( !(currLocTangent[0] == 0 && 
						   currLocTangent[1] == 0 &&
						   currLocTangent[2] == 0) )
					{
						// this vertex has already been visited
						continue;
					}
					
					var norvec:AVector = new AVector( locNormal[curr][0],
													  locNormal[curr][1],
													  locNormal[curr][2] );
					
					var prev:int = ((curr + 2) % 3);
					var next:int = ((curr + 1) % 3);
					
					p0.set( locPosition[curr][0],
							locPosition[curr][1],
							locPosition[curr][2] );
					
					p1.set( locPosition[next][0],
							locPosition[next][1],
							locPosition[next][2] );
					
					p2.set( locPosition[prev][0],
							locPosition[prev][1],
							locPosition[prev][2] );
					
					var tanvec:AVector = computeTangent( p0, locTCoord[curr],
														 p1, locTCoord[next],
														 p2, locTCoord[prev] );
					
					tanvec = tanvec.subtractEq( norvec.scale( norvec.dotProduct( tanvec ) ) );
					tanvec.normalize();
					
					var binvec:AVector = norvec.unitCrossProduct( tanvec );
					
					k = v[curr];
					if ( vba.hasTangent() )
					{
						locTangent[k] = tanvec.toTuple();
						if ( vba.hasBinormal() )
						{
							vba.setBinormalAt(k, binvec.toTuple() );
						}
					}
					else
					{
						vba.setBinormalAt( k, tanvec.toTuple() );
					}
				}
			}
		}
		
		
		private static function computeTangent( position0: APoint, tCoord0: Array,
												position1: APoint, tCoord1: Array,
												position2: APoint, tCoord2: Array ): AVector
		{
			
			var diffP1P0: AVector = position1.subtract( position0 );
			var diffP2P0: AVector = position2.subtract( position0 );
			
			if ( Math.abs( diffP1P0.length ) < MathHelper.ZERO_TOLLERANCE
			  || Math.abs( diffP2P0.length ) < MathHelper.ZERO_TOLLERANCE )
			{
				return AVector.ZERO;
			}
			
			var diffU1U0: Number = tCoord1[ 0 ] - tCoord0[ 0 ];
			var diffV1V0: Number = tCoord1[ 1 ] - tCoord0[ 1 ];
			
			if ( Math.abs( diffV1V0 ) < MathHelper.ZERO_TOLLERANCE )
			{
				if ( Math.abs( diffU1U0 ) < MathHelper.ZERO_TOLLERANCE )
				{
					return AVector.ZERO;
				}
				return diffP1P0.divide( diffU1U0 );
			}
			
			
			var diffU2U0: Number = tCoord2[ 0 ] - tCoord0[ 0 ];
			var diffV2V0: Number = tCoord2[ 1 ] - tCoord0[ 1 ];
			var det: Number = diffV1V0 * diffU2U0 - diffV2V0 * diffU1U0;
			
			if ( Math.abs( det ) < MathHelper.ZERO_TOLLERANCE )
			{
				return AVector.ZERO;
			}
			
			return diffP2P0.scale( diffV1V0 ).subtract( diffP1P0.scale( diffV2V0 ) ).divide( det );
		}
		
		
	}

}