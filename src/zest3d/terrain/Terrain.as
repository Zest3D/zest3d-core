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
package zest3d.terrain 
{
	import plugin.core.errors.IllegalArgumentError;
	import plugin.core.interfaces.IDisposable;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.AVector;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Node;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Terrain extends Node implements IDisposable 
	{
		
		protected var _mode: int;
		protected var _vFormat: VertexFormat;
		
		protected var _numRows: int;
		protected var _numCols: int;
		
		protected var _size: int;
		protected var _minElevation: Number;
		protected var _maxElevation: Number;
		protected var _spacing: Number;
		
		protected var _pages: Array;
		
		protected var _cameraRow: int;
		protected var _cameraCol: int;
		
		protected var _camera: Camera;
		
		//TODO investigate mode: FileMode for steaming content
		public function Terrain( heightName: String, vFormat: VertexFormat, camera: Camera ) 
		{
			//TODO remove and get from file data
			_spacing = 1;
			_minElevation = 1;
			_maxElevation = 0xFFFFFF;
			_size = 33; // valid sizes; 5, 9, 17, 33, 65, 129
			
			// loads header data... TODO investigate the linkage of file from the heightName
			
			_vFormat = vFormat;
			_cameraRow = -1;
			_cameraCol = -1;
			_camera = camera;
			
			// loadHeader( ... // unnecessary for as3, but to show the implementation
			
			_pages = [];
			
			var row: int;
			var col: int;
			
			//TODO remove these, they are temporary
			_numRows = 10;
			_numCols = 10;
			
			for ( row = 0; row < _numRows; ++row )
			{
				_pages[ row ] = [];
				for ( col = 0; col < _numCols; ++col )
				{
					var heightSuffix: String = ".filetype" // TODO link this to a defined data type
					loadPage( row, col, heightName, heightSuffix );
				}
			}
			
			
			for ( row = 0; row < _numCols; ++row )
			{
				for ( col = 0; col < _numCols; ++col )
				{
					addChild( _pages[ row ][ col ] );
				}
			}
			
		}
		
		override public function dispose():void 
		{
			for ( var row: int = 0; row < _numRows; ++row )
			{
				for ( var col: int = 0; col < _numCols; ++col )
				{
					_pages[ row ][ col ] = null;
				}
				_pages[ row ] = null;
			}
			_pages = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get rowQuantity(): int
		{
			return _numRows;
		}
		
		[Inline]
		public final function get colQuantity(): int
		{
			return _numCols;
		}
		
		[Inline]
		public final function get size(): int
		{
			return _size;
		}
		
		[Inline]
		public final function get minElevation(): Number
		{
			return _minElevation;
		}
		
		[Inline]
		public final function get maxElevation(): Number
		{
			return _maxElevation;
		}
		
		[Inline]
		public final function get spacing(): Number
		{
			return _spacing;
		}
		
		// page management
		public function getPage( row: int, col: int ): TerrainPage
		{
			if ( 0 <= row && row < _numRows && 0 <= col && col < _numRows )
			{
				return _pages[ row ][ col ];
			}
			throw new IllegalArgumentError( "Invalid row or column index." );
		}
		
		public function getCurrentPage( x: Number, y: Number ): TerrainPage
		{
			var invLength: Number = 1 / (_spacing * (_size - 1) );
			
			var col: int = int( Math.floor( x * invLength ) );
			col %= _numCols;
			if ( col < 0 )
			{
				col += _numCols;
			}
			
			var row: int = int( Math.floor( y * invLength ) );
			row %= _numRows;
			if ( row < 0 )
			{
				row += _numRows;
			}
			
			return _pages[ row ][ col ];
		}
		
		public function getHeight( x: Number, y: Number ): Number
		{
			var page: TerrainPage = getCurrentPage( x, y );
			
			x -= page.localTransform.translate.x;
			y -= page.localTransform.translate.y;
			
			return page.getHeight( x, y );
		}
		
		public function getNormal( x: Number, y: Number ): AVector
		{
			var xp: Number = x + _spacing;
			var xm: Number = x - _spacing;
			var yp: Number = y + _spacing;
			var ym: Number = y - _spacing;
			
			var page: TerrainPage = getCurrentPage( xp, y );
			var xtmp: Number = xp - page.localTransform.translate.x;
			var ytmp: Number = y - page.localTransform.translate.y;
			var hpz: Number = page.getHeight( xtmp, ytmp );
			
			page = getCurrentPage( xm, y );
			xtmp = xm - page.localTransform.translate.x;
			ytmp = y - page.localTransform.translate.y;
			var hmz: Number = page.getHeight( xtmp, ytmp );
			
			page = getCurrentPage( x, ym );
			xtmp = x - page.localTransform.translate.x;
			ytmp = yp - page.localTransform.translate.y;
			var hzp: Number = page.getHeight( xtmp, ytmp );
			
			page = getCurrentPage( x, ym );
			xtmp = x - page.localTransform.translate.x;
			ytmp = ym - page.localTransform.translate.y;
			var hzm: Number = page.getHeight( xtmp, ytmp );
			
			var normal: AVector = new AVector( hmz - hpz, hzm - hzp, 1 );
			normal.normalize();
			
			return normal;
		}
		
		public function replacePageLoad( row: int, col: int, heightName: String, heightSuffix: String ): TerrainPage
		{
			if ( 0 <= row && row < _numRows && 0 <= col && col < _numCols )
			{
				var save: TerrainPage = _pages[ row ][ col ];
				loadPage( row, col, heightName, heightSuffix );
				return save;
			}
			throw new IllegalArgumentError( "Invalid row or column index." );
		}
		
		/*
		public function replacePage( row: int, col: int, heightName: String, heightSuffix: String ): TerrainPage
		{
			if ( 0 <= row && row < _numRows && 0 <= col && col < _numCols )
			{
				var save: TerrainPage = _pages[ row ][ col ];
				loadPage( row, col, heightName, heightSuffix );
				_pages[ row ][ col ] = newPage;
				return save;
			}
			throw new IllegalArgumentError( "Invalid row or column index." );
		}
		*/
		
		public function onCameraMotion(): void
		{
			if ( !_camera )
			{
				throw new Error( "A camera must exist." );
			}
			
			var worldEye: APoint = _camera.position;
			var worldDir: AVector = _camera.dVector;
			var modelEye: APoint = worldTransform.inverse.multiplyAPoint( worldEye );
			var modelDir: AVector = worldTransform.inverse.multiplyAVector( worldDir );
			
			var length: Number = _spacing * (_size - 1);
			var invLength: Number = 1 / length;
			var newCameraCol: int = Math.floor( modelEye.x * invLength );
			var newCameraRow: int = Math.floor( modelEye.y * invLength );
			
			if ( newCameraCol != _cameraCol ||  newCameraRow != _cameraRow )
			{
				_cameraCol = newCameraCol;
				_cameraRow = newCameraRow;
				
				var cminO: int = _cameraCol - _numCols / 2;
				var cminP: int = cminO % _numCols;
				if ( cminP < 0 )
				{
					cminP += _numCols;
				}
				
				var rminO: int = _cameraRow - _numRows / 2;
				var rminP: int = rminO % _numRows;
				if ( rminP < 0 )
				{
					rminP += _numRows;
				}
				
				var rO: int = rminO;
				var rP: int = rminP;
				for ( var row: int = 0; row < _numRows; ++row )
				{
					var cO: int = cminO;
					var cP: int = cminP;
					for ( var col: int = 0; col < _numCols; ++col )
					{
						var page: TerrainPage = _pages[rP][cP];
						var oldOrigin:Array = page.origin;
						var newOrigin: Array = [cO * length, rO * length];
						var pageTrn: APoint = new APoint( newOrigin[ 0 ] - oldOrigin[ 0 ],
													newOrigin[ 1 ] - oldOrigin[ 1 ],
													page.localTransform.translate.z );
						page.localTransform.translate = pageTrn;
						
						++cO;
						if ( ++cP == _numCols )
						{
							cP = 0;
						}
					}
					
					++rO;
					if ( ++rP == _numRows )
					{
						rP = 0
					}
				}
				update();
			}
		}
		
		
		//TODO can we load a header only or even split headers in a file format
		// see LoadHeader( ...
		// add maxLoader/equivalent
		protected function loadPage( row: int, col: int, heightName: String, heightSuffix: String ): void
		{
			
			/*
			trace( "warning...Terrain::loadPage not yet implemented until load solution defined." );
			trace( "loading... " );
			trace( "row: " + row + ", col: " + col + ", heightName: " + heightName + ", heightSuffix: " + heightSuffix );
			*/
			
			var numHeights: int = _size * _size;
			var heights: Array = [];
			
			// TODO load from file
			for ( var i: int = 0; i < numHeights; ++i )
			{
				heights[i] = Math.random();
			}
			
			
			var length: Number = _spacing * ( _size - 1 );
			var origin: Array = [ col * length, row * length ];
			var page: TerrainPage = new TerrainPage(_vFormat, _size, heights, origin, _minElevation, _maxElevation, _spacing );
			
			_pages[ row ][ col ] = page;
		}
		
		
	}

}