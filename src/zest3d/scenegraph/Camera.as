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
	import io.plugin.math.algebra.HMatrix;
	import io.plugin.math.base.MathHelper;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Camera implements IDisposable 
	{
		
		public static const DMIN: int = 0;
		public static const DMAX: int = 1;
		public static const UMIN: int = 2;
		public static const UMAX: int = 3;
		public static const RMIN: int = 4;
		public static const RMAX: int = 5;
		public static const VF_QUANTITY: int = 6;
		
		public static const ZERO_TO_ONE: int = 0;
		public static const MINUS_ONE_TO_ONE: int = 1;
		public static const DEPTH_QUANTITY: int = 2;
		
		protected var _position: APoint;
		protected var _dVector:AVector;
		protected var _uVector:AVector;
		protected var _rVector:AVector;
		
		protected var _viewMatrix:HMatrix;
		
		protected var _frustum:Array;
		
		protected var _projectionMatrix: Array;
		protected var _projectionViewMatrix: Array;
		
		protected var _previewMatrix:HMatrix;
		protected var _previewIsIdentity:Boolean;
		
		protected var _postProjectionMatrix:HMatrix;
		protected var _postProjectionIsIdentity:Boolean;
		
		protected var _isPerspective:Boolean;
		
		protected var _depthType:int;
		
		protected var _isDisposed:Boolean;
		
		protected static var msDefaultDepthType:int = ZERO_TO_ONE;
		
		private var _validateCameraFrame: Boolean;
		
		
		public function Camera( isPerspective: Boolean = true ) 
		{
			_viewMatrix = HMatrix.IDENTITY;
			
			_previewMatrix = HMatrix.IDENTITY;
			_previewIsIdentity = false;
			
			_postProjectionMatrix = HMatrix.IDENTITY;
			_postProjectionIsIdentity = false;
			
			_isPerspective = isPerspective;
			
			_depthType = msDefaultDepthType;
			_validateCameraFrame = true;
			
			var i: int;
			_frustum = new Array( VF_QUANTITY );
			for ( i = 0; i < VF_QUANTITY; i++ )
			{
				_frustum[ i ] = 0;
			}
			
			_projectionMatrix = new Array( DEPTH_QUANTITY );
			_projectionViewMatrix = new Array( DEPTH_QUANTITY );
			for ( i = 0; i < DEPTH_QUANTITY; i++ )
			{
				_projectionMatrix[ i ] = HMatrix.IDENTITY;
				_projectionViewMatrix[ i ] = HMatrix.IDENTITY;
			}
			
			setFrame( APoint.ORIGIN, AVector.UNIT_Z, AVector.UNIT_Y, AVector.UNIT_X );
			setFrustumFOV( 90, 1, 1, 10000 );
			
			_isDisposed = true;
		}
		
		public function dispose(): void
		{
			//TODO  Camera::dispose()
			
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function setFrame( position: APoint, dVector: AVector, uVector: AVector, rVector:AVector ): void
		{
			_position = position;
			setAxes( dVector, uVector, rVector );
		}
		
		public function set position( position: APoint ): void
		{
			_position = position;
			onFrameChange();
		}
		
		public function setAxes( dVector: AVector, uVector: AVector,  rVector: AVector ):void
		{
			_dVector = dVector;
			_uVector = uVector;
			_rVector = rVector;
			
			var epsilon: Number = 0.01;
			var det: Number = _dVector.dotProduct( _uVector.crossProduct( _rVector ) );
			
			if (Math.abs( 1 - det ) > epsilon )
			{
				if (_validateCameraFrame)
				{
					_validateCameraFrame = false;
					
					var lenD: Number = _dVector.length;
					var lenU: Number = _uVector.length;
					var lenR: Number = _rVector.length;
					
					var dotDU: Number = _dVector.dotProduct( _uVector );
					var dotDR: Number = _dVector.dotProduct( _rVector );
					var dotUR: Number = _uVector.dotProduct( _rVector );
					
					if ( Math.abs( 1 - lenD ) > epsilon
					  || Math.abs( 1 - lenU ) > epsilon
					  || Math.abs( 1 - lenR ) > epsilon
					  || Math.abs( dotDU ) > epsilon
					  || Math.abs( dotDR ) > epsilon
					  || Math.abs( dotUR ) > epsilon )
					{
						Assert.isTrue( false, "Camera frame is not orthonormal." );
					}
				}
				
				var orth:Array = AVector.orthonormalize( _dVector, _uVector, _rVector )
				_dVector = orth[ 0 ];
				_uVector = orth[ 1 ];
				_rVector = orth[ 2 ];
			}
			
			onFrameChange();
		}
		
		[Inline]
		public final function get position(): APoint
		{
			return _position;
		}
		
		[Inline]
		public final function get dVector(): AVector
		{
			return _dVector;
		}
		
		[Inline]
		public final function get uVector(): AVector
		{
			return _uVector;
		}
		
		[Inline]
		public final function get rVector(): AVector
		{
			return _rVector;
		}
		
		[Inline]
		public final function get viewMatrix(): HMatrix
		{
			return _viewMatrix;
		}
		
		[Inline]
		public final function get isPerspective(): Boolean
		{
			return _isPerspective;
		}
		
		public function setFrustum( frustum: Array ): void
		{
			if ( frustum.length < 6 )
			{
				throw new Error( "Camera::setFrustum invalid value length." );
			}
			
			_frustum[ DMIN ] = frustum[ DMIN ];
			_frustum[ DMAX ] = frustum[ DMAX ];
			_frustum[ UMIN ] = frustum[ UMIN ];
			_frustum[ UMAX ] = frustum[ UMAX ];
			_frustum[ RMIN ] = frustum[ RMIN ];
			_frustum[ RMAX ] = frustum[ RMAX ];
			
			onFrustumChange();
		}
		
		public function setFrustumFOV( upFOVDegrees: Number, aspectRatio: Number, dMin: Number, dMax: Number ): void
		{
			var halfAngleRadians: Number = 0.5 * upFOVDegrees * MathHelper.DEG_TO_RAD;
			_frustum[ UMAX ] = dMin * Math.tan( halfAngleRadians );
			_frustum[ RMAX ] = aspectRatio * _frustum[ UMAX ];
			_frustum[ UMIN ] = -_frustum[ UMAX ];
			_frustum[ RMIN ] = -_frustum[ RMAX ];
			_frustum[ DMIN ] = dMin;
			_frustum[ DMAX ] = dMax;
			
			onFrustumChange();
		}
		
		public function get frustum( ): Array
		{
			return [ _frustum[ DMIN ], _frustum[ DMAX ], _frustum[ UMIN ], _frustum[ UMAX ], _frustum[ RMIN ], _frustum[ RMAX ] ];
		}
		
		public function getFrustumFOV( values: Array ): Boolean
		{
			if ( _frustum[RMIN] == -_frustum[RMAX]
			  && _frustum[UMIN] == -_frustum[UMAX] )
			{
				var tmp: Number = _frustum[UMAX] / _frustum[DMIN];
				
				values[ 0 ] = 2 * Math.atan( tmp ) * MathHelper.RAD_TO_DEG;
				values[ 1 ] = _frustum[RMAX] / _frustum[UMAX];
				values[ 2 ] = _frustum[DMIN];
				values[ 3 ] = _frustum[DMAX];
				
				return true;
			}
			return false;
		}
		
		[Inline]
		public final function get dMin(): Number
		{
			return _frustum[ DMIN ];
		}
		
		[Inline]
		public final function get dMax(): Number
		{
			return _frustum[ DMAX ];
		}
		
		[Inline]
		public final function get uMin(): Number
		{
			return _frustum[UMIN];
		}
		
		[Inline]
		public final function get uMax(): Number
		{
			return _frustum[UMAX];
		}
		
		[Inline]
		public final function get rMin(): Number
		{
			return _frustum[RMIN];
		}
		
		[Inline]
		public final function get rMax(): Number
		{
			return _frustum[RMAX];
		}
		
		[Inline]
		public final function get depthType(): int
		{
			return _depthType;
		}
		
		[Inline]
		public final function get projectionMatrix(): HMatrix
		{
			return _projectionMatrix[ _depthType ];
		}
		
		
		
		[Inline]
		public final function set projectionMatrix( projMatrix:HMatrix ): void
		{
			_projectionMatrix[ _depthType ] = projMatrix;
		}
		
		[Inline]
		public final function get projectionViewMatrix(): HMatrix
		{
			return _projectionViewMatrix[ _depthType ];
		}
		
		/*
		public function setProjectionMatrix( p00: APoint, p10: APoint, p11: APoint, p01: APoint, nearExtrude: Number, farExtrude: Number ): void
		{
			Assert.isTrue( nearExtrude > 0, "Invalid nearExtrude." );
			Assert.isTrue( farExtrude > nearExtrude, "Invalid farExtrude." );
			
			var q000: APoint = p00.scale( nearExtrude );
			var q100: APoint = p10.scale( nearExtrude );
			var q110: APoint = p11.scale( nearExtrude );
			var q010: APoint = p01.scale( nearExtrude );
			
			var q001: APoint = p00.scale( farExtrude );
			var q101: APoint = p10.scale( farExtrude );
			var q111: APoint = p11.scale( farExtrude );
			var q011: APoint = p01.scale( farExtrude );
			
			var u0: AVector = q100.subtract( q000 );
			var u1: AVector = q010.subtract( q000 );
			var u2: AVector = q001.subtract( q000 );
			
			var m :HMatrix = new HMatrix(
			
		}
		*/
		
		public function set previewMatrix( previewMatrix: HMatrix ): void
		{
			_previewMatrix = previewMatrix;
			_previewIsIdentity = _previewMatrix.equals( HMatrix.IDENTITY );
			
			updatePVMatrix();
		}
		
		[Inline]
		public final function get previewMatrix( ): HMatrix
		{
			return _previewMatrix;
		}
		
		[Inline]
		public final function get previewIsIdentity(): Boolean
		{
			return _previewIsIdentity;
		}
		
		
		public function set postProjectionMatrix(postProjMatrix:HMatrix ): void
		{
			_postProjectionMatrix = postProjMatrix;
			_postProjectionIsIdentity = ( _postProjectionMatrix.equals( HMatrix.IDENTITY ) );
			
			updatePVMatrix();
		}
		
		[Inline]
		public final function get postProjectionMatrix(): HMatrix
		{
			return _postProjectionMatrix;
		}
		
		[Inline]
		public final function get postProjectionIsIdentity(): Boolean
		{
			return _postProjectionIsIdentity;
		}
		
		[Inline]
		public static function set defaultDepthType( type:int ): void
		{
			msDefaultDepthType = type;
		}
		
		[Inline]
		internal static function get defaultDepthType(): int
		{
			return msDefaultDepthType;
		}
		
		//TODO revise and encap min/max values
		//public function computeBoundingAABB( numVertices: int, vertices:ByteArray, stride: int, worldMatrix:HMatrix, xMin: Number,
		
		protected function onFrameChange(): void
		{
			_viewMatrix.m00 = _rVector.x;
			_viewMatrix.m01 = _rVector.y;
			_viewMatrix.m02 = _rVector.z;
			_viewMatrix.m03 = -_position.dotProduct( _rVector );
			
			_viewMatrix.m10 = _uVector.x;
			_viewMatrix.m11 = _uVector.y;
			_viewMatrix.m12 = _uVector.z;
			_viewMatrix.m13 = -_position.dotProduct( _uVector );
			
			_viewMatrix.m20 = _dVector.x;
			_viewMatrix.m21 = _dVector.y;
			_viewMatrix.m22 = _dVector.z;
			_viewMatrix.m23 = -_position.dotProduct( _dVector );
			
			_viewMatrix.m30 = 0;
			_viewMatrix.m31 = 0;
			_viewMatrix.m32 = 0;
			_viewMatrix.m33 = 1;
			
			updatePVMatrix();
		}
		
		protected function onFrustumChange(): void
		{
			var dMin: Number = _frustum[ DMIN ];
			var dMax: Number = _frustum[ DMAX ];
			var uMin: Number = _frustum[ UMIN ];
			var uMax: Number = _frustum[ UMAX ];
			var rMin: Number = _frustum[ RMIN ];
			var rMax: Number = _frustum[ RMAX ];
			
			var invDDiff: Number = 1 / (dMax - dMin);
			var invUDiff: Number = 1 / (uMax - uMin);
			var invRDiff: Number = 1 / (rMax - rMin);
			
			var sumRMinRMaxInvRDiff: Number = (rMin + rMax) * invRDiff;
			var sumUMinUMaxInvUDiff: Number = (uMin + uMax) * invUDiff;
			var sumDMinDMaxInvDDiff: Number = (dMin + dMax) * invDDiff;
			
			if ( _isPerspective )
			{
				var twoDMinInvRDiff: Number = 2 * dMin * invRDiff;
				var twoDMinInvUDiff: Number = 2 * dMin * invUDiff;
				var dMaxInvDDiff: Number = dMax * invDDiff;
				var dMinDMaxInvDDiff: Number = dMin * dMaxInvDDiff;
				var twoDMinDMaxInvDDiff: Number = 2 * dMinDMaxInvDDiff;
				
				if ( _depthType == ZERO_TO_ONE )
				{
					HMatrix( _projectionMatrix[ ZERO_TO_ONE ] ).set
						(
							twoDMinInvRDiff,
							0,
							-sumRMinRMaxInvRDiff,
							0,
							0,
							twoDMinInvUDiff,
							-sumUMinUMaxInvUDiff,
							0,
							0,
							0,
							dMaxInvDDiff,
							-dMinDMaxInvDDiff,
							0,
							0,
							1,
							0
						); 
				}
				else
				{
					HMatrix( _projectionMatrix[ MINUS_ONE_TO_ONE ] ).set
						(
							twoDMinInvRDiff,
							0,
							-sumRMinRMaxInvRDiff,
							0,
							0,
							twoDMinInvUDiff,
							-sumUMinUMaxInvUDiff,
							0,
							0,
							0,
							sumDMinDMaxInvDDiff,
							-twoDMinDMaxInvDDiff,
							0,
							0,
							1,
							0
						);
				}
			}
			else
			{
				var twoInvRDiff: Number = 2 * invRDiff;
				var twoInvUDiff: Number = 2 * invUDiff;
				var twoInvDDiff: Number = 2 * invDDiff;
				var dMinInvDDiff: Number = dMin * invDDiff;
				
				if ( _depthType == ZERO_TO_ONE )
				{
					HMatrix( _projectionMatrix[ ZERO_TO_ONE ] ).set(
						twoInvRDiff,
						0,
						0,
						-sumRMinRMaxInvRDiff,
						0,
						twoInvUDiff,
						0,
						-sumUMinUMaxInvUDiff,
						0,
						0,
						invDDiff,
						-dMinInvDDiff,
						0,
						0,
						0,
						1
					)
				}
				else
				{
					HMatrix( _projectionMatrix[ MINUS_ONE_TO_ONE ] ).set
					(
						twoInvRDiff,
						0,
						0,
						-sumRMinRMaxInvRDiff,
						0,
						twoInvUDiff,
						0,
						-sumUMinUMaxInvUDiff,
						0,
						0,
						twoInvDDiff,
						-sumDMinDMaxInvDDiff,
						0,
						0,
						0,
						1
					);
				}
				
			}
			
			updatePVMatrix();
		}
		
		protected function updatePVMatrix(): void
		{
			var pMatrix: HMatrix = _projectionMatrix[ _depthType ];
			var pvMatrix: HMatrix = _projectionViewMatrix[ _depthType ];
			
			pvMatrix = pMatrix.multiply( _viewMatrix );
			
			if ( !_postProjectionIsIdentity )
			{
				pvMatrix = _postProjectionMatrix.multiply( pvMatrix );
			}
			
			if ( !_previewIsIdentity )
			{
				pvMatrix.multiplyEq( _previewMatrix );
			}
			
			_projectionViewMatrix[ _depthType ] = pvMatrix;
		}
	}

}