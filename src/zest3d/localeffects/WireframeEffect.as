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
package zest3d.localeffects 
{
	import io.plugin.core.graphics.Color;
	import zest3d.shaderfloats.matrix.PVWMatrixConstant;
	import zest3d.shaderfloats.ShaderFloat;
	import zest3d.shaders.enum.VariableSemanticType;
	import zest3d.shaders.enum.VariableType;
	import zest3d.shaders.PixelShader;
	import zest3d.shaders.states.AlphaState;
	import zest3d.shaders.states.CullState;
	import zest3d.shaders.states.DepthState;
	import zest3d.shaders.states.OffsetState;
	import zest3d.shaders.states.StencilState;
	import zest3d.shaders.states.WireState;
	import zest3d.shaders.VertexShader;
	import zest3d.shaders.VisualEffect;
	import zest3d.shaders.VisualEffectInstance;
	import zest3d.shaders.VisualPass;
	import zest3d.shaders.VisualTechnique;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class WireframeEffect extends VisualEffectInstance 
	{
		
		public static const msAGALPRegisters: Array = [ 0 ];
		public static const msAGALVRegisters: Array = [ 0 ];
		
		public static const msVRegisters: Array =
		[
			null,
			msAGALVRegisters,
			null,
			null,
			null
		];
		
		public static const msPRegisters: Array =
		[
			null,
			msAGALPRegisters,
			null,
			null,
			null
		];
		
		public static const msVPrograms: Array =
		[
			"",
			// AGAL_1_0
			"m44 op, va0, vc0 \n" +
			"mov v0, va1",
			// AGAL_2_0
			"",
			"",
			""
		];
			
		public static const msPPrograms: Array =
		[
			"",
			// AGAL_1_0
			"add ft0.x, v0.x,     v0.y     \n" +
			"add ft0.y, v0.y,     v0.z     \n" +
			"add ft0.z, v0.z,     v0.w     \n" +
			"add ft0.w, v0.w,     v0.x     \n" +
			"sub ft0,   ft0,      fc1.xxxx \n" +
			"slt ft0,   ft0,      fc1.yyyy \n" +
			"mul ft0.x, ft0.x,    ft0.y    \n" +
			"mul ft0.x, ft0.x,    ft0.z    \n" +
			"mul ft0.x, ft0.x,    ft0.w    \n" +
			"sub ft0.x, fc1.x,    ft0.x    \n" +
			"kil ft0.x \n" +
			"mov oc, fc0",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		public function WireframeEffect( color: Color, thickness:Number ) 
		{
			var vShader: VertexShader = new VertexShader( "Zest3D.Wireframe", 2, 1, 1, 0, false );
			vShader.setInput( 0, "modelPosition", VariableType.FLOAT3, VariableSemanticType.POSITION );
			vShader.setInput( 1, "modelWireBlend", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			vShader.setOutput( 0, "clipPosition", VariableType.FLOAT4, VariableSemanticType.POSITION );
			vShader.setConstant( 0, "PVWMatrix", 4 );
			vShader.setBaseRegisters( msVRegisters );
			vShader.setPrograms( msVPrograms );
			
			var pShader: PixelShader = new PixelShader( "Zest3D.Wireframe", 1, 1, 2, 0, false );
			pShader.setInput( 0, "vertexWireBlend", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			pShader.setOutput( 0, "pixelColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
			pShader.setConstant( 0, "color", 1 );
			pShader.setConstant( 1, "thickness", 1 );
			pShader.setBaseRegisters( msPRegisters );
			pShader.setPrograms( msPPrograms );
			
			var pass: VisualPass = new VisualPass();
			pass.vertexShader = vShader;
			pass.pixelShader = pShader;
			pass.alphaState = new AlphaState();
			pass.cullState = new CullState();
			pass.depthState = new DepthState();
			pass.offsetState = new OffsetState();
			pass.stencilState = new StencilState();
			pass.wireState = new WireState();
			
			var technique: VisualTechnique = new VisualTechnique();
			technique.insertPass( pass );
			
			var visualEffect:VisualEffect = new VisualEffect();
			visualEffect.insertTechnique( technique );
			
			super( visualEffect, 0 );
			
			///// vertex
			setVertexConstantByHandle( 0, 0, new PVWMatrixConstant() );
			
			
			
			///// fragment
			// color
			var col:ShaderFloat = new ShaderFloat(1);
			col.setRegister( 0, [ 1, 1, 1, 1 ] );
			setPixelConstantByHandle( 0, 0, col );
			
			// thickness
			var vals:ShaderFloat = new ShaderFloat(1);
			vals.setRegister( 0, [1 - 0.01, 0, 0, 0] );
			setPixelConstantByHandle( 0, 1, vals );
		}
	}
}