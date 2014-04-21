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
package zest3d.resources 
{
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.Assert;
	import io.plugin.core.system.object.PluginObject;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.BufferUsageType;
	import zest3d.resources.enum.TextureFormat;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class RenderTarget extends PluginObject implements IDisposable 
	{
		
		protected var _numTargets: int;
		protected var _colorTextures: Array;
		protected var _depthStencilTexture: TextureRectangle;
		protected var _hasMipmaps: Boolean;
		
		public function RenderTarget( numTargets: int, tFormat: TextureFormat, width: int,
				height: int, hasMipmaps: Boolean, hasDepthStencil: Boolean ) 
		{
			_numTargets = numTargets;
			_hasMipmaps = hasMipmaps;
			
			Assert.isTrue( _numTargets > 0 );
			
			_colorTextures = [];
			
			var i: int = 0;
			for ( i = 0; i < _numTargets; ++i )
			{
				_colorTextures[i] = new TextureRectangle( tFormat, width, height, BufferUsageType.RENDERTARGET );
			}
			
			if ( hasDepthStencil )
			{
				_depthStencilTexture = new TextureRectangle( TextureFormat.RGBA8888, width, height, BufferUsageType.DEPTHSTENCIL );
			}
		}
		
		public function dispose(): void
		{
			Renderer.unbindAllRenderTarget( this );
			for each( var texture:TextureRectangle in _colorTextures )
			{
				texture.dispose();
			}
			_colorTextures = null;
		}
		
		[Inline]
		public final function get numTargets(): int
		{
			return _numTargets;
		}
		
		[Inline]
		public final function get format(): TextureFormat
		{
			return _colorTextures[0].format;
		}
		
		[Inline]
		public final function get width(): int
		{
			return _colorTextures[0].width;
		}
		
		[Inline]
		public final function get height(): int
		{
			return _colorTextures[0].height;
		}
		
		[Inline]
		public final function getColorTextureAt( index: int ): TextureRectangle
		{
			return _colorTextures[index];
		}
		
		[Inline]
		public final function get depthStencilTexture(): TextureRectangle
		{
			return _depthStencilTexture;
		}
		
		[Inline]
		public final function get hasMipmaps(): Boolean
		{
			return _hasMipmaps;
		}
		
		[Inline]
		public final function get hasDepthStencil(): Boolean
		{
			return _depthStencilTexture != null;
		}
		
	}

}