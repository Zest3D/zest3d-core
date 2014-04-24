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
package zest3d.localeffects 
{
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.resources.Texture2D;
	import zest3d.shaderfloats.matrix.PVWMatrixConstant;
	import zest3d.shaders.enum.SamplerCoordinateType;
	import zest3d.shaders.enum.SamplerFilterType;
	import zest3d.shaders.PixelShader;
	import zest3d.shaders.VisualEffect;
	import zest3d.shaders.VisualEffectInstance;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class MRTEffect extends VisualEffect implements IDisposable
	{
		
		public function MRTEffect( texture0:Texture2D, texture1:Texture2D ) 
		{
			var instance:VisualEffectInstance = new VisualEffectInstance( this, 0 );
			instance.setVertexConstantByHandle( 0, 0, new PVWMatrixConstant() );
			instance.setPixelTextureByHandle( 0, 0, texture0 );
			instance.setPixelTextureByHandle( 0, 1, texture1 );
			
			super();
			
			var pShader:PixelShader = getPixelShader( 0, 0 );
			
			// sampler0
			pShader.setFilter( 0, SamplerFilterType.LINEAR );
			pShader.setCoordinate( 0, 0, SamplerCoordinateType.CLAMP_EDGE );
			pShader.setCoordinate( 0, 1, SamplerCoordinateType.CLAMP_EDGE );
			
			// sampler1
			pShader.setFilter( 1, SamplerFilterType.LINEAR );
			pShader.setCoordinate( 1, 0, SamplerCoordinateType.CLAMP_EDGE );
			pShader.setCoordinate( 1, 1, SamplerCoordinateType.CLAMP_EDGE );
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}