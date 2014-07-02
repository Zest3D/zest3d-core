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
	import flash.utils.getQualifiedClassName;
	import plugin.core.errors.AbstractClassError;
	import plugin.core.interfaces.IDisposable;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.AVector;
	import plugin.math.algebra.HMatrix;
	import zest3d.renderers.Renderer;
	import zest3d.resources.VertexBufferAccessor;
	import zest3d.scenegraph.Polypoint;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class PointController extends Controller implements IDisposable 
	{
		
		public var systemLinearSpeed: Number;
		public var systemAngluarSpeed: Number;
		public var systemLinearAxis: AVector;
		public var systemAngularAxis: AVector;
		
		protected var _numPoints: int;
		protected var _pointLinearSpeed: Vector.<Number>;
		protected var _pointAngularSpeed: Vector.<Number>;
		protected var _pointLinearAxis: Vector.<AVector>;
		protected var _pointAngularAxis: Vector.<AVector>;
		
		// abstract
		public function PointController() 
		{
			if ( getQualifiedClassName( this ) == "zest3d.controllers::PointController" )
			{
				throw new AbstractClassError();
			}
			
			systemLinearSpeed = 0;
			systemAngluarSpeed = 0;
			systemLinearAxis = AVector.UNIT_Z;
			systemAngularAxis = AVector.UNIT_Z;
			
			_numPoints = 0;
		}
		
		override public function dispose():void 
		{
			//TODO dispose of things
			super.dispose();
		}
		
		[Inline]
		public final function get numPoints(): int
		{
			return _numPoints;
		}
		
		[Inline]
		public final function get pointLinearSpeed(): Vector.<Number>
		{
			return _pointLinearSpeed;
		}
		
		[Inline]
		public final function get pointAngularSpeed(): Vector.<Number>
		{
			return _pointAngularSpeed;
		}
		
		[Inline]
		public final function get pointLinearAxis(): Vector.<AVector>
		{
			return _pointLinearAxis;
		}
		
		[Inline]
		public final function get pointAngularAxis(): Vector.<AVector>
		{
			return _pointAngularAxis;
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
		
		protected function reallocate( numPoints: int ): void
		{
			_pointLinearSpeed = null;
			_pointAngularSpeed = null;
			_pointLinearAxis = null;
			_pointAngularAxis = null;
			
			_numPoints = numPoints;
			if ( _numPoints > 0 )
			{
				_pointLinearSpeed = new Vector.<Number>( _numPoints );
				_pointAngularSpeed = new Vector.<Number>( _numPoints );
				_pointLinearAxis = new Vector.<AVector>( _numPoints );
				_pointAngularAxis = new Vector.<AVector>( _numPoints );
				
				for ( var i: int = 0; i < _numPoints; ++i )
				{
					_pointLinearSpeed[ i ] = 0;
					_pointAngularSpeed[ i ] = 0;
					_pointLinearAxis[ i ] = AVector.UNIT_Z;
					_pointAngularAxis[ i ] = AVector.UNIT_Z;
				}
			}
		}
		
		// virtual
		override public function set object(object:ControlledObject):void 
		{
			super.object = object;
			
			if ( object is Polypoint )
			{
				var points: Polypoint = object as Polypoint;
				reallocate( points.vertexBuffer.numElements );
			}
			else
			{
				reallocate( 0 );
			}
		}
		
		protected function updateSystemMotion( ctrlTime: Number ): void
		{
			var points: Polypoint = _object as Polypoint;
			
			var distance: Number = ctrlTime * systemLinearSpeed;
			var deltaTrn: AVector = systemLinearAxis.scale( distance );
			points.localTransform.translate = points.localTransform.translate.addAVector( deltaTrn );
			
			var angle: Number = ctrlTime * systemAngluarSpeed;
			
			var deltaRot: HMatrix = new HMatrix().rotation( systemAngularAxis, angle );
			points.localTransform.rotate = deltaRot.multiply( points.localTransform.rotate );
			
		}
		
		protected function updatePointMotion( ctrlTime: Number ): void
		{
			var points: Polypoint = _object as Polypoint;
			
			var vba: VertexBufferAccessor = new VertexBufferAccessor( points.vertexFormat, points.vertexBuffer );
			
			var numPoints: int = points.numPoints;
			
			var i: int;
			for (  i = 0;  i < numPoints; ++i )
			{
				var distance: Number = _pointLinearSpeed[ i ] * ctrlTime;
				
				var position: APoint = APoint.fromTuple( vba.getPositionAt( i ) );
				var deltaTrn: AVector = _pointLinearAxis[ i ].scale( distance );
				
				
				var posDelta: APoint = position.addAVector( deltaTrn );
				vba.setPositionAt( i, posDelta.toTuple().slice( 0, 3 ) );
				
			}
			
			if ( vba.hasNormal() )
			{
				for ( i = 0; i < numPoints; ++i )
				{
					var angle: Number = ctrlTime * _pointAngularSpeed[ i ];
					var normal: AVector = AVector.fromTuple( vba.getPositionAt( i ) );
					normal.normalize();
					
					var deltaRot: HMatrix = HMatrix.fromAxisAngle( _pointAngularAxis[ i ], angle );
					
					var normalDelta: AVector = deltaRot.multiplyAVector( normal);
					vba.setNormalAt( i, normalDelta.toTuple().slice( 0, 3 ) );
				}
			}
			
			Renderer.updateAllVertexBuffer( points.vertexBuffer );
		}
		
	}

}