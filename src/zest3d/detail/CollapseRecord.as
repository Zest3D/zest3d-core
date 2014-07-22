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
package zest3d.detail 
{
	import plugin.core.interfaces.IDisposable;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class CollapseRecord implements IDisposable 
	{
		
		public var vKeep: int;
		public var vThrow: int;
		public var numVertices: int;
		public var numTriangles: int;
		
		public var numIndices: int;
		public var indices: Array;
		
		private var _isDisposed:Boolean;
		
		public function CollapseRecord( vKeep: int = -1, vThrow: int = -1, numVertices: int = 0, numTriangles: int = 0 ) 
		{
			_isDisposed = false;
			
			this.vKeep = vKeep;
			this.vThrow = vThrow;
			this.numVertices = numVertices;
			this.numTriangles = numTriangles;
			
			numIndices = 0;
			indices = [];
		}
		
		public function dispose(): void
		{
			indices.length = 0;
			indices = null;
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean 
		{
			return _isDisposed;
		}
		
	}

}