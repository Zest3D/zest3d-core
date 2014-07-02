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
package zest3d.controllers 
{
	import plugin.core.interfaces.IDisposable;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.HMatrix;
	import plugin.math.algebra.HQuaternion;
	import plugin.math.base.MathHelper;
	import zest3d.datatypes.Transform;
	import zest3d.scenegraph.Spatial;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class BlendTransformController extends TransformController implements IDisposable 
	{
		
		protected var _controller0: TransformController;
		protected var _controller1: TransformController;
		protected var _weight: Number;
		
		protected var _rsMatrices: Boolean;
		protected var _geometricRotation: Boolean;
		protected var _geometricScale: Boolean;
		
		public function BlendTransformController( controller0: TransformController, controller1: TransformController, rsMatrices: Boolean, geometricRotation: Boolean = false, geometricScale: Boolean = false ) 
		{
			super( Transform.IDENTITY );
			
			_controller0 = controller0;
			_controller1 = controller1;
			
			_weight = 0;
			_rsMatrices = rsMatrices;
			_geometricRotation = geometricRotation;
			_geometricScale = geometricScale;
		}
		
		override public function dispose():void 
		{
			_controller0.dispose();
			_controller1.dispose();
			
			_controller0 = null;
			_controller1 = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get controller0(): TransformController
		{
			return _controller0;
		}
		
		[Inline]
		public final function get controller1(): TransformController
		{
			return _controller1;
		}
		
		[Inline]
		public final function get rsMatrices(): Boolean
		{
			return _rsMatrices;
		}
		
		[Inline]
		public final function set weight( weight: Number ): void
		{
			_weight = weight;
		}
		
		[Inline]
		public final function get weight(): Number
		{
			return _weight;
		}
		
		override public function update(applicationTime:Number):Boolean 
		{
			if ( !super.update( applicationTime ) )
			{
				return false;
			}
			
			_controller0.update( applicationTime );
			_controller1.update( applicationTime );
			
			var xfrm0: Transform = _controller0.transform;
			var xfrm1: Transform = _controller1.transform;
			var oneMinusWeight: Number = 1 - _weight;
			
			var trn0: APoint = xfrm0.translate;
			var trn1: APoint = xfrm1.translate;
			var blendTrn: APoint = trn0.scale( oneMinusWeight ).add( trn1.scale( _weight ) );
			
			_localTransform.translate = blendTrn;
			
			if ( _rsMatrices )
			{
				var rot0: HMatrix = xfrm0.rotate;
				var rot1: HMatrix = xfrm1.rotate;
				
				
				//here we need HQuaternion::fromMatrix()
				var quat0: HQuaternion = HQuaternion.fromRotationMatrix( rot0 );
				var quat1: HQuaternion = HQuaternion.fromRotationMatrix( rot1 );
				if ( quat0.dotProduct( quat1 ) < 0 )
				{
					quat1 = quat1.negate();
				}
				
				var sca0: APoint = xfrm0.scale;
				var sca1: APoint = xfrm1.scale;
				
				var blendRot: HMatrix = new HMatrix();
				var blendQuat: HQuaternion = new HQuaternion();
				var blendSca: APoint = new APoint();
				
				if ( _geometricRotation )
				{
					blendQuat.slerp( _weight, quat0, quat1 );
				}
				else
				{
					blendQuat = quat0.scale( oneMinusWeight ).add( quat1.scale( _weight ) );
					blendQuat.normalize();
				}
				
				blendRot = blendQuat.toRotationMatrix();
				_localTransform.rotate = blendRot;
				
				if ( _geometricScale )
				{
					for ( var i: int = 0; i < 3; ++i )
					{
						var s0: Number = sca0[i];
						var s1: Number = sca1[i];
						if ( s0 != 0 && s1 != 0 )
						{
							var sign0: Number = MathHelper.sign( s0 );
							var sign1: Number = MathHelper.sign( s1 );
							s0 = Math.abs( s0 );
							s1 = Math.abs( s1 );
							var pow0: Number = Math.pow(s0, oneMinusWeight );
							var pow1: Number = Math.pow(s1, _weight );
							blendSca[i] = sign0 * sign1 * pow0 * pow1;
						}
						else
						{
							blendSca[i] = 0;
						}
					}
				}
				else
				{
					//blendSca[i] = oneMinusWeight * sca0 + _weight * sca1;
					blendSca[i] =  sca0.scale( oneMinusWeight ).add( sca1.scale( _weight ) );
				}
				_localTransform.scale = blendSca;
			}
			else
			{
				var mat0: HMatrix = xfrm0.matrix;
				var mat1: HMatrix = xfrm1.matrix;
				var blendMat: HMatrix = mat0.scale( oneMinusWeight ).add( mat1.scale( _weight ) );
				_localTransform.rotate = blendMat;
			}
			
			var spatial: Spatial = _object as Spatial;
			spatial.localTransform = _localTransform;
			return true;
		}
		
		// internal use only
		override public function set object(value:ControlledObject):void 
		{
			super.object = value;
			_controller0.object = object;
			_controller1.object = object;
		}
		
		//TODO add name support
	}

}