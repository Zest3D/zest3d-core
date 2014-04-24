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
package zest3d.geometry 
{
	import zest3d.localeffects.SkyboxEffect;
	import zest3d.resources.enum.AttributeType;
	import zest3d.resources.enum.AttributeUsageType;
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.TextureCube;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.TriMesh;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class SkyboxGeometry extends TriMesh 
	{
		
		private var _camera:Camera;
		
		public function SkyboxGeometry( texture:TextureCube ) 
		{
			var iBuffer:IndexBuffer = new IndexBuffer( 36, 2 );
			
			iBuffer.data.writeShort( 0 );
			iBuffer.data.writeShort( 1 );
			iBuffer.data.writeShort( 3 );
			iBuffer.data.writeShort( 0 );
			iBuffer.data.writeShort( 3 );
			iBuffer.data.writeShort( 2 );
			
			iBuffer.data.writeShort( 4 );
			iBuffer.data.writeShort( 5 );
			iBuffer.data.writeShort( 7 );
			iBuffer.data.writeShort( 4 );
			iBuffer.data.writeShort( 7 );
			iBuffer.data.writeShort( 6 );
			
			iBuffer.data.writeShort( 8 );
			iBuffer.data.writeShort( 9 );
			iBuffer.data.writeShort( 11 );
			iBuffer.data.writeShort( 8 );
			iBuffer.data.writeShort( 11 );
			iBuffer.data.writeShort( 10 );
			
			iBuffer.data.writeShort( 12 );
			iBuffer.data.writeShort( 13 );
			iBuffer.data.writeShort( 15 );
			iBuffer.data.writeShort( 12 );
			iBuffer.data.writeShort( 15 );
			iBuffer.data.writeShort( 14 );
			
			iBuffer.data.writeShort( 16 );
			iBuffer.data.writeShort( 17 );
			iBuffer.data.writeShort( 19 );
			iBuffer.data.writeShort( 16 );
			iBuffer.data.writeShort( 19 );
			iBuffer.data.writeShort( 18 );
			
			iBuffer.data.writeShort( 20 );
			iBuffer.data.writeShort( 21 );
			iBuffer.data.writeShort( 23 );
			iBuffer.data.writeShort( 20 );
			iBuffer.data.writeShort( 23 );
			iBuffer.data.writeShort( 22 );
			
			var vFormat:VertexFormat = VertexFormat.create( 1, AttributeUsageType.POSITION, AttributeType.FLOAT3, 0 );
			
			var vBuffer:VertexBuffer = new VertexBuffer( 24, vFormat.stride );
			
			//+x
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			//-x
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			//+y
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			//-y
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			//+z
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			
			// -z
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			vBuffer.data.writeFloat( -1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( +1.005 );
			vBuffer.data.writeFloat( -1.005 );
			
			this.effect = new SkyboxEffect( texture );
			super( vFormat, vBuffer, iBuffer );
		}
		
		public function get camera():Camera 
		{
			return _camera;
		}
		
		public function set camera(value:Camera):void 
		{
			_camera = value;
		}
		
	}
}