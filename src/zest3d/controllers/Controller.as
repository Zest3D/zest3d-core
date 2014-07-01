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
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.object.PluginObject;
	import zest3d.controllers.enum.RepeatType;
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Controller extends PluginObject implements IDisposable
	{
		
		public var repeat: RepeatType;
		public var minTime: Number;
		public var maxTime: Number;
		public var phase: Number;
		public var frequency: Number;
		public var active: Boolean;
		
		protected var _object: ControlledObject;
		protected var _applicationTime: Number;
		
		public function Controller() 
		{
			repeat = RepeatType.CLAMP;
			minTime = 0;
			maxTime = 0;
			phase = 0;
			frequency = 1;
			active = true;
			_object = null;
			_applicationTime = -Number.MAX_VALUE;
		}
		
		override public function dispose(): void
		{
			super.dispose();
		}
		
		
		[Inline]
		public function get object(): ControlledObject
		{
			return _object;
		}
		
		[Inline]
		public function get applicationTime(): Number
		{
			return _applicationTime;
		}
		
		[Inline]
		public function set applicationTime( applicationTime: Number ): void
		{
			_applicationTime = applicationTime;
		}
		
		// virtual
		public function update( applicationTime: Number ): Boolean
		{
			if ( active )
			{
				_applicationTime = applicationTime;
				return true;
			}
			return false;
		}
		
		// internal use
		public function set object( object: ControlledObject ): void
		{
			_object = object;
		}
		
		protected function getControlTime( applicationTime: Number ): Number
		{
			var controlTime: Number = frequency * applicationTime + phase;
			
			if ( repeat == RepeatType.CLAMP )
			{
				if ( controlTime < minTime )
				{
					return minTime;
				}
				if ( controlTime > maxTime )
				{
					return maxTime;
				}
				return controlTime;
			}
			
			var timeRange: Number = maxTime - minTime;
			if ( timeRange > 0 )
			{
				var multiples: Number = ( controlTime - minTime ) / timeRange;
				var integerTime: Number = Math.floor( multiples );
				var fractionTime: Number = multiples - integerTime;
				
				if ( repeat == RepeatType.WRAP )
				{
					return minTime + fractionTime * timeRange;
				}
				
				if ( int( integerTime ) & 1 )
				{
					return maxTime - fractionTime * timeRange;
				}
				else
				{
					return minTime + fractionTime * timeRange;
				}
			}
			
			return minTime;
		}
		
		//{ NAME SUPPORT
		override public function getObjectByName( name: String ): Object
		{
			return super.getObjectByName( name );
		}
		
		override public function getAllObjectsByName(name:String, objects:Vector.<Object>):void 
		{
			super.getAllObjectsByName(name, objects);
		}
		//}
	}

}