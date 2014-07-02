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
package zest3d.shaderfloats.camera 
{
	import plugin.core.interfaces.IDisposable;
	import plugin.math.algebra.AVector;
	import plugin.math.algebra.HMatrix;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Visual;
	import zest3d.shaderfloats.ShaderFloat;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class CameraModelDVectorConstant extends ShaderFloat implements IDisposable 
	{
		
		public function CameraModelDVectorConstant() 
		{
			super( 1 );
			_allowUpdater = true;
		}
		
		override public function dispose():void 
		{
			super.dispose();
		}
		
		override public function update(visual:Visual, camera:Camera):void 
		{
			var worldDVector: AVector = camera.dVector;
			var worldInvMatrix: HMatrix = visual.worldTransform.inverse;
			var modelDVector: AVector = worldInvMatrix.multiplyAVector( worldDVector );
			
			var tuple: Array = modelDVector.toTuple();
			
			_data.position = 0;
			for ( var i: int = 0; i < 4; ++i )
			{
				_data.writeFloat( tuple[ i ] );
			}
		}
		
	}

}