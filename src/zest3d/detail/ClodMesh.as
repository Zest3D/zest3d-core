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
	import flash.utils.ByteArray;
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import zest3d.renderers.Renderer;
	import zest3d.scenegraph.Culler;
	import zest3d.scenegraph.TriMesh;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class ClodMesh extends TriMesh implements IDisposable 
	{
		
		protected var _currentRecord: int;
		protected var _targetRecord: int;
		protected var _recordArray: CollapseRecordArray;
		
		public function ClodMesh( mesh: TriMesh, recordArray: CollapseRecordArray ) 
		{
			super( mesh.vertexFormat, mesh.vertexBuffer, mesh.indexBuffer );
			
			_currentRecord = 0;
			_targetRecord = 0;
			
			_recordArray = recordArray;
		}
		
		override public function dispose():void 
		{
			_recordArray.dispose();
			_recordArray = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get numRecords(): int
		{
			return _recordArray.numRecords;
		}
		
		[Inline]
		public final function get targetRecord(): int
		{
			return _targetRecord;
		}
		
		// virtual 
		[Inline]
		public final function get automatedTargetRecord(): int
		{
			return _targetRecord;
		}
		
		public function selectLevelOfDetail(): void
		{
			var records: CollapseRecord = _recordArray.records;
			
			var targetRecord: int = automatedTargetRecord;
			
			var indices: ByteArray = _iBuffer.data;
			var iBufferChanged: Boolean = (_currentRecord != targetRecord );
			
			var i: int;
			var c: int;
			var record: CollapseRecord;
			while ( _currentRecord < targetRecord )
			{
				++_currentRecord;
				
				record = record[ _currentRecord ];
				for ( i = 0; i < record.numIndices; ++i )
				{
					c = record.indices[ i ];
					Assert.isTrue( indices[ c ] == record.vThrow, "Inconsistent record in SelectLevelOfDetail." );
					
					indices.position = c * 4;
					indices.writeUnsignedInt( record.vKeep );
				}
				
				_vBuffer.numElements = record.numVertices;
				_iBuffer.numElements = 3 * record.numTriangles;
			}
			
			while ( _currentRecord > targetRecord )
			{
				record = records[ _currentRecord ];
				for ( i = 0; i < record.numIndices; ++i )
				{
					c = record.indices[ i ];
					Assert.isTrue( indices[ c ] == record.vKeep, "Inconsistent record in SelectLevelOfDetail." );
					
					indices[ c ] = record.vThrow;
				}
				
				--_currentRecord;
				var prevRecord: CollapseRecord = records[ _currentRecord ];
				
				_vBuffer.numElements = prevRecord.numVertices;
				_iBuffer.numElements = 3 * prevRecord.numTriangles;
			}
			
			if ( iBufferChanged )
			{
				Renderer.updateAllIndexBuffer( _iBuffer );
			}
		}
		
		
		// virtual
		override public function getVisibleSet(culler:Culler, noCull:Boolean):void 
		{
			selectLevelOfDetail();
			super.getVisibleSet(culler, noCull);
		}
	}

}