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
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.Assert;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import io.plugin.math.algebra.HMatrix;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Transform implements IDisposable 
	{
		
		[Inline]
		public static function get IDENTITY(): Transform
		{
			return new Transform();
		}
		
		private var _hMatrix:HMatrix;
		private var _invHMatrix:HMatrix;
		
		private var _rotate: HMatrix;
		private var _translate: APoint;
		private var _scale: APoint;
		
		private var _isIdentity: Boolean;
		private var _isRSMatrix: Boolean;
		private var _isUniformScale: Boolean;
		
		private var _inverseNeedsUpdate: Boolean;
		
		
		public function Transform() 
		{
			_hMatrix = HMatrix.IDENTITY;
			_invHMatrix = HMatrix.IDENTITY;
			
			_rotate = HMatrix.IDENTITY;
			_translate = APoint.ORIGIN;
			_scale = APoint.ONE;
			
			_isIdentity = true;
			_isRSMatrix = true;
			_isUniformScale = true;
			_inverseNeedsUpdate = false;
		}
		
		public function dispose(): void
		{
			_hMatrix.dispose();
			_invHMatrix.dispose();
			_rotate.dispose();
			_translate.dispose();
			_scale.dispose();
			
			_hMatrix = null;
			_invHMatrix = null;
			_rotate = null;
			_translate = null;
			_scale = null;
		}
		
		public function toIdentity(): void
		{
			_rotate.identity();
			_translate.set( 0, 0, 0 );
			_scale.set( 1, 1, 1 );
			_isIdentity = true;
			_isRSMatrix = true;
			_isUniformScale = true;
			updateHMatrix();
		}
		
		public function toUnitScale(): void
		{
			Assert.isTrue( _isRSMatrix, "Matrix is not a rotation" );
			
			_scale.set( 1, 1, 1 );
			_isUniformScale = true;
			updateHMatrix();
		}
		
		[Inline]
		public final function get isIdentity(): Boolean
		{
			return _isIdentity;
		}
		
		[Inline]
		public final function get isRSMatrix(): Boolean
		{
			return _isRSMatrix;
		}
		
		[Inline]
		public final function get isUniformScale(): Boolean
		{
			return _isRSMatrix && _isUniformScale;
		}
		
		
		public final function set rotate( rotate: HMatrix ): void
		{
			_rotate = rotate;
			_isIdentity = false;
			_isRSMatrix = true;
			updateHMatrix();
		}
		
		public final function setMatrix( matrix: HMatrix ): void
		{
			_rotate = matrix;
			_isIdentity = false;
			_isRSMatrix = false;
			_isUniformScale = false;
			updateHMatrix();
		}
		
		public final function set translate( translate: APoint ): void
		{
			_translate = translate;
			_isIdentity = false;
			updateHMatrix();
		}
		
		public final function set scale( scale: APoint ): void
		{
			Assert.isTrue( _isRSMatrix, "Matrix is not a rotation." );
			Assert.isTrue( _scale.x != 0 && _scale.y != 0 && _scale.z != 0, "Scales must be nonzero" );
			
			_scale = scale;
			_isIdentity = false;
			_isUniformScale = false;
			updateHMatrix();
		}
		
		public final function set uniformScale( scale: Number ): void
		{
			Assert.isTrue( _isRSMatrix, "Matrix is not a rotation." );
			Assert.isTrue( scale != 0, "Scale must be nonzero" );
			
			_scale.set( scale, scale, scale );
			_isIdentity = false;
			_isUniformScale = true;
			
			updateHMatrix();
		}
		
		
		[Inline]
		public final function get rotate( ): HMatrix
		{
			Assert.isTrue( _isRSMatrix, "Matrix is not a rotation." );
			return _rotate;
		}
		
		
		public final function getMatrix(): HMatrix
		{
			return _rotate;
		}
		
		
		[Inline]
		public final function get translate(): APoint
		{
			return _translate;
		}
		
		[Inline]
		public final function get scale(): APoint
		{
			Assert.isTrue( _isRSMatrix, "Matrix is not a rotation-scale.");
			return _scale;
		}
		
		[Inline]
		public final function get uniformScale(): Number
		{
			Assert.isTrue( _isRSMatrix, "Matrix is not a rotation-scale." );
			Assert.isTrue( _isUniformScale, "Matrix is not uniform scale." );
			return _scale.x;
		}
		
		[Inline]
		public final function get norm(): Number
		{
			if ( _isRSMatrix )
			{
				var maxValue: Number = Math.abs( _scale.x );
				if ( Math.abs( _scale.y ) > maxValue )
				{
					maxValue = Math.abs( _scale.y );
				}
				if ( Math.abs( _scale.z ) > maxValue )
				{
					maxValue  = Math.abs( _scale.z );
				}
				return maxValue;
			}
			
			var maxRowSum: Number =
				Math.abs( _rotate.m00 ) +
				Math.abs( _rotate.m01 ) +
				Math.abs( _rotate.m02 );
			
			var rowSum: Number =
				Math.abs( _rotate.m10 ) +
				Math.abs( _rotate.m11 ) +
				Math.abs( _rotate.m12 );
			
			if ( rowSum > maxRowSum )
			{
				maxRowSum = rowSum;
			}
			
			rowSum =
				Math.abs( _rotate.m20 ) +
				Math.abs( _rotate.m21 ) +
				Math.abs( _rotate.m22 );
			
			if ( rowSum > maxRowSum )
			{
				maxRowSum = rowSum;
			}
			
			return maxRowSum;
		}
		
		[Inline]
		public final function multiplyAPoint( p: APoint ): APoint
		{
			return _hMatrix.multiplyAPoint( p );
		}
		
		[Inline]
		public final function multiplyAVector( v:AVector ): AVector
		{
			return _hMatrix.multiplyAVector( v );
		}
		
		public function multiply( transform: Transform ): Transform
		{
			if ( isIdentity )
			{
				return transform;
			}
			
			if ( transform.isIdentity )
			{
				return this;
			}
			
			var product: Transform = new Transform();
			if ( _isRSMatrix && transform._isRSMatrix )
			{
				if ( _isUniformScale )
				{
					product.rotate = _rotate.multiply( transform._rotate );
					
					
					// product.SetTranslate(GetUniformScale()*( mMatrix*transform.mTranslate) + mTranslate);
					// product.translate = uniformScale * (_rotate * transform._translate) + _translate;
					
					
					product.translate = _rotate.multiplyAPoint( transform._translate ).scale( uniformScale ).add( _translate );
					
					if ( transform.isUniformScale )
					{
						product.uniformScale = uniformScale * transform.uniformScale;
					}
					else
					{
						product.scale = transform.scale.scale( uniformScale );
					}
					
					return product;
				}
			}
			
			var matMA: HMatrix = (_isRSMatrix ? _rotate.timesDiagonal( _scale ) : _rotate);
			var matMB: HMatrix = (transform._isRSMatrix ?
				transform._rotate.timesDiagonal( transform._scale ) :
				transform._rotate );
			
			product.setMatrix( matMA.multiply( matMB ) );
			
			/**
			 * product.translate = (matMA*transform._translate + _translate);
			 */
			product.translate = matMA.multiplyAPoint( transform._translate ).add( _translate );
			
			return product;
		}
		
		public function get matrix(): HMatrix
		{
			return _hMatrix;
		}
		
		
		public function get inverse():HMatrix
		{
			if ( _inverseNeedsUpdate  )
			{
				if ( _isIdentity )
				{
					_invHMatrix = HMatrix.IDENTITY;
				}
				else
				{
					if ( _isRSMatrix )
					{
						if ( _isUniformScale )
						{
							var invScale: Number = 1 / scale.x;
							_invHMatrix.m00 = invScale * _rotate.m00;
							_invHMatrix.m01 = invScale * _rotate.m10;
							_invHMatrix.m02 = invScale * _rotate.m20;
							
							_invHMatrix.m10 = invScale * _rotate.m01;
							_invHMatrix.m11 = invScale * _rotate.m11;
							_invHMatrix.m12 = invScale * _rotate.m21;
							
							_invHMatrix.m20 = invScale * _rotate.m02;
							_invHMatrix.m21 = invScale * _rotate.m12;
							_invHMatrix.m22 = invScale * _rotate.m22;
						}
						else
						{
							var s01: Number = _scale.x * _scale.y;
							var s02: Number = _scale.x * _scale.z;
							var s12: Number = _scale.y * _scale.z;
							
							var invs012: Number = 1 / ( s01 * _scale.z );
							var invS0: Number = s12 * invs012;
							var invS1: Number = s02 * invs012;
							var invS2: Number = s01 * invs012;
							
							_invHMatrix.m00 = invS0 * _rotate.m00;
							_invHMatrix.m01 = invS0 * _rotate.m10;
							_invHMatrix.m02 = invS0 * _rotate.m20;
							_invHMatrix.m10 = invS1 * _rotate.m01;
							_invHMatrix.m11 = invS1 * _rotate.m11;
							_invHMatrix.m12 = invS1 * _rotate.m21;
							_invHMatrix.m20 = invS2 * _rotate.m02;
							_invHMatrix.m21 = invS2 * _rotate.m12;
							_invHMatrix.m22 = invS2 * _rotate.m22;
						}
					}
					else
					{
						_invHMatrix = invert3x3( _hMatrix );
					}
					
					_invHMatrix.m03 = -(
						_invHMatrix.m00 * _translate.x +
						_invHMatrix.m01 * _translate.y +
						_invHMatrix.m02 * _translate.z
					);
					
					_invHMatrix.m13 = -(
						_invHMatrix.m10 * _translate.x +
						_invHMatrix.m11 * _translate.y +
						_invHMatrix.m12 * _translate.z
					);
					
					_invHMatrix.m23 = -(
						_invHMatrix.m20 * _translate.x +
						_invHMatrix.m21 * _translate.y +
						_invHMatrix.m22 * _translate.z
					);
					
				}
				_inverseNeedsUpdate = false;
			}
			
			return _invHMatrix;
		}
		
		public function get inverseTransform(): Transform
		{
			if ( _isIdentity )
			{
				return IDENTITY;
			}
			
			var inverse: Transform = new Transform();
			var invTrn: APoint = new APoint();
			
			if ( _isRSMatrix )
			{
				var invRot: HMatrix = _rotate.transpose();
				inverse.rotate = invRot;
				if ( _isUniformScale )
				{
					var invScaleN: Number = 1 / _scale.x;
					inverse.uniformScale = invScaleN;
					
					//TODO check that this is completely inverted or -invScaleN
					invTrn = invRot.multiplyAPoint( _translate ).scale( invScaleN ).negate();
				}
				else
				{
					var invScaleP: APoint = new APoint( 1 / _scale.x, 1 / _scale.y, 1 / scale.z );
					inverse.scale = invScaleP;
					
					invTrn = invRot.multiplyAPoint( _translate );
					invTrn.x *= -invScaleP.x;
					invTrn.y *= -invScaleP.y;
					invTrn.z *= -invScaleP.z;
				}
			}
			else
			{
				var invMat: HMatrix = invert3x3( _rotate );
				inverse.setMatrix( invMat );
				
				invTrn = ( invMat.multiplyAPoint( _translate )).negate();
			}
			
			inverse.translate = invTrn;
			
			return inverse;
		}
		
		private function updateHMatrix(): void
		{
			if ( _isIdentity )
			{
				_hMatrix = HMatrix.IDENTITY;
			}
			else
			{
				if ( _isRSMatrix )
				{
					_hMatrix.m00 = _rotate.m00 * _scale.x;
					_hMatrix.m01 = _rotate.m01 * _scale.y;
					_hMatrix.m02 = _rotate.m02 * _scale.z;
					
					_hMatrix.m10 = _rotate.m10 * _scale.x;
					_hMatrix.m11 = _rotate.m11 * _scale.y;
					_hMatrix.m12 = _rotate.m12 * _scale.z;
					
					_hMatrix.m20 = _rotate.m20 * _scale.x;
					_hMatrix.m21 = _rotate.m21 * _scale.y;
					_hMatrix.m22 = _rotate.m22 * _scale.z;
				}
				else
				{
					_hMatrix.m00 = _rotate.m00;
					_hMatrix.m01 = _rotate.m01;
					_hMatrix.m02 = _rotate.m02;
					
					_hMatrix.m10 = _rotate.m10;
					_hMatrix.m11 = _rotate.m11;
					_hMatrix.m12 = _rotate.m12;
					
					_hMatrix.m20 = _rotate.m20;
					_hMatrix.m21 = _rotate.m21;
					_hMatrix.m22 = _rotate.m22;
				}
				_hMatrix.m03 = _translate.x;
				_hMatrix.m13 = _translate.y;
				_hMatrix.m23 = _translate.z;
			}
			
			_inverseNeedsUpdate = true;
		}
		
		private static function invert3x3( mat:HMatrix ): HMatrix
		{
			var invMat: HMatrix = mat.clone();
			
			invMat.m00 = mat.m11 * mat.m22 - mat.m12 * mat.m21;
			invMat.m01 = mat.m02 * mat.m21 - mat.m01 * mat.m22;
			invMat.m02 = mat.m01 * mat.m12 - mat.m02 * mat.m11;
			invMat.m10 = mat.m12 * mat.m20 - mat.m10 * mat.m22;
			invMat.m11 = mat.m00 * mat.m22 - mat.m02 * mat.m20;
			invMat.m12 = mat.m02 * mat.m10 - mat.m00 * mat.m12;
			invMat.m20 = mat.m10 * mat.m21 - mat.m11 * mat.m20;
			invMat.m21 = mat.m01 * mat.m20 - mat.m00 * mat.m21;
			invMat.m22 = mat.m00 * mat.m11 - mat.m01 * mat.m10;
			
			var invDet: Number = 1 / ( mat.m00 * invMat.m00 +
									   mat.m01 * invMat.m10 +
									   mat.m02 * invMat.m20 );
			
			invMat.m00 *= invDet;
			invMat.m01 *= invDet;
			invMat.m02 *= invDet;
			
			invMat.m10 *= invDet;
			invMat.m11 *= invDet;
			invMat.m12 *= invDet;
			
			invMat.m20 *= invDet;
			invMat.m21 *= invDet;
			invMat.m22 *= invDet;
			
			return invMat;
		}
		
	}

}