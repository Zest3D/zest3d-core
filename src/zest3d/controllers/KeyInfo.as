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
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class KeyInfo implements IDisposable
	{
		public var ctrlTime: Number;
		public var numTimes: int;
		public var times: Array;
		public var lastIndex: int;
		public var normTime: Number;
		public var i0: int;
		public var i1: int;
		
		private var _isDisposed:Boolean;
		
		public function KeyInfo()
		{
			ctrlTime = 0;
			numTimes = 0;
			times = [];
			lastIndex = -1;
			normTime = 0;
			i0 = 0;
			i1 = 0;
			
			_isDisposed = false;
		};
		
		
		
		public function dispose():void
		{
			times.length = 0;
			times = [];
			
			_isDisposed = false;
		}
		
		public function set( ctrlTime: Number, numTimes: int, times: Array, lastIndex: int, normTime: Number, i0: int, i1: int ): void
		{
			this.ctrlTime = ctrlTime;
			this.numTimes = numTimes;
			this.times = times;
			this.lastIndex = lastIndex;
			this.normTime = normTime;
			this.i0 = i0;
			this.i1 = i1;
		}
		
		public function get isDisposed():Boolean 
		{
			return _isDisposed;
		}
	}

}