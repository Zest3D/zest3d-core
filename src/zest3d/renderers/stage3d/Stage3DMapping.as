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
package zest3d.renderers.stage3d {
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Stage3DMapping 
	{
		
		public function Stage3DMapping() 
		{
			
		}
		
		public static const alphaSrcBlend: Array =
		[
			Context3DBlendFactor.ZERO,
			Context3DBlendFactor.ONE,
			Context3DBlendFactor.DESTINATION_COLOR,
			Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR,
			Context3DBlendFactor.SOURCE_ALPHA,
			Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA,
			Context3DBlendFactor.DESTINATION_ALPHA,
			Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,
			null, // SBM_SRC_ALPHA_SATURATE
			Context3DBlendFactor.SOURCE_COLOR,
			Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR,
			null,
			null
		];
		
		public static const alphaDstBlend: Array =
		[
			Context3DBlendFactor.ZERO,
			Context3DBlendFactor.ONE,
			Context3DBlendFactor.SOURCE_COLOR,
			Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR,
			Context3DBlendFactor.SOURCE_ALPHA,
			Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA,
			Context3DBlendFactor.DESTINATION_ALPHA,
			Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,
			Context3DBlendFactor.DESTINATION_COLOR,
			Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR,
			null,
			null
		];
		
		public static const alphaCompare: Array =
		[
			Context3DCompareMode.NEVER,
			Context3DCompareMode.LESS,
			Context3DCompareMode.EQUAL,
			Context3DCompareMode.LESS_EQUAL,
			Context3DCompareMode.GREATER,
			Context3DCompareMode.NOT_EQUAL,
			Context3DCompareMode.GREATER_EQUAL,
			Context3DCompareMode.ALWAYS
		];
		
		public static const depthCompare: Array =
		[
			Context3DCompareMode.NEVER,
			Context3DCompareMode.LESS,
			Context3DCompareMode.EQUAL,
			Context3DCompareMode.LESS_EQUAL,
			Context3DCompareMode.GREATER,
			Context3DCompareMode.NOT_EQUAL,
			Context3DCompareMode.GREATER_EQUAL,
			Context3DCompareMode.ALWAYS
		];
		
		public static const stencilCompare: Array =
		[
			Context3DCompareMode.NEVER,
			Context3DCompareMode.LESS,
			Context3DCompareMode.EQUAL,
			Context3DCompareMode.LESS_EQUAL,
			Context3DCompareMode.GREATER,
			Context3DCompareMode.NOT_EQUAL,
			Context3DCompareMode.GREATER_EQUAL,
			Context3DCompareMode.ALWAYS
		];
		
		// TODO add INCREMENT_WRAP & DECREMENT_WRAP
		public static const stencilOperation: Array =
		[
			Context3DStencilAction.KEEP,
			Context3DStencilAction.ZERO,
			Context3DStencilAction.SET,
			Context3DStencilAction.INCREMENT_SATURATE,
			Context3DStencilAction.DECREMENT_SATURATE,
			Context3DStencilAction.INVERT
		];
		
		public static const attributeChannels: Array =
		[
			0, 1, 2, 3, 4, 1, 2, 3, 4, 4, 1, 2, 4
		];
		
		public static const attributeType: Array =
		[
			null,
			Context3DVertexBufferFormat.FLOAT_1,
			Context3DVertexBufferFormat.FLOAT_2,
			Context3DVertexBufferFormat.FLOAT_3,
			Context3DVertexBufferFormat.FLOAT_4,
			Context3DVertexBufferFormat.FLOAT_1, // unused
			Context3DVertexBufferFormat.FLOAT_2, // unused
			Context3DVertexBufferFormat.FLOAT_3, // unused
			Context3DVertexBufferFormat.FLOAT_4, // unused
			Context3DVertexBufferFormat.FLOAT_4, //?????
			Context3DVertexBufferFormat.FLOAT_1, // unused
			Context3DVertexBufferFormat.FLOAT_2, // unused
			Context3DVertexBufferFormat.FLOAT_4  // unused
		];
		
		public static const bufferLocking: Array =
		[
			null,
			null,
			null
		];
		
		public static const bufferUsage: Array =
		[
			null,
			null,
			null,
			null,
			null
		];
		
		public static const minFilter: Array =
		[
			null,
			null,
			null,
			null,
			null,
			null,
			null
		];
		
		public static const textureInternalFormat: Array =
		[
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null
		];
		
		public static const textureFormat: Array =
		[
			Context3DTextureFormat.COMPRESSED,			// DXT1
			Context3DTextureFormat.COMPRESSED_ALPHA,	// DXT5
			Context3DTextureFormat.COMPRESSED,			// ETC1
			Context3DTextureFormat.COMPRESSED,			// PVRTC
			Context3DTextureFormat.BGRA,				// RGBA
			null,
			null,
			null,
			null,
			null,
			Context3DTextureFormat.BGRA,				// RGBA8888
			Context3DTextureFormat.BGRA,				// RGB888
			Context3DTextureFormat.BGRA_PACKED,			// RGB565
			Context3DTextureFormat.BGR_PACKED			// RGBA4444
		];
		
		public static const textureTarget: Array =
		[
			null,
			null,
			null,
			null,
			null
		];
		
		public static const textureType: Array =
		[
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null
		];
		
		public static const wrapMode: Array =
		[
			null,
			null,
			null,
			null,
			null,
			null
		];
		
		public static const primitiveType: Array =
		[
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null
		];
	}
}