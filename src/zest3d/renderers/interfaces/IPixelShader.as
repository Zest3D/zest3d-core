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
package zest3d.renderers.interfaces 
{
	import zest3d.renderers.Renderer;
	import zest3d.shaders.FragmentShader;
	import zest3d.shaders.ShaderParameters;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public interface IPixelShader 
	{
		function enable( renderer: Renderer, pShader:FragmentShader, parameters: ShaderParameters ): void;
		function disable( renderer: Renderer, pShader: FragmentShader, parameters: ShaderParameters ): void;
	}
	
}