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
	
	import flash.utils.getQualifiedClassName;
	import io.plugin.core.errors.AbstractClassError;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.object.PluginObject;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class ControlledObject extends PluginObject implements IDisposable
	{
		
		private var _controllers: Vector.<Controller>;
		
		public function ControlledObject()
		{
			if ( getQualifiedClassName( this ) == "zest3d.controllers::ControlledObject" )
			{
				throw new AbstractClassError();
			}
			
			_controllers = new Vector.<Controller>();
		}
		
		
		public function dispose(): void
		{
			removeAllControllers();
			_controllers = null;
		}
		
		[Inline]
		public final function get numControllers(): int
		{
			return _controllers.length;
		}
		
		[Inline]
		public final function getControllerAt( index: int ): Controller
		{
			if ( 0 <= index && index < numControllers )
			{
				return _controllers[ index ];
			}
			
			throw new ArgumentError( "Invalid index." );
		}
		
		public function addController( controller: Controller ): void
		{
			
			if ( getQualifiedClassName( controller ) == "zest3d.controllers::Controller" )
			{
				throw new ArgumentError( "Controllers may not be controlled." );
			}
			
			if ( !controller )
			{
				throw new ArgumentError( "Cannot attach a null controller." );
			}
			
			if ( _controllers.indexOf( controller ) > -1 )
			{
				return;
			}
			
			controller.object = this;
			_controllers.push( controller );
		}
		
		public function removeController( controller: Controller ): void
		{
			var pos: int = _controllers.indexOf( controller );
			
			if ( pos == -1 )
			{
				return;
			}
			
			//TODO optimize
			_controllers.splice( pos, 1 );
		}
		
		public function removeAllControllers(): void
		{
			var i: int;
			for ( i = 0; i < numControllers; ++i )
			{
				_controllers[ i ].object = null;
			}
			_controllers.length = 0;
		}
		
		public function updateControllers( applicationTime: Number ): Boolean
		{
			var someoneUpdate: Boolean = false;
			var i:int;
			for ( i = 0; i < numControllers; ++i )
			{
				if ( _controllers[ i ].update( applicationTime ) )
				{
					someoneUpdate = true;
				}
			}
			return someoneUpdate;
		}
		
		//{ NAME SUPPORT
		override public function getObjectByName(name:String):Object 
		{
			var found: Object = super.getObjectByName( name );
			if ( found )
			{
				return found;
			}
			for ( var i: int = 0; i < numControllers; ++i )
			{
				//PLUGIN_GET_OBJECT_BY_NAME( _controllers[ i ], name, found )
				if (_controllers[ i ])
				{
					found = _controllers[ i ].getObjectByName(name);
					if (found)
					{
						return found;
					}
				}
			}
			return null;
		}
		
		override public function getAllObjectsByName(name:String, objects:Vector.<Object>):void 
		{
			super.getAllObjectsByName(name, objects);
			
			for ( var i: int = 0; i < numControllers; ++i )
			{
				PLUGIN_GET_ALL_OBJECTS_BY_NAME( _controllers[i], name, objects );
			}
		}
		//}
		
	}

}