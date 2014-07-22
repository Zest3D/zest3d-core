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
	public class CollapseRecordArray implements IDisposable 
	{
		
		protected var _numRecords: int;
		protected var _records:CollapseRecord;
		
		private var _isDisposed:Boolean;
		
		public function CollapseRecordArray( numRecords: int, records: CollapseRecord ) 
		{
			_isDisposed = false;
			_records = records;
			_numRecords = numRecords;
		}
		
		public function dispose(): void
		{
			_records.dispose();
			_records = null;
			_isDisposed = true;
		}
		
		[Inline]
		public final function get numRecords(): int
		{
			return _numRecords;
		}
		
		[Inline]
		public final function get records(): CollapseRecord
		{
			return _records;
		}
		
		public function get isDisposed():Boolean 
		{
			return _isDisposed;
		}
		
	}

}