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
	public class VisualEffect implements IDisposable 
	{
		
		protected var _techniques: Vector.<VisualTechnique>;
		protected var _isDisposed: Boolean;
		
		public function VisualEffect() 
		{
			_techniques = new Vector.<VisualTechnique>();
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			for each( var technique: VisualTechnique in _techniques )
			{
				technique.dispose();
			}
			_techniques = null;
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function insertTechnique( technique: VisualTechnique ): void
		{
			if ( technique )
			{
				_techniques.push( technique );
				return;
			}
			throw new IllegalArgumentError( "Input to InsertTechnique must be nonnull." );
		}
		
		[Inline]
		public final function get numTechniques(): int
		{
			return _techniques.length;
		}
		
		public function getTechnique( techniqueIndex: int ): VisualTechnique
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ];
			}
			throw new IllegalArgumentError( "Invalid index" );
		}
		
		public function getNumPasses( techniqueIndex: int ): int
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ].numPasses;
			}
			throw new IllegalArgumentError( "Invalid index" );
		}
		
		public function getVertexShader( techniqueIndex: int, passIndex: int ): VertexShader
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ].getVertexShader( passIndex );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getPixelShader( techniqueIndex: int, passIndex: int ): FragmentShader
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ].getPixelShader( passIndex );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getAlphaState( techniqueIndex: int, passIndex: int ): AlphaState
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ].getAlphaState( passIndex );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getCullState( techniqueIndex: int, passIndex: int ): CullState
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ].getCullState( passIndex );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getDepthState( techniqueIndex: int, passIndex: int ): DepthState
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ].getDepthState( passIndex );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getOffsetState( techniqueIndex: int, passIndex: int ): OffsetState
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ].getOffsetState( passIndex );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getStencilState( techniqueIndex: int, passIndex: int ): StencilState
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ].getStencilState( passIndex );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getWireState( techniqueIndex: int, passIndex: int ): WireState
		{
			if ( 0 <= techniqueIndex && techniqueIndex < _techniques.length )
			{
				return _techniques[ techniqueIndex ].getWireState( passIndex );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
	}

}