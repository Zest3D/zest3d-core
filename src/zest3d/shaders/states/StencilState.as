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
package zest3d.shaders.states 
{
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.shaders.enum.CompareMode;
	import zest3d.shaders.enum.OperationType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class StencilState implements IDisposable 
	{
		
		public var enabled: Boolean;
		public var compare: CompareMode;
		public var reference: uint;
		public var mask: uint;
		public var writeMask: uint;
		
		public var onFail: OperationType;
		public var onZFail: OperationType;
		public var onZPass: OperationType;
		
		public function StencilState() 
		{
			enabled = false;
			compare = CompareMode.NEVER;
			reference = 0;
			mask = 0xff; // 8-bit mask
			writeMask = 0xff; // 8-bit mask
			
			onFail = OperationType.KEEP;
			onZFail = OperationType.KEEP;
			onZPass = OperationType.KEEP;
		}
		
		public function dispose(): void
		{
		}
		
	}

}