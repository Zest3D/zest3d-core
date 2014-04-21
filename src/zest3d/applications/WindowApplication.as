/**
 * Plugin.IO - http://www.plugin.io
 * Copyright (c) 2013-2014
 *
 * Geometric Tools, LLC
 * Copyright (c) 1998-2012
 * 
 * Distributed under the Boost Software License, Version 1.0.
 * http://www.boost.org/LICENSE_1_0.txt
 */
package zest3d.applications 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	import io.plugin.core.graphics.Color;
	import io.plugin.core.interfaces.IDisposable;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.TextureFormat;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class WindowApplication extends Sprite implements IDisposable 
	{
		
		protected var _width:int;
		protected var _height:int;
		
		private var _clearColor: Color;
		
		protected var _colorFormat: TextureFormat;
		protected var _depthStencilFormat: TextureFormat;
		protected var _numMultisamples: int;
		protected var _renderer: Renderer;
		
		protected var _lastTime: Number;
		protected var _accumulatedTime: Number;
		protected var _frameRate: Number;
		
		protected var _frameCount: int;
		protected var _accumulatedFrameCount: int;
		protected var _timer: int;
		protected var _maxTimer: int;
		
		
		
		public function WindowApplication( clearColor: Color ) 
		{
			_clearColor = clearColor;
			
			_lastTime = -1;
			_accumulatedTime = 0;
			_frameRate = 0;
			_accumulatedFrameCount = 0;
			_timer = 30;
			_maxTimer = 30;
			
			// TODO can we specify new texture formats for better precision matching?
			_colorFormat = TextureFormat.RGBA8888;
			_depthStencilFormat = TextureFormat.RGBA8888;
			_numMultisamples = 0;
			
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		protected function onAddedToStage( e: Event ): void
		{
			_width = stage.stageWidth;
			_height = stage.stageHeight;
			renderer.setViewport( 0, 0, _width, _height );
		}
		
		[Inline]
		public final function get aspectRatio(): Number
		{
			return _width / _height;
		}
		
		[Inline]
		public final function get renderer(): Renderer
		{
			return _renderer;
		}
		
		[Inline]
		public final function get clearColor():Color 
		{
			return _clearColor;
		}
		
		[Inline]
		public final function set clearColor(value:Color):void 
		{
			_renderer.clearColor = value;
			_clearColor = value;
		}
		
		// virtual
		public function onInitialize(): Boolean
		{
			_renderer.clearColor = _clearColor;
			return true;
		}
		
		// virtual
		public function onTerminate(): void
		{
			
		}
		
		// virtual
		public function onResize( width: int, height: int ): void
		{
			_width = width;
			_height = height;
		}
		
		// virtual
		public function onPrecreate(): Boolean
		{
			// stub
			return true;
		}
		
		// virtual
		public function onPreidle(): void
		{
			_renderer.clearBuffers();
		}
		
		// virtual
		public function onDisplay(): void
		{
			// stub
		}
		
		// virtual
		public function onIdle(): void
		{
			// stub
		}
		
		public function dispose():void 
		{
			
		}
		
		protected function resetTime(): void
		{
			_lastTime = -1;
		}
		
		//TODO consolidate the getTimer() calls
		protected function measureTime(): void
		{
			if ( _lastTime == -1 )
			{
				_lastTime = getTimer();
				_accumulatedTime = 0;
				_frameRate = 0;
				_frameCount = 0;
				_accumulatedFrameCount = 0;
				_timer = _maxTimer;
			}
			
			if ( --_timer == 0 )
			{
				var dCurrentTime: Number = getTimer();
				var dDelta: Number = getTimer() - _lastTime;
				_lastTime = dCurrentTime;
				_accumulatedTime += dDelta;
				_accumulatedFrameCount += _frameCount;
				_frameCount = 0;
				_timer = _maxTimer;
			}
		}
		
		protected function updateFrameCount(): void
		{
			++_frameCount;
		}
		
	}

}