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
	import zest3d.resources.Texture2D;
	import zest3d.scenegraph.Light;
	import zest3d.shaderfloats.camera.CameraModelPositionConstant;
	import zest3d.shaderfloats.light.LightAmbientConstant;
	import zest3d.shaderfloats.light.LightModelPositionConstant;
	import zest3d.shaderfloats.light.LightSpecularConstant;
	import zest3d.shaderfloats.light.LightSpecularExponentConstant;
	import zest3d.shaderfloats.matrix.PVWMatrixConstant;
	import zest3d.shaderfloats.ShaderFloat;
	import zest3d.shaders.enum.SamplerCoordinateType;
	import zest3d.shaders.enum.SamplerFilterType;
	import zest3d.shaders.enum.SamplerType;
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
	public class PhongEffect extends VisualEffectInstance 
	{
		
		public static const msAGALPRegisters: Array = [ 0 ];
		public static const msAGALVRegisters: Array = [ 0 ];
		public static const msAllPTextureUnits: Array = [ 0 ];
		
		public static const msPTextureUnits: Array =
		[
			null,
			msAllPTextureUnits,
			null,
			null,
			null
		];
		
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
			"mov v0, va1 \n" +
			"mov v1, va2 \n" + 
			"sub v2, vc4, va0 \n" +
			"sub v3, va0, vc5",
			// AGAL_2_0
			"",
			"",
			""
		];
			
		public static const msPPrograms: Array =
		[
			"",
			// AGAL_1_0
			"tex ft0, v0, fs0 <2d, clamp, linear, miplinear, dxt1> \n" +
			
			"nrm ft1.xyz, v1 \n" +		 			// normal FT1 = normalize (lerp_normal)
			"nrm ft2.xyz, v2 \n" +		 			// lightVec FT2 = normalize (lerp_lightVec)
			"nrm ft3.xyz, v3 \n" +		 			// viewVec FT3 = normalize (lerp_viewVec)
			
			"dp3 ft5.x, ft1.xyz, ft2.xyz \n" +	 	// FT5 = dot (normal, lightVec)
			"max ft5.x, ft5.x, fc0.x \n" +	 		// FT5 = max (FT5, 0.0)
			"add ft5, fc1, ft5.x \n" +		 		// FT5 = ambient + FT5
			"mul ft0, ft0, ft5 \n" +
			
			// calculation of the reflection vector Reflect (-viewVec, normal)
			"dp3 ft4.x, ft1.xyz ft3.xyz \n" +		// FT4 = dot (normal, viewVec)
			"mul ft4 , ft1.xyz, ft4.x \n" +	 		// * = normal FT4
			"add ft4, ft4, ft4 \n" +		 		// * FT4 = 2
			"sub ft4, ft3.xyz, ft4 \n" +	 		// Reflect FT4 = viewVec - FT4
			
			// phong
			"dp3 ft6.x, ft2.xyz, ft4.xyz \n" +		// FT6 = dot (lightVec, Reflect)
			"max ft6.x, ft6.x, fc0.x \n" +			// FT6 = max (FT6, 0.0)
			"pow ft6.x, ft6.x, fc3.x \n" +			// FT6 = Pow (FT6, SpecularPower)
			"mul ft6, ft6.x, fc2.xyz \n" +			// * = FT6 specularLevel
			"add ft0, ft0, ft6 \n" +
			
			"mov oc, ft0",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		public function PhongEffect( texture:Texture2D, light:Light, filter:SamplerFilterType = null,
								coord0: SamplerCoordinateType = null, coord1: SamplerCoordinateType = null ) 
		{
			
			filter ||= SamplerFilterType.LINEAR;
			coord0 ||= SamplerCoordinateType.CLAMP;
			coord1 ||= SamplerCoordinateType.CLAMP;
			
			var vShader: VertexShader = new VertexShader( "Zest3D.PhongEffect", 3, 1, 3, 0, false );
			vShader.setInput( 0, "modelPosition", VariableType.FLOAT3, VariableSemanticType.POSITION );
			vShader.setInput( 1, "modelTexCoords", VariableType.FLOAT2, VariableSemanticType.TEXCOORD0 );
			vShader.setInput( 2, "modelNormals", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			vShader.setOutput( 0, "clipPosition", VariableType.FLOAT4, VariableSemanticType.POSITION );
			vShader.setConstant( 0, "PVWMatrix", 4 );
			vShader.setConstant( 1, "LightPosition", 1 );
			vShader.setConstant( 2, "ViewVec", 1 );
			vShader.setBaseRegisters( msVRegisters );
			vShader.setPrograms( msVPrograms );
			
			var pShader: PixelShader = new PixelShader( "Zest3D.PhongEffect", 2, 1, 4, 1, false );
			pShader.setInput( 0, "modelTexCoords", VariableType.FLOAT2, VariableSemanticType.TEXCOORD0 );
			pShader.setInput( 1, "vertexNormal", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			pShader.setConstant( 0, "Common", 1 );
			pShader.setConstant( 1, "LightAmbient", 1 );
			pShader.setConstant( 2, "spec", 1 );
			pShader.setConstant( 3, "pow", 1 );
			pShader.setOutput( 0, "pixelColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
			pShader.setSampler( 0, "BaseSampler", SamplerType.TYPE_2D );
			pShader.setFilter( 0, filter );
			pShader.setCoordinate( 0, 0, coord0 );
			pShader.setCoordinate( 0, 1, coord1 );
			pShader.setBaseRegisters( msPRegisters );
			pShader.setTextureUnits( msPTextureUnits );
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
			
			var visualEffect: VisualEffect = new VisualEffect();
			visualEffect.insertTechnique( technique );
			
			super( visualEffect, 0 );
			
			setVertexConstantByHandle( 0, 0, new PVWMatrixConstant() );
			setVertexConstantByHandle( 0, 1, new LightModelPositionConstant( light ) );
			setVertexConstantByHandle( 0, 2, new CameraModelPositionConstant( ) );
			
			var common:ShaderFloat = new ShaderFloat(1);
			common.setRegister( 0, [ 0, 0.5, 1, 2 ] );
			
			setPixelConstantByHandle( 0, 0, common );
			setPixelConstantByHandle( 0, 1, new LightAmbientConstant( light ) );
			setPixelConstantByHandle( 0, 2, new LightSpecularConstant( light ) );
			setPixelConstantByHandle( 0, 3, new LightSpecularExponentConstant( light ) );
			
			setPixelTextureByHandle( 0, 0, texture );
			
			var filterType: SamplerFilterType = visualEffect.getPixelShader( 0, 0 ).getFilter( 0 );
			
			if ( filterType != SamplerFilterType.NEAREST &&
				 filterType != SamplerFilterType.LINEAR &&
				 !texture.hasMipmaps )
			{
				texture.generateMipmaps();
			}
			
		}
	}
}