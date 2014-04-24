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
	import flash.utils.ByteArray;
	import zest3d.localeffects.TextureEffect;
	import zest3d.resources.enum.AttributeType;
	import zest3d.resources.enum.AttributeUsageType;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.Particles;
	import zest3d.shaders.enum.DstBlendMode;
	import zest3d.shaders.enum.SrcBlendMode;
	import zest3d.shaders.states.AlphaState;
	import zest3d.shaders.states.DepthState;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ParticleGeometry extends Particles
	{
		
		// TODO... create Particle geometry specific shaders and set states in there.
		public function ParticleGeometry( effect:TextureEffect, numParticles:int, positionSizes:ByteArray, sizeAdjust:Number = 1 ) 
		{
			this.effect = effect;
			
			var alphaState:AlphaState = effect.getPass(0).alphaState;
			alphaState.blendEnabled = true;
			alphaState.srcBlend = SrcBlendMode.ONE;
			alphaState.dstBlend = DstBlendMode.ONE;
			
			var depthState:DepthState = effect.getPass(0).depthState;
			depthState.enabled = false;
			
			var vFormat:VertexFormat = new VertexFormat( 2 );
			vFormat.setAttribute( 0, 0, 0, AttributeUsageType.POSITION, AttributeType.FLOAT3, 0 );
			vFormat.setAttribute( 1, 0, 12, AttributeUsageType.TEXCOORD, AttributeType.FLOAT2, 0 );
			vFormat.stride = 20;
			
			var vBuffer:VertexBuffer = new VertexBuffer( numParticles * 4, vFormat.stride );
			
			super( vFormat, vBuffer, 2, positionSizes, sizeAdjust );
		}
	}
}