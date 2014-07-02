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
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.enum.PrimitiveType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class TriMesh extends Triangles implements IDisposable 
	{
		
		public function TriMesh( vFormat:VertexFormat, vBuffer: VertexBuffer, iBuffer: IndexBuffer = null ) 
		{
			super( PrimitiveType.TRIMESH, vFormat, vBuffer, iBuffer );
		}
		
		override public function get numTriangles():int 
		{
			return int( _iBuffer.numElements / 3 );
		}
		
		override public function getTriangleAt(index:int, data:Array):Boolean 
		{
			
			if ( 0 <= index && index < numTriangles )
			{
				_iBuffer.data.position = index * ( _iBuffer.elementSize * 3 );
				
				data[ 0 ] = _iBuffer.data.readShort();
				data[ 1 ] = _iBuffer.data.readShort();
				data[ 2 ] = _iBuffer.data.readShort();
				
				return true;
			}
			return false;
		}
	}

}