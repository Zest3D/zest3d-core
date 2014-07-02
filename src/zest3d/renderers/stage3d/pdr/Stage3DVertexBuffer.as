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
package zest3d.renderers.stage3d.pdr {
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import plugin.core.interfaces.IDisposable;
	import zest3d.renderers.stage3d.Stage3DRenderer;
	import zest3d.renderers.interfaces.IVertexBuffer;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.BufferLockingType;
	import zest3d.resources.VertexBuffer;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Stage3DVertexBuffer implements IVertexBuffer, IDisposable 
	{
		
		private var _renderer: Stage3DRenderer
		private var _context: Context3D;
		private var _vertexBuffer: VertexBuffer;
		
		private var _vertexBuffer3D: VertexBuffer3D;
		
		public static var currentVBuffer: VertexBuffer3D;
		
		protected var _isDisposed:Boolean;
		
		public function Stage3DVertexBuffer( renderer: Renderer, vBuffer: VertexBuffer ) 
		{
			_renderer = renderer as Stage3DRenderer;
			_context = _renderer.data.context;
			
			_vertexBuffer = vBuffer;
			
			_vertexBuffer3D = _context.createVertexBuffer( _vertexBuffer.numElements, _vertexBuffer.elementSize /  4 );
			
			_vertexBuffer3D.uploadFromByteArray( _vertexBuffer.data, 0, 0, _vertexBuffer.numElements );
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_vertexBuffer3D.dispose();
			_vertexBuffer3D = null;
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function enable( renderer: Renderer, vertexSize: uint, streamIndex: uint, offset: uint ): void
		{
			
			currentVBuffer = _vertexBuffer3D;
		}
		
		public function disable( renderer: Renderer, steamIndex: uint ): void
		{
		}
		
		public function lock( mode: BufferLockingType ): void
		{
		}
		
		public function unlock(): void
		{
		}
		
		[Inline]
		public final function get vertexBuffer3D():VertexBuffer3D 
		{
			return _vertexBuffer3D;
		}
		
	}

}