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
package zest3d.shaders 
{
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.resources.TextureBase;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Visual;
	import zest3d.shaderfloats.ShaderFloat;
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class ShaderParameters implements IDisposable 
	{
		
		protected var _shader: Shader;
		protected var _numConstants: int;
		protected var _constants:Vector.<ShaderFloat>;
		protected var _numTextures: int;
		protected var _textures:Vector.<TextureBase>;
		protected var _isDisposed:Boolean;
		
		public function ShaderParameters( shader: Shader ) 
		{
			_shader = shader;
			
			_numConstants = _shader.numConstants;
			if ( _numConstants > 0 )
			{
				_constants = new Vector.<ShaderFloat>( _numConstants );
			}
			
			_numTextures = _shader.numSamplers;
			if ( _numTextures )
			{
				_textures = new Vector.<TextureBase>( _numTextures );
			}
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			if ( _constants )
			{
				for each( var constant: ShaderFloat in _constants )
				{
					constant.dispose();
				}
				_constants = null;
			}
			
			if ( _textures )
			{
				for each( var texture: TextureBase in _textures )
				{
					texture.dispose();
				}
				_textures = null;
			}
			
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		[Inline]
		public final function get numConstants(): int
		{
			return _numConstants;
		}
		
		[Inline]
		public final function get numTextures(): int
		{
			return _numTextures;
		}
		
		[Inline]
		public final function get constants(): Vector.<ShaderFloat>
		{
			return _constants;
		}
		
		[inline]
		public final function get textures(): Vector.<TextureBase>
		{
			return _textures;
		}
		
		public function setConstantByName( name: String, sFloat: ShaderFloat ): int
		{
			for ( var i: int = 0; i < _numConstants; ++i )
			{
				if ( _shader.getConstantName( i ) == name )
				{
					_constants[ i ] = sFloat;
					return i;
				}
			}
			throw new Error( "Cannot find constant." );
		}
		
		public function setTextureByName( name: String, texture: TextureBase ): int
		{
			for ( var i: int = 0; i < _numTextures; ++i )
			{
				if ( _shader.getSamplerName( i ) == name )
				{
					_textures[ i ] = texture;
					return i;
				}
			}
			throw new Error( "Cannot find texture." );
		}
		
		public function setConstantByHandle( handle: int, sFloat: ShaderFloat ): void
		{
			if ( 0 <= handle && handle < _numConstants )
			{
				_constants[ handle ] = sFloat;
				return;
			}
			throw new Error( "Invalid constant handle." );
		}
		
		public function setTextureByHandle( handle: int, texture: TextureBase ): void
		{
			if ( 0 <= handle && handle < _numTextures )
			{
				_textures[ handle ] = texture;
				return;
			}
			throw new Error( "Invalid texture handle." );
		}
		
		public function getConstantByName( name: String ): ShaderFloat
		{
			for ( var i: int = 0; i < _numConstants; ++i )
			{
				if ( _shader.getConstantName( i ) == name )
				{
					return _constants[ i ];
				}
			}
			throw new Error( "Cannot find constant." );
		}
		
		public function getTextureByName( name: String ): TextureBase
		{
			for ( var i: int = 0; i < _numTextures; ++i )
			{
				if ( _shader.getSamplerName( i ) == name )
				{
					return _textures[ i ];
				}
			}
			
			throw new Error( "Invalid constant handle." );
		}
		
		public function getConstantByHandle( handle: int ): ShaderFloat
		{
			if ( 0 <= handle && handle < _numConstants )
			{
				return _constants[ handle ];
			}
			throw new Error( "Invalid constant handle." );
		}
		
		public function getTextureByHandle( handle: int ): TextureBase
		{
			if ( 0 <= handle && handle < _numTextures )
			{
				return _textures[ handle ];
			}
			throw new Error( "Invalid texture handle." );
		}
		
		public function updateConstants( visual: Visual, camera: Camera ): void
		{
			for each( var constant: ShaderFloat in _constants )
			{
				if ( constant.allowUpdater() )
				{
					constant.update( visual, camera );
				}
			}
		}
		
	}

}