package zest3d.applications 
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import plugin.core.graphics.Color;
	import plugin.core.interfaces.IDisposable;
	import zest3d.renderers.stage3d.Stage3DRenderer;
	import zest3d.renderers.stage3d.Stage3DRendererInput;
	import zest3d.scenegraph.Camera;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class Stage3DApplication extends WinApplicationExt implements IDisposable 
	{
		
		private static var gsButton:int = -1;
		
		public function Stage3DApplication() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler );
			super( 800, 600, new Color( 0.3, 0.6, 0.9, 1 ) );
		}
		
		private function onAddedToStageHandler(e:Event):void
		{
			_width = stage.stageWidth;
			_height = stage.stageHeight;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler );
			initListeners();
			requestContext();
		}
		
		private function initListeners():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler );
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler );
			stage.addEventListener(Event.RESIZE, onResizeHandler);
			
			
			addEventListener(MouseEvent.CLICK, onMouseClickHandler);
			addEventListener(MouseEvent.RIGHT_CLICK, onRightMouseClickHandler);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextCreateHandler );
		}
		
		private function requestContext():void
		{
			stage.stage3Ds[0].requestContext3D();
		}
		
		private function onContextCreateHandler(e:Event ):void
		{
			var stage3D:Stage3D = e.currentTarget as Stage3D;
			init( stage3D.context3D );
		}
		
		private function init( context:Context3D ):void
		{
			Camera.defaultDepthType = Camera.ZERO_TO_ONE; // TODO create a camera depth type
			var input:Stage3DRendererInput = new Stage3DRendererInput( context );
			_renderer = new Stage3DRenderer( input, _width, _height, _colorFormat, _depthStencilFormat, _numMultisamples );
			
			if ( onInitialize() )
			{
				onPreidle();
				addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			}
		}
		
		private function onResizeHandler(e:Event):void
		{
			var stage:Stage = e.currentTarget as Stage;
			var width:int = stage.stageWidth;
			var height:int = stage.stageHeight;
			if ( width < 50 ) { width = 50 };
			if ( height < 50 ) { height = 50 };
			onResize( width, height );
			onDisplay();
		}
		
		private function onEnterFrameHandler(e:Event ):void
		{
			onIdle();
			onDisplay();
		}
		
		private function onMouseClickHandler(e:MouseEvent):void
		{
			if ( e.buttonDown )
			{
				gsButton = 1;
			}
			else
			{
				gsButton = -1;
			}
			
			onMouseClick( 1, WinApplication.MOUSE_DOWN, e.stageX, e.stageY, 0 );
		}
		
		private function onRightMouseClickHandler(e:MouseEvent):void
		{
			
		}
		
		private function onMouseMoveHandler(e:MouseEvent):void
		{
			onMotion( gsButton, e.stageX, e.stageY, 0 );
		}
		
		private function onKeyDownHandler(e:KeyboardEvent):void
		{
			onKeyDown( String.fromCharCode(e.charCode), 0, 0 );
		}
		
		private function onKeyUpHandler(e:KeyboardEvent):void
		{
			
		}
		
	}

}