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
	public class VisualPass implements IDisposable 
	{
		
		protected var _vShader: VertexShader;
		protected var _pShader: FragmentShader;
		protected var _alphaState: AlphaState;
		protected var _cullState: CullState;
		protected var _depthState: DepthState;
		protected var _offsetState: OffsetState;
		protected var _stencilState: StencilState;
		protected var _wireState: WireState;
		protected var _isDisposed:Boolean;
		
		public function VisualPass() 
		{
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_vShader.dispose();
			_pShader.dispose();
			_alphaState.dispose();
			_cullState.dispose();
			_depthState.dispose();
			_offsetState.dispose();
			_stencilState.dispose();
			_wireState.dispose();
			
			_vShader = null;
			_pShader = null;
			_alphaState = null;
			_cullState = null;
			_depthState = null;
			_offsetState = null;
			_stencilState = null;
			_wireState = null;
			
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		[Inline]
		public final function set vertexShader( vShader: VertexShader ): void
		{
			_vShader = vShader;
		}
		
		[Inline]
		public final function set pixelShader( pShader: FragmentShader ): void
		{
			_pShader = pShader;
		}
		
		[Inline]
		public final function set alphaState( alphaState: AlphaState ): void
		{
			_alphaState = alphaState;
		}
		
		[Inline]
		public final function set cullState( cullState: CullState ): void
		{
			_cullState = cullState;
		}
		
		[Inline]
		public final function set depthState( depthState: DepthState ): void
		{
			_depthState = depthState;
		}
		
		[Inline]
		public final function set offsetState( offsetState: OffsetState ): void
		{
			_offsetState = offsetState;
		}
		
		[Inline]
		public final function set stencilState( stencilState: StencilState ): void
		{
			_stencilState = stencilState;
		}
		
		[Inline]
		public final function set wireState( wireState: WireState ): void
		{
			_wireState = wireState;
		}
		
		
		
		[Inline]
		public final function get vertexShader(): VertexShader
		{
			return _vShader;
		}
		
		[Inline]
		public final function get pixelShader(): FragmentShader
		{
			return _pShader;
		}
		
		[Inline]
		public final function get alphaState(): AlphaState
		{
			return _alphaState;
		}
		
		[Inline]
		public final function get cullState(): CullState
		{
			return _cullState;
		}
		
		[Inline]
		public final function get depthState(): DepthState
		{
			return _depthState;
		}
		
		[Inline]
		public final function get offsetState(): OffsetState
		{
			return _offsetState;
		}
		
		[Inline]
		public final function get stencilState(): StencilState
		{
			return _stencilState;
		}
		
		[Inline]
		public final function get wireState(): WireState
		{
			return _wireState;
		}
		
	}

}