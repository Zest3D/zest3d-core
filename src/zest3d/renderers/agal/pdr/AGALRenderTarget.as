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
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.Assert;
	import zest3d.renderers.agal.AGALRenderer;
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
	public class AGALRenderTarget implements IRenderTarget, IDisposable 
	{
		
		private var _renderer: AGALRenderer;
		
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
		
		private var bitmapData:BitmapData;
		
		public function AGALRenderTarget( renderer: AGALRenderer, renderTarget: RenderTarget ) 
		{
			_renderTarget = renderTarget;
			_renderer = renderer;
			
			_numTargets = renderTarget.numTargets;
			Assert.isTrue( _numTargets > 0, "Number of render targets must be at least 1." );
			
			_width = renderTarget.width;
			_height = renderTarget.height;
			_format = renderTarget.format;
			_hasMipmaps = renderTarget.hasMipmaps;
			_hasDepthStencil = renderTarget.hasDepthStencil;
			
			// create framebuffers (necessary with Stage3D??) < basically bitmaps or at least data e.g. ByteArrays
			
			// previous bound texture
			// TODO var previousBind:Texture 
			_colorTextures = new Vector.<RectangleTexture>( _numTargets );
			_drawBuffers = new Vector.<RectangleTexture>( _numTargets );
			
			
			// color buffers
			for ( var i:int = 0; i < _numTargets; ++i )
			{
				
				// TODO some targets can be packed etc
				_colorTextures[ i ] = renderer.data.context.createRectangleTexture( _width, _height, Context3DTextureFormat.BGRA, true );
				_drawBuffers[ i ] = renderer.data.context.createRectangleTexture( _width, _height, Context3DTextureFormat.BGRA, true );
				
				
				
				var colorTexture:TextureRectangle = renderTarget.getColorTextureAt( i );
				
				
				/////// temporary - empty bitmap data ///////////////
				//var bitmap:Bitmap = new UVTexture() as Bitmap;
				//bitmapData = bitmap.bitmapData;
				
				//var byteArray:ByteArray = new ByteArray();
				//bitmapData.copyPixelsToByteArray( new Rectangle( 0, 0, 800, 600 ), byteArray );
				
				//colorTexture.data = byteArray;
				/////////////////////////
				
				Assert.isTrue( !renderer.inTextureRectangleMap( colorTexture ), "Texture shouldn't exist." );
				var ogColorTexture:AGALTextureRectangle = new AGALTextureRectangle( renderer, colorTexture );
				
				
				renderer.insertInTextureRectangleMap( colorTexture, ogColorTexture );
				_colorTextures[i] = ogColorTexture.texture;
				
				
				// _renderer.data.context.setTextureAt( i, _colorTextures[ i ] ); // set and make available to the MRTEffect
				
				// set the sampler accordingly
				if ( _hasMipmaps )
				{
					
					/*
					 * glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
					 * glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
					 */
				}
				else
				{
					/*
					 * glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
					 * glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
					 */
				}
			}
			
			// depth stencil buffer
			var depthStencilTexture:TextureRectangle = renderTarget.depthStencilTexture;
			if ( depthStencilTexture )
			{
				Assert.isTrue( !renderer.inTextureRectangleMap( depthStencilTexture ), "Texture shouldn't exist." );
				
				var ogDepthStencilTexture:AGALTextureRectangle = new AGALTextureRectangle( renderer, depthStencilTexture );
				renderer.insertInTextureRectangleMap( depthStencilTexture, ogDepthStencilTexture );
				_depthStencilTexture = ogDepthStencilTexture.texture;
				
			}
		}
		
		public function dispose(): void
		{
			
		}
		
		public function enable( renderer: Renderer ): void
		{
			_renderer.data.context.clear( 1, 0, 0, 1 );
			
		}
		
		//private var bitmapData:BitmapData = new BitmapData( 1024, 1024, true, 0x00000000 );
		public function disable( renderer: Renderer ): void
		{
			
			/*
			_renderer.data.context.setRenderToTexture( _renderTarget.getColorTextureAt( 0 ) as TextureBase );
			_renderer.data.context.setRenderToBackBuffer();
			*/
			_renderer.data.context.drawToBitmapData( bitmapData );
			
			for ( var i:int = 0; i < _numTargets; ++i )
			{
				var colorTexture:TextureRectangle = _renderTarget.getColorTextureAt( i );
				var byteArray:ByteArray = new ByteArray();
				byteArray.endian = Endian.LITTLE_ENDIAN;
				bitmapData.copyPixelsToByteArray( new Rectangle( 0, 0, 800, 600 ), byteArray );
				colorTexture.data = byteArray;
				
				var ogColorTexture:AGALTextureRectangle = new AGALTextureRectangle( _renderer, colorTexture );
				renderer.insertInTextureRectangleMap( colorTexture, ogColorTexture );
				_colorTextures[i] = ogColorTexture.texture;
			}
		}
		
		public function readColor( i: int, renderer: Renderer, texture: Texture2D ): void
		{
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
			/*
			var colorTexture:TextureRectangle = _renderTarget.getColorTextureAt( i );
			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			bitmapData.copyPixelsToByteArray( new Rectangle( 0, 0, 1024, 1024 ), byteArray );
			colorTexture.data = null;
			colorTexture.data = byteArray;
			
			var ogColorTexture:AGALTextureRectangle = new AGALTextureRectangle( _renderer, colorTexture );
			renderer.insertInTextureRectangleMap( colorTexture, ogColorTexture );
			_colorTextures[i] = ogColorTexture.texture;
			*/
			disable( renderer );
		}
	}
}