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
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.Assert;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import io.plugin.math.intersection.IntrLine3Triangle3;
	import io.plugin.math.objects3d.Line3;
	import io.plugin.math.objects3d.Triangle3;
	import zest3d.detail.SwitchNode;
	import zest3d.resources.VertexBufferAccessor;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Picker implements IDisposable 
	{
		
		private var _origin: APoint;
		private var _direction: AVector;
		private var _tMin: Number;
		private var _tMax: Number;
		
		private static const msInvalid: PickRecord = new PickRecord();
		
		public var records: Vector.<PickRecord>
		
		public function Picker() 
		{
			_origin = APoint.ORIGIN;
			_direction = AVector.ZERO;
			_tMin = 0;
			_tMax = 0;
			
			records = new Vector.<PickRecord>();
		}
		
		public function dispose(): void
		{
			_origin.dispose();
			_origin = null;
			
			_direction.dispose();
			_direction = null;
		}
		
		public function execute( scene: Spatial, origin: APoint, direction: AVector, tMin: Number, tMax: Number ): void
		{
			if ( tMin == -Number.MAX_VALUE )
			{
				Assert.isTrue( tMax == Number.MAX_VALUE, "Invalid inputs." );
			}
			else
			{
				Assert.isTrue( tMin == 0 && tMax > 0, "Invalid inputs" );
			}
			
			_origin = origin;
			_direction = direction;
			_tMin = tMin;
			_tMax = tMax;
			
			records.length = 0;
			executeRecursive( scene );
		}
		
		public function get closestToZero():PickRecord
		{
			if ( records.length == 0 )
			{
				return msInvalid;
			}
			
			var closest: Number = Math.abs( records[ 0 ].t );
			var index: int = 0;
			var numRecords: int = records.length;
			
			for ( var i: int = 1; i < numRecords; ++i )
			{
				var tmp: Number = Math.abs( records[ i ].t );
				if ( tmp < closest )
				{
					closest = tmp;
					index = i;
				}
			}
			
			return records[ index ];
		}
		
		public function get closestNonNegative(): PickRecord
		{
			if ( records.length == 0 )
			{
				return msInvalid;
			}
			
			var closest: Number = Number.MAX_VALUE;
			var index: int;
			var numRecords: int = records.length;
			
			for ( index = 0; index < numRecords; ++index )
			{
				if ( records[ index ].t >= 0 )
				{
					closest = records[ index ].t;
					break;
				}
			}
			
			if ( index == numRecords )
			{
				return msInvalid;
			}
			
			for ( var i: int = index + 1; i < numRecords; ++i )
			{
				if ( 0 <= records[ i ].t && records[ i ].t < closest )
				{
					closest = records[ i ].t;
					index = i;
				}
			}
			
			return records[ index ];
		}
		
		public function get closestNonPositive(): PickRecord
		{
			if ( records.length == 0 )
			{
				return msInvalid;
			}
			
			var closest: Number = -Number.MAX_VALUE;
			var index: int;
			var numRecords: int = records.length;
			
			for ( index = 0; index < numRecords; index++ )
			{
				if ( records[ index ].t <= 0 )
				{
					closest = records[ index ].t;
					break;
				}
			}
			if ( index == numRecords )
			{
				return msInvalid;
			}
			
			for ( var i: int = index + 1; i < numRecords; ++i )
			{
				if ( closest < records[ i ].t && records[ i ].t <= 0 )
				{
					closest = records[ i ].t;
					index = i;
				}
			}
			return records[ index ];
		}
		
		private function executeRecursive( object: Spatial ): void
		{
			
			var i: int;
			var child: Spatial;
			
			var mesh: Triangles = object as Triangles;
			if ( mesh )
			{
				if ( mesh.worldBound.testIntersectionRay( _origin, _direction, _tMin, _tMax ) )
				{
					
					var ptmp: APoint = mesh.worldTransform.inverse.multiplyAPoint( _origin );
					var modelOrigin: APoint = new APoint( ptmp.x, ptmp.y, ptmp.z );
					
					var vtmp: AVector = mesh.worldTransform.inverse.multiplyAVector( _direction );
					var modelDirection: AVector = new AVector( vtmp.x, vtmp.y, vtmp.z );
					
					var line: Line3 = new Line3( modelOrigin, modelDirection );
					
					var vba: VertexBufferAccessor = new VertexBufferAccessor( mesh.vertexFormat, mesh.vertexBuffer );
					var numTriangles: int = mesh.numTriangles;
					
					for ( i = 0; i < numTriangles; ++i )
					{
						var data: Array = [ ];
						
						if ( !mesh.getTriangleAt( i, data ) )
						{
							continue;
						}
						
						var vertex0: APoint = APoint.fromTuple( vba.getPositionAt( data[0] ) );
						var vertex1: APoint = APoint.fromTuple( vba.getPositionAt( data[1] ) );
						var vertex2: APoint = APoint.fromTuple( vba.getPositionAt( data[2] ) );
						
						var triangle: Triangle3 = new Triangle3( vertex0, vertex1, vertex2 );
						
						var calc: IntrLine3Triangle3 = new IntrLine3Triangle3( line, triangle );
						
						if ( calc.find() && _tMin <= calc.lineParameter
							&& calc.lineParameter <= _tMax )
						{
							var record: PickRecord = new PickRecord();
							record.intersected = mesh;
							record.t = calc.lineParameter;
							record.triangle = i;
							record.bary[ 0 ] = calc.triBary0;
							record.bary[ 1 ] = calc.triBary1;
							record.bary[ 2 ] = calc.triBary2;
							
							records.push( record );
						}
					}
				}
				//TODO check if this should be above
				return;
			}
			
			var switchNode: SwitchNode = object as SwitchNode;
			if ( switchNode )
			{
				var activeChild: int = switchNode.activeChild;
				if ( activeChild != SwitchNode.INVALID_CHILD )
				{
					if ( switchNode.worldBound.testIntersectionRay( _origin,
								_direction, _tMin, _tMax ) )
					{
						child = switchNode.getChildAt( activeChild );
						if ( child )
						{
							executeRecursive( child );
						}
					}
				}
				return;
			}
			
			var node: Node = object as Node;
			if ( node )
			{
				if ( node.worldBound.testIntersectionRay( _origin, _direction, _tMin, _tMax ) )
				{
					
					for ( i = 0; i < node.numChildren; ++i )
					{
						child = node.getChildAt( i );
						if ( child )
						{
							executeRecursive( child );
						}
					}
				}
			}
		}
		
	}

}