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
	import zest3d.shaderfloats.camera.CameraModelPositionConstant;
	import zest3d.shaderfloats.matrix.PVWMatrixConstant;
	import zest3d.shaderfloats.matrix.VWMatrixConstant;
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
	public class ReflectionEffect extends VisualEffectInstance 
	{
		
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
		
		public static const msVPrograms: Array =
		[
			"",
			// AGAL_1_0
			"mov vt0, va1\n"+
			"m33 vt0.xyz, vt0.xyz, vc5\n"+
			"sub vt1, vc4, va0\n"+
			"m33 vt1.xyz, vt1.xyz, vc5\n"+
			"dp3 vt2, vt1, vt0\n"+
			"add vt2, vt2, vt2\n"+
			"mul vt2, vt0, vt2\n"+
			"sub vt2, vt1, vt2\n"+
			"neg vt2, vt2\n"+
			"nrm vt2.xyz, vt2.xyz\n"+
			"mov v0, vt2\n"+
			"m44 op, va0, vc0",
			// AGAL_2_0
			"",
			"",
			""
		];
			
		public static const msPPrograms: Array =
		[
			"",
			// AGAL_1_0
			"tex ft0,v0.xyz,fs0 <cube,linear,mipnearest,clamp,dxt1>\n"+
			"mov oc, ft0",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		private var _visualEffect:VisualEffect;
		
		public function ReflectionEffect( texture: TextureCube, filter:SamplerFilterType = null,
										  coord0: SamplerCoordinateType = null, coord1: SamplerCoordinateType = null ) 
		{
			
			filter ||= SamplerFilterType.LINEAR;
			coord0 ||= SamplerCoordinateType.CLAMP;
			coord1 ||= SamplerCoordinateType.CLAMP;
			
			var vShader: VertexShader = new VertexShader( "Zest3D.Reflection", 2, 1, 3, 0, false );
			vShader.setInput( 0, "modelPosition", VariableType.FLOAT3, VariableSemanticType.POSITION );
			vShader.setInput( 1, "modelNormal", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			vShader.setOutput( 0, "clipPosition", VariableType.FLOAT4, VariableSemanticType.POSITION );
			vShader.setConstant( 0, "PVWMatrix", 4 );
			vShader.setConstant( 1, "CameraModelPosition", 1 );
			vShader.setConstant( 2, "VWMatrix", 4 );
			vShader.setBaseRegisters( msVRegisters );
			vShader.setPrograms( msVPrograms );
			
			var pShader: PixelShader = new PixelShader( "Zest3D.Reflection", 1, 1, 0, 1, false );
			pShader.setInput( 0, "vertexNormal", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			pShader.setOutput( 0, "pixelColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
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
			setVertexConstantByHandle( 0, 1, new CameraModelPositionConstant() );
			setVertexConstantByHandle( 0, 2, new VWMatrixConstant() );
			setPixelTextureByHandle( 0, 0, texture );
			
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