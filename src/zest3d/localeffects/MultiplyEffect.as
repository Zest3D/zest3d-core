package zest3d.localeffects
{
	import zest3d.resources.Texture;
	import zest3d.resources.Texture2D;
	import zest3d.scenegraph.Light;
	import zest3d.shaderfloats.camera.CameraModelPositionConstant;
	import zest3d.shaderfloats.light.LightModelPositionConstant;
	import zest3d.shaderfloats.matrix.PMatrixConstant;
	import zest3d.shaderfloats.matrix.PVMatrixConstant;
	import zest3d.shaderfloats.matrix.PVWMatrixConstant;
	import zest3d.shaderfloats.matrix.VWMatrixConstant;
	import zest3d.shaderfloats.matrix.WMatrixConstant;
	import zest3d.shaderfloats.ShaderFloat;
	import zest3d.shaders.enum.SamplerCoordinateType;
	import zest3d.shaders.enum.SamplerFilterType;
	import zest3d.shaders.enum.SamplerType;
	import zest3d.shaders.enum.VariableSemanticType;
	import zest3d.shaders.enum.VariableType;
	import zest3d.shaders.FragmentShader;
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
	
	public class MultiplyEffect extends VisualEffectInstance
	{
		
		public static const msAGALVRegisters: Array = [ 0 ];
		public static const msAGALPRegisters: Array = [ 0 ];
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
		
		public static const msVPrograms: Array =
		[
			"",
			// AGAL_1_0
			"m44 op, va0, vc0 \n" +
			"mov vi0, va1",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		public static const msPPrograms: Array =
		[
			"",
			"tex ft0 vi0 fs0 <2d,repeat,linear,miplinear,dxt1> \n" +
			"tex ft1 vi0 fs1 <2d,repeat,linear,miplinear,dxt1> \n" +
			"mul oc ft0 ft1",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		private var _visualEffect:VisualEffect;
		
		public function MultiplyEffect( texture:Texture2D, noise:Texture2D,filter:SamplerFilterType = null,
										  coord0: SamplerCoordinateType = null, coord1:SamplerCoordinateType = null ) 
		{
			filter ||= SamplerFilterType.LINEAR;
			coord0 ||= SamplerCoordinateType.CLAMP;
			coord1 ||= SamplerCoordinateType.CLAMP;
			
			var vShader: VertexShader = new VertexShader( "Zest3D.TextureEffect", 2, 1, 1, 0, false );
			vShader.setInput( 0, "modelPosition", VariableType.FLOAT3, VariableSemanticType.POSITION );
			vShader.setInput( 1, "modelTCoord", VariableType.FLOAT2, VariableSemanticType.TEXCOORD0 );
			vShader.setOutput( 0, "clipPosition", VariableType.FLOAT4, VariableSemanticType.POSITION );
			vShader.setConstant( 0, "PVWMatrix", 4 );
			vShader.setBaseRegisters( msVRegisters );
			vShader.setPrograms( msVPrograms );
			
			var pShader: FragmentShader = new FragmentShader( "Zest3D.TextureEffect", 2, 1, 0, 2, false );
			pShader.setInput( 0, "depthTexture", VariableType.FLOAT2, VariableSemanticType.TEXCOORD0 );
			pShader.setInput( 1, "noiseTexture", VariableType.FLOAT3, VariableSemanticType.NORMAL );
			pShader.setOutput( 0, "pixelColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
			pShader.setSampler( 0, "DepthMap", SamplerType.TYPE_2D );
			pShader.setSampler( 1, "NoiseMap", SamplerType.TYPE_2D );
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
			
			_visualEffect = new VisualEffect();
			_visualEffect.insertTechnique( technique );
			
			super( _visualEffect, 0 );
			
			setVertexConstantByHandle( 0, 0, new PVWMatrixConstant() );
			
			setPixelTextureByHandle( 0, 0, texture );
			setPixelTextureByHandle( 0, 1, noise );
			
		}
	}
}