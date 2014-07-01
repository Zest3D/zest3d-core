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
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.renderers.Renderer;
	import zest3d.shaders.enum.PixelShaderProfileType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class FragmentShader extends Shader implements IDisposable 
	{
		
		protected static var msProfile: PixelShaderProfileType = PixelShaderProfileType.AGAL_1_0;
		
		public function FragmentShader( programName: String, numInputs: int, numOutputs: int, numConstants: int, numSamplers: int, profileOwner: Boolean ) 
		{
			super( programName, numInputs, numOutputs, numConstants, numSamplers, profileOwner );
		}
		
		override public function dispose():void 
		{
			Renderer.unbindAllPixelShader( this );
			super.dispose();
		}
		
		public static function get profile(): PixelShaderProfileType
		{
			return msProfile;
		}
		
		public static function set profile( profile: PixelShaderProfileType ): void
		{
			msProfile = profile;
		}
		
	}

}