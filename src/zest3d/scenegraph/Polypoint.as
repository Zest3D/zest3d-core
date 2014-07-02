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
package zest3d.scenegraph 
{
	import plugin.core.interfaces.IDisposable;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.enum.PrimitiveType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Polypoint extends Visual implements IDisposable 
	{
		
		protected var _numPoints: int;
		
		public function Polypoint( vFormat: VertexFormat, vBuffer: VertexBuffer ) 
		{
			super( PrimitiveType.POLYPOINT, vFormat, vBuffer );
		}
		
		override public function dispose():void 
		{
			
			super.dispose();
		}
		
		public function get maxNumPoints(): int
		{
			return _vBuffer.numElements;
		}
		
		public function set numPoints( numPoints: int ): void
		{
			var numVerties: int = _vBuffer.numElements;
			if ( 0 <= numPoints && numPoints <= numVerties )
			{
				_numPoints = numPoints;
			}
			else
			{
				_numPoints = numVerties;
			}
		}
		
		[Inline]
		public function get numPoints(): int
		{
			return _numPoints;
		}
		
	}

}