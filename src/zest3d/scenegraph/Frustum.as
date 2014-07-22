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
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Frustum implements IDisposable 
	{
		
		protected var _dMin: Number;
		protected var _dMax: Number;
		protected var _uMin: Number;
		protected var _uMax: Number;
		protected var _rMin: Number;
		protected var _rMax: Number;
		
		private var _isDisposed:Boolean;
		
		public function Frustum( dMin: Number, dMax: Number, uMin: Number, uMax:Number, rMin: Number, rMax: Number ) 
		{
			_dMin = dMin;
			_dMax = dMax;
			_uMin = uMin;
			_uMax = uMax;
			_rMin = rMin;
			_rMax = rMax;
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_isDisposed  = true;
		}
		
		[Inline]
		public final function get dMin():Number 
		{
			return _dMin;
		}
		
		[Inline]
		public final function get dMax():Number 
		{
			return _dMax;
		}
		
		[Inline]
		public final function get uMin():Number 
		{
			return _uMin;
		}
		
		[Inline]
		public final function get uMax():Number 
		{
			return _uMax;
		}
		
		[Inline]
		public final function get rMin():Number 
		{
			return _rMin;
		}
		
		[Inline]
		public final function get rMax():Number 
		{
			return _rMax;
		}
		
		public function get isDisposed():Boolean 
		{
			return _isDisposed;
		}
		
	}

}