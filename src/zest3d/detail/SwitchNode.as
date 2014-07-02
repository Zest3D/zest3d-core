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
	import plugin.core.system.Assert;
	import zest3d.scenegraph.Culler;
	import zest3d.scenegraph.Node;
	import zest3d.scenegraph.Spatial;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class SwitchNode extends Node implements IDisposable 
	{
		
		public static const INVALID_CHILD: int = -1;
		
		protected var _activeChild: int;
		
		public function SwitchNode( ) 
		{
			_activeChild = INVALID_CHILD;
		}
		
		override public function dispose(): void
		{
			super.dispose();
		}
		
		override public function getVisibleSet( culler: Culler, noCull: Boolean ): void
		{
			if ( _activeChild == INVALID_CHILD )
			{
				return;
			}
			
			var child: Spatial = _child[ _activeChild ];
			if ( child )
			{
				child.onGetVisibleSet( culler, noCull );
			}
		}
		
		[Inline]
		public final function set activeChild( activeChild: int ): void
		{
			Assert.isTrue( activeChild == INVALID_CHILD
			     || activeChild < _child.length , "Invalid active child specified." )
			_activeChild = activeChild;
		}
		
		[Inline]
		public final function get activeChild(): int
		{
			return _activeChild;
		}
		
		[Inline]
		public final function disableAllChildren(): void
		{
			_activeChild = INVALID_CHILD;
		}
		
		
		
	}

}