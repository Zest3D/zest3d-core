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
	import flash.utils.ByteArray;
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import plugin.math.algebra.AVector;
	import plugin.math.algebra.HMatrix;
	import zest3d.scenegraph.Particles;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class ParticleController extends Controller implements IDisposable 
	{
		
		public var systemLinearSpeed: Number;
		public var systemAngularSpeed: Number;
		public var systemLinearAxis: AVector;
		public var systemAngularAxis: AVector;
		public var systemSizeChange: Number;
		
		protected var _numParticles: int;
		protected var _particleLinearSpeed: Vector.<Number>;
		protected var _particleLinearAxis: Vector.<AVector>;
		protected var _particleSizeChange: Vector.<Number>;
		
		public function ParticleController() 
		{
			systemLinearSpeed = 0;
			systemAngularSpeed = 0;
			systemLinearAxis = AVector.UNIT_Z;
			systemAngularAxis = AVector.UNIT_Z;
			systemSizeChange = 0;
			_numParticles = 0;
			_particleLinearSpeed = null;
			_particleLinearAxis = null;
			_particleSizeChange = null;
		}
		
		override public function dispose():void 
		{
			_particleLinearSpeed = null;
			_particleLinearAxis = null;
			_particleSizeChange = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get numParticles(): int
		{
			return _numParticles;
		}
		
		[Inline]
		public final function get particleLinearSpeed(): Vector.<Number>
		{
			return _particleLinearSpeed;
		}
		
		[Inline]
		public final function get particleLinearAxis(): Vector.<AVector>
		{
			return _particleLinearAxis;
		}
		
		[Inline]
		public final function get particleSizeChange(): Vector.<Number>
		{
			return _particleSizeChange;
		}
		
		override public function update(applicationTime:Number):Boolean 
		{
			if ( !super.update( applicationTime ) )
			{
				return false;
			}
			
			var ctrlTime: Number = getControlTime( applicationTime );
			updateSystemMotion( ctrlTime );
			updatePointMotion( ctrlTime );
			
			return true;
		}
		
		protected function reallocate( numParticles: int ): void
		{
			_particleLinearSpeed = null;
			_particleLinearAxis = null;
			_particleSizeChange = null;
			
			_numParticles = numParticles;
			if ( _numParticles > 0 )
			{
				_particleLinearSpeed = new Vector.<Number>( _numParticles );
				_particleLinearAxis = new Vector.<AVector>( _numParticles );
				_particleSizeChange = new Vector.<Number>( _numParticles );
				for ( var i: int = 0; i < _numParticles; ++i )
				{
					_particleLinearSpeed[ i ] = 0;
					_particleLinearAxis[ i ] = AVector.UNIT_Z;
					_particleSizeChange[ i ] = 0;
				}
			}
		}
		
		protected function setObject( object: ControlledObject ): void
		{
			super.object = object;
			
			if ( object )
			{
				Assert.isTrue( object is Particles, "Class must be of type Particles." );
				
				var particles: Particles = object as Particles;
				reallocate( particles.numParticles );
			}
			else
			{
				reallocate( 0 );
			}
		}
		
		// virtual
		protected function updateSystemMotion( ctrlTime: Number ): void
		{
			var particles: Particles = _object as Particles;
			
			var dSize: Number = ctrlTime * systemSizeChange;
			particles.sizeAdjust = particles.sizeAdjust + dSize;
			if ( particles.sizeAdjust < 0 )
			{
				particles.sizeAdjust = 0;
			}
			
			var distance: Number = ctrlTime * systemLinearSpeed;
			var deltaTrn: AVector = systemLinearAxis.scale( distance );
			particles.localTransform.translate = particles.localTransform.translate.addAVector( deltaTrn );
			
			var angle: Number = ctrlTime * systemAngularSpeed;
			var deltaRot: HMatrix = HMatrix.fromAxisAngle( systemAngularAxis, angle );
			particles.localTransform.rotate = deltaRot.multiply( particles.localTransform.rotate );
		}
		
		// virtual
		protected function updatePointMotion( ctrlTime: Number ): void
		{
			var particles: Particles = _object as Particles;
			var posSizes: ByteArray = particles.positionSizes;
			posSizes.position = 0;
			
			var numActive: int = particles.numActive;
			
			var i: int;
			var j: int;
			for ( i = 0, j = 0; i < numActive; ++i, j += 16 )
			{
				var dSize: Number = ctrlTime * _particleSizeChange[ i ];
				var distance: Number = ctrlTime * _particleLinearSpeed[ i ];
				var deltaTrn: AVector = _particleLinearAxis[ i ].scale( distance );
				
				var posSize0: Number = posSizes.readFloat() + deltaTrn.x;
				var posSize1: Number = posSizes.readFloat() + deltaTrn.y;
				var posSize2: Number = posSizes.readFloat() + deltaTrn.z;
				var dSizeNew: Number = posSizes.readFloat() + dSize;
				
				posSizes.position = j;
				posSizes.writeFloat( posSize0 );
				posSizes.writeFloat( posSize1 );
				posSizes.writeFloat( posSize2 );
				posSizes.writeFloat( dSizeNew );
			}
		}
		
		
	}

}