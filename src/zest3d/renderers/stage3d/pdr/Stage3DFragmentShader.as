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
package zest3d.renderers.stage3d.pdr {
	import com.adobe.utils.extended.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import plugin.core.interfaces.IDisposable;
	import zest3d.renderers.stage3d.Stage3DRenderer;
	import zest3d.renderers.interfaces.IPixelShader;
	import zest3d.renderers.Renderer;
	import zest3d.shaders.enum.PixelShaderProfileType;
	import zest3d.shaders.FragmentShader;
	import zest3d.shaders.ShaderParameters;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Stage3DFragmentShader extends Stage3DShader implements IPixelShader, IDisposable 
	{
		
		private var _renderer: Stage3DRenderer;
		private var _context: Context3D;
		private var _pixelShader: FragmentShader;
		
		public static var program: ByteArray;
		public var _program: Program3D;
		
		public function Stage3DFragmentShader( renderer: Renderer, pShader: FragmentShader ) 
		{
			_renderer = renderer as Stage3DRenderer;
			_context = _renderer.data.context;
			
			var programText: String = pShader.getProgram( FragmentShader.profile.index );
			var assembler: AGALMiniAssembler = new AGALMiniAssembler( false );
			
			
			switch( FragmentShader.profile )
			{
				case PixelShaderProfileType.AGAL_1_0 :
						program = assembler.assemble( Context3DProgramType.FRAGMENT, programText, 1 );
					break;
				case PixelShaderProfileType.AGAL_2_0 :
						program = assembler.assemble( Context3DProgramType.FRAGMENT, programText, 2 );
					break;
			}
			
			_program = _context.createProgram();
			
			_program.upload( Stage3DVertexShader.program, Stage3DFragmentShader.program );
		}
		
		override public function dispose(): void
		{
			//TODO _shader
			super.dispose();
		}
		
		public function enable( renderer: Renderer, pShader: FragmentShader, parameters: ShaderParameters ): void
		{
			//  glEnable(GL_FRAGMENT_PROGRAM_ARB);
			//  glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB, mShader);
			
			_context.setProgram( _program );
			
			var profile: int = FragmentShader.profile.index;
			var numConstants: int = pShader.numConstants;
			var offset: int = 0;
			
			
			for ( var i: int = 0; i < numConstants; ++i )
			{
				var numRegisters: int = pShader.getNumRegistersUsed( i );
				var data: ByteArray = parameters.getConstantByHandle( i ).data;
				var baseRegister: int = pShader.getBaseRegister( profile, i );
				
				_context.setProgramConstantsFromByteArray( Context3DProgramType.FRAGMENT, offset, numRegisters, data, 0 );
				offset += numRegisters;
				
			}
			
			setSamplerState( renderer, pShader, profile, parameters, _renderer.data.maxPShaderImages, _renderer.data.currentSS, _context );
		}
		
		public function disable( renderer: Renderer, pShader: FragmentShader, parameters: ShaderParameters ): void
		{
			var profile: int = FragmentShader.profile.index;
			var agalRenderer:Stage3DRenderer = renderer as Stage3DRenderer;
			
			disableTextures( renderer, pShader, profile, parameters, agalRenderer.data.maxPShaderImages );
		}
		
	}

}