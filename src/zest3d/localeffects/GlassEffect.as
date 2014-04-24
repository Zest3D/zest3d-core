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
	import zest3d.resources.TextureCube;
	import zest3d.shaderfloats.camera.CameraWorldPositionConstant;
	import zest3d.shaderfloats.matrix.PVWMatrixConstant;
	import zest3d.shaderfloats.matrix.WMatrixConstant;
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
	public class GlassEffect extends VisualEffectInstance 
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
			"m44 op va0 vc0 \n" +
			"m44 vt0 va0 vc4 \n" +
			"m33 vt1.xyz va1 vc4 \n" +
			"sub vt2 vc8 vt0 \n" +
			"nrm vt2.xyz vt2 \n" +
			"mov v0 vt1.xyz \n" +
			"mov v1 vt2 \n" +
			"dp3 vt3 vt2.xyz vt1.xyz \n" +
			"sub vt3 vc9.w vt3 \n" +
			"mov v2 vt3",
			// AGAL_2_0
			"",
			"",
			""
		];
			
		public static const msPPrograms: Array =
		[
			"",
			// AGAL_1_0
			"dp3 ft0 v1 v0 \n" +
			"add ft0 ft0 ft0 \n" +
			"mul ft0 v0 ft0 \n" +
			"sub ft0 v1 ft0 \n" +
			"neg ft0 ft0 \n" +
			"nrm ft0.xyz ft0 \n" +
			"dp3 ft2 v1 v0 \n" +
			"mul ft2 ft2 v0 \n" +
			"sub ft2 ft2 v1 \n" +
			"mul ft2 ft2 fc0.x \n" +
			"dp3 ft1 v1 v0 \n" +
			"mul ft1 ft1 ft1 \n" +
			"sub ft1 fc0.w ft1 \n" +
			"mul ft1 fc0.y ft1 \n" +
			"sub ft1 fc0.w ft1 \n" +
			"sqt ft1 ft1 \n" +
			"mul ft1 ft1 v0 \n" +
			"sub ft1 ft2 ft1 \n" +
			"tex ft0 ft0 fs0 <cube,linear,mipnearest,clamp,dxt1> \n" +
			"tex ft1 ft1 fs0 <cube,linear,mipnearest,clamp,dxt1> \n" +
			"sub ft2 ft0 ft1 \n" +
			"mul ft2 ft2 v2 \n" +
			"add ft2 ft2 ft1 \n" +
			"mov oc ft2",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		private var _visualEffect:VisualEffect;
		
		public function GlassEffect( texture: TextureCube, filter:SamplerFilterType = null,
										  coord0: SamplerCoordinateType = null, coord1: SamplerCoordinateType = null ) 
		{
			
			filter ||= SamplerFilterType.LINEAR;
			coord0 ||= SamplerCoordinateType.CLAMP;
			coord1 ||= SamplerCoordinateType.CLAMP;
			
			var vShader: VertexShader = new VertexShader( "Zest3D.GlassEffect", 2, 1, 4, 0, false );
			vShader.setInput( 0, "modelPosition", VariableType.FLOAT3, VariableSemanticType.POSITION );
			vShader.setInput( 1, "modelNormal", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			vShader.setOutput( 0, "clipPosition", VariableType.FLOAT4, VariableSemanticType.POSITION );
			vShader.setConstant( 0, "PVWMatrix", 4 );
			vShader.setConstant( 1, "VWMatrix", 4 );
			vShader.setConstant( 2, "CameraModelPosition", 1 );
			vShader.setConstant( 3, "Ones", 1 );
			vShader.setBaseRegisters( msVRegisters );
			vShader.setPrograms( msVPrograms );
			
			var pShader: PixelShader = new PixelShader( "Zest3D.GlassEffect", 1, 1, 1, 1, false );
			pShader.setInput( 0, "vertexNormal", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			pShader.setOutput( 0, "pixelColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
			pShader.setConstant( 0, "rr2", 1 );
			pShader.setBaseRegisters( msPRegisters );
			pShader.setSampler( 0, "BaseSampler", SamplerType.CUBE );
			pShader.setFilter( 0, filter );
			pShader.setCoordinate( 0, 0, coord0 );
			pShader.setCoordinate( 0, 1, coord1 );
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
			
			_visualEffect = new VisualEffect();
			_visualEffect.insertTechnique( technique );
			
			super( _visualEffect, 0 );
			
			setVertexConstantByHandle( 0, 0, new PVWMatrixConstant() );
			setVertexConstantByHandle( 0, 1, new WMatrixConstant() );
			setVertexConstantByHandle( 0, 2, new CameraWorldPositionConstant() );
			
			var ones:ShaderFloat = new ShaderFloat( 1 );
			ones.setRegister( 0, [ 1, 1, 1, 1 ] );
			setVertexConstantByHandle( 0, 3, ones );
			
			setPixelTextureByHandle( 0, 0, texture );
			
			// frag constants
			var rr2:ShaderFloat = new ShaderFloat(1);
			rr2.setRegister( 0, [ 0.9, 0.81, 0, 1 ] );
			setPixelConstantByHandle( 0, 0, rr2 );
			
			var filterType: SamplerFilterType = visualEffect.getPixelShader( 0, 0 ).getFilter( 0 );
			
			if ( filterType != SamplerFilterType.NEAREST &&
				 filterType != SamplerFilterType.LINEAR &&
				 !texture.hasMipmaps )
			{
				texture.generateMipmaps();
			}
		}
		
		public function get visualEffect():VisualEffect 
		{
			return _visualEffect;
		}
		
	}

}