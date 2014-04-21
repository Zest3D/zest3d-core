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
package zest3d.datatypes 
{
	import flash.utils.ByteArray;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.Assert;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import io.plugin.math.algebra.HPlane;
	import io.plugin.math.base.MathHelper;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Bound implements IDisposable 
	{
		
		private var _center: APoint;
		private var _radius: Number;
		
		public function Bound() 
		{
			_center = APoint.ORIGIN;
			_radius = 0;
		}
		
		public function dispose(): void
		{
			_center = null;
		}
		
		public function set( bound: Bound ): Bound
		{
			_center = bound.center;
			_radius = bound.radius;
			
			return this;
		}
		
		[Inline]
		public final function set center( center:APoint ): void
		{
			_center = center;
		}
		
		[Inline]
		public final function set radius( radius: Number ): void
		{
			_radius = radius;
		}
		
		[Inline]
		public final function get center(): APoint
		{
			return _center;
		}
		
		[Inline]
		public final function get radius( ): Number
		{
			return _radius;
		}
		
		public function whichSide( plane: HPlane ): int
		{
			var signedDistance: Number = plane.distanceTo( _center );
			if ( signedDistance <= -_radius )
			{
				return -1;
			}
			
			if ( signedDistance >= _radius )
			{
				return 1;
			}
			
			return 0;
		}
		
		public function growToContain( bound: Bound ): void
		{
			if ( bound._radius == 0 )
			{
				return;
			}
			
			if ( _radius == 0 )
			{
				set( bound );
				return;
			}
			
			var centerDiff:AVector = bound._center.subtract( _center );
			var lengthSqr: Number = centerDiff.squaredLength;
			var radiusDiff: Number = bound._radius - _radius;
			var radiusDiffSqr: Number = radiusDiff * radiusDiff;
			
			if ( radiusDiffSqr >= lengthSqr )
			{
				if ( radiusDiff >= 0 )
				{
					_center = bound._center;
					_radius = bound._radius;
				}
				return;
			}
			
			var length: Number = Math.sqrt( lengthSqr );
			if ( length > MathHelper.ZERO_TOLLERANCE )
			{
				var coeff: Number = (length + radiusDiff) / (2 * length );
				_center.addAVectorEq( centerDiff.scale( coeff ) );
			}
			
			_radius = 0.5 * ( length + _radius + bound._radius );
		}
		
		public function transformBy( transform:Transform, bound: Bound ): void
		{
			bound._center = transform.multiplyAPoint( _center );
			bound._radius = transform.norm * _radius;
		}
		
		
		public function computeFromData( numElements: int, stride: int, data: ByteArray ): void
		{
			
			var sum0: Number = 0;
			var sum1: Number = 0;
			var sum2: Number = 0;
			
			var pos0: Number = 0;
			var pos1: Number = 0;
			var pos2: Number = 0;
			
			var diff0: Number = 0;
			var diff1: Number = 0;
			var diff2: Number = 0;
			
			var radiusSqr: Number = 0;
			
			_radius = 0;
			
			var i: int;
			
			data.position = 0;
			
			for ( i = 0; i < numElements; ++i )
			{
				
				data.position = ( i * stride );
				pos0 = data.readFloat();
				pos1 = data.readFloat();
				pos2 = data.readFloat();
				
				sum0 += pos0;
				sum1 += pos1;
				sum2 += pos2;
				
				diff0 = pos0 - _center.x;
				diff1 = pos1 - _center.y;
				diff2 = pos2 - _center.z;
				
				radiusSqr = diff0 * diff0 + diff1 * diff1 + diff2 * diff2;
				
				if ( radiusSqr > _radius )
				{
					_radius = radiusSqr;
				}
			}
			
			var invNumElements: Number = 1 / numElements;
			_center.x = sum0 * invNumElements;
			_center.y = sum1 * invNumElements;
			_center.z = sum2 * invNumElements;
			
			_radius = Math.sqrt( _radius );
			
		}
		
		
		public function testIntersectionRay( origin: APoint, direction:AVector, tMin: Number, tMax: Number ): Boolean
		{
			if ( _radius == 0 )
			{
				return false;
			}
			
			var diff: AVector;
			var a0: Number = 0;
			var a1: Number = 0;
			var discr: Number = 0;
			
			if ( tMin == -Number.MAX_VALUE )
			{
				Assert.isTrue( tMax == Number.MAX_VALUE, "tMax must be infinity for a line." );
				
				diff = origin.subtract( _center );
				a0 = diff.dotProduct( diff ) - _radius * _radius;
				a1 = direction.dotProduct( diff );
				discr = a1 * a1 - a0;
				
				return discr >= 0;
			}
			
			if ( tMax == Number.MAX_VALUE )
			{
				Assert.isTrue( tMin == 0, "tMin must be zero for a ray." );
				
				diff = origin.subtract( _center );
				a0 = diff.dotProduct( diff ) - _radius * _radius;
				
				if ( a0 <= 0 )
				{
					return true;
				}
				
				a1 = direction.dotProduct( diff );
				if ( a1 >= 0 )
				{
					return false;
				}
				
				discr = a1 * a1 - a0;
				
				return discr >= 0;
			}
			
			Assert.isTrue( tMax > tMin, "tMin < tMax is required for a segment." );
			
			var segExtent: Number = 0.5 * (tMin + tMax);
			
			var segOrigin: APoint = origin.addAVector( direction.scale( segExtent ) );
			
			diff = segOrigin.subtract( _center );
			a0 = diff.dotProduct( diff ) - _radius * _radius;
			a1 = direction.dotProduct( diff );
			discr = a1 * a1 - a0;
			
			if ( discr < 0 )
			{
				return false;
			}
			
			var tmp0: Number = segExtent * segExtent + a0;
			var tmp1: Number = 2 * a1 * segExtent;
			var qm: Number = tmp0 - tmp1;
			var qp: Number = tmp0 + tmp1;
			if ( qm * qp <= 0 )
			{
				return true;
			}
			
			return qm > 0 && Math.abs( a1 ) < segExtent;
		}
		
		public function testIntersectionBound( bound:Bound ): Boolean
		{
			if ( bound._radius == 0 ||  _radius == 0 )
			{
				return false;
			}
			
			var diff:AVector = _center.subtract( bound._center );
			var rSum: Number = _radius + bound._radius;
			return diff.squaredLength <= rSum * rSum;
		}
		
		public function testIntersectionMovingBound( bound: Bound, tMax: Number, velocity0: AVector, velocity1: AVector ): Boolean
		{
			if ( bound._radius  == 0 || _radius == 0 )
			{
				return false;
			}
			
			var relVelocity: AVector = velocity1.subtract( velocity0 );
			var cenDiff: AVector = bound._center.subtract( _center );
			var a: Number = relVelocity.squaredLength;
			var c: Number = cenDiff.squaredLength;
			var rSum: Number = bound._radius + _radius;
			var rSumSqr: Number = rSum * rSum;
			
			if ( a > 0 )
			{
				var b: Number = cenDiff.dotProduct( relVelocity );
				if ( b <= 0 )
				{
					if ( -tMax * a <= b )
					{
						return a * a - b * b <= a * rSumSqr;
					}
					else
					{
						return tMax * (tMax * a + 2 * b) + c <= rSumSqr;
					}
				}
			}
			
			return c <= rSumSqr;
		}
		
		public function toString(): String
		{
			return "[object Bound]\nradius: " + _radius.toPrecision( 7 ).substring( 0, 7 ) + "\n" + "center: " + _center.toString() + "\n";
		}
	}

}