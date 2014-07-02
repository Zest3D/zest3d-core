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
package zest3d.resources 
{
	import plugin.core.interfaces.IDisposable;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.BufferUsageType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class VertexBuffer extends Buffer implements IDisposable 
	{
		
		public function VertexBuffer( numVertices: int, vertexSize: int, usage: BufferUsageType = null ) 
		{
			usage ||= BufferUsageType.STATIC;
			super( numVertices, vertexSize, usage );
		}
		
		override public function dispose():void 
		{
			Renderer.unbindAllVertexBuffer( this );
			super.dispose();
		}
		
	}

}