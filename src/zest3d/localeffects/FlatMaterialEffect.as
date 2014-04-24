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
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.scenegraph.Material;
	import zest3d.shaderfloats.material.MaterialAmbientConstant;
	import zest3d.shaderfloats.matrix.PVWMatrixConstant;
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
	 * @author Gary Paluk
	 */
	public class FlatMaterialEffect extends VisualEffectInstance implements IDisposable 
	{
		
		public static const msAGALVRegisters: Array = [ 0 ];
		
		public static const msVRegisters: Array =
		[
			null,
			msAGALVRegisters,
			null,
			null,
			null
		];
		
		public static const msVPrograms: Array =
		[
			"",
			// AGAL_1_0
			"m44 op, va0, vc0 \n" +
			"mov v0, vc4",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		public static const msPPrograms: Array =
		[
			"",
			// AGAL_1_0
			"mov oc, v0",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		public function FlatMaterialEffect( material: Material ) 
		{
			var vShader: VertexShader = new VertexShader( "Zest3D.FlatMaterial", 1, 2, 2, 0, false );
			vShader.setInput( 0, "modelPosition", VariableType.FLOAT3, VariableSemanticType.POSITION );
			vShader.setOutput( 0, "clipPosition", VariableType.FLOAT4, VariableSemanticType.POSITION );
			vShader.setOutput( 1, "vertexColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
			vShader.setConstant( 0, "PVWMatrix", 4 );
			vShader.setConstant( 1, "MaterialAmbient", 1 );
			vShader.setBaseRegisters( msVRegisters );
			vShader.setPrograms( msVPrograms );
			
			var pShader: PixelShader = new PixelShader( "Zest3D.FlatMaterial", 1, 1, 0, 0, false );
			pShader.setInput( 0, "vertexColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
			pShader.setOutput( 0, "pixelColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
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
			
			setVertexConstantByHandle( 0, 0, new PVWMatrixConstant() );
			setVertexConstantByHandle( 0, 1, new MaterialAmbientConstant( material ) );
			/*
			var ambient:ShaderFloat = new ShaderFloat(1);
			ambient.setRegister( 0, [material.ambient.r, material.ambient.g, material.ambient.b, material.ambient.a ] );
			
			setVertexConstantByHandle( 0, 1, ambient );
			*/
		}
		
		override public function dispose():void 
		{
			super.dispose();
		}
	}

}