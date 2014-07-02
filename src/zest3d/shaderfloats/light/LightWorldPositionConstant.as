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
package zest3d.shaderfloats.light 
{
	import plugin.core.interfaces.IDisposable;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Light;
	import zest3d.scenegraph.Visual;
	import zest3d.shaderfloats.ShaderFloat;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class LightWorldPositionConstant extends ShaderFloat implements IDisposable 
	{
		
		protected var _light: Light;
		
		public function LightWorldPositionConstant( light: Light ) 
		{
			super( 1 );
			_light = light;
			_allowUpdater = true;
		}
		
		override public function dispose():void 
		{
			_light.dispose();
			_light = null;
			
			super.dispose();
		}
		
		override public function update(visual:Visual, camera:Camera):void 
		{
			var tuple: Array = _light.position.toTuple();
			_data.position = 0;
			
			for ( var i: int = 0; i < 4; ++i )
			{
				_data.writeFloat( tuple[ i ] );
			}
		}
		
		public function get light(): Light
		{
			return _light;
		}
		
	}

}