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
	import io.plugin.core.errors.IllegalArgumentError;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.shaders.states.AlphaState;
	import zest3d.shaders.states.CullState;
	import zest3d.shaders.states.DepthState;
	import zest3d.shaders.states.OffsetState;
	import zest3d.shaders.states.StencilState;
	import zest3d.shaders.states.WireState;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class VisualTechnique implements IDisposable 
	{
		
		protected var _passes:Vector.<VisualPass>
		protected var _isDisposed:Boolean;
		
		public function VisualTechnique() 
		{
			_passes = new Vector.<VisualPass>();
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			for each( var pass: VisualPass in _passes )
			{
				pass.dispose();
			}
			_passes = null;
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function insertPass( pass:VisualPass ): void
		{
			if ( pass )
			{
				_passes.push( pass );
				return;
			}
			throw new IllegalArgumentError( "Input to InsertPass must be nonnull." );
		}
		
		[Inline]
		public final function get numPasses(): int
		{
			return _passes.length;
		}
		
		public function getPass( index: int ): VisualPass
		{
			if ( 0 <= index && index < _passes.length )
			{
				return _passes[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getVertexShader( index: int ): VertexShader
		{
			if ( 0 <= index && index < _passes.length )
			{
				return _passes[ index ].vertexShader;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getPixelShader( index: int ): FragmentShader
		{
			if ( 0 <= index && index < _passes.length )
			{
				return _passes[ index ].pixelShader;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getAlphaState( index: int ): AlphaState
		{
			if ( 0 <= index && index < _passes.length )
			{
				return _passes[ index ].alphaState;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getCullState( index: int ): CullState
		{
			if ( 0 <= index && index < _passes.length )
			{
				return _passes[ index ].cullState;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getDepthState( index: int ): DepthState
		{
			if ( 0 <= index && index < _passes.length )
			{
				return _passes[ index ].depthState;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getOffsetState( index: int ): OffsetState
		{
			if ( 0 <= index && index < _passes.length )
			{
				return _passes[ index ].offsetState;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getStencilState( index: int ): StencilState
		{
			if ( 0 <= index && index < _passes.length )
			{
				return _passes[ index ].stencilState;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getWireState( index: int ): WireState
		{
			if ( 0 <= index && index < _passes.length )
			{
				return _passes[ index ].wireState;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
	}

}