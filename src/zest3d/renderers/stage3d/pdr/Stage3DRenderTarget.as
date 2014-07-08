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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import zest3d.renderers.stage3d.Stage3DRenderer;
	import zest3d.renderers.interfaces.IRenderTarget;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.TextureFormat;
	import zest3d.resources.RenderTarget;
	import zest3d.resources.Texture2D;
	import zest3d.resources.TextureRectangle;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Stage3DRenderTarget implements IRenderTarget, IDisposable 
	{
		
		private var _renderer: Stage3DRenderer;
		
		private var _numTargets:int;
		private var _width:int;
		private var _height:int;
		private var _format:TextureFormat;
		private var _hasMipmaps:Boolean;
		private var _hasDepthStencil:Boolean;
		
		private var _colorTextures:Vector.<RectangleTexture>;
		private var _depthStencilTexture:RectangleTexture;
		private var _frameBuffer:Texture;
		private var _drawBuffers:Vector.<RectangleTexture>;
		private var _prevViewport:Array;
		private var _prevDepthRange:Array;
		
		private var _renderTarget:RenderTarget;
		
		private var _context:Context3D;
		
		protected var _isDisposed:Boolean;
		
		/*
		[Embed(source = "../../../../../../../Flash Projects/Zest3D AS3 Harness/bin/assets/textures/texture.png")]
		private const UVTexture:Class;
		*/
		
		public function Stage3DRenderTarget( renderer: Stage3DRenderer, renderTarget: RenderTarget ) 
		{
			_renderTarget = renderTarget;
			_renderer = renderer;
			_context = _renderer.data.context;
			
			
			_numTargets = renderTarget.numTargets;
			Assert.isTrue( _numTargets > 0, "Number of render targets must be at least one." );
			
			_width = renderTarget.width;
			_height = renderTarget.height;
			_format = renderTarget.format;
			_hasMipmaps = renderTarget.hasMipmaps;
			_hasDepthStencil = renderTarget.hasDepthStencil;
			
			
			_prevViewport = [] //4 int
			_prevViewport[0] = 0;
			_prevViewport[1] = 0;
			_prevViewport[2] = 0;
			_prevViewport[3] = 0;
			_prevDepthRange = [] //2 Number
			_prevDepthRange[0] = 0;
			_prevDepthRange[1] = 0;
			
			// TODO Once viewports and depth ranges are complete in renderer
			renderer.getViewport();
			renderer.getDepthRange();
			
			// TODO create framebuffers (necessary with Stage3D??) < basically bitmaps or at least data e.g. ByteArrays
			
			// previous bound texture
			// TODO var previousBind:Texture 
			_colorTextures = new Vector.<RectangleTexture>( _numTargets );
			_drawBuffers = new Vector.<RectangleTexture>( _numTargets );
			
			// color buffers
			for ( var i:int = 0; i < _numTargets; ++i )
			{
				var colorTexture:TextureRectangle = renderTarget.getColorTextureAt(i);
				Assert.isTrue( !renderer.inTextureRectangleMap(colorTexture), "Texture should not yet exist." );
				
				var ogColorTexture:Stage3DTextureRectangle = new Stage3DTextureRectangle( renderer, colorTexture );
				renderer.insertInTextureRectangleMap( colorTexture, ogColorTexture );
				
				//_colorTextures[i] = ogColorTexture.texture;
				
				_colorTextures[ i ] = renderer.data.context.createRectangleTexture( _width, _height, Context3DTextureFormat.BGRA, true );
				_drawBuffers[ i ] = renderer.data.context.createRectangleTexture( _width, _height, Context3DTextureFormat.BGRA, true );
			}
			
			// depth stencil buffer
			var depthStencilTexture:TextureRectangle = renderTarget.depthStencilTexture;
			if ( depthStencilTexture )
			{
				Assert.isTrue( !renderer.inTextureRectangleMap( depthStencilTexture ), "Texture shouldn't exist." );
				
				var ogDepthStencilTexture:Stage3DTextureRectangle = new Stage3DTextureRectangle( renderer, depthStencilTexture );
				renderer.insertInTextureRectangleMap( depthStencilTexture, ogDepthStencilTexture );
				_depthStencilTexture = ogDepthStencilTexture.texture;
			}
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			var texture:RectangleTexture;
			for each( texture in _colorTextures )
			{
				texture.dispose();
			}
			for each( texture in _depthStencilTexture )
			{
				texture.dispose();
			}
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function enable( renderer: Renderer ): void
		{
			// TODO temporarily set the target to the 0 indexed color texture
			_context.setTextureAt( 0, _renderTarget.getColorTextureAt( 0 ) as TextureBase );
			_renderer.data.context.setRenderToTexture( _renderTarget.getColorTextureAt( 0 ) as TextureBase );
		}
		
		public function disable( renderer: Renderer ): void
		{
			_renderer.data.context.setRenderToTexture( _renderTarget.getColorTextureAt( 0 ) as TextureBase );
			_context.setTextureAt( 0, null );
			_renderer.data.context.setRenderToBackBuffer();
		}
		
		public function readColor( i: int, renderer: Renderer, texture: Texture2D ): void
		{
			//TODO render texture to a bitmap and return the ByteArray
			trace( "WARNING>>>>>>>>>>>>> readColor not yet implemented" );
			/*
			if ( i < 0 || i >= _numTargets )
			{
				Assert.isTrue( false, "Invalid number of targets." );
			}
			
			enable( renderer );
			
			if ( texture )
			{
				if ( texture.format != _format ||
					 texture.width != _width ||
					 texture.height != _height )
				{
					Assert.isTrue( false, "Incompatible texture." );
					texture = null;
					texture = new Texture2D( _format, _width, _height, 0 );
				}
			}
			else
			{
				texture = new Texture2D( _format, _width, _height, 0 );
			}
			
			// TODO read buffer here
			// TODO read data here
			
			var colorTexture:TextureRectangle = _renderTarget.getColorTextureAt( i );
			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			bitmapData.copyPixelsToByteArray( new Rectangle( 0, 0, 1024, 1024 ), byteArray );
			colorTexture.data = null;
			colorTexture.data = byteArray;
			
			var ogColorTexture:AGALTextureRectangle = new AGALTextureRectangle( _renderer, colorTexture );
			renderer.insertInTextureRectangleMap( colorTexture, ogColorTexture );
			_colorTextures[i] = ogColorTexture.texture;
			
			disable( renderer );
			*/
		}
	}
}