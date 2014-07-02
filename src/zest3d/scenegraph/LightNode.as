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
	import plugin.core.interfaces.IDisposable;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.HMatrix;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class LightNode extends Node implements IDisposable 
	{
		
		protected var _light: Light;
		
		public function LightNode( light: Light ) 
		{
			_light = light;
			
			if ( _light )
			{
				localTransform.translate = light.position;
				
				var rotate:HMatrix = HMatrix.fromTuple( _light.dVector.toTuple(),
															   _light.uVector.toTuple(),
															   _light.rVector.toTuple(),
															   APoint.ORIGIN.toTuple(),
															   true );
				
				localTransform.rotate = rotate;
			}
		}
		
		override public function dispose():void 
		{
			
			super.dispose();
		}
		
		[Inline]
		public final function set light( light: Light ): void
		{
			_light = light;
			
			if ( _light )
			{
				localTransform.translate = light.position;
				
				var rotate:HMatrix = HMatrix.fromTuple( _light.dVector.toTuple(),
															   _light.uVector.toTuple(),
															   _light.rVector.toTuple(),
															   APoint.ORIGIN.toTuple(),
															   true );
				
				localTransform.rotate = rotate;
				
				update();
			}
		}
		
		[Inline]
		public final function get light( ): Light
		{
			return _light;
		}
		
		override protected function updateWorldData(applicationTime:Number):void 
		{
			super.updateWorldData(applicationTime);
			
			if ( _light )
			{
				_light.position = worldTransform.translate;
				
				var col0: Array = worldTransform.rotate.getColumn( 0 );
				var col1: Array = worldTransform.rotate.getColumn( 1 );
				var col2: Array = worldTransform.rotate.getColumn( 2 );
				
				_light.dVector.set( col0[ 0 ], col0[ 1 ], col0[ 2 ] );
				_light.uVector.set( col1[ 0 ], col1[ 1 ], col1[ 2 ] );
				_light.rVector.set( col2[ 0 ], col2[ 1 ], col2[ 2 ] );
			}
		}
	}

}