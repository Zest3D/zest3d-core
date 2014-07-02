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
package zest3d.shaderfloats.material 
{
	import plugin.core.interfaces.IDisposable;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Material;
	import zest3d.scenegraph.Visual;
	import zest3d.shaderfloats.ShaderFloat;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class MaterialDiffuseConstant extends ShaderFloat implements IDisposable 
	{
		
		protected var _material: Material;
		
		public function MaterialDiffuseConstant( material: Material ) 
		{
			super( 1 );
			_material = material;
			_allowUpdater = true;
		}
		
		override public function dispose():void 
		{
			_material.dispose();
			_material = null;
			
			super.dispose();
		}
		
		override public function update(visual:Visual, camera:Camera):void 
		{
			var tuple: Array = _material.diffuse.toArray();
			_data.position = 0;
			for ( var i: int = 0; i < 4; ++i )
			{
				_data.writeFloat( tuple[ i ] );
			}
		}
		
		public function get material(): Material
		{
			return _material;
		}
		
	}

}