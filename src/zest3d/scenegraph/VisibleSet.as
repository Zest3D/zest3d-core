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
	import plugin.core.system.Assert;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class VisibleSet implements IDisposable
	{
		
		private var _visible: Vector.<Spatial>;
		
		protected var _isDisposed:Boolean;
		
		public function VisibleSet() 
		{
			_visible = new Vector.<Spatial>();
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			for each( var d:IDisposable in _visible )
			{
				d.dispose();
			}
			_visible.length = 0;
			_visible = null;
			
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		[Inline]
		public final function get numVisible(): int
		{
			return _visible.length;
		}
		
		[Inline]
		public final function getAllVisible(): Vector.<Spatial>
		{
			return _visible;
		}
		
		[Inline]
		public final function getVisibleAt( index: int ): Spatial
		{
			Assert.isTrue( 0 <= index && index < numVisible, "Invalid index to GetVisible." );
			return _visible[ index ];
		}
		
		public function insert( visible: Spatial ): void
		{
			_visible.push( visible );
		}
		
		[inline]
		public final function clear(): void
		{
			_visible.length = 0;
		}
		
	}

}