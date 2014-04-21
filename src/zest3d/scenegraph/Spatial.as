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
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.HMatrix;
	import zest3d.controllers.ControlledObject;
	import zest3d.datatypes.Bound;
	import zest3d.datatypes.Transform;
	import zest3d.scenegraph.enum.CullingType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Spatial extends ControlledObject implements IDisposable 
	{
		/**
		 * Internal use only
		 */
		public var localTransform: Transform;
		
		/**
		 * Internal use only
		 */
		public var worldTransform: Transform;
		
		public var worldTransformIsCurrent: Boolean;
		
		public var worldBound: Bound;
		public var worldBoundIsCurrent: Boolean;
		
		public var culling: CullingType;
		
		protected var _parent: Spatial;
		
		
		
		////////////////////////////////////////////////////////////////////////
		// convenience API
		////////////////////////////////////////////////////////////////////////
		protected var _rotate: HMatrix;
		
		protected var _rotationX: Number = 0;
		protected var _rotationY: Number = 0;
		protected var _rotationZ: Number = 0;
		
		protected var _rotMatX: HMatrix;
		protected var _rotMatY: HMatrix;
		protected var _rotMatZ: HMatrix;
		
		protected var _translate: APoint;
		protected var _scale: APoint;
		
		protected var _rotationNeedsUpdate: Boolean;
		protected var _translateNeedsUpdate: Boolean;
		protected var _scaleNeedsUpdate: Boolean;
		
		// scale ===========================
		public function set scaleUniform( value: Number ): void
		{
			_scale.set( value, value, value );
			_scaleNeedsUpdate = true;
		}
		
		public function set scaleX( value: Number ): void
		{
			_scale.x = value;
			_scaleNeedsUpdate = true;
		}
		
		public function set scaleY( value: Number ): void
		{
			_scale.y = value;
			_scaleNeedsUpdate = true;
		}
		
		public function set scaleZ( value: Number ): void
		{
			_scale.z = value;
			_scaleNeedsUpdate = true;
		}
		
		public function scale( x: Number, y: Number, z: Number ): void
		{
			_scale.set( x, y, z );
			_scaleNeedsUpdate = true;
		}
		////////////////////////////////////////////////////////////////////////
		
		
		
		// rotation ////////////////////////////////////////////////////////////
		public function set rotationX( radians: Number ): void
		{
			_rotationX = radians;
			_rotMatX.rotationX( radians );
			_rotationNeedsUpdate = true;
		}
		
		public function set rotationY( radians: Number ): void
		{
			_rotationY = radians;
			_rotMatY.rotationY( radians );
			_rotationNeedsUpdate = true;
		}
		
		public function set rotationZ( radians: Number ): void
		{
			_rotationZ = radians;
			_rotMatZ.rotationZ( radians );
			_rotationNeedsUpdate = true;
		}
		
		public function get rotationX(): Number
		{
			return _rotationX;
		}
		
		public function get rotationY(): Number
		{
			return _rotationY;
		}
		
		public function get rotationZ(): Number
		{
			return _rotationZ;
		}
		
		public function rotate( radiansX: Number, radiansY: Number, radiansZ: Number ): void
		{
			rotationX = radiansX;
			rotationY = radiansY;
			rotationZ = radiansZ;
			_rotationNeedsUpdate = true;
		}
		////////////////////////////////////////////////////////////////////////
		
		
		// translation /////////////////////////////////////////////////////////
		public function set position( p:APoint ):void
		{
			x = p.x;
			y = p.y;
			z = p.z;
			_translateNeedsUpdate = true;
		}
		
		public function get position( ):APoint
		{
			return localTransform.translate;
		}
		
		public function translate( x:Number, y:Number, z:Number ):void
		{
			this.x = x;
			this.y = y;
			this.z = z;
			_translateNeedsUpdate = true;
		}
		
		public function set x( value: Number ): void
		{
			_translate.x = value;
			_translateNeedsUpdate = true;
		}
		
		public function get x(): Number
		{
			return _translate.x;
		}
		
		public function set y( value: Number ): void
		{
			_translate.y = value;
			_translateNeedsUpdate = true;
		}
		
		public function get y(): Number
		{
			return _translate.y;
		}
		
		public function set z( value: Number ): void
		{
			_translate.z = value;
			_translateNeedsUpdate = true;
		}
		
		public function get z(): Number
		{
			return _translate.z;
		}
		////////////////////////////////////////////////////////////////////////
		
		
		public function Spatial() 
		{
			localTransform = new Transform();
			_scale = localTransform.scale;
			_rotate = localTransform.rotate;
			_translate = localTransform.translate;
			
			worldTransform = new Transform();
			worldTransformIsCurrent = false;
			
			worldBound = new Bound();
			worldBoundIsCurrent = false;
			
			culling = CullingType.DYNAMIC;
			_parent = null;
			
			_rotMatX = HMatrix.IDENTITY;
			_rotMatY = HMatrix.IDENTITY;
			_rotMatZ = HMatrix.IDENTITY;
		}
		
		override public function dispose(): void
		{
			// The _parent member is not reference counted by Spatial so do not
			// release it here.
			super.dispose();
		}
		
		public function update( applicationTime: Number = -1.79e+308, initiator:Boolean = true ): void
		{
			if ( _scaleNeedsUpdate )
			{
				localTransform.scale = _scale;
				_scaleNeedsUpdate = false;
			}
			
			if ( _rotationNeedsUpdate )
			{
				_rotate = _rotMatX.multiply( _rotMatY ).multiply( _rotMatZ );
				localTransform.rotate = _rotate;
				_rotationNeedsUpdate = false;
			}
			
			if ( _translateNeedsUpdate )
			{
				localTransform.translate = _translate;
				_translateNeedsUpdate = false;
			}
			
			updateWorldData( applicationTime );
			updateWorldBound();
			if ( initiator )
			{
				propagateBoundToRoot();
			}
		}
		
		[Inline]
		public final function get parent(): Spatial
		{
			return _parent;
		}
		
		protected function updateWorldData( applicationTime: Number ): void
		{
			updateControllers( applicationTime );
			
			if ( !worldTransformIsCurrent )
			{
				if ( _parent )
				{
					worldTransform = _parent.worldTransform.multiply( localTransform );
				}
				else
				{
					worldTransform = localTransform;
				}
			}
		}
		
		// virtual
		protected function updateWorldBound( ): void
		{
			
		}
		
		protected function propagateBoundToRoot(): void
		{
			if ( _parent )
			{
				_parent.updateWorldBound();
				_parent.propagateBoundToRoot();
			}
		}
		
		// internal use only
		public function onGetVisibleSet( culler: Culler, noCull: Boolean ): void
		{
			if ( culling == CullingType.ALWAYS )
			{
				return;
			}
			
			if ( culling == CullingType.NEVER )
			{
				noCull = true;
			}
			
			var savePlaneState: uint = culler.planeState;
			if ( noCull || culler.isVisibleBound( worldBound ) )
			{
				getVisibleSet( culler, noCull );
			}
			
			culler.planeState = savePlaneState;
		}
		
		// internal use only
		public function getVisibleSet(culler: Culler, noCull: Boolean ): void
		{
		}
		
		[Inline]
		public final function set parent( parent: Spatial ): void
		{
			_parent = parent;
		}
		
		//{ NAME SUPPORT
		override public function getObjectByName(name:String):Object 
		{
			return super.getObjectByName(name);
		}
		
		override public function getAllObjectsByName(name:String, objects:Vector.<Object>):void 
		{
			super.getAllObjectsByName(name, objects);
		}
		//}
		
	}

}