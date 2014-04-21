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
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.Assert;
	import io.plugin.math.algebra.APoint;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Node extends Spatial implements IDisposable 
	{
		
		protected var _child:Vector.<Spatial>
		
		public function Node() 
		{
			_child = new Vector.<Spatial>();
		}
		
		override public function dispose():void 
		{
			for each( var i:Spatial in _child )
			{
				i.parent = null;
				i.dispose();
			}
			_child.length = 0;
			_child = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get numChildren(): int
		{
			return _child.length;
		}
		
		public function addChild( child: Spatial ): int
		{
			if ( child.parent )
			{
				Assert.isTrue( false, "The child already has a parent." );
				return -1;
			}
			
			child.parent = this;
			
			var numChild:int = numChildren;
			_child.push( child );
			return numChild;
		}
		
		public function removeChild( child: Spatial ): int
		{
			for ( var i: int = 0; i < numChildren; ++i )
			{
				if ( _child[ i ] == child )
				{
					_child.splice( i, 1 );
					return i;
				}
			}
			return -1;
		}
		
		public function removeChildAt( index: int ): Spatial
		{
			if ( 0 <= index && index < numChildren )
			{
				var child: Spatial = _child[ index ];
				if ( child )
				{
					child.parent = null;
					child.dispose();
					child = null;
				}
				return child;
			}
			throw new RangeError( "index does not exist in the child list" );
		}
		
		public function addChildAt( index: int, child: Spatial ): Spatial
		{
			if (0 <= index && index < numChildren)
			{
				var previousChild: Spatial = _child[ index ];
				if ( previousChild )
				{
					previousChild.parent.dispose();
				}
				
				child.parent = this;
				_child[ index ] = child;
				
				return previousChild;
			}
			
			throw new RangeError( "Out of range." );
		}
		
		public function getChildAt( index: int ): Spatial
		{
			if ( 0 <= index && index < numChildren )
			{
				return _child[ index ];
			}
			
			throw new RangeError( "Out of range" );
		}
		
		
		// virtual method
		override protected function updateWorldData( applicationTime: Number ): void
		{
			super.updateWorldData( applicationTime );
			
			for each( var child: Spatial in _child )
			{
				child.update( applicationTime, false );
			}
		}
		
		// virtual method
		override protected function updateWorldBound(): void
		{
			if ( !worldBoundIsCurrent )
			{
				worldBound.center = APoint.ORIGIN;
				worldBound.radius = 0;
				
				for each( var child: Spatial in _child )
				{
					worldBound.growToContain( child.worldBound );
				}
			}
		}
		
		override public function getVisibleSet(culler:Culler, noCull:Boolean): void 
		{
			for each( var child: Spatial in _child )
			{
				child.onGetVisibleSet( culler, noCull );
			}
		}
		
		//{ NAME SUPPORT
		override public function getObjectByName(name:String):Object 
		{
			var found: Object = super.getObjectByName( name );
			if ( found )
			{
				return found;
			}
			
			for ( var i: int = 0; i < numChildren; ++i )
			{
				//PLUGIN_GET_OBJECT_BY_NAME(_child[ i ], name, found );
				if (_child[ i ])
				{
					var foundObject: Object = _child[ i ].getObjectByName(name);
					if (foundObject)
					{
						return foundObject;
					}
				}
			}
			return null;
		}
		
		override public function getAllObjectsByName(name:String, objects:Vector.<Object>):void 
		{
			super.getAllObjectsByName(name, objects);
			
			for ( var i: int = 0; i < numChildren; ++i )
			{
				PLUGIN_GET_ALL_OBJECTS_BY_NAME( _child[i], name, objects );
			}
		}
		//}
		
	}

}