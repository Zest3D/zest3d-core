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
	
	import flash.display3D.Context3D;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.resources.enum.TextureFormat;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Stage3DRendererData implements IDisposable
	{
		
		public static const MAX_NUM_VSAMPLERS: int = 4;
		public static const MAX_NUM_PSAMPLERS: int = 16;
		
		// internal use only
		public var context: Context3D;
		
		// internal use only
		public var currentRS: Stage3DRenderState;
		
		// internal use only
		public var currentSS: Array;
		
		// internal use only
		public var maxVShaderImages: int = 4;
		
		// internal use only
		public var maxPShaderImages: int = 4;
		
		// internal use only
		public var maxCombinedImages: int;
		
		protected var _isDisposed:Boolean;
		
		public function Stage3DRendererData( input: Stage3DRendererInput, width: int, height: int, colorFormat:TextureFormat, depthStencilFormat: TextureFormat, numMultiSamples: int  ) 
		{
			context = input.context;
			
			currentRS = new Stage3DRenderState( context );
			
			currentSS = [];
			for ( var i: int = 0; i < MAX_NUM_PSAMPLERS; ++i )
			{
				currentSS[ i ] = new Stage3DSamplerState();
			}
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			currentRS.dispose();
			currentSS = null;
			context = null;
			
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
	}

}