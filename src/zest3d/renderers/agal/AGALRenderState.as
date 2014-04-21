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
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.renderers.agal.AGALMapping;
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
	public class AGALRenderState implements IDisposable 
	{
		// internal use only
		
		// alpha state
		public var _alphaBlendEnabled: Boolean;
		public var _alphaSrcBlend: String;
		public var _alphaDstBlend: String;
		public var _alphaCompareEnabled: Boolean;
		public var _compareFunction: String;
		public var _alphaReference: Number;
		public var _blendColor: Array;
		
		// cull state
		public var _cullEnabled: Boolean;
		public var _ccwOrder: Boolean;
		
		// depth state
		public var _depthEnabled: Boolean;
		public var _depthWriteEnabled: Boolean;
		public var _depthCompareFunction: String;
		
		// offset state
		public var _fillEnabled: Boolean;
		public var _lineEnabled: Boolean;
		public var _pointEnabled: Boolean;
		public var _offsetScale: Number;
		public var _offsetBias: Number;
		
		// stencil state
		public var _stencilEnabled: Boolean;
		public var _stencilCompareFunction: String;
		public var _stencilReference: uint;
		public var _stencilMask: uint;
		public var _stencilWriteMask: uint;
		public var _stencilOnFail: String;
		public var _stencilOnZFail: String;
		public var _stencilOnZPass: String;
		
		// wire state
		public var _wireEnabled: Boolean
		
		public var _context: Context3D;
		
		public function AGALRenderState( context: Context3D )
		{
			_context = context;
		}
		
		public function dispose(): void
		{
			_context = null;
		}
		
		public function initialize( alphaState:AlphaState, cullState: CullState, depthState:DepthState,
								offsetState: OffsetState, stencilState: StencilState, wireState: WireState ): void
		{
			// alpha state
			_alphaBlendEnabled = alphaState.blendEnabled;
			_alphaSrcBlend = AGALMapping.alphaSrcBlend[ alphaState.srcBlend.index ];
			_alphaDstBlend = AGALMapping.alphaDstBlend[ alphaState.dstBlend.index ];
			_alphaCompareEnabled = alphaState.compareEnabled;
			_compareFunction = AGALMapping.alphaCompare[ alphaState.compare.index ];
			
			_alphaReference = alphaState.reference;
			_blendColor = alphaState.constantColor;
			
			if ( _alphaBlendEnabled )
			{
				//glEnable(GL_BLEND) // NOTE: ONE for premultiplied alpha
				_context.setBlendFactors( _alphaSrcBlend, _alphaDstBlend );
			}
			else
			{
				//glDisable(GL_BLEND);
				_context.setBlendFactors( Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO );	
			}
			//glBlendFunc(alphaSrcBlend, GL_ONE_MINUS_SRC_ALPHA);
			
			// TODO replicate glEnable( GL_ALPHA_TEST );
			if ( _alphaCompareEnabled )
			{
				//glEnable( GL_ALPHA_TEST );
				_context.setDepthTest( true, _compareFunction );
			}
			else
			{
				//glDisable( GL_ALPHA_TEST );
				_context.setDepthTest( true, Context3DCompareMode.NEVER );
			}
			
			// cull state
			_cullEnabled = cullState.enabled;
			_ccwOrder = cullState.ccwOrder;
			
			if ( _cullEnabled )
			{
				if ( _ccwOrder )
				{
					_context.setCulling( Context3DTriangleFace.FRONT );
				}
				else
				{
					_context.setCulling( Context3DTriangleFace.BACK );
				}
			}
			else
			{
				_context.setCulling( Context3DTriangleFace.NONE );
			}
			
			// depth state
			_depthEnabled = depthState.enabled;
			_depthWriteEnabled = depthState.writable;
			_depthCompareFunction = AGALMapping.depthCompare[ depthState.compare.index ];
			
			//TODO investigate here depthstates
			
			if ( _depthEnabled )
			{
				_context.setDepthTest( _depthWriteEnabled, _depthCompareFunction );
			}
			else
			{
				_context.setDepthTest( false, Context3DCompareMode.LESS );
			}
			
			
			
			/*
			// TODO investigate offsetState
			*/
			
			/*
			// stencil state
			_stencilEnabled = stencilState.enabled;
			_stencilCompareFunction = AGALMapping.stencilCompare[ stencilState.compare.index ];
			_stencilReference = stencilState.reference;
			_stencilMask = stencilState.mask;
			_stencilWriteMask = stencilState.writeMask;
			_stencilOnFail = AGALMapping.stencilOperation[ stencilState.onFail.index ];
			_stencilOnZFail = AGALMapping.stencilOperation[ stencilState.onZFail.index ];
			_stencilOnZPass = AGALMapping.stencilOperation[ stencilState.onZPass.index ];
			
			
			// TODO investigate setStencilActions( triangleFace ...
			
			if ( _stencilEnabled )
			{
				_context.setStencilActions( Context3DTriangleFace.FRONT_AND_BACK,
											_stencilCompareFunction,
											_stencilOnZPass,
											_stencilOnZFail,
											_stencilOnFail );
				_context.setStencilReferenceValue( _stencilReference, _stencilMask, _stencilWriteMask );
			}
			else
			{
				
				_context.setStencilActions( Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP );
				_context.setStencilReferenceValue( _stencilReference );
			}
			//TODO investigate wireState
			// i.e. can we use a shader to achieve something similar?
			*/
		}
		
	}

}