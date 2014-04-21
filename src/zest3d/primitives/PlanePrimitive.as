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
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class PlanePrimitive extends Primitive 
	{
		
		public function PlanePrimitive( effect:VisualEffectInstance, hasTexCoords:Boolean = true, hasNormals: Boolean = true, hasBinormals:Boolean = false, hasTangents:Boolean = false, xSamples:int = 2, ySamples:int = 2, xExtent:Number = 1, yExtent:Number = 1, bothSides:Boolean = false, isStatic:Boolean = true, inside:Boolean = false, transform:Transform = null ) 
		{
			this.effect = effect;
			this.bothSides = bothSides;
			var vFormat:VertexFormat = generateVertexFormat( hasTexCoords, hasNormals, hasBinormals, hasTangents );
			var primitive:TriMesh = new StandardMesh( vFormat, isStatic, inside, transform ).rectangle( xSamples, ySamples, xExtent, yExtent );
			
			super( vFormat, primitive.vertexBuffer, primitive.indexBuffer );
		}
		
	}
}