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
	import io.plugin.core.graphics.Color;
	import io.plugin.core.interfaces.IDisposable;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Material implements IDisposable 
	{
		
		public var emissive: Color;
		public var ambient: Color;
		public var diffuse: Color;
		public var specular: Color;
		
		protected var _isDisposed:Boolean;
		
		public function Material() 
		{
			emissive = new Color( 0, 0, 0, 1 );
			ambient = new Color( 0, 0, 0, 1 );
			diffuse = new Color( 0, 0, 0, 1 );
			specular = new Color( 0, 0, 0, 0 );
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			emissive.dispose();
			emissive = null;
			
			ambient.dispose();
			ambient = null;
			
			diffuse.dispose();
			diffuse = null;
			
			specular.dispose();
			specular = null;
			
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
	}
}