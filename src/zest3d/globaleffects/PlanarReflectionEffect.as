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
package zest3d.globaleffects 
{
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.HMatrix;
	import io.plugin.math.algebra.HPlane;
	import zest3d.renderers.Renderer;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.enum.CullingType;
	import zest3d.scenegraph.TriMesh;
	import zest3d.scenegraph.VisibleSet;
	import zest3d.scenegraph.Visual;
	import zest3d.shaders.enum.CompareMode;
	import zest3d.shaders.enum.OperationType;
	import zest3d.shaders.states.AlphaState;
	import zest3d.shaders.states.CullState;
	import zest3d.shaders.states.DepthState;
	import zest3d.shaders.states.StencilState;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class PlanarReflectionEffect extends GlobalEffect implements IDisposable 
	{
		
		protected var _numPlanes: int;
		protected var _planes: Vector.<TriMesh>;
		protected var _reflectances: Array;
		
		protected var _alphaState: AlphaState;
		protected var _depthState: DepthState;
		protected var _stencilState: StencilState;
		
		public function PlanarReflectionEffect( numPlanes: int ) 
		{
			_numPlanes = numPlanes;
			
			_planes = new Vector.<TriMesh>( _numPlanes );
			_reflectances = [];
			_alphaState = new AlphaState();
			_depthState = new DepthState();
			_stencilState = new StencilState();
		}
		
		override public function dispose():void 
		{
			_planes = null;
			_reflectances = null;
			
			super.dispose();
		}
		
		override public function draw(renderer:Renderer, visible:VisibleSet):void 
		{
			var saveDState: DepthState = renderer.overrideDepthState;
			var saveSState: StencilState = renderer.overrideStencilState;
			
			renderer.overrideDepthState = _depthState;
			renderer.overrideStencilState = _stencilState;
			
			var depthRange: Array = renderer.getDepthRange();
			var minDepth: Number = depthRange[ 0 ];
			var maxDepth: Number = depthRange[ 1 ];
			
			
			var camera: Camera = renderer.camera;
			
			var numVisible: int = visible.numVisible;
			var i: int;
			var j: int;
			
			for ( i = 0; i < _numPlanes; ++i )
			{
				
				_stencilState.enabled = true;
				_stencilState.compare = CompareMode.ALWAYS;
				
				// stencil reference update lock to 8 bit
				_stencilState.reference = uint( i + 1 );
				
				_stencilState.onFail = OperationType.KEEP;
				_stencilState.onZFail = OperationType.KEEP;
				_stencilState.onZPass = OperationType.REPLACE;
				
				
				_depthState.enabled = true;
				_depthState.writable = false;
				_depthState.compare = CompareMode.LEQUAL;
				
				renderer.setColorMask( false, false, false, false );
				
				renderer.drawVisual( _planes[ i ] );
				
				renderer.setColorMask( true, true, true, true );
				
				
				
				_stencilState.enabled = true;
				_stencilState.compare = CompareMode.EQUAL;
				
				// stencil reference update lock to 8 bit
				_stencilState.reference = uint( i + 1 );
				
				_stencilState.onFail = OperationType.KEEP;
				_stencilState.onZFail = OperationType.KEEP;
				_stencilState.onZPass = OperationType.KEEP;
				
				//renderer.setDepthRange( 1, 1 ); // TODO make it fail a depth test
				
				_depthState.enabled = true;
				_depthState.writable = true;
				_depthState.compare = CompareMode.ALWAYS;
				
				renderer.drawVisual( _planes[ i ] );
				
				_depthState.compare = CompareMode.GEQUAL; // TODO check edit LEQUAL
				//renderer.setDepthRange( minDepth, maxDepth );
				
				var array: Array = getReflectionMatrixAndModelPlaneAt( i );
				var reflection: HMatrix = array[ 0 ];
				var modelPlane: HPlane = array[ 1 ];
				
				camera.previewMatrix = reflection;
				
				var c1:CullState = new CullState();
				c1.ccwOrder = false;
				
				// TODO - This is HACKED, it needs the render states sorting out properly
				renderer.overrideCullState = c1;
				renderer.reverseCullOrder = true;
				for ( j = 0; j < numVisible; ++j )
				{
					renderer.drawVisual( visible.getVisibleAt( j ) as Visual );
				}
				c1.ccwOrder = true;
				renderer.reverseCullOrder = false;
				
				camera.previewMatrix = HMatrix.IDENTITY;
				
				var saveAState: AlphaState = renderer.overrideAlphaState;
				renderer.overrideAlphaState = _alphaState;
				
				//_alphaState.blendEnabled = true;
				//_alphaState.compareEnabled = true;
				//_alphaState.srcBlend = SrcBlendMode.ONE_MINUS_CONSTANT_ALPHA;
				//_alphaState.dstBlend = DstBlendMode.CONSTANT_ALPHA; 
				
				_alphaState.constantColor = [ 1, 0, 0, _reflectances[ i ] ]; //TODO a constant alpha must be part of the shader
				
				_stencilState.compare = CompareMode.EQUAL;
				
				// stencil reference update lock to 8 bit
				_stencilState.reference = uint( i + 1 );
				
				_stencilState.onFail = OperationType.KEEP;
				_stencilState.onZFail = OperationType.KEEP;
				_stencilState.onZPass = OperationType.INVERT;
				
				renderer.drawVisual( _planes[ i ] );
				
				renderer.overrideAlphaState = saveAState;
			}
			
			renderer.overrideStencilState = saveSState;
			renderer.overrideDepthState = saveDState;
			
			for ( j = 0; j < numVisible; ++j )
			{
				renderer.drawVisual( visible.getVisibleAt( j ) as Visual );
			}
			
		}
		
		protected function getReflectionMatrixAndModelPlaneAt( index: int ): Array
		{
			
			var vertex: Array = [];
			
			// TODO check for errors with the arrays here + cast to TriMesh
			_planes[ index ].getWorldTriangleAt( 0, vertex );
			
			var worldPlane: HPlane = HPlane.fromAPoints( APoint.fromTuple( vertex[ 0 ] ), APoint.fromTuple( vertex[ 1 ] ), APoint.fromTuple( vertex[ 2 ] ) );
			
			var reflection: HMatrix = new HMatrix();
			reflection.reflection( APoint.fromTuple( vertex[ 0 ] ), worldPlane.normal );
			
			_planes[ index ].getModelTriangleAt( 0, vertex );
			
			var modelPlane: HPlane = HPlane.fromAPoints( APoint.fromTuple(vertex[ 0 ]), APoint.fromTuple(vertex[ 1 ]), APoint.fromTuple(vertex[ 2 ]) );
			
			return [ reflection, modelPlane ];
		}
		
		[Inline]
		public final function get numPlanes(): int
		{
			return _numPlanes;
		}
		
		[Inline]
		public final function setPlaneAt( index: int, plane: TriMesh ): void
		{
			_planes[ index ] = plane;
			_planes[ index ].culling = CullingType.ALWAYS;
		}
		
		[Inline]
		public final function getPlaneAt( index: int ): TriMesh
		{
			return _planes[ index ];
		}
		
		[Inline]
		public final function setReflectanceAt( index: int, reflectance: Number ): void
		{
			_reflectances[ index ] = reflectance;
		}
		
		[Inline]
		public final function getReflectanceAt( index: int ): Number
		{
			return _reflectances[ index ];
		}
		
	}

}