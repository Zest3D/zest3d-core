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
package zest3d.primitives 
{
	import zest3d.datatypes.Transform;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.TriMesh;
	import zest3d.shaders.VisualEffectInstance;
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class SpherePrimitive extends Primitive 
	{
		
		public function SpherePrimitive( effect:VisualEffectInstance,
										 hasTexCoords:Boolean = true,
										 hasNormals: Boolean = true,
										 hasBinormals:Boolean = false,
										 hasTangents:Boolean = false,
										 zSamples:int = 64,
										 radialSamples:int = 64,
										 radius:Number = 1,
										 bothSides:Boolean = false,
										 isStatic:Boolean = true,
										 inside:Boolean = false,
										 transform:Transform = null )
		{
			this.effect = effect;
			this.bothSides = bothSides;
			
			var vFormat:VertexFormat = generateVertexFormat( hasTexCoords, hasNormals, hasBinormals, hasTangents );
			var primitive:TriMesh = new StandardMesh( vFormat, isStatic, inside, transform ).sphere( zSamples, radialSamples, radius );
			
			super( vFormat, primitive.vertexBuffer, primitive.indexBuffer );
		}
		
	}

}