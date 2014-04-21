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
	import flash.utils.ByteArray;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.renderers.agal.AGALRenderer;
	import zest3d.renderers.interfaces.IVertexShader;
	import zest3d.renderers.Renderer;
	import zest3d.shaders.enum.VertexShaderProfileType;
	import zest3d.shaders.ShaderParameters;
	import zest3d.shaders.VertexShader;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class AGALVertexShader extends AGALShader implements IVertexShader, IDisposable 
	{
		
		private var _renderer: AGALRenderer;
		private var _context: Context3D;
		private var _vertexShader: VertexShader;
		
		public static var program: ByteArray;
		
		
		public function AGALVertexShader( renderer: Renderer, vShader: VertexShader ) 
		{
			_renderer = renderer as AGALRenderer;
			_context = _renderer.data.context;
			
			var programText: String = vShader.getProgram( VertexShader.profile.index );
			var assembler:AGALMiniAssembler = new AGALMiniAssembler( false );
			
			switch( VertexShader.profile )
			{
				case VertexShaderProfileType.AGAL_1_0:
						program = assembler.assemble( Context3DProgramType.VERTEX, programText, 1 );
					break;
				case VertexShaderProfileType.AGAL_2_0:
						program = assembler.assemble( Context3DProgramType.VERTEX, programText, 2 );
					break;
			}
		}
		
		override public function dispose(): void
		{
			//TODO dispose _shader
			super.dispose();
		}
		
		public function enable( renderer: Renderer, vShader: VertexShader, parameters: ShaderParameters ): void
		{
			// glEnable(GL_VERTEX_PROGRAM_ARB);
			// glBindProgramARB(GL_VERTEX_PROGRAM_ARB, mShader);
			
			var profile: int = VertexShader.profile.index;
			var numConstants: int = vShader.numConstants;
			
			var offset: int = 0;
			for ( var i: int = 0; i < numConstants; ++i )
			{
				var numRegisters: int = vShader.getNumRegistersUsed( i );
				var data: ByteArray = parameters.getConstantByHandle( i ).data;
				var baseRegister: int = vShader.getBaseRegister( profile, i );
				
				// TODO set all offsets etc (We have lots of power here)
				_context.setProgramConstantsFromByteArray( Context3DProgramType.VERTEX, offset, numRegisters, data, 0 );
				offset += numRegisters;
			}
			
			var agalRenderer: AGALRenderer = renderer as AGALRenderer;
			
			setSamplerState( renderer, vShader, profile, parameters, agalRenderer.data.maxVShaderImages, agalRenderer.data.currentSS, _context );
		}
		
		public function disable( renderer: Renderer, vShader: VertexShader, parameters: ShaderParameters ): void
		{
			var profile: int = VertexShader.profile.index;
			var agalRenderer:AGALRenderer = renderer as AGALRenderer;
			
			disableTextures( renderer, vShader, profile, parameters, agalRenderer.data.maxVShaderImages );
		}
		
	}

}