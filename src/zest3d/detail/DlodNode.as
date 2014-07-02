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
package zest3d.detail 
{
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.AVector;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Culler;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class DlodNode extends SwitchNode implements IDisposable 
	{
		
		protected var _modelLODCenter: APoint;
		protected var _worldLODCenter: APoint;
		
		protected var _numLevelsOfDetail: int;
		
		protected var _modelMinDist: Array;
		protected var _modelMaxDist: Array;
		protected var _worldMinDist: Array;
		protected var _worldMaxDist: Array;
		
		public function DlodNode( numLevelsOfDetail: int ) 
		{
			
			_modelLODCenter = new APoint();
			
			_numLevelsOfDetail = numLevelsOfDetail;
			
			_modelMinDist = [];
			_modelMaxDist = [];
			_worldMinDist = [];
			_worldMaxDist = [];
			
			var i: int = 0;
			for ( i = 0; i < _numLevelsOfDetail; ++i )
			{
				_modelMinDist[ i ] = 0;
				_modelMaxDist[ i ] = 0;
				_worldMinDist[ i ] = 0;
				_worldMaxDist[ i ] = 0;
			}
			
		}
		
		override public function dispose(): void
		{
			_modelMinDist.length = 0;
			_modelMaxDist.length = 0;
			_worldMinDist.length = 0;
			_worldMaxDist.length = 0;
			
			_modelMinDist = null;
			_modelMaxDist = null;
			_worldMinDist = null;
			_worldMaxDist = null;
			
			_modelLODCenter.dispose();
			_modelLODCenter = null;
			
			_worldLODCenter.dispose();
			_worldLODCenter = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get modelCenter(): APoint
		{
			return _modelLODCenter;
		}
		
		[Inline]
		public final function set modelCenter( value: APoint ): void
		{
			_modelLODCenter = value;
		}
		
		[Inline]
		public final function get worldCenter(): APoint
		{
			return _worldLODCenter;
		}
		
		[Inline]
		public final function get numLevelsOfDetail(): int
		{
			return _numLevelsOfDetail;
		}
		
		[Inline]
		public final function getModelMinDistanceAt( index: int ): Number
		{
			Assert.isTrue( 0 <= index && index < _numLevelsOfDetail, "Invalid index in getModelMinDistance." );
			
			return _modelMinDist[ index ];
		}
		
		[Inline]
		public final function getModelMaxDistanceAt( index: int ): Number
		{
			Assert.isTrue( 0 <= index && index < _numLevelsOfDetail, "Invalid index in getModelMaxDistance." );
			
			return _modelMaxDist[ index ];
		}
		
		[Inline]
		public final function getWorldMinDistanceAt( index: int ): Number
		{
			Assert.isTrue( 0 <= index && index < _numLevelsOfDetail, "Invalid index in getWorldMinDistance." );
			
			return _worldMinDist[ index ];
		}
		
		[Inline]
		public final function getWorldMaxDistanceAt( index: int ): Number
		{
			Assert.isTrue( 0 <= index && index < _numLevelsOfDetail, "Invalid index in getWorldMaxDistanceAt." );
			
			return _worldMaxDist[ index ];
		}
		
		public function setModelDistanceAt( index: int, minDist: Number, maxDist: Number ): void
		{
			if ( 0 <= index && index < _numLevelsOfDetail )
			{
				_modelMinDist[ index ] = minDist;
				_modelMaxDist[ index ] = maxDist;
				_worldMinDist[ index ] = minDist;
				_worldMaxDist[ index ] = maxDist;
				return;
			}
			
			throw new Error( "Invalid index in SetModelDistance." );
		}
		
		
		
		protected function selectLevelOfDetail( camera: Camera ): void
		{
			_worldLODCenter = worldTransform.multiplyAPoint( _modelLODCenter );
			
			var i: int;
			for ( i = 0; i < _numLevelsOfDetail; ++i )
			{
				_worldMinDist[ i ] = worldTransform.uniformScale * _modelMinDist[ i ];
				_worldMaxDist[ i ] = worldTransform.uniformScale * _modelMaxDist[ i ];
			}
			
			activeChild = INVALID_CHILD;
			var diff:AVector = _worldLODCenter.subtract( camera.position );
			var dist: Number = diff.length;
			
			for ( i = 0; i < _numLevelsOfDetail; ++i )
			{
				if ( _worldMinDist[ i ] <= dist && dist < _worldMaxDist[ i ] )
				{
					activeChild = i;
					break;
				}
			}
			
		}
		
		override public function getVisibleSet(culler:Culler, noCull:Boolean):void 
		{
			selectLevelOfDetail( culler.camera );
			super.getVisibleSet(culler, noCull);
		}
		
	}

}