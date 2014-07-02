package zest3d.applications 
{
	import flash.events.Event;
	import flash.utils.getTimer;
	import plugin.core.graphics.Color;
	import plugin.core.interfaces.IDisposable;
	import zest3d.renderers.Renderer;
	import zest3d.resources.enum.TextureFormat;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class WinApplication extends Application implements IDisposable 
	{
		
		protected var _width:int;
		protected var _height:int;
		protected var _clearColor:Color;
		protected var _colorFormat:TextureFormat;
		protected var _depthStencilFormat:TextureFormat;
		protected var _numMultisamples:int;
		protected var _renderer:Renderer;
		
		protected var _lastTime:Number;
		protected var _accumulatedTime:Number;
		protected var _frameRate:Number;
		protected var _frameCount:int;
		protected var _accumulatedFrameCount:int;
		protected var _timer:int;
		protected var _maxTimer:int;
		
		private var _isDisposed:Boolean;
		
		public static var KEY_TERMINATE:int;  // default KEY_ESCAPE, redefine as desired
		public static var KEY_ESCAPE:int;
		public static var KEY_LEFT_ARROW:int;
		public static var KEY_RIGHT_ARROW:int;
		public static var KEY_UP_ARROW:int;
		public static var KEY_DOWN_ARROW:int;
		public static var KEY_HOME:int;
		public static var KEY_END:int;
		public static var KEY_PAGE_UP:int;
		public static var KEY_PAGE_DOWN:int;
		public static var KEY_INSERT:int;
		public static var KEY_DELETE:int;
		public static var KEY_F1:int;
		public static var KEY_F2:int;
		public static var KEY_F3:int;
		public static var KEY_F4:int;
		public static var KEY_F5:int;
		public static var KEY_F6:int;
		public static var KEY_F7:int;
		public static var KEY_F8:int;
		public static var KEY_F9:int;
		public static var KEY_F10:int;
		public static var KEY_F11:int;
		public static var KEY_F12:int;
		public static var KEY_BACKSPACE:int;
		public static var KEY_TAB:int;
		public static var KEY_ENTER:int;
		public static var KEY_RETURN:int;
		
		// Keyboard modifiers.
		public static var KEY_SHIFT:int;
		public static var KEY_CONTROL:int;
		public static var KEY_ALT:int;
		public static var KEY_COMMAND:int;
		
		// Mouse buttons.
		public static var MOUSE_LEFT_BUTTON:int;
		public static var MOUSE_MIDDLE_BUTTON:int;
		public static var MOUSE_RIGHT_BUTTON:int;
		
		// Mouse state.
		public static var MOUSE_UP:int;
		public static var MOUSE_DOWN:int;
		
		// Mouse modifiers.
		public static var MODIFIER_CONTROL:int;
		public static var MODIFIER_LBUTTON:int;
		public static var MODIFIER_MBUTTON:int;
		public static var MODIFIER_RBUTTON:int;
		public static var MODIFIER_SHIFT:int;
		
		public function WinApplication( width:int, height:int, clearColor:Color ) 
		{
			_width = width;
			_height = height;
			_clearColor = clearColor;
			
			_lastTime = -1;
			_accumulatedTime = 0;
			_frameRate = 0;
			_frameCount = 0;
			_accumulatedFrameCount = 0;
			_timer = 30;
			_maxTimer = 30;
			
			_colorFormat = TextureFormat.RGBA8888;
			_depthStencilFormat = TextureFormat.RGBA8888;
			
			_isDisposed = false;
		}
		
		override public function dispose():void 
		{
			
			_isDisposed = true;
			super.dispose();
		}
		
		//TODO
		/*
		public function main( numArguments:int, args:Array):void
		{
			// virtual method
		}
		*/
		
		public function getAspectRatio():Number
		{
			return _width / _height;
		}
		
		public function get renderer():Renderer
		{
			return _renderer;
		}
		
		// callbacks
		public function onInitialize():Boolean
		{
			_renderer.clearColor = _clearColor;
			return true;
		}
		
		public function onTerminate():void
		{
			// virtual method
		}
		
		public function onMove():void
		{
			// virtual method
			// TODO Air we should be able to implement this.
		}
		
		public function onResize( width:int, height:int ):void
		{
			if ( width > 0 && height > 0 )
			{
				if ( _renderer )
				{
					_renderer.resize( width, height );
				}
				_width = width;
				_height = height;
			}
		}
		
		[Inline]
		public final function onPrecreate():Boolean
		{
			// virtual method
			return true;
		}
		
		[Inline]
		public final function onPreidle():void
		{
			// The default behavior is to clear the buffers before the window is
			// displayed for the first time.
			_renderer.clearBuffers();
		}
		
		[Inline]
		public final function onDisplay():void
		{
			// virtual method
		}
		
		public function onIdle():void
		{
			// virtual method
		}
		
		//TODO 
		public function onKeyDown( key:String, x:int, y:int ):Boolean
		{
			if ( key == '?' )
			{
				resetTime();
				return true;
			}
			return false;
		}
		
		[Inline]
		public final function onKeyUp( key:String, x:int, y:int ):Boolean
		{
			// virtual method
			return false;
		}
		
		public function onSpecialKeyUp( key:int, x:int, y:int ):Boolean
		{
			// virtual method
			return false;
		}
		
		public function onSpecialKeyDown( key:int, x:int, y:int ):Boolean
		{
			// virtual method
			return false;
		}
		
		[Inline]
		public function onMouseClick( button:int, state:int, x:int, y:int, motifiers:uint ):Boolean
		{
			// virtual method
			return false;
		}
		
		public function onMotion( button:int, x:int, y:int, modifiers:uint ):Boolean
		{
			// virtual method
			return false;
		}
		
		[Inline]
		public final function onPassiveMotion( x:int, y:int ):Boolean
		{
			// virtual method
			return false;
		}
		
		[Inline]
		public final function onMouseWheel( delta:int, x:int, y:int, modifiers:uint ):Boolean
		{
			// virtual method
			return false;
		}
		
		/*
		 * //TODO with mouse lock, can we set this?
		public function setMousePosition( x:int, y:int ):void
		{
			
		}
		*/
		public function getMousePosition():Array
		{
			return [];
		}
		
		protected function resetTime():void
		{
			_lastTime = -1;
		}
		
		protected function measureTime():void
		{
			if ( _lastTime == -1 )
			{
				_lastTime = getTimer() / 1000; //TODO evaluate timer
				_accumulatedTime = 0;
				_frameRate = 0;
				_frameCount = 0;
				_accumulatedFrameCount = 0;
				_timer = _maxTimer;
			}
			
			if ( --_timer == 0 )
			{
				var dCurrentTime:Number = getTimer() / 1000; //TODO evaluate timer
				var dDelta:Number = dCurrentTime - _lastTime;
				_lastTime = dCurrentTime;
				_accumulatedTime += dDelta;
				_accumulatedFrameCount += _frameCount;
				_frameCount = 0;
				_timer = _maxTimer;
			}
		}
		
		protected function updateFrameCount():void
		{
			++_frameCount;
		}
		
		protected function drawFrameRate( x:int, y:int, color:Color ):void
		{
			if ( _accumulatedTime > 0 )
			{
				_frameRate = _accumulatedFrameCount / _accumulatedTime;
			}
			else
			{
				_frameRate = 0;
			}
			
			//TODO send to textfield
			trace( "Framerate: " + _frameRate );
		}
		
	}

}