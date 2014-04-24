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
	public class DepthEffect extends VisualEffectInstance 
	{
		
		public static const msAGALVRegisters: Array = [ 0 ];
		public static const msAGALPRegisters: Array = [ 0 ];
		
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
			"m44 vt0 va0 vc0 \n" +
            "mov op vt0 \n" +                                   
            "mov v0 vt0",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		
		// TODO rebuild to accept changes to sampler (this is just an example)
		
		public static const msPPrograms: Array =
		[
			"",
			// AGAL_1_0
			"div ft0 v0.z fc0.x \n" +      //FT0 Ranges From 0 to 1 and its the depth of the pixel from the light                                     
            "mul ft0 ft0 fc1 \n" +         //FT0 = [FT0,255*FT0,(255^2)*FT0,(255^3)*FT0] for encoding 32 bit floating point into RGBA
            "frc ft0 ft0 \n" +             //FT0 = [f(FT0),f(255*FT0), f((255^2)*FT0), f((255^3)*FT0)] where f(number) = number - floor(number)
            "mul ft1 ft0.yzww fc2 \n" +    //FT1 = [(f(255*FT0))/255.0, (f((255^2)*FT0))/255.0, (f((255^3)*FT0))/255.0, 0.0]
            "sub ft0 ft0 ft1 \n" +         //FT0 = [f(FT0) - ((f(255*FT0))/255.0), f(255*FT0) - ((f((255^2)*FT0))/255.0), f((255^2)*FT0) -  ((f((255^3)*FT0))/255.0), f((255^3)*FT0)]
            "mov oc ft0 \n",
			// AGAL_2_0
			"",
			"",
			""
		];
		
		private var _visualEffect:VisualEffect;
		
		public function DepthEffect( ) 
		{
			var vShader: VertexShader = new VertexShader( "Zest3D.DepthEffect", 1, 1, 1, 0, false );
			vShader.setInput( 0, "modelPosition", VariableType.FLOAT3, VariableSemanticType.POSITION );
			vShader.setOutput( 0, "clipPosition", VariableType.FLOAT4, VariableSemanticType.POSITION );
			vShader.setConstant( 0, "PVWMatrix", 4 );
			vShader.setBaseRegisters( msVRegisters );
			vShader.setPrograms( msVPrograms );
			
			var pShader: PixelShader = new PixelShader( "Zest3D.DepthEffect", 0, 1, 3, 0, false );
			pShader.setOutput( 0, "pixelColor", VariableType.FLOAT4, VariableSemanticType.COLOR0 );
			pShader.setBaseRegisters( msPRegisters );
			pShader.setPrograms( msPPrograms );
			pShader.setConstant( 0, "fc0", 1 );
			pShader.setConstant( 1, "fc1", 1 );
			pShader.setConstant( 2, "fc2", 1 );
			
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
			
			
			var fc0:ShaderFloat = new ShaderFloat( 1 );
			fc0.setRegister( 0, [ 100, 1, 1, 1] ); // [0] should be the dMax value
			
			var fc1:ShaderFloat = new ShaderFloat( 1 );
			fc1.setRegister( 0, [ 1, 255, 6025, 1681375 ] );
			
			var fc2:ShaderFloat = new ShaderFloat( 1 );
			fc2.setRegister( 0, [ 1 / 255, 1 / 255, 1 / 255, 0 ] );
			
			setVertexConstantByHandle( 0, 0, new PVWMatrixConstant() );
			setPixelConstantByHandle( 0, 0, fc0 );
			setPixelConstantByHandle( 0, 1, fc1 );
			setPixelConstantByHandle( 0, 2, fc2 );
			
		}
		
		public function get visualEffect():VisualEffect 
		{
			return _visualEffect;
		}
	}

}