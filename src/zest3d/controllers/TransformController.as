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
package zest3d.controllers 
{
	import plugin.core.interfaces.IDisposable;
	import zest3d.datatypes.Transform;
	import zest3d.scenegraph.Spatial;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class TransformController extends Controller implements IDisposable 
	{
		
		protected var _localTransform: Transform;
		
		public function TransformController( localTransform: Transform ) 
		{
			_localTransform = localTransform;
		}
		
		override public function dispose():void 
		{
			_localTransform.dispose();
			_localTransform = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function set transform( localTransform: Transform ): void
		{
			_localTransform = localTransform;
		}
		
		[Inline]
		public final function get transform(): Transform
		{
			return _localTransform;
		}
		
		// virtual
		override public function update( applicationTime: Number ): Boolean
		{
			if ( !super.update( applicationTime ) )
			{
				return false;
			}
			var spatial: Spatial = _object as Spatial;
			spatial.localTransform = _localTransform;
			return true;
		}
		
	}

}