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
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import zest3d.resources.Texture2D;
	import zest3d.scenegraph.Light;
	import zest3d.shaderfloats.camera.CameraModelPositionConstant;
	import zest3d.shaderfloats.light.LightAmbientConstant;
	import zest3d.shaderfloats.light.LightModelPositionConstant;
	import zest3d.shaderfloats.light.LightSpecularConstant;
	import zest3d.shaderfloats.matrix.PVWMatrixConstant;
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
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ColorEffect extends VisualEffectInstance
	{
		
		public static const msAGALPRegisters:Array = [0];
		public static const msAGALVRegisters:Array = [0];
		public static const msAllPTextureUnits:Array = [0, 1];
		
		public static const msPTextureUnits:Array = [null, msAllPTextureUnits, null, null, null];
		
		public static const msVRegisters:Array = [null, msAGALVRegisters, null, null, null];
		
		public static const msPRegisters:Array = [null, msAGALPRegisters, null, null, null];
		
		public static const msVPrograms:Array = ["", 
			// AGAL_1_0
			"m44 op, va0, vc0 \n" + "mov v0, va1 \n" + "mov v1, va2 ", "", "", ""];
		
		public static const msPPrograms:Array = ["", 
			// AGAL_1_0
			"add ft0, v0, fc0.xy \n" + "tex ft1, ft0, fs0 <2d, clamp, linear, miplinear, dxt1> \n" + "mul oc, ft1, fc1 ", 
			// AGAL_2_0
			"", "", ""];
		
		private var _visualEffect:VisualEffect;
		
		public function ColorEffect(texture:Texture2D, x:Number, y:Number, color:Vector3D)
		{
			var vShader:VertexShader = new VertexShader("Zest3D.GodRayEffect", 2, 1, 1, 0, false);
			vShader.setInput(0, "modelPosition", VariableType.FLOAT3, VariableSemanticType.POSITION);
			vShader.setInput(1, "modelTexCoords", VariableType.FLOAT2, VariableSemanticType.TEXCOORD0);
			vShader.setOutput(0, "clipPosition", VariableType.FLOAT4, VariableSemanticType.POSITION);
			vShader.setConstant(0, "PVWMatrix", 4);
			vShader.setBaseRegisters(msVRegisters);
			vShader.setPrograms(msVPrograms);
			
			// setSampler ต้องมีจำนวนเท่ากับ sampler ที่สร้างใน glsl
			
			var pShader:FragmentShader = new FragmentShader("Zest3D.GodRayEffect", 1, 1, 2, 1, false);
			pShader.setInput(0, "vertexTCoord", VariableType.FLOAT2, VariableSemanticType.TEXCOORD0);
			pShader.setConstant(0, "Common1", 1);
			pShader.setConstant(1, "Common2", 1);
			pShader.setOutput(0, "pixelColor", VariableType.FLOAT4, VariableSemanticType.COLOR0);
			pShader.setSampler(0, "BaseSampler", SamplerType.TYPE_2D);
			//pShader.setFilter(0, filter);
			pShader.setBaseRegisters(msPRegisters);
			pShader.setTextureUnits(msPTextureUnits);
			pShader.setPrograms(msPPrograms);
			
			var pass:VisualPass = new VisualPass();
			pass.vertexShader = vShader;
			pass.pixelShader = pShader;
			pass.alphaState = new AlphaState();
			pass.cullState = new CullState();
			pass.depthState = new DepthState();
			pass.offsetState = new OffsetState();
			pass.stencilState = new StencilState();
			pass.wireState = new WireState();
			
			var technique:VisualTechnique = new VisualTechnique();
			technique.insertPass(pass);
			var visualEffect:VisualEffect = new VisualEffect();
			visualEffect.insertTechnique(technique);
			super(visualEffect, 0);
			
			update(texture, x, y, color);
		}
		
		public function update(texture:Texture2D, x:Number, y:Number, color:Vector3D):void
		{
			setVertexConstantByHandle(0, 0, new PVWMatrixConstant());
			
			var common1:ShaderFloat = new ShaderFloat(1);
			common1.setRegister(0, [x, y, 1, 1]);
			var common2:ShaderFloat = new ShaderFloat(1);
			common2.setRegister(0, [color.x, color.y, color.z, 1]);
			
			setPixelConstantByHandle(0, 0, common1);
			setPixelConstantByHandle(0, 1, common2);
			
			setPixelTextureByHandle(0, 0, texture);
		}
	}
}