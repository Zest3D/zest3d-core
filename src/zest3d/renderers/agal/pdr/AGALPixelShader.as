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
package zest3d.renderers.agal.pdr 
{
	import com.adobe.utils.extended.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.renderers.agal.AGALRenderer;
	import zest3d.renderers.interfaces.IPixelShader;
	import zest3d.renderers.Renderer;
	import zest3d.shaders.enum.PixelShaderProfileType;
	import zest3d.shaders.PixelShader;
	import zest3d.shaders.ShaderParameters;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class AGALPixelShader extends AGALShader implements IPixelShader, IDisposable 
	{
		
		private var _renderer: AGALRenderer;
		private var _context: Context3D;
		private var _pixelShader: PixelShader;
		
		public static var program: ByteArray;
		public var _program: Program3D;
		
		public function AGALPixelShader( renderer: Renderer, pShader: PixelShader ) 
		{
			_renderer = renderer as AGALRenderer;
			_context = _renderer.data.context;
			
			var programText: String = pShader.getProgram( PixelShader.profile.index );
			var assembler: AGALMiniAssembler = new AGALMiniAssembler( false );
			
			
			switch( PixelShader.profile )
			{
				case PixelShaderProfileType.AGAL_1_0 :
						program = assembler.assemble( Context3DProgramType.FRAGMENT, programText, 1 );
					break;
				case PixelShaderProfileType.AGAL_2_0 :
						program = assembler.assemble( Context3DProgramType.FRAGMENT, programText, 2 );
					break;
			}
			
			_program = _context.createProgram();
			
			_program.upload( AGALVertexShader.program, AGALPixelShader.program );
		}
		
		override public function dispose(): void
		{
			//TODO _shader
			super.dispose();
		}
		
		public function enable( renderer: Renderer, pShader: PixelShader, parameters: ShaderParameters ): void
		{
			//  glEnable(GL_FRAGMENT_PROGRAM_ARB);
			//  glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB, mShader);
			
			_context.setProgram( _program );
			
			var profile: int = PixelShader.profile.index;
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
		
		public function disable( renderer: Renderer, pShader: PixelShader, parameters: ShaderParameters ): void
		{
			var profile: int = PixelShader.profile.index;
			var agalRenderer:AGALRenderer = renderer as AGALRenderer;
			
			disableTextures( renderer, pShader, profile, parameters, agalRenderer.data.maxPShaderImages );
		}
		
	}

}