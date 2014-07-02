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
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.AVector;
	import plugin.math.algebra.HMatrix;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Node;
	import zest3d.scenegraph.Spatial;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class BillboardNode extends Node implements IDisposable 
	{
		
		protected var _camera:Camera;
		
		public function BillboardNode( camera: Camera = null ) 
		{
			super();
			_camera = camera;
		}
		
		override public function dispose(): void
		{
			super.dispose();
		}
		
		public function alignTo( camera: Camera ): void
		{
			_camera = camera;
		}
		
		override protected function updateWorldData( applicationTime: Number ): void
		{
			super.updateWorldData( applicationTime );
			
			if ( _camera )
			{
				var modelPos:APoint = worldTransform.inverse.multiplyAPoint( _camera.position );
				
				var angle: Number = Math.atan2( modelPos.x, modelPos.z );
				var orient: HMatrix = new HMatrix().rotation( AVector.UNIT_Y, angle );
				
				worldTransform.rotate = worldTransform.rotate.multiply( orient );
			}
			
			var child: Spatial;
			for each( child in _child )
			{
				child.update( applicationTime, false );
			}
		}
		
	}

}