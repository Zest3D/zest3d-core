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
	import flash.utils.ByteArray;
	import plugin.core.system.Assert;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.AVector;
	import zest3d.renderers.Renderer;
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexBufferAccessor;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.enum.UpdateType;
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Particles extends TriMesh 
	{
		
		protected var _numParticles: int;
		protected var _positionSizes: ByteArray;
		protected var _sizeAdjust: Number;
		protected var _numActive: int;
		
		public function Particles( vFormat: VertexFormat, vBuffer: VertexBuffer, indexSize: int, positionSizes: ByteArray, sizeAdjust: Number ) 
		{
			super( vFormat, vBuffer );
			
			_positionSizes = positionSizes;
			
			Assert.isTrue( indexSize == 2 || indexSize == 4, "Invlaid index size." );
			
			var numVertices: int = _vBuffer.numElements;
			Assert.isTrue( (numVertices % 4) == 0, "Number of vertices must be a multiple of 4." );
			
			_numParticles = int( numVertices / 4 );
			_numActive = _numParticles;
			
			this.sizeAdjust = sizeAdjust;
			
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, _vBuffer );
			Assert.isTrue( vba.hasTCoord( 0 ), "Texture coordinates must exist and use channel 0" );
			
			var i: int;
			var j: int;
			
			for ( i = 0, j = 0; i < _numParticles; ++i )
			{
				vba.setTCoordAt( 0, j++, [ 0, 0 ] );
				vba.setTCoordAt( 0, j++, [ 1, 0 ] );
				vba.setTCoordAt( 0, j++, [ 1, 1 ] );
				vba.setTCoordAt( 0, j++, [ 0, 1 ] );
			}
			
			_iBuffer = new IndexBuffer( 6 * _numParticles, indexSize );
			
			var iFI: int;
			var iFIp1: int;
			var iFIp2: int;
			var iFIp3: int;
			
			if ( indexSize == 2 )
			{
				var indices: ByteArray = _iBuffer.data;
				
				indices.position = 0;
				
				for ( i = 0; i < _numParticles; ++i )
				{
					iFI = 4 * i;
					iFIp1 = iFI + 1;
					iFIp2 = iFI + 2;
					iFIp3 = iFI + 3;
					
					indices.writeShort( iFI );
					indices.writeShort( iFIp1 );
					indices.writeShort( iFIp2 );
					
					indices.writeShort( iFI );
					indices.writeShort( iFIp2 );
					indices.writeShort( iFIp3 );
				}
			}
			else
			{
				throw new Error( "Stage3D only supports index sizes of 2." );
			}
			
			_modelBound.computeFromData( _numParticles, 16, _positionSizes );
			
		}
		
		override public function dispose():void 
		{
			_positionSizes.length = 0;
			super.dispose();
		}
		
		[Inline]
		public final function get numParticles(): int
		{
			return _numParticles;
		}
		
		[Inline]
		public final function get positionSizes(): ByteArray
		{
			return _positionSizes;
		}
		
		public function set sizeAdjust( sizeAdjust: Number ): void
		{
			if ( sizeAdjust > 0 )
			{
				_sizeAdjust = sizeAdjust;
			}
			else
			{
				throw new Error( "Invalid size-adjust parameter." );
			}
		}
		
		[Inline]
		public final function get sizeAdjust(): Number
		{
			return _sizeAdjust;
		}
		
		public function set numActive( numActive: int ): void
		{
			if ( 0 <= numActive && numActive )
			{
				_numActive = numActive;
			}
			else
			{
				_numActive = _numParticles;
			}
			
			_iBuffer.numElements = 6 * _numActive;
			_vBuffer.numElements = 4 * _numActive;
		}
		
		public function get numActive(): int
		{
			return _numActive;
		}
		
		public function generateParticles( camera: Camera ): void
		{
			var vba: VertexBufferAccessor = new VertexBufferAccessor( _vFormat, _vBuffer );
			Assert.isTrue( vba.hasPosition(), "Positions must exist" );
			
			var upR: AVector = worldTransform.inverse.multiplyAVector( camera.uVector.add( camera.rVector ) );
			var umR: AVector = worldTransform.inverse.multiplyAVector( camera.uVector.subtract( camera.rVector ) );
			
			var i: int;
			var j: int;
			
			_positionSizes.position = 0;
			
			var position: APoint = new APoint();
			var trueSize: Number;
			var scaledUpR: AVector;
			var scaledUmR: AVector;
			
			for ( i = 0; i < _numActive; ++i )
			{
				position.x = _positionSizes.readFloat();
				position.y = _positionSizes.readFloat();
				position.z = _positionSizes.readFloat();
				
				trueSize = _positionSizes.readFloat();
				scaledUpR = upR.scale( trueSize );
				scaledUmR = umR.scale( trueSize );
				
				var posSubUpR: Array = position.subtractAVector( scaledUpR ).toTuple();
				var posSubUmR: Array = position.subtractAVector( scaledUmR ).toTuple();
				var posAddUpR: Array = position.addAVector( scaledUpR ).toTuple();
				var posAddUmR: Array = position.addAVector( scaledUmR ).toTuple();
				
				vba.setPositionAt( j++, posSubUpR );
				vba.setPositionAt( j++, posSubUmR );
				vba.setPositionAt( j++, posAddUpR );
				vba.setPositionAt( j++, posAddUmR );
			}
			
			updateModelSpace( UpdateType.NORMALS );
			Renderer.updateAllVertexBuffer( _vBuffer );
		}
		
		//virtual
		override public function getVisibleSet(culler:Culler, noCull:Boolean):void 
		{
			generateParticles( culler.camera );
			super.getVisibleSet(culler, noCull);
		}
		
	}

}