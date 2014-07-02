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
	import plugin.core.errors.IllegalArgumentError;
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import plugin.core.system.object.PluginObject;
	import zest3d.resources.TextureBase;
	import zest3d.shaderfloats.ShaderFloat;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class VisualEffectInstance extends PluginObject implements IDisposable 
	{
		
		protected var _effect: VisualEffect;
		protected var _techniqueIndex: int;
		protected var _numPasses: int;
		protected var _vertexParameters:Vector.<ShaderParameters>;
		protected var _pixelParameters:Vector.<ShaderParameters>
		
		
		public function VisualEffectInstance( effect: VisualEffect, techniqueIndex: int ) 
		{
			Assert.isTrue( 0 <= techniqueIndex && techniqueIndex < effect.numTechniques, "Invalid technique index." );
			
			_effect = effect;
			_techniqueIndex = techniqueIndex;
			
			var technique: VisualTechnique = _effect.getTechnique( _techniqueIndex );
			_numPasses = technique.numPasses;
			_vertexParameters = new Vector.<ShaderParameters>( _numPasses );
			_pixelParameters = new Vector.<ShaderParameters>( _numPasses );
			
			var p: int;
			for ( p = 0; p < _numPasses; ++p )
			{
				var pass: VisualPass = technique.getPass( p );
				_vertexParameters[ p ] = new ShaderParameters( pass.vertexShader );
				_pixelParameters[ p ] = new ShaderParameters( pass.pixelShader );
			}
		}
		
		override public function dispose(): void
		{
			var p: ShaderParameters;
			for each( p in _vertexParameters )
			{
				p.dispose();
				p = null;
			}
			_vertexParameters = null;
			
			for each( p in _pixelParameters )
			{
				p.dispose();
				p = null;
			}
			_pixelParameters = null;
			
			_effect.dispose();
			
			_effect = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get effect(): VisualEffect
		{
			return _effect;
		}
		
		[Inline]
		public final function get techniqueIndex(): int
		{
			return _techniqueIndex;
		}
		
		[Inline]
		public final function get numPasses(): int
		{
			return _effect.getTechnique( _techniqueIndex ).numPasses;
		}
		
		public function getPass( pass: int ): VisualPass
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _effect.getTechnique( _techniqueIndex ).getPass( pass );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function getVertexParameters( pass: int ): ShaderParameters
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _vertexParameters[ pass ];
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function getPixelParameters( pass: int ): ShaderParameters
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _pixelParameters[ pass ];
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function setVertexConstantByName( pass: int, name: String, sFloat: ShaderFloat ): int
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _vertexParameters[ pass ].setConstantByName( name, sFloat );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function setPixelConstantByName( pass: int, name: String, sFloat: ShaderFloat): int
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _pixelParameters[ pass ].setConstantByName( name, sFloat );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function setVertexTextureByName( pass: int, name: String, texture: TextureBase ): int
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _vertexParameters[ pass ].setTextureByName( name, texture );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function setPixelTextureByName( pass: int, name: String, texture: TextureBase ): int
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _pixelParameters[ pass ].setTextureByName( name, texture );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		
		public function setVertexConstantByHandle( pass: int, handle: int, sFloat: ShaderFloat ): void
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				_vertexParameters[ pass ].setConstantByHandle( handle, sFloat );
				return;
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function setPixelConstantByHandle( pass: int, handle: int, sFloat: ShaderFloat): void
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				_pixelParameters[ pass ].setConstantByHandle( handle, sFloat );
				return;
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function setVertexTextureByHandle( pass: int, handle: int, texture: TextureBase ): void
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				_vertexParameters[ pass ].setTextureByHandle( handle, texture );
				return;
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function setPixelTextureByHandle( pass: int, handle: int, texture: TextureBase ): void
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				_pixelParameters[ pass ].setTextureByHandle( handle, texture );
				return;
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		
		
		public function getVertexConstantByName( pass: int, name: String ): ShaderFloat
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _vertexParameters[ pass ].getConstantByName( name );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function getPixelConstantByName( pass: int, name: String ): ShaderFloat
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _pixelParameters[ pass ].getConstantByName( name );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function getVertexTextureByName( pass: int, name: String ): TextureBase
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _vertexParameters[ pass ].getTextureByName( name );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function getPixelTextureByName( pass: int, name: String ): TextureBase
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _pixelParameters[ pass ].getTextureByName( name );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function getVertexConstantByHandle( pass: int, handle: int ): ShaderFloat
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _vertexParameters[ pass ].getConstantByHandle( handle );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function getPixelConstantByHandle( pass: int, handle: int ): ShaderFloat
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _pixelParameters[ pass ].getConstantByHandle( handle );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function getVertexTextureByHandle( pass: int, handle: int ): TextureBase
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _vertexParameters[ pass ].getTextureByHandle( handle );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
		public function getPixelTextureByHandle( pass: int, handle: int ): TextureBase
		{
			if ( 0 <= pass && pass < _numPasses )
			{
				return _pixelParameters[ pass ].getTextureByHandle( handle );
			}
			throw new IllegalArgumentError( "Invalid pass index." );
		}
		
	}

}