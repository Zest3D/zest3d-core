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
	import io.plugin.math.algebra.HPlane;
	import io.plugin.math.base.MathHelper;
	import zest3d.datatypes.Bound;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Culler implements IDisposable 
	{
		
		public static const MAX_PLANE_QUANTITY: int = 32;
		
		protected var _camera: Camera;
		protected var _frustum: Array;
		protected var _planeQuantity: int;
		protected var _plane: Array;
		protected var _planeState: uint;
		
		protected var _visibleSet: VisibleSet;
		
		public function Culler( camera: Camera = null ) 
		{
			_camera = camera;
			_frustum = [];
			
			_planeQuantity = 6;
			_plane = [];
			
			for ( var i: int = 0; i < _planeQuantity; ++i )
			{
				_plane[ i ] = new HPlane( AVector.ZERO );
			}
			
			_visibleSet = new VisibleSet();
		}
		
		public function dispose(): void
		{
			_visibleSet.dispose();
			_visibleSet = null;
			
			_frustum.length = 0;
			_frustum = null;
		}
		
		[Inline]
		public final function set camera( camera: Camera ): void
		{
			_camera = camera;
		}
		
		[Inline]
		public final function get camera(): Camera
		{
			return _camera;
		}
		
		
		public function set frustum( frustum: Array ): void
		{
			_frustum[Camera.DMIN] = frustum[Camera.DMIN];
			_frustum[Camera.DMAX] = frustum[Camera.DMAX];
			_frustum[Camera.UMIN] = frustum[Camera.UMIN];
			_frustum[Camera.UMAX] = frustum[Camera.UMAX];
			_frustum[Camera.RMIN] = frustum[Camera.RMIN];
			_frustum[Camera.RMAX] = frustum[Camera.RMAX];
			
			var dMin2: Number = _frustum[Camera.DMIN] * _frustum[Camera.DMIN];
			var uMin2: Number = _frustum[Camera.UMIN] * _frustum[Camera.UMIN];
			var uMax2: Number = _frustum[Camera.UMAX] * _frustum[Camera.UMAX];
			var rMin2: Number = _frustum[Camera.RMIN] * _frustum[Camera.RMIN];
			var rMax2: Number = _frustum[Camera.RMAX] * _frustum[Camera.RMAX];
			
			var position: APoint = _camera.position;
			var dVector: AVector = camera.dVector;
			var uVector: AVector = camera.uVector;
			var rVector: AVector = camera.rVector;
			
			var dirDotEye: Number = position.dotProduct( dVector );
			
			// near plane
			_plane[ Camera.DMIN ].normal = dVector ;
			_plane[ Camera.DMIN ].constant = (dirDotEye + _frustum[ Camera.DMIN ] );
			
			// far plane
			_plane[ Camera.DMAX ].normal = dVector.negate();
			_plane[ Camera.DMAX ].constant = -(dirDotEye + _frustum[Camera.DMAX]);
			
			// bottom plane
			var invLength: Number = MathHelper.invSqrt( dMin2 + uMin2 );
			var c0: Number = -_frustum[Camera.UMIN] * invLength;
			var c1: Number =  _frustum[Camera.DMIN] * invLength;
			
			var normal:AVector = dVector.scale( c0 ).add( uVector.scale( c1 ) );
			var constant: Number = position.dotProduct( normal );
			_plane[ Camera.UMIN ].normal = normal;
			_plane[ Camera.UMIN ].constant = constant;
			
			
			// top plane
			invLength = MathHelper.invSqrt( dMin2 + uMax2 );
			c0 =  _frustum[Camera.UMAX] * invLength;
			c1 = -_frustum[Camera.DMIN] * invLength;
			normal = dVector.scale( c0 ).add( uVector.scale( c1 ) );
			constant = position.dotProduct( normal );
			_plane[Camera.UMAX].normal = normal;
			_plane[Camera.UMAX].constant = constant;
			
			// left plane
			invLength = MathHelper.invSqrt( dMin2 + rMin2 );
			c0 = -_frustum[Camera.RMIN] * invLength;
			c1 =  _frustum[Camera.DMIN] * invLength;
			normal = dVector.scale( c0 ).add( rVector.scale( c1 ) );
			constant = position.dotProduct( normal );
			_plane[Camera.RMIN].normal = normal;
			_plane[Camera.RMIN].constant = constant;
			
			// right plane
			invLength = MathHelper.invSqrt( dMin2 + rMax2 );
			c0 =  _frustum[Camera.RMAX] * invLength;
			c1 = -_frustum[Camera.DMIN] * invLength;
			normal = dVector.scale( c0 ).add( rVector.scale( c1 ) );
			constant = position.dotProduct( normal );
			_plane[Camera.RMAX].normal = normal;
			_plane[Camera.RMAX].constant = constant;
			
			_planeState = uint.MAX_VALUE;
		}
		
		[Inline]
		public final function get frustum():Array
		{
			return _frustum;
		}
		
		[Inline]
		public final function get visibleSet(): VisibleSet
		{
			return _visibleSet;
		}
		
		// virtual
		public function insert( visible: Spatial ): void
		{
			_visibleSet.insert( visible );
		}
		
		[Inline]
		public final function get planeQuantity(): int
		{
			return _planeQuantity;
		}
		
		[Inline]
		public final function get planes(): Array
		{
			return _plane;
		}
		
		[Inline]
		public final function set planeState( planeState: uint ): void
		{
			_planeState = planeState;
		}
		
		[Inline]
		public final function get planeState( ): uint
		{
			return _planeState;
		}
		
		[Inline]
		public final function pushPlane( plane: HPlane ): void
		{
			if ( _planeQuantity < MAX_PLANE_QUANTITY )
			{
				_plane[ _planeQuantity ] = plane;
				++_planeQuantity;
			}
		}
		
		[Inline]
		public final function popPlane(): void
		{
			if ( _planeQuantity > Camera.VF_QUANTITY )
			{
				--_planeQuantity;
			}
		}
		
		public function isVisibleBound( bound: Bound ): Boolean
		{
			if ( bound.radius == 0 )
			{
				return false;
			}
			
			var index: int = _planeQuantity - 1;
			var mask: uint = ( 1 << index );
			
			for ( var i: int = 0; i < _planeQuantity; ++i, --index, mask >>= 1 )
			{
				if ( _planeState & mask )
				{
					var side: int = bound.whichSide( _plane[ index ] );
					
					if ( side < 0 )
					{
						return false;
					}
					
					if ( side > 0 )
					{
						_planeState &= ~mask;
					}
				}
			}
			
			return true;
		}
		
		//TODO Culler::isVisiblePortal()
		/*
		public function isVisiblePortal( numVertices: int, vertices: ByteArray, ignoreNearPlane: Boolean ): Boolean
		{
			
		}
		*/
		
		
		public function whichSide( plane: HPlane ): int
		{
			var NdEmC: Number = plane.distanceTo( _camera.position );
			
			var normal: AVector = plane.normal;
			
			var NdD: Number = normal.dotProduct( _camera.dVector );
			var NdU: Number = normal.dotProduct( _camera.uVector );
			var NdR: Number = normal.dotProduct( _camera.rVector );
			var FdN: Number = _frustum[Camera.DMAX] / _frustum[Camera.DMIN];
			
			var positive: int = 0;
			var negative: int = 0;
			var sgnDist: Number;
			
			var PDMin: Number = _frustum[Camera.DMIN] * NdD;
			var NUMin: Number = _frustum[Camera.UMIN] * NdU;
			var NUMax: Number = _frustum[Camera.UMAX] * NdU;
			var NRMin: Number = _frustum[Camera.RMIN] * NdR;
			var NRMax: Number = _frustum[Camera.RMAX] * NdR;
			
			sgnDist = NdEmC  + PDMin + NUMin + NRMin;
			
			if ( sgnDist > 0 )
			{
				positive++;
			}
			else if ( sgnDist < 0 )
			{
				negative++;
			}
			
			
			
			sgnDist = NdEmC + PDMin + NUMin + NRMax;
			if ( sgnDist > 0 )
			{
				positive++;
			}
			else if ( sgnDist < 0 )
			{
				negative++;
			}
			
			
			
			sgnDist = NdEmC + PDMin + NUMax + NRMin;
			if ( sgnDist > 0 )
			{
				positive++;
			}
			else if ( sgnDist < 0 )
			{
				negative++;
			}
			
			
			
			sgnDist = NdEmC + PDMin + NUMax + NRMax;
			if ( sgnDist > 0 )
			{
				positive++;
			}
			else if ( sgnDist < 0 )
			{
				negative++;
			}
			
			
			
			var PDMax: Number = _frustum[Camera.DMAX] * NdD;
			var FUMin: Number = FdN * NUMin;
			var FUMax: Number = FdN * NUMax;
			var FRMin: Number = FdN * NRMin;
			var FRMax: Number = FdN * NRMax;
			
			sgnDist = NdEmC + PDMax + FUMin + FRMin;
			if ( sgnDist > 0 )
			{
				positive++;
			}
			else if ( sgnDist < 0 )
			{
				negative++;
			}
			
			
			
			
			sgnDist = NdEmC + PDMax + FUMin + FRMax;
			if ( sgnDist > 0 )
			{
				positive++;
			}
			else if ( sgnDist < 0 )
			{
				negative++;
			}
			
			
			
			
			sgnDist = NdEmC + PDMax + FUMax + FRMin;
			if ( sgnDist > 0 )
			{
				positive++;
			}
			else if ( sgnDist < 0 )
			{
				negative++;
			}
			
			
			
			sgnDist = NdEmC + PDMax + FUMax + FRMax;
			if ( sgnDist > 0 )
			{
				positive++;
			}
			else if ( sgnDist < 0 )
			{
				negative++;
			}
			
			
			
			if ( positive > 0 )
			{
				if ( negative > 0 )
				{
					return 0;
				}
				
				return 1;
			}
			
			return -1;
		}
		
		public function computeVisibleSet( scene: Spatial ): void
		{
			if ( _camera && scene )
			{
				frustum = _camera.frustum;
				_visibleSet.clear();
				scene.onGetVisibleSet( this, false );
			}
			else
			{
				Assert.isTrue( false, "A camera and a scene are required for culling" );
			}
		}
		
		
	}

}