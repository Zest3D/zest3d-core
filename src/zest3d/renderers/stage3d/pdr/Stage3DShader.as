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
	import flash.display3D.Context3D;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.renderers.stage3d.Stage3DMapping;
	import zest3d.renderers.stage3d.Stage3DSamplerState;
	import zest3d.renderers.Renderer;
	import zest3d.resources.Texture2D;
	import zest3d.resources.Texture3D;
	import zest3d.resources.TextureBase;
	import zest3d.resources.TextureCube;
	import zest3d.resources.TextureRectangle;
	import zest3d.shaders.enum.SamplerType;
	import zest3d.shaders.Shader;
	import zest3d.shaders.ShaderParameters;
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Stage3DShader implements IDisposable
	{
		
		protected var _isDisposed:Boolean;
		
		public function Stage3DShader() 
		{
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		protected function setSamplerState( renderer: Renderer, shader: Shader, profile: int,
										parameters: ShaderParameters, maxSamplers: int, currentSS: Array, context3D: Context3D ): void
		{
			
			var numSamplers: int = shader.numSamplers;
			if ( numSamplers > maxSamplers )
			{
				numSamplers = maxSamplers;
			}
			for ( var i: int = 0; i < numSamplers; ++i )
			{
				var type: SamplerType = shader.getSamplerType( i );
				var target: String = Stage3DMapping.textureTarget[ type.index ]; // TODO map targets
				var textureUnit: int = shader.getTextureUnit( profile, i );
				var texture: TextureBase = parameters.getTextureByHandle( i );
				var current: Stage3DSamplerState = currentSS[ textureUnit ];
				
				//TODO context3D.setSamplerStateAt( textureUnit, Context3DWrapMode.CLAMP, Context3DTextureFilter.LINEAR, Context3DMipFilter.MIPLINEAR );
				
				// TODO set up any wrap mode where/if possisble via AGAL and recompile
				switch( type )
				{
					case SamplerType.TYPE_2D:
							renderer.enableTexture2D( texture as Texture2D, textureUnit );
						break;
					case SamplerType.TYPE_3D:
							renderer.enableTexture3D( texture as Texture3D, textureUnit );
						break;
					case SamplerType.CUBE:
							renderer.enableTextureCube( texture as TextureCube, textureUnit );
						break;
					case SamplerType.RECTANGLE:
							renderer.enableTextureRectangle( texture as TextureRectangle, textureUnit );
						break;
					default:
						throw new Error( "Invalid sampler type." );
				}
				
				// setup the anisotropic filtering
				// TODO can we do something here for AGAL JIT shaders
				var maxAnisotropy: Number = Shader.MAX_ANISOTROPY;
				var anisotropy: Number = shader.getAnisotropy( i );
				if ( anisotropy < 1 || anisotropy > maxAnisotropy )
				{
					anisotropy = 1;
				}
				if ( anisotropy != current.anisotropy )
				{
					current.anisotropy = anisotropy;
					// TODO update this with the shader
				}
				
				//TODO same again, can we get this to the shader... flag and recompile?
				var lodBias: Number = shader.getLodBias( i );
				if ( lodBias != current.lodBias )
				{
					current.lodBias = lodBias;
				}
				//TODO same again maxFilter, can we get this to the shader... flag and recompile?
			}
		}
		
		protected function disableTextures( renderer: Renderer, shader: Shader,
										profile: int, parameters: ShaderParameters, maxSamplers: int ): void
		{
			var numSamplers: int = shader.numSamplers;
			if ( numSamplers > maxSamplers )
			{
				numSamplers = maxSamplers;
			}
			
			for ( var i: int = 0; i < numSamplers; ++i )
			{
				var type: SamplerType = shader.getSamplerType( i );
				var textureUnit: int = shader.getTextureUnit( profile, i );
				var texture: TextureBase = parameters.getTextureByHandle( i );
				
				switch( type )
				{
					case SamplerType.TYPE_2D:
							renderer.disableTexture2D( texture as Texture2D, textureUnit );
						break;
					case SamplerType.TYPE_3D:
							renderer.disableTexture3D( texture as Texture3D, textureUnit );
						break;
					case SamplerType.CUBE:
							renderer.disableTextureCube( texture as TextureCube, textureUnit );
						break;
					case SamplerType.RECTANGLE:
							renderer.disableTextureRectangle( texture as TextureRectangle, textureUnit );
						break;
					default:
							throw new Error( "Invalid sampler type." );
						break;
				}
				
			}
		}
		
	}

}