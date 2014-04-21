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
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class AGALSamplerState 
	{
		
		// internal use only
		public var anisotropy: Number = 1;
		
		// internal use only
		public var lodBias: Number = 0;
		
		// internal use only
		public var magFilter: String = "";
		
		// internal use only
		public var minFilter: String = "";
		
		public var borderColor: Array = [ 0, 0, 0, 0 ];
		
		// internal use only
		public var wrap: Array = [ 0, 0, 0 ];
		
		public function AGALSamplerState() 
		{
			// TODO implement setSamplerAt....
			// trace( "* querying the current sampler state (not implemented)" );
		}
		
		public function get current(): Array
		{
			return [
				anisotropy,
				lodBias,
				magFilter,
				minFilter,
				borderColor,
				wrap[ 0 ],
				wrap[ 1 ],
				wrap[ 2 ]
			];
		}
		
	}

}