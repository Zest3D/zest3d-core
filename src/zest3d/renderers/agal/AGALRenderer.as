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
package zest3d.renderers.agal 
{
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTriangleFace;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.globaleffects.GlobalEffect;
	import zest3d.renderers.agal.pdr.AGALIndexBuffer;
	import zest3d.renderers.agal.pdr.AGALPixelShader;
	import zest3d.renderers.agal.pdr.AGALRenderTarget;
	import zest3d.renderers.agal.pdr.AGALTexture2D;
	import zest3d.renderers.agal.pdr.AGALTexture3D;
	import zest3d.renderers.agal.pdr.AGALTextureCube;
	import zest3d.renderers.agal.pdr.AGALTextureRectangle;
	import zest3d.renderers.agal.pdr.AGALVertexBuffer;
	import zest3d.renderers.agal.pdr.AGALVertexFormat;
	import zest3d.renderers.agal.pdr.AGALVertexShader;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.TextureFormat;
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.VertexBuffer;
	import zest3d.scenegraph.enum.PrimitiveType;
	import zest3d.scenegraph.Visual;
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
	public class AGALRenderer extends Renderer implements IDisposable 
	{
		
		public function AGALRenderer( input: AGALRendererInput, width: int, height: int, colorFormat: TextureFormat, depthStencilFormat: TextureFormat, numMultiSamples: int ) 
		{			
			super( GlobalEffect, AGALIndexBuffer, AGALPixelShader, AGALRenderTarget,
				/*AGALTexture1D,*/ AGALTexture2D, AGALTexture3D, AGALTextureCube, AGALTextureRectangle,
				AGALVertexBuffer, AGALVertexFormat, AGALVertexShader );
			
			_initialize( width, height, colorFormat, depthStencilFormat, numMultiSamples ); // sets and stores application properties
			
			_data = new AGALRendererData( input, width, height, colorFormat, depthStencilFormat, numMultiSamples );
			
			data.currentRS.initialize( _defaultAlphaState, _defaultCullState, _defaultDepthState,
									   _defaultOffsetState, _defaultStencilState, _defaultWireState );
			
			data.context.configureBackBuffer( width, height, numMultiSamples );
		}
		
		override public function dispose():void 
		{
			data.dispose();
			_data = null;
			terminate();
		}
		
		// helper method
		public function get data(): AGALRendererData
		{
			return _data as AGALRendererData;
		}
		
		override public function set alphaState( alphaState:AlphaState):void 
		{
			if ( !_overrideAlphaState )
			{
				_alphaState = alphaState;
			}
			else
			{
				_alphaState = _overrideAlphaState;
			}
			
			if (  _alphaState.blendEnabled )
			{
				var srcBlend: String = AGALMapping.alphaSrcBlend[ _alphaState.srcBlend.index ];
				var dstBlend: String = AGALMapping.alphaDstBlend[ _alphaState.dstBlend.index ];
				data.context.setBlendFactors( srcBlend, dstBlend );
			}
			else
			{
				data.context.setBlendFactors( Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO );
			}
			
			if ( _alphaState.compareEnabled )
			{
				var compare: String = AGALMapping.alphaCompare[ _alphaState.compare.index ];
				data.context.setDepthTest( true, compare );
			}
			else
			{
				data.context.setDepthTest( false, Context3DCompareMode.NEVER );
			}
		}
		
		override public function set cullState( cullState:CullState ):void 
		{
			if ( !_overrideCullState )
			{
				_cullState = cullState;
			}
			else
			{
				_cullState = _overrideCullState;
			}
			
			if ( _cullState.enabled )
			{
				if ( _cullState.ccwOrder )
				{
					data.context.setCulling(Context3DTriangleFace.FRONT );
				}
				else
				{
					data.context.setCulling(Context3DTriangleFace.BACK );
				}
			}
			else
			{
				data.context.setCulling(Context3DTriangleFace.NONE);
			}
		}
		
		override public function set depthState( depthState:DepthState):void 
		{
			
			if ( !_overrideDepthState )
			{
				_depthState = depthState;
			}
			else
			{
				_depthState = _overrideDepthState;
			}
			
			if ( _depthState.enabled )
			{
				var mask:Boolean = _depthState.writable;
				var compare:String = AGALMapping.depthCompare[ _depthState.compare.index ];
				data.context.setDepthTest( mask, compare );
			}
			else
			{
				data.context.setDepthTest( false, Context3DCompareMode.LESS );
			}
		}
		
		override public function set offsetState(offsetState:OffsetState):void 
		{
			
		}
		
		override public function set stencilState(stencilState:StencilState):void 
		{
			if ( !_overrideStencilState )
			{
				_stencilState = stencilState;
			}
			else
			{
				_stencilState = _overrideStencilState;
			}
			
			if ( _stencilState.enabled )
			{
				var compare:String = AGALMapping.stencilCompare[ _stencilState.compare.index ];
				var onZPass:String = AGALMapping.stencilOperation[ _stencilState.onZPass.index ];
				var onZFail:String = AGALMapping.stencilOperation[ _stencilState.onZFail.index ];
				var onFail:String = AGALMapping.stencilOperation[ _stencilState.onFail.index ];
				
				// TODO pass Context3DTriangleFace mapping
				data.context.setStencilReferenceValue( _stencilState.reference, _stencilState.mask, _stencilState.writeMask );
				data.context.setStencilActions( Context3DTriangleFace.FRONT_AND_BACK, compare, onZPass, onZFail, onFail );
			}
			else
			{
				data.context.setStencilReferenceValue( _stencilState.reference );
				data.context.setStencilActions( Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP );
			}
		}
		
		override public function set wireState(wireState:WireState):void 
		{
		}
		
		override public function setViewport(x:int, y:int, width:int, height:int):void 
		{
			_width = width;
			_height = height;
			if ( _camera )
			{
				var frustumFOV:Array = [];
				if ( _camera.getFrustumFOV( frustumFOV ) )
				{
					_camera.setFrustumFOV( frustumFOV[0], _width/_height, frustumFOV[2], frustumFOV[3] );
					data.context.configureBackBuffer( _width, _height, _numMultiSamples );
				}
			}
		}
		
		override public function getViewport():Array 
		{
			// TODO encapsulate a viewport rectangle
			return [0, 0, _width, _height];
		}
		
		override public function setDepthRange(zMin:Number, zMax:Number):void 
		{
			//data.context.
			//data.context.setStencilReferenceValue( 0, zMin, zMax );
		}
		
		override public function getDepthRange():Array 
		{
			//TODO calculate this
			//data.context.setStencilReferenceValue( 0, 0, 255 );
			return [ 0, 1 ];
		}
		
		override public function resize(width:int, height:int):void 
		{
			_width = width;
			_height = height;
			// glGetIntegerv(GL_VIEWPORT, param);
			// glViewport(param[0], param[1], width, height);
			setViewport( 0, 0, width, height );
		}
		
		override public function clearColorBuffer(x:int = 0, y:int = 0, width:int = -1, height:int = -1):void 
		{
			if ( width > 0 || height > 0 )
			{
				throw new Error( "Scissoring does not affect AGAL clear operations." );
			}
			data.context.clear( _clearColor.r, _clearColor.g, _clearColor.b, _clearColor.a );
		}
		
		override public function clearDepthBuffer(x:int = 0, y:int = 0, width:int = -1, height:int = -1):void
		{
			if ( width > 0 || height > 0 )
			{
				throw new Error( "Scissoring does not affect AGAL clear operations." );
			}
			//data.context.clear( null, null, null, null, _clearDepth, null, null );
		}
		
		override public function clearStencilBuffer(x:int = 0, y:int = 0, width:int = -1, height:int = -1):void
		{
			if ( width > 0 || height > 0 )
			{
				throw new Error( "Scissoring does not affect AGAL clear operations." );
			}
			//data.context.clear( null, null, null, null, null, null, _clearStencil );
		}
		
		override public function clearBuffers(x:int = 0, y:int = 0, width:int = -1, height:int = -1):void
		{
			if ( width > 0 || height > 0 )
			{
				throw new Error( "Scissoring does not affect AGAL clear operations." );
			}
			// TODO investigate the use of mask
			data.context.clear( _clearColor.r, _clearColor.g, _clearColor.b, _clearColor.a, _clearDepth, _clearStencil );
		}
		
		override public function setColorMask(allowRed:Boolean, allowGreen:Boolean, allowBlue:Boolean, allowAlpha: Boolean ):void 
		{
			_allowRed = allowRed;
			_allowGreen = allowGreen;
			_allowBlue = allowBlue;
			_allowAlpha = allowAlpha;
			
			data.context.setColorMask( _allowRed, _allowGreen, _allowBlue, _allowAlpha );
		}
		
		override public function preDraw():Boolean 
		{
			data.context.clear();
			return true;
		}
		
		override public function postDraw():void 
		{
		}
		
		override protected function drawPrimitive(visual:Visual):void 
		{
			var type: PrimitiveType = visual.primitiveType;
			var vBuffer: VertexBuffer = visual.vertexBuffer;
			var iBuffer:IndexBuffer = visual.indexBuffer;
			
			if ( type == PrimitiveType.TRIMESH ||
				 type == PrimitiveType.TRISTRIP ||
				 type == PrimitiveType.TRIFAN )
			{
				var numVertices: int = vBuffer.numElements;
				var numIndices: int = iBuffer.numElements;
				
				//TODO set ibuffer offsets etc in DRAW :D
				var indexType: String;
				if ( numVertices > 0 && numIndices > 0 )
				{
					if ( iBuffer.elementSize == 2 )
					{
						var agalIBuffer: AGALIndexBuffer = getResourceIndexBuffer( iBuffer ) as AGALIndexBuffer;
						data.context.drawTriangles( agalIBuffer.indexBuffer3D ); // TODO the offset an count
					}
					else
					{
						throw new Error( "Only element sizes of 2 bytes are supported. AGALRenderer::drawPrimitive()" );
					}
					
				}
			}
			else
			{
				throw new Error( "Currently supports meshes only." );
			}
		}
		
		override public function displayColorBuffer():void 
		{
			data.context.present();
		}
	}

}