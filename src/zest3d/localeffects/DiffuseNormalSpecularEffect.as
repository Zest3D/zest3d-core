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
	import zest3d.shaderfloats.camera.CameraWorldPositionConstant;
	import zest3d.shaderfloats.light.LightAmbientConstant;
	import zest3d.shaderfloats.light.LightDiffuseConstant;
	import zest3d.shaderfloats.light.LightModelPositionConstant;
	import zest3d.shaderfloats.light.LightSpecularConstant;
	import zest3d.shaderfloats.light.LightSpecularExponentConstant;
	import zest3d.shaderfloats.light.LightWorldPositionConstant;
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
	public class DiffuseNormalSpecularEffect extends VisualEffectInstance 
	{
		
		public static const msAGALPRegisters: Array = [ 0 ];
		public static const msAGALVRegisters: Array = [ 0 ];
		public static const msAllPTextureUnits: Array = [ 0, 1 ];
		
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
		
		// vc0	model view matrix
		// vc4	light world position
		// vc5	camera world position
		
		// va0	positions
		// va1	texture coords
		// va2	normals
		// va3  tangents
		// va4	binormals
		public static const msVPrograms: Array =
		[
			"",
			// AGAL_1_0
			"m44 op, va0, vc0 \n" +		// m44 model positions to 	output position
			"mov v0, va1 \n" +			// model tex coords to 		varying 0
			
			"sub vt1, vc4, va0 \n"+		// vt1 = lightPos - vertex (lightVec)					
			"dp3 vt3.x, vt1, va4 \n"+
			"dp3 vt3.y, vt1, va3 \n"+
			"dp3 vt3.z, vt1, va2 \n"+
			"mov v2, vt3.xyzx \n" +		// v2 = lightVec
			
			// transform viewVec
			"sub vt2, va0, vc5 \n"+		// vt2 = viewPos - vertex (viewVec)
			"dp3 vt4.x, vt2, va4 \n"+
			"dp3 vt4.y, vt2, va3 \n"+
			"dp3 vt4.z, vt2, va2 \n"+					
			"mov v3, vt4.xyzx",
			
			// AGAL_2_0
			"",
			"",
			""
		];
		
		// fragment
		// fc0	vec4(0.0, 0.5, 1.0, 2.0)
		// fc1	ambient
		// fc2	vec4(specularLevel.xyz, specularPower)
		// ft0	output color
		// ft1	normalize(lerp_normal)
		// ft2	normalize(lerp_lightVec)
		// ft3	normalize(lerp_viewVec)
		// ft4 	reflect(-ft3, ft1)
		// ft5..ft7	temp
		public static const msPPrograms: Array =
		[
			"",
			// AGAL_1_0
			'tex ft0, v0, fs0 <2d,repeat,linear,miplinear,dxt1> \n' +	// diffuse map to	fragment temp 0
			'tex ft1, v0, fs1 <2d,repeat,linear,miplinear,dxt1> \n' +	// ft1 = normalMap(v0)
			//'tex ft2, v0, fs2 <2d,repeat,linear,miplinear,dxt1> \n' +
			
			// 0..1 to -1..1
			'add ft1, ft1, ft1 \n'+				// ft1 *= 2
			'sub ft1, ft1, fc0.z \n'+			// ft1 -= 1
			'nrm ft1.xyz, ft1 \n'+				// normal ft1 = normalize(normal)
			
			'nrm ft2.xyz, v2 \n'+				// lightVec	ft2 = normalize(lerp_lightVec)
			'nrm ft3.xyz, v3 \n'+				// viewVec	ft3 = normalize(lerp_viewVec)
			
			// calc reflect vec (ft4)
			'dp3 ft4.x, ft1.xyz ft3.xyz \n'+	// ft4 = dot(normal, viewVec)
			'mul ft4, ft1.xyz, ft4.x \n'+		// ft4 *= normal
			'add ft4, ft4, ft4 \n'+				// ft4 *= 2					
			'sub ft4, ft3.xyz, ft4 \n'+			// reflect	ft4 = viewVec - ft4
			
			// lambert
			'dp3 ft5.x, ft1.xyz, ft2.xyz \n'+	// ft5 = dot(normal, lightVec)
			'max ft5.x, ft5.x, fc0.x \n'+		// ft5 = max(ft5, 0.0)					
			'add ft5, fc1, ft5.x \n'+			// ft5 = ambient + ft5
			'mul ft0, ft0, ft5 \n'+				// color *= ft5
			
			//phong
			'dp3 ft6.x, ft2.xyz, ft4.xyz \n'+	// ft6 = dot(lightVec, reflect)
			'max ft6.x, ft6.x, fc0.x \n'+		// ft6 = max(ft6, 0.0)
			'pow ft6.x, ft6.x, fc3.x \n'+		// ft6 = pow(ft6, specularPower)
			'mul ft6, ft6.x, fc2.xyz \n'+		// ft6 *= specularLevel
			'add ft0, ft0, ft6 \n'+				// color += ft6
			
			'mov oc, ft0',
			// AGAL_2_0
			"",
			"",
			""
		];
		
		public function DiffuseNormalSpecularEffect( diffuse:Texture2D,
													 normal:Texture2D,
													 specular:Texture2D,
													 light:Light,
													 filter:SamplerFilterType = null,
													 coord0:SamplerCoordinateType = null,
													 coord1:SamplerCoordinateType = null )
		{
			
			filter ||= SamplerFilterType.LINEAR;
			coord0 ||= SamplerCoordinateType.CLAMP;
			coord1 ||= SamplerCoordinateType.CLAMP;
			
			var vShader: VertexShader = new VertexShader( "Zest3D.DiffuseNormalSpecularEffect", 5, 1, 3, 0, false );
			vShader.setInput( 0, "modelPosition", VariableType.FLOAT3, VariableSemanticType.POSITION );
			vShader.setInput( 1, "modelTexCoords", VariableType.FLOAT2, VariableSemanticType.TEXCOORD0 );
			vShader.setInput( 2, "modelNormals", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			vShader.setInput( 3, "modelBinormals", VariableType.FLOAT3, VariableSemanticType.BINORMAL );
			vShader.setInput( 4, "modelTangents", VariableType.FLOAT3, VariableSemanticType.TANGENT );
			vShader.setOutput( 0, "clipPosition", VariableType.FLOAT4, VariableSemanticType.POSITION );
			vShader.setConstant( 0, "PVWMatrix", 4 );
			vShader.setConstant( 1, "LightModelPosition", 1 );
			vShader.setConstant( 2, "CameraModelPosition", 1 );
			vShader.setBaseRegisters( msVRegisters );
			vShader.setPrograms( msVPrograms );
			
			var pShader: PixelShader = new PixelShader( "Zest3D.DiffuseNormalSpecularEffect", 4, 1, 4, 2, false );
			pShader.setInput( 0, "modelTexCoords", VariableType.FLOAT2, VariableSemanticType.TEXCOORD0 );
			pShader.setInput( 1, "modelNormals", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			pShader.setInput( 2, "lightVec", VariableType.FLOAT3, VariableSemanticType.NONE );
			pShader.setInput( 3, "viewVec", VariableType.FLOAT3, VariableSemanticType.NONE );
			pShader.setConstant( 0, "Common", 1 );
			pShader.setConstant( 1, "LightAmbient", 1 );
			pShader.setConstant( 2, "LightSpecular", 1 );
			pShader.setConstant( 3, "LightSpecularExponent", 1 );
			pShader.setOutput( 0, "pixelColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
			pShader.setSampler( 0, "Diffuse", SamplerType.TYPE_2D );
			pShader.setSampler( 1, "Normal", SamplerType.TYPE_2D );
			//pShader.setSampler( 2, "Specular", SamplerType.TYPE_2D );
			pShader.setFilter( 0, filter );
			pShader.setFilter( 1, filter );
			pShader.setCoordinate( 0, 0, coord0 );
			pShader.setCoordinate( 0, 1, coord1 );
			pShader.setCoordinate( 1, 0, coord0 );
			pShader.setCoordinate( 1, 1, coord1 );
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
			setVertexConstantByHandle( 0, 2, new CameraModelPositionConstant() );
			
			var common:ShaderFloat = new ShaderFloat(1);
			common.setRegister( 0, [ 0, 0.5, 1, 2 ] );
			
			setPixelConstantByHandle( 0, 0, common );
			setPixelConstantByHandle( 0, 1, new LightAmbientConstant( light ) );
			//setPixelConstantByHandle( 0, 2, new LightDiffuseConstant( light ) );
			setPixelConstantByHandle( 0, 2, new LightSpecularConstant( light ) );
			setPixelConstantByHandle( 0, 3, new LightSpecularExponentConstant( light ) );
			
			setPixelTextureByHandle( 0, 0, diffuse );
			setPixelTextureByHandle( 0, 1, normal );
			//setPixelTextureByHandle( 0, 2, specular );
			
			/*
			var filterType: SamplerFilterType = visualEffect.getPixelShader( 0, 0 ).getFilter( 0 );
			
			if ( filterType != SamplerFilterType.NEAREST &&
				 filterType != SamplerFilterType.LINEAR &&
				 !texture.hasMipmaps )
			{
				texture.generateMipmaps();
			}
			*/
		}
	}
}