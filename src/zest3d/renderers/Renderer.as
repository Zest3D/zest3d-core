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
package zest3d.renderers 
{
	import flash.utils.Dictionary;
	import io.plugin.core.graphics.Color;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.Assert;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import io.plugin.math.algebra.HMatrix;
	import zest3d.globaleffects.GlobalEffect;
	import zest3d.renderers.interfaces.IIndexBuffer;
	import zest3d.renderers.interfaces.IPixelShader;
	import zest3d.renderers.interfaces.IRenderTarget;
	import zest3d.renderers.interfaces.ITexture2D;
	import zest3d.renderers.interfaces.ITexture3D;
	import zest3d.renderers.interfaces.ITextureCube;
	import zest3d.renderers.interfaces.IVertexBuffer;
	import zest3d.renderers.interfaces.IVertexFormat;
	import zest3d.renderers.interfaces.IVertexShader;
	import zest3d.resources.enum.BufferLockingType;
	import zest3d.resources.enum.TextureFormat;
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.RenderTarget;
	import zest3d.resources.Texture2D;
	import zest3d.resources.Texture3D;
	import zest3d.resources.TextureCube;
	import zest3d.resources.TextureRectangle;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.VisibleSet;
	import zest3d.scenegraph.Visual;
	import zest3d.shaders.PixelShader;
	import zest3d.shaders.ShaderParameters;
	import zest3d.shaders.states.AlphaState;
	import zest3d.shaders.states.CullState;
	import zest3d.shaders.states.DepthState;
	import zest3d.shaders.states.OffsetState;
	import zest3d.shaders.states.StencilState;
	import zest3d.shaders.states.WireState;
	import zest3d.shaders.VertexShader;
	import zest3d.shaders.VisualEffectInstance;
	import zest3d.shaders.VisualPass;
	//import zest3d.renderers.interfaces.ITexture1D;
	//import zest3d.resources.Texture1D;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Renderer implements IDisposable
	{
		
		public static var msRenderers: Dictionary = new Dictionary();
		
		// internal use only
		protected var _data: *;
		
		protected var _width: int;
		protected var _height: int;
		protected var _colorFormat: TextureFormat;
		protected var _depthStencilFormat: TextureFormat;
		protected var _numMultiSamples: int;
		
		/*
		protected var CRendererInput: Class;
		protected var CRendererData: Class;
		*/
		
		protected var CGlobalEffect: Class;
		
		protected var CPdrIndexBuffer: Class;
		protected var CPdrPixelShader: Class;
		protected var CPdrRenderTarget: Class;
		//protected var CPdrTexture1D: Class;
		protected var CPdrTexture2D: Class;
		protected var CPdrTexture3D: Class;
		protected var CPdrTextureCube: Class;
		protected var CPdrTextureRectangle: Class;
		protected var CPdrVertexBuffer: Class;
		protected var CPdrVertexFormat: Class;
		protected var CPdrVertexShader: Class;
		
		//{ region global state
		protected var _defaultAlphaState: AlphaState;
		protected var _defaultCullState: CullState;
		protected var _defaultDepthState: DepthState;
		protected var _defaultOffsetState: OffsetState;
		protected var _defaultStencilState: StencilState;
		protected var _defaultWireState: WireState;
		
		protected var _alphaState: AlphaState;
		protected var _cullState: CullState;
		protected var _depthState: DepthState;
		protected var _offsetState: OffsetState;
		protected var _stencilState: StencilState;
		protected var _wireState: WireState;
		protected var _reverseCullOrder: Boolean;
		//}
		
		//{ region override global state
		protected var _overrideAlphaState: AlphaState;
		protected var _overrideCullState: CullState;
		protected var _overrideDepthState: DepthState;
		protected var _overrideOffsetState: OffsetState;
		protected var _overrideStencilState: StencilState;
		protected var _overrideWireState: WireState;
		//}
		
		protected var _camera: Camera;
		
		protected var _clearColor: Color;
		protected var _clearDepth: Number;
		protected var _clearStencil: uint;
		
		protected var _allowRed: Boolean;
		protected var _allowGreen: Boolean;
		protected var _allowBlue: Boolean;
		protected var _allowAlpha: Boolean;
		
		private var _vertexFormats: Dictionary;
		private var _vertexBuffers: Dictionary;
		private var _indexBuffers: Dictionary;
		//private var _texture1Ds: Dictionary;
		private var _texture2Ds: Dictionary;
		private var _texture3Ds: Dictionary;
		private var _textureCubes: Dictionary;
		private var _textureRectangles: Dictionary;
		private var _renderTargets: Dictionary;
		private var _vertexShaders: Dictionary;
		private var _pixelShaders: Dictionary;
		
		[Inline]
		public function get vertexFormats():Dictionary
		{
			return _vertexFormats;
		}
		
		[Inline]
		public function get vertexBuffers():Dictionary
		{
			return _vertexBuffers;
		}
		
		[Inline]
		public function get indexBuffers():Dictionary
		{
			return _indexBuffers;
		}
		
		[Inline]
		public function get texture2Ds():Dictionary
		{
			return _texture2Ds;
		}
		
		[Inline]
		public function get texture3Ds():Dictionary
		{
			return _texture3Ds;
		}
		
		[Inline]
		public function get textureCubes():Dictionary
		{
			return _textureCubes;
		}
		
		[Inline]
		public function get textureRectangles():Dictionary
		{
			return _textureRectangles;
		}
		
		[Inline]
		public function get renderTargets():Dictionary
		{
			return _renderTargets;
		}
		
		[Inline]
		public function get vertexShaders():Dictionary
		{
			return _vertexShaders;
		}
		
		[Inline]
		public function get pixelShaders():Dictionary
		{
			return _pixelShaders;
		}
		
		public function Renderer( CGlobalEffect: Class, CPdrIndexBuffer:Class, CPdrPixelShader: Class,
				CPdrRenderTarget: Class, /*CPdrTexture1D: Class,*/ CPdrTexture2D: Class, CPdrTexture3D: Class,
				CPdrTextureCube: Class, CPdrTextureRectangle:Class, CPdrVertexBuffer: Class, CPdrVertexFormat: Class, 
				CPdrVertexShader: Class ) 
		{
			//this.CRendererInput = CRendererInput;
			//this.CRendererData = CRendererData;
			
			this.CGlobalEffect = CGlobalEffect;
			this.CPdrIndexBuffer = CPdrIndexBuffer;
			this.CPdrPixelShader = CPdrPixelShader;
			this.CPdrRenderTarget = CPdrRenderTarget;
			//this.CPdrTexture1D = CPdrTexture1D;
			this.CPdrTexture2D = CPdrTexture2D;
			this.CPdrTexture3D = CPdrTexture3D;
			this.CPdrTextureCube = CPdrTextureCube;
			this.CPdrTextureRectangle = CPdrTextureRectangle;
			
			this.CPdrVertexBuffer = CPdrVertexBuffer;
			this.CPdrVertexFormat = CPdrVertexFormat;
			this.CPdrVertexShader = CPdrVertexShader;
		}
		
		public function dispose(): void
		{
		}
		
		protected function _initialize( width: int, height: int, colorFormat:TextureFormat,
										depthStencilFormat: TextureFormat, numMultiSamples: int ): void
		{
			Assert.isTrue( width > 0, "Width must be positive." );
			Assert.isTrue( height > 0, "Height must be positive." );
			Assert.isTrue( numMultiSamples == 0 || 
						   numMultiSamples == 2 ||
						   numMultiSamples == 4, "The number of multisamples can be only 0, 2, or 4." );
			
			_width = width;
			_height = height;
			_colorFormat = colorFormat;
			_depthStencilFormat = depthStencilFormat;
			_numMultiSamples = numMultiSamples;
			
			_defaultAlphaState = new AlphaState();
			_defaultCullState = new CullState();
			_defaultDepthState = new DepthState();
			_defaultOffsetState = new OffsetState();
			_defaultStencilState = new StencilState();
			_defaultWireState = new WireState();
			
			_vertexFormats = new Dictionary();
			_vertexBuffers = new Dictionary();
			_indexBuffers = new Dictionary();
			//_texture1Ds = new Dictionary();
			_texture2Ds = new Dictionary();
			_texture3Ds = new Dictionary();
			_textureCubes = new Dictionary();
			_textureRectangles = new Dictionary();
			_renderTargets = new Dictionary();
			_vertexShaders = new Dictionary();
			_pixelShaders = new Dictionary();
			
			_alphaState = _defaultAlphaState;
			_cullState = _defaultCullState;
			_depthState = _defaultDepthState;
			_offsetState = _defaultOffsetState;
			_stencilState = _defaultStencilState;
			_wireState = _defaultWireState;
			
			_reverseCullOrder = false;
			
			_overrideAlphaState = null;
			_overrideCullState = null;
			_overrideDepthState = null;
			_overrideOffsetState = null;
			_overrideStencilState = null;
			_overrideWireState = null;
			
			_camera = null;
			_clearColor = new Color( 1, 1, 1, 1 );
			_clearDepth = 1;
			_clearStencil = 0;
			
			_allowRed = true;
			_allowGreen = true;
			_allowBlue = true;
			_allowAlpha = true;
			
			msRenderers[ this ] = this;
		}
		
		public function terminate(): void
		{
			_defaultAlphaState.dispose();
			_defaultCullState.dispose();
			_defaultDepthState.dispose();
			_defaultOffsetState.dispose();
			_defaultStencilState.dispose();
			_defaultWireState.dispose();
			
			_defaultAlphaState = null;
			_defaultCullState = null;
			_defaultDepthState = null;
			_defaultOffsetState = null;
			_defaultStencilState = null;
			_defaultWireState = null;
			
			destroyAllVertexFormats();
			destroyAllVertexBuffers();
			destroyAllIndexBuffers();
			//destroyAllTexture1Ds();
			destroyAllTexture2Ds();
			destroyAllTexture3Ds();
			destroyAllTextureCubes();
			destroyAllTextureRectangles();
			destroyAllRenderTargets();
			destroyAllVertexShaders();
			destroyAllPixelShaders();
			
			msRenderers[ this ] = null;
		}
		
		
		[Inline]
		public final function get width(): int
		{
			return _width;
		}
		
		[Inline]
		public final function get height(): int
		{
			return _height;
		}
		
		[Inline]
		public final function get colorFormat(): TextureFormat
		{
			return _colorFormat;
		}
		
		[Inline]
		public final function get depthStencilFormat(): TextureFormat
		{
			return _depthStencilFormat;
		}
		
		[Inline]
		public final function get numMultiSamples(): int
		{
			return _numMultiSamples;
		}
		
		
		//{region vertex format
		public function bindVertexFormat( vFormat: VertexFormat ): void
		{
			if ( !_vertexFormats[ vFormat ] )
			{
				_vertexFormats[ vFormat ] = new CPdrVertexFormat( this, vFormat );
			}
		}
		
		public static function bindAllVertexFormat( vFormat: VertexFormat ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindVertexFormat( vFormat );
			}
		}
		
		public function unbindVertexFormat( vFormat: VertexFormat ): void
		{
			_vertexFormats[ vFormat ] = null;
		}
		
		public static function unbindAllVertexFormat(vFormat:VertexFormat ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindVertexFormat( vFormat );
			}
		}
		
		public function enableVertexFormat( vFormat: VertexFormat ): void
		{
			if ( !_vertexFormats[ vFormat ] )
			{
				_vertexFormats[ vFormat ] = new CPdrVertexFormat( this, vFormat );
			}
			_vertexFormats[ vFormat ].enable( this );
		}
		
		public function disableVertexFormat( vFormat: VertexFormat ): void
		{
			if ( _vertexFormats[ vFormat ] )
			{
				_vertexFormats[ vFormat ].disable( this );
			}
		}
		//}
		
		//{region vertex buffer
		public function bindVertexBuffer( vBuffer: VertexBuffer ): void
		{
			if ( !_vertexBuffers[ vBuffer ] )
			{
				_vertexBuffers[ vBuffer ] = new CPdrVertexBuffer( this, vBuffer );
			}
		}
		
		public static function bindAllVertexBuffer( vBuffer: VertexBuffer ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindVertexBuffer( vBuffer );
			}
		}
		
		public function unbindVertexBuffer( vBuffer: VertexBuffer ): void
		{
			_vertexBuffers[ vBuffer ] = null;
		}
		
		public static function unbindAllVertexBuffer( vBuffer: VertexBuffer ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindVertexBuffer( vBuffer );
			}
		}
		
		public function enableVertexBuffer( vBuffer: VertexBuffer, streamIndex: uint = 0, offset: uint = 0): void
		{
			if ( !_vertexBuffers[ vBuffer ] )
			{
				_vertexBuffers[ vBuffer ] = new CPdrVertexBuffer( this, vBuffer );
			}
			_vertexBuffers[ vBuffer ].enable( this, vBuffer.elementSize, streamIndex, offset );
		}
		
		public function disableVertexBuffer( vBuffer: VertexBuffer, streamIndex: uint = 0 ): void
		{
			if ( _vertexBuffers[ vBuffer ] )
			{
				_vertexBuffers[ vBuffer ].disable( this, streamIndex );
			}
		}
		
		public function lockVertexbuffer( vBuffer: VertexBuffer, mode: BufferLockingType ): void
		{
			if ( !_vertexBuffers[ vBuffer ] )
			{
				_vertexBuffers[ vBuffer ] = new CPdrVertexBuffer( this, vBuffer );
			}
			_vertexBuffers[ vBuffer ].lock( mode );
		}
		
		public function unlockVertexBuffer( vBuffer: VertexBuffer, mode: BufferLockingType ): void
		{
			if ( _vertexBuffers[ vBuffer ] )
			{
				_vertexBuffers[ vBuffer ].unlock();
			}
		}
		
		public function updateVertexBuffer( vBuffer: VertexBuffer ): void
		{
			_vertexBuffers[ vBuffer ] = new CPdrVertexBuffer( this, vBuffer );
		}
		
		public static function updateAllVertexBuffer( vBuffer: VertexBuffer ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.updateVertexBuffer( vBuffer );
			}
		}
		
		//}
		
		//{region index buffer
		public function bindIndexBuffer( iBuffer: IndexBuffer ): void
		{
			if ( !_indexBuffers[ iBuffer ] )
			{
				_indexBuffers[ iBuffer ] = new CPdrIndexBuffer( this, iBuffer );
			}
		}
		
		public static function bindAllIndexBuffer( iBuffer: IndexBuffer ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindIndexBuffer( iBuffer );
			}
		}
		
		public function unbindIndexBuffer( iBuffer: IndexBuffer ): void
		{
			_indexBuffers[ iBuffer ] = null;
		}
		
		public static function unbindAllIndexBuffer( iBuffer: IndexBuffer ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindIndexBuffer( iBuffer );
			}
		}
		
		public function enableIndexBuffer( iBuffer: IndexBuffer ): void
		{
			if ( !_indexBuffers[ iBuffer ] )
			{
				_indexBuffers[ iBuffer ] = new CPdrIndexBuffer( this, iBuffer );
			}
			_indexBuffers[ iBuffer ].enable( this );
		}
		
		public function disableIndexBuffer( iBuffer: IndexBuffer ): void
		{
			if ( _indexBuffers[ iBuffer ] )
			{
				_indexBuffers[ iBuffer ].disable( this );
			}
		}
		
		public function lockIndexBuffer( iBuffer: IndexBuffer, mode: BufferLockingType ): void
		{
			if ( !_indexBuffers[ iBuffer ] )
			{
				_indexBuffers[ iBuffer ] = new CPdrIndexBuffer( this, iBuffer );
			}
			_indexBuffers[ iBuffer ].lock( mode );
		}
		
		public function unlockIndexBuffer( iBuffer: IndexBuffer ): void
		{
			if ( _indexBuffers[ iBuffer ] )
			{
				_indexBuffers[ iBuffer ].unlock();
			}
		}
		
		public function updateIndexBuffer( iBuffer: IndexBuffer ): void
		{
			_indexBuffers[ iBuffer ] = new CPdrIndexBuffer( this, iBuffer );
		}
		
		public static function updateAllIndexBuffer( iBuffer: IndexBuffer ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.updateIndexBuffer( iBuffer );
			}
		}
		//}
		
		//{region texture 1d (not yet implemented)
		/*
		public function bindTexture1D( texture: Texture1D ): void
		{
			
		}
		
		public static function bindAllTexture1D( texture: Texture1D ): void
		{
			
		}
		
		public function unbindTexture1D( texture: Texture1D ): void
		{
			
		}
		
		public static function unbindAllTexture1D( texture: Texture1D ): void
		{
			
		}
		
		public function enableTexture1D( texture: Texture1D, textureUnit: int ): void
		{
			
		}
		
		public function disableTexture1D( texture: Texture1D, textureUnit: int ): void
		{
			
		}
		
		public function lockTexture1D( texture: Texture1D, textureUnit: int, mode: BufferLockingType ): void
		{
			
		}
		
		public function unlockTexture1D( texture: Texture1D, textureUnit: int ): void
		{
			
		}
		
		public function updateTexture1D( texture: Texture1D, textureUnit: int ): void
		{
			
		}
		
		public static function updateAllTexture1D( iBuffer: Texture1D, textureUnit: int ): void
		{
			
		}
		*/
		//}
		
		//{
		public function bindTexture2D( texture: Texture2D ): void
		{
			if ( !_texture2Ds[ texture ] )
			{
				_texture2Ds[ texture ] = new CPdrTexture2D( this, texture );
			}
		}
		
		public static function bindAllTexture2D( texture: Texture2D ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindTexture2D( texture );
			}
		}
		
		public function unbindTexture2D( texture: Texture2D ): void
		{
			_texture2Ds[ texture ] = null;
		}
		
		public static function unbindAllTexture2D( texture: Texture2D ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindTexture2D( texture );
			}
		}
		
		public function enableTexture2D( texture: Texture2D, textureUnit: int ): void
		{
			if ( !_texture2Ds[ texture ] )
			{
				_texture2Ds[ texture ] = new CPdrTexture2D( this, texture );
			}
			_texture2Ds[ texture ].enable( this, textureUnit );
		}
		
		public function disableTexture2D( texture: Texture2D, textureUnit: int ): void
		{
			if ( _texture2Ds[ texture ] )
			{
				_texture2Ds[ texture ].disable( this, textureUnit );
			}
		}
		
		public function lockTexture2D( texture: Texture2D, textureUnit: int, mode: BufferLockingType ): void
		{
			
		}
		
		public function unlockTexture2D( texture: Texture2D, textureUnit: int ): void
		{
			
		}
		
		public function updateTexture2D( texture: Texture2D, textureUnit: int ): void
		{
			_texture2Ds[ texture ] = new CPdrTexture2D( this, texture );
		}
		
		public static function updateAllTexture2D( texture: Texture2D, textureUnit: int ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.updateTexture2D( texture, textureUnit );
			}
		}
		//}
		
		//{region texture 3d (not yet implemented)
		public function bindTexture3D( texture: Texture3D ): void
		{
			if ( !_texture3Ds[ texture ] )
			{
				_texture3Ds[ texture ] = new CPdrTexture3D( this, texture );
			}
		}
		
		public static function bindAllTexture3D( texture: Texture3D ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindTexture3D( texture );
			}
		}
		
		public function unbindTexture3D( texture: Texture3D ): void
		{
			_texture3Ds[ texture ] = null;
		}
		
		public static function unbindAllTexture3D( texture: Texture3D ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindTexture3D( texture );
			}
		}
		
		public function enableTexture3D( texture: Texture3D, textureUnit: int ): void
		{
			if ( !_texture3Ds[ texture ] )
			{
				_texture3Ds[ texture ] = new CPdrTexture3D( this, texture );
			}
			_texture3Ds[ texture ].enable( this, textureUnit );
		}
		
		public function disableTexture3D( texture: Texture3D, textureUnit: int ): void
		{
			if ( _texture3Ds[ texture ] )
			{
				_texture3Ds[ texture ].disable( this, textureUnit );
			}
		}
		
		public function lockTexture3D( texture: Texture3D, textureUnit: int, mode: BufferLockingType ): void
		{
			
		}
		
		public function unlockTexture3D( texture: Texture3D, textureUnit: int ): void
		{
			
		}
		
		public function updateTexture3D( texture: Texture3D, textureUnit: int ): void
		{
			_texture3Ds[ texture ] = new CPdrTexture3D( this, texture );
		}
		
		public static function updateAllTexture3D( texture: Texture3D, textureUnit: int ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.updateTexture3D( texture, textureUnit );
			}
		}
		//}
		
		//{region texture cube (not yet implemented)
		public function bindTextureCube( texture: TextureCube ): void
		{
			if ( !_textureCubes[ texture ] )
			{
				_textureCubes[ texture ] = new CPdrTextureCube( this, texture );
			}
		}
		
		public static function bindAllTextureCube( texture: TextureCube ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindTextureCube( texture );
			}
		}
		
		public function unbindTextureCube( texture: TextureCube ): void
		{
			_textureCubes[ texture ] = null;
		}
		
		public static function unbindAllTextureCube( texture: TextureCube ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindTextureCube( texture );
			}
		}
		
		public function enableTextureCube( texture: TextureCube, textureUnit: int ): void
		{
			if ( !_textureCubes[ texture ] )
			{
				_textureCubes[ texture ] = new CPdrTextureCube( this, texture );
			}
			_textureCubes[ texture ].enable( this, textureUnit );
		}
		
		public function disableTextureCube( texture: TextureCube, textureUnit: int ): void
		{
			if ( _textureCubes[ texture ] )
			{
				_textureCubes[ texture ].disable( this, textureUnit );
			}
		}
		
		public function lockTextureCube( texture: TextureCube, face: int, level: int, mode: BufferLockingType ): void
		{
			
		}
		
		public function unlockTextureCube( texture: TextureCube, face: int, level: int ): void
		{
			
		}
		
		public function updateTextureCube( texture: TextureCube, face: int, level: int ): void
		{
			
		}
		
		public static function updateAllTextureCube( iBuffer: TextureCube, face: int, level: int ): void
		{
			
		}
		//}
		
		
		
		
		//{region texture rectangle
		public function bindTextureRectangle( texture: TextureRectangle ): void
		{
			if ( !_textureRectangles[ texture ] )
			{
				_textureRectangles[ texture ] = new CPdrTextureRectangle( this, texture );
			}
		}
		
		public static function bindAllTextureRectangle( texture: TextureRectangle ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindTextureRectangle( texture );
			}
		}
		
		public function unbindTextureRectangle( texture: TextureRectangle ): void
		{
			_textureRectangles[ texture ] = null;
		}
		
		public static function unbindAllTextureRectangle( texture: TextureRectangle ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindTextureRectangle( texture );
			}
		}
		
		public function enableTextureRectangle( texture: TextureRectangle, textureUnit: int ): void
		{
			if ( !_textureRectangles[ texture ] )
			{
				_textureRectangles[ texture ] = new CPdrTextureRectangle( this, texture );
			}
			_textureRectangles[ texture ].enable( this, textureUnit );
		}
		
		public function disableTextureRectangle( texture: TextureRectangle, textureUnit: int ): void
		{
			if ( _texture2Ds[ texture ] )
			{
				_texture2Ds[ texture ].disable( this, textureUnit );
			}
		}
		
		public function lockTextureRectangle( texture: TextureRectangle, textureUnit: int, mode: BufferLockingType ): void
		{
			
		}
		
		public function unlockTextureRectangle( texture: TextureRectangle, textureUnit: int ): void
		{
			
		}
		
		public function updateTextureRectangle( texture: TextureRectangle, textureUnit: int ): void
		{
			_textureRectangles[ texture ] = new CPdrTextureRectangle( this, texture );
		}
		
		public static function updateAllTextureRectangle( texture: TextureRectangle, textureUnit: int ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.updateTextureRectangle( texture, textureUnit );
			}
		}
		//}
		
		
		
		
		//{region render target
		public function bindRenderTarget( renderTarget: RenderTarget ): void
		{
			if ( !_renderTargets[ renderTarget ] )
			{
				_renderTargets[ renderTarget ] = new CPdrRenderTarget( this, renderTarget );
			}
		}
		
		public static function bindAllRenderTarget( renderTarget: RenderTarget ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindRenderTarget( renderTarget );
			}
		}
		
		public function unbindRenderTarget( renderTarget: RenderTarget ): void
		{
			_renderTargets[ renderTarget ] = null;
		}
		
		public static function unbindAllRenderTarget( renderTarget:RenderTarget ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindRenderTarget( renderTarget );
			}
		}
		
		public function enableRenderTarget( renderTarget: RenderTarget ): void
		{
			if ( !_renderTargets[ renderTarget ] )
			{
				_renderTargets[ renderTarget ] = new CPdrRenderTarget( this, renderTarget );
			}
			_renderTargets[ renderTarget ].enable( this );
		}
		
		public function disableRenderTarget( renderTarget: RenderTarget ): void
		{
			if ( _renderTargets[ renderTarget ] )
			{
				_renderTargets[ renderTarget ].disable( this );
			}
		}
		
		public function readColor( i: int, renderTarget: RenderTarget, texture: TextureRectangle ): void
		{
			for ( var target:* in _renderTargets )
			{
				target.readColor( i, this, texture );
			}
		}
		//}
		
		//{region vertex shader
		public function bindVertexShader( vShader: VertexShader ): void
		{
			if ( !_vertexShaders[ vShader ] )
			{
				_vertexShaders[ vShader ] = new CPdrVertexShader( this, vShader );
			}
		}
		
		public static function bindAllVertexShader( vShader: VertexShader ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindVertexShader( vShader );
			}
		}
		
		public function unbindVertexShader( vShader: VertexShader ): void
		{
			if ( _vertexShaders[ vShader ] )
			{
				_vertexShaders[ vShader ] = null;
			}
		}
		
		public static function unbindAllVertexShader( vShader: VertexShader ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindVertexShader( vShader );
			}
		}
		
		public function enableVertexShader( vShader: VertexShader, parameters: ShaderParameters ): void
		{
			if ( !_vertexShaders[ vShader ] )
			{
				_vertexShaders[ vShader ] = new CPdrVertexShader( this, vShader );
			}
			_vertexShaders[ vShader ].enable( this, vShader, parameters );
		}
		
		public function disableVertexShader( vShader:VertexShader, parameters: ShaderParameters ): void
		{
			if ( _vertexShaders[ vShader ] )
			{
				_vertexShaders[ vShader ].disable( this, vShader, parameters );
			}
		}
		//}
		
		//{region pixel shader
		public function bindPixelShader( pShader: PixelShader ): void
		{
			if ( !_pixelShaders[ pShader ] )
			{
				_pixelShaders[ pShader ] = new CPdrPixelShader( this, pShader );
			}
		}
		
		public static function bindAllPixelShader( pShader: PixelShader ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.bindPixelShader( pShader );
			}
		}
		
		public function unbindPixelShader( pShader: PixelShader ): void
		{
			if ( _pixelShaders[ pShader ] )
			{
				_pixelShaders[ pShader ] = null;
			}
		}
		
		public static function unbindAllPixelShader( pShader: PixelShader ): void
		{
			for each( var renderer: Renderer in msRenderers )
			{
				renderer.unbindPixelShader( pShader );
			}
		}
		
		public function enablePixelShader( pShader: PixelShader, parameters: ShaderParameters ): void
		{
			if ( !_pixelShaders[ pShader ] )
			{
				_pixelShaders[ pShader ] = new CPdrPixelShader( this, pShader );
			}
			_pixelShaders[ pShader ].enable( this, pShader, parameters );
		}
		
		public function disablePixelShader( pShader: PixelShader, parameters: ShaderParameters ): void
		{
			if ( _pixelShaders[ pShader ] )
			{
				_pixelShaders[ pShader ].disable( this, pShader, parameters );
			}
		}
		//}
		
		
		
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
		
		
		
		
		[Inline]
		public final function set camera( camera: Camera ): void
		{
			_camera = camera;
		}
		
		[Inline]
		public final function get camera(): Camera
		{
			return _camera;
		}
		
		[Inline]
		public final function get viewMatrix(): HMatrix
		{
			return _camera.viewMatrix;
		}
		
		[Inline]
		public final function get projectionMatrix(): HMatrix
		{
			return _camera.projectionMatrix;
		}
		
		[Inline]
		public final function get postProjectionMatrix(): HMatrix
		{
			return _camera.postProjectionMatrix;
		}
		
		public function getPickRay( x: int, y: int, origin: APoint, direction: AVector ): Boolean
		{
			if ( !_camera )
			{
				throw new Error( "A camera is needed to get a pick ray." );
			}
			var viewport: Array = getViewport();
			var viewX: int = viewport[ 0 ];
			var viewY: int = viewport[ 1 ];
			var viewW: int = viewport[ 2 ];
			var viewH: int = viewport[ 3 ];
			
			if ( x < viewX || x > viewX + viewW || y < viewY || y > viewY + viewH )
			{
				return false;
			}
			
			var r: Number = (x - viewX) / viewW;
			var u: Number = (y - viewY) / viewH;
			
			var rBlend: Number = ( 1 - r ) * _camera.rMin + r * _camera.rMax;
			var uBlend: Number = ( 1 - u ) * _camera.uMin + u * _camera.uMax;
			
			var point: APoint;
			var vector: AVector;
			if ( _camera.isPerspective )
			{
				point = _camera.position;
				
				origin.set( point.x, point.y, point.z );
				vector = _camera.dVector.scale( _camera.dMin ).add( _camera.rVector.scale( rBlend ) ).add ( _camera.uVector.scale( uBlend ) );
				vector.normalize();
				
				direction.set( vector.x, vector.y, vector.z );
				
			}
			else
			{
				point = _camera.position.addAVector( _camera.dVector.scale( _camera.dMin ) ).addAVector( _camera.rVector.scale( rBlend ) ).addAVector( _camera.uVector.scale( uBlend ) );
				origin.set( point.x, point.y, point.z );
				
				vector = _camera.dVector;
				direction.set( vector.x, vector.y, vector.z );
			}
			return true;
		}
		
		
		[Inline]
		public final function set clearColor( clearColor: Color ): void
		{
			_clearColor = clearColor;
		}
		
		[Inline]
		public final function get clearColor( ): Color
		{
			return _clearColor;
		}
		
		[Inline]
		public final function set clearDepth( clearDepth: Number ): void
		{
			_clearDepth = clearDepth;
		}
		
		[Inline]
		public final function get clearDepth(): Number
		{
			return _clearDepth;
		}
		
		[Inline]
		public final function set clearStencil( clearStencil: uint ): void
		{
			_clearStencil = clearStencil;
		}
		
		[Inline]
		public final function get clearStencil(): uint
		{
			return _clearStencil;
		}
		
		[Inline]
		public final function get colorMask( ): Array 
		{
			return [
					_allowRed,
					_allowGreen,
					_allowBlue,
					_allowAlpha
				];
		}
		
		
		//{region override global states
		[Inline]
		public final function set overrideAlphaState( alphaState: AlphaState ): void
		{
			_overrideAlphaState = alphaState;
			if ( alphaState )
			{
				this.alphaState = alphaState;
			}
			else
			{
				this.alphaState = _defaultAlphaState;
			}
		}
		
		[Inline]
		public final function set overrideCullState( cullState: CullState ): void
		{
			_overrideCullState = cullState;
			if ( cullState )
			{
				this.cullState = cullState;
			}
			else
			{
				this.cullState = _defaultCullState;
			}
		}
		
		[Inline]
		public final function set overrideDepthState( depthState: DepthState ): void
		{
			_overrideDepthState = depthState;
			if ( depthState )
			{
				this.depthState = depthState;
			}
			else
			{
				this.depthState = _defaultDepthState;
			}
		}
		
		[Inline]
		public final function set overrideOffsetState( offsetState: OffsetState ): void
		{
			_overrideOffsetState = offsetState;
			if ( offsetState )
			{
				this.offsetState = offsetState;
			}
			else
			{
				this.offsetState = _defaultOffsetState;
			}
		}
		
		[Inline]
		public final function set overrideStencilState( stencilState: StencilState ): void
		{
			_overrideStencilState = stencilState;
			if ( stencilState )
			{
				this.stencilState = stencilState;
			}
			else
			{
				this.stencilState = _defaultStencilState;
			}
		}
		
		[Inline]
		public final function set overrideWireState( wireState: WireState ): void
		{
			_overrideWireState = wireState;
			if ( wireState )
			{
				this.wireState = wireState;
			}
			else
			{
				this.wireState = _defaultWireState;
			}
		}
		
		[Inline]
		public final function get overrideAlphaState(): AlphaState
		{
			return _overrideAlphaState;
		}
		
		[Inline]
		public final function get overrideCullState(): CullState
		{
			return _overrideCullState;
		}
		
		[Inline]
		public final function get overrideDepthState(): DepthState
		{
			return _overrideDepthState;
		}
		
		[Inline]
		public final function get overrideOffsetState(): OffsetState
		{
			return _overrideOffsetState;
		}
		
		[Inline]
		public final function get overrideStencilState(): StencilState
		{
			return _overrideStencilState;
		}
		
		[Inline]
		public final function get overrideWireState(): WireState
		{
			return _overrideWireState;
		}
		
		[Inline]
		public final function set reverseCullOrder( reverseCullOrder: Boolean ): void
		{
			_reverseCullOrder = reverseCullOrder;
		}
		
		[Inline]
		public final function get reverseCullOrder(): Boolean
		{
			return _reverseCullOrder;
		}
		//}
		
		public function drawVisibleSet( visibleSet: VisibleSet, globalEffect: GlobalEffect = null ): void
		{
			if ( !globalEffect )
			{
				var numVisible: int = visibleSet.numVisible;
				for ( var i: int = 0; i < numVisible; ++i )
				{
					var visual: Visual = visibleSet.getVisibleAt( i ) as Visual;
					var instance: VisualEffectInstance = visual.effect;
					drawVisual( visual, instance );
				}
			}
			else
			{
				globalEffect.draw( this, visibleSet );
			}
		}
		
		public function drawVisual( visual: Visual, instance: VisualEffectInstance = null ): void
		{
			if ( !instance )
			{
				instance = visual.effect;
			}
			
			if ( !instance )
			{
				throw new Error( "The visual object must have an effect instance." );
			}
			
			var vFormat: VertexFormat = visual.vertexFormat;
			var vBuffer: VertexBuffer = visual.vertexBuffer;
			var iBuffer: IndexBuffer = visual.indexBuffer;
			
			enableVertexBuffer( vBuffer );
			enableVertexFormat( vFormat );
			
			if ( iBuffer )
			{
				enableIndexBuffer( iBuffer );
			}
			
			var numPasses: int = instance.numPasses;
			for ( var i: int = 0; i < numPasses; ++i )
			{
				var pass:VisualPass = instance.getPass( i );
				var vParams: ShaderParameters = instance.getVertexParameters( i );
				var pParams: ShaderParameters = instance.getPixelParameters( i );
				var vShader: VertexShader = pass.vertexShader;
				var pShader: PixelShader = pass.pixelShader;
				
				vParams.updateConstants( visual, _camera );
				pParams.updateConstants( visual, _camera );
				
				alphaState = pass.alphaState;
				cullState = pass.cullState;
				depthState = pass.depthState;
				offsetState = pass.offsetState;
				stencilState = pass.stencilState;
				wireState = pass.wireState;
				
				enableVertexShader( vShader, vParams );
				enablePixelShader( pShader, pParams );
				
				drawPrimitive( visual );
				
				disableVertexShader( vShader, vParams );
				disablePixelShader( pShader, pParams );
				
				//TODO decide to reset the state after drawing
				//alphaState = _defaultAlphaState;
				//cullState = _defaultCullState;
				//depthState = _defaultDepthState;
				//offsetState = _defaultOffsetState;
				//stencilState = _defaultStencilState;
				//wireState = _defaultWireState;
				
				if ( iBuffer )
				{
					disableIndexBuffer( iBuffer );
				}
				
				disableVertexFormat( vFormat );
				disableVertexBuffer( vBuffer );
			}
			
		}
		
		
		
		private function destroyAllVertexFormats(): void
		{
			for each( var key: VertexFormat in _vertexFormats )
			{
				_vertexFormats[ key ].dispose();
				_vertexFormats[ key ] = null;
			}
		}
		
		private function destroyAllVertexBuffers(): void
		{
			for each( var key: VertexBuffer in _vertexBuffers )
			{
				_vertexBuffers[ key ].dispose();
				_vertexBuffers[ key ] = null;
			}
		}
		
		private function destroyAllIndexBuffers(): void
		{
			for each( var key: IndexBuffer in _indexBuffers )
			{
				_indexBuffers[ key ].dispose();
				_indexBuffers[ key ] = null;
			}
		}
		/*
		private function destroyAllTexture1Ds(): void
		{
			for each( var key: Texture1D in _texture1Ds )
			{
				_texture1Ds[ key ].dispose();
				_texture1Ds[ key ] = null;
			}
		}
		*/
		private function destroyAllTexture2Ds(): void
		{
			for each( var key: Texture2D in _texture2Ds )
			{
				_texture2Ds[ key ].dispose();
				_texture2Ds[ key ] = null;
			}
		}
		
		private function destroyAllTexture3Ds(): void
		{
			for each( var key: Texture3D in _texture3Ds )
			{
				_texture3Ds[ key ].dispose();
				_texture3Ds[ key ] = null;
			}
		}
		
		private function destroyAllTextureCubes(): void
		{
			for each( var key: TextureCube in _textureCubes )
			{
				_textureCubes[ key ].dispose();
				_textureCubes[ key ] = null;
			}
		}
		
		private function destroyAllTextureRectangles(): void
		{
			for each( var key: TextureRectangle in _textureRectangles )
			{
				_textureRectangles[ key ].dispose();
				_textureRectangles[ key ] = null;
			}
		}
		
		private function destroyAllRenderTargets(): void
		{
			for each( var key: RenderTarget in _renderTargets )
			{
				_renderTargets[ key ].dispose();
				_renderTargets[ key ] = null;
			}
		}
		
		private function destroyAllVertexShaders(): void
		{
			for each ( var key: VertexShader in _vertexShaders )
			{
				_vertexShaders[ key ].dispose();
				_vertexShaders[ key ] = null;
			}
		}
		
		private function destroyAllPixelShaders(): void
		{
			for each( var key: PixelShader in _pixelShaders )
			{
				_pixelShaders[ key ].dispose();
				_pixelShaders[ key ] = null;
			}
		}
		
		
		
		
		
		
		//////////////////////////////////////////////////////////
		// platform dependent methods
		//////////////////////////////////////////////////////////
		public function set alphaState( alphaState: AlphaState ): void
		{
			throw new Error( "set alphaState must be overridden." );
		}
		
		public function set cullState( cullState: CullState ): void
		{
			throw new Error( "set cullState must be overridden." );
		}
		
		public function set depthState( depthState: DepthState ): void
		{
			throw new Error( "set depthState must be overridden" );
		}
		
		public function set offsetState( offsetState: OffsetState ): void
		{
			throw new Error( "set offsetState must be overridden" );
		}
		
		public function set stencilState( stencilState: StencilState ): void
		{
			throw new Error( "set stencilState must be overridden" );
		}
		
		public function set wireState( wireState: WireState ): void
		{
			throw new Error( "set wireState must be overridden" );
		}
		
		public function setViewport( x:int, y: int, width: int, height: int ): void
		{
			throw new Error( "setViewport must be overridden." );
		}
		
		public function getViewport(): Array
		{
			throw new Error( "getViewport must be overridden." );
		}
		
		public function setDepthRange( zMin: Number, zMax: Number ): void
		{
			throw new Error( "setDepthRange must be overridden." );
		}
		
		public function getDepthRange(): Array
		{
			throw new Error( "getDepthRange must be overridden." );
		}
		
		public function resize( width: int, height: int ): void
		{
			throw new Error( "resize must be overridden." );
		}
		
		public function clearColorBuffer( x: int = 0, y: int = 0, width: int = -1, height: int = -1 ): void
		{
			throw new Error( "clearColorBuffer must be overridden." );
		}
		
		public function clearDepthBuffer( x: int = 0, y: int = 0, width: int = -1, height: int = -1 ): void
		{
			throw new Error( "clearDepthBuffer must be overridden." );
		}
		
		public function clearStencilBuffer( x: int = 0, y: int = 0, width: int = -1, height: int = -1 ): void
		{
			throw new Error( "clearStencilBuffer must be overridden." );
		}
		
		public function clearBuffers( x: int = 0, y: int = 0, width: int = -1, height: int = -1 ): void
		{
			throw new Error( "clearBuffers must be overridden." );
		}
		
		public function displayColorBuffer(): void
		{
			throw new Error( "displayColorBuffer must be overridden." );
		}
		
		public function setColorMask( allowRed: Boolean, allowGreen: Boolean, allowBlue: Boolean, allowAlpha: Boolean ): void
		{
			throw new Error( "setColorMask must be overridden." );
		}
		
		public function preDraw(): Boolean
		{
			throw new Error( "preDraw must be overridden." );
		}
		
		public function postDraw(): void
		{
			throw new Error( "postDraw must be overridden." );
		}
		
		//TODO 2D drawing routines for text etc
		
		protected function drawPrimitive( visual: Visual ): void
		{
			throw new Error( "drawPrimitive must be overridden." );
		}
		
		// internal use only
		public function getResourceVertexFormat( vFormat: VertexFormat ): IVertexFormat
		{
			return _vertexFormats[ vFormat ];
		}
		
		public function getResourceVertexBuffer( vBuffer: VertexBuffer ): IVertexBuffer
		{
			return _vertexBuffers[ vBuffer ];
		}
		
		public function getResourceIndexBuffer( iBuffer: IndexBuffer ): IIndexBuffer
		{
			return _indexBuffers[ iBuffer ];
		}
		/*
		public function getResourceTexture1D( texture: Texture1D ): ITexture1D
		{
			return _texture1Ds[ texture ];
		}
		*/
		public function getResourceTexture2D( texture: Texture2D ): ITexture2D
		{
			return _texture2Ds[ texture ];
		}
		
		public function getResourceTexture3D( texture: Texture3D ): ITexture3D
		{
			return _texture3Ds[ texture ];
		}
		
		public function getResouceTextureCube( texture: TextureCube ): ITextureCube
		{
			return _textureCubes[ texture ];
		}
		
		public function getResourceRenderTarget( renderTarget: RenderTarget ): IRenderTarget
		{
			return _renderTargets[ renderTarget ];
		}
		
		public function getResourceVertexShader( vShader: VertexShader ): IVertexShader
		{
			return _vertexShaders[ vShader ];
		}
		
		public function getResourcePixelShader( pShader: PixelShader ): IPixelShader
		{
			return _pixelShaders[ pShader ];
		}
		
		[Inline]
		public function inTextureRectangleMap( texture: TextureRectangle ): Boolean
		{
			return _textureRectangles[ texture ] != null;
		}
		
		[Inline]
		public function insertInTextureRectangleMap( texture: TextureRectangle, platformTexture: * ): void
		{
			_textureRectangles[ texture ] = platformTexture;
		}
		
		
	}

}