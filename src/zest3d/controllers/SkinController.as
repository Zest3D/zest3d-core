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
	import io.plugin.core.system.Assert;
	import io.plugin.math.algebra.APoint;
	import zest3d.datatypes.Transform;
	import zest3d.renderers.Renderer;
	import zest3d.resources.VertexBufferAccessor;
	import zest3d.scenegraph.enum.UpdateType;
	import zest3d.scenegraph.Node;
	import zest3d.scenegraph.TriMesh;
	import zest3d.scenegraph.Visual;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class SkinController extends Controller implements IDisposable 
	{
		
		protected var _numVertices: int;
		protected var _numBones: int;
		
		protected var _bones: Vector.<Node>; // Nodes
		protected var _weights: Array;	// Number
		protected var _offsets: Array; // APoint
		
		
		public function SkinController( numVertices: int, numBones: int ) 
		{
			_numVertices = numVertices;
			_numBones = numBones;
			
			_bones = new Vector.<Node>( _numBones, true );
			_weights = [];
			_offsets = [];
			
			var i: int;
			var j: int;
			
			for ( i = 0; i < _numBones; ++i )
			{
				_bones[ i ] = new Node();
			}
			
			/**
			 * mBones = new1<Node*>(mNumBones);
			 * mWeights = new2<float>(mNumBones, mNumVertices);
			 * mOffsets = new2<APoint>(mNumBones, mNumVertices);
			 */
			for ( i = 0; i < _numVertices; ++i )
			{
				_offsets[ i ] = [];
				_weights[ i ] = [];
				for ( j = 0; j < _numBones; ++j )
				{
					_offsets[ i ][ j ] = new APoint();
					_weights[ i ][ j ] = 0;
				}
			}
			
			// TODO consolidate pointer structure (I'm thinking direct to ByteArray)
		}
		
		override public function dispose():void 
		{
			_bones = null;
			_weights = null;
			_offsets = null;
			
			super.dispose();
		}
		
		
		[Inline]
		public final function get numVertices(): int
		{
			return _numVertices;
		}
		
		[Inline]
		public final function get numBones(): int
		{
			return _numBones;
		}
		
		[Inline]
		public final function get bones(): Vector.<Node>
		{
			return _bones;
		}
		
		[Inline]
		public final function get weights(): Array
		{
			return _weights;
		}
		
		[Inline]
		public final function get offsets(): Array
		{
			return _offsets;
		}
		
		override public function update(applicationTime:Number):Boolean 
		{
			if ( !super.update( applicationTime ) )
			{
				return false;
			}
			
			var visual: Visual = _object as Visual;
			
			Assert.isTrue( _numVertices == visual.vertexBuffer.numElements, "Controller must have the same number of vertices as the buffer" );
			
			var vba: VertexBufferAccessor = new VertexBufferAccessor( visual.vertexFormat, visual.vertexBuffer );
			
			visual.worldTransform = Transform.IDENTITY;
			visual.worldTransformIsCurrent = true;
			
			for ( var vertex: int = 0; vertex < _numVertices; ++vertex )
			{
				var position: APoint = APoint.ORIGIN;
				
				for ( var bone: int = 0; bone < _numBones; ++bone )
				{
					var weight: Number = _weights[ vertex ][ bone ];
					if ( weight != 0 )
					{
						var offset: APoint = _offsets[ vertex ][ bone ];
						var worldOffset: APoint = _bones[ bone ].worldTransform.multiplyAPoint( offset );
						position.addEq( worldOffset.scale( weight ) );
					}
				}
				vba.setPositionAt( vertex, position.toTuple().slice( 0, 3 ) );
			}
			
			visual.updateModelSpace( UpdateType.NORMALS );
			Renderer.updateAllVertexBuffer( visual.vertexBuffer );
			
			return true;
		}
		
	}

}