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
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import io.plugin.core.graphics.Color;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import zest3d.geometry.SkyboxGeometry;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Culler;
	import zest3d.scenegraph.Node;
	import zest3d.scenegraph.Picker;
	import zest3d.scenegraph.PickRecord;
	import zest3d.scenegraph.Spatial;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Zest3DApplication extends AGALApplication implements IDisposable 
	{
		
		private var _scene: Node;
		private var _skybox:SkyboxGeometry;
		
		protected var _culler: Culler;
		
		protected var _picker:Picker;
		protected var _pickOrigin:APoint;
		protected var _pickDirection:AVector;
		
		private var _tf:TextField;
		
		public function Zest3DApplication( ) 
		{
			super( new Color( 0.3, 0.6, 0.9, 1 ) );
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_picker = new Picker();
			_pickOrigin = new APoint();
			_pickDirection = new AVector();
			
			_tf = new TextField();
			_tf.textColor = 0xFFFFFF;
			_tf.width = 1024;
			_tf.height = 640;
			_tf.selectable = false;
			addChild( _tf );
		}
		
		override public function dispose():void 
		{
			_picker.dispose();
			_pickOrigin.dispose();
			_pickDirection.dispose();
			
			_picker = null;
			_pickOrigin = null;
			_pickDirection = null;
			
			super.dispose();
		}
		
		private function onMouseWheel(e:MouseEvent):void
		{
			if ( e.delta > 0 )
			{
				moveForward();
				moveForward();
			}
			else
			{
				moveBackward();
				moveBackward();
			}
		}
		
		override public function onInitialize(): Boolean 
		{
			if ( !super.onInitialize() )
			{
				return false;
			}
			
			stage.addEventListener( Event.RESIZE, onResizeHandler );
			
			_camera.setFrustumFOV( 70, stage.stageWidth/stage.stageHeight, 0.01, 1000 );
			var camPosition: APoint = new APoint( 0, 0, -5 );
			var camDVector: AVector = AVector.UNIT_Z;
			var camUVector: AVector = AVector.UNIT_Y_NEGATIVE;
			var camRVector: AVector = camDVector.crossProduct( camUVector );
			
			_camera.setFrame( camPosition, camDVector, camUVector, camRVector );
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel );
			
			_scene = new Node();
			_scene.name = "scene";
			
			_culler = new Culler( _camera );
			_culler.computeVisibleSet( _scene );
			
			initializeCameraMotion( 0.1, 0.01 );
			initializeObjectMotion( _scene );
			
			initialize();
			return true;
		}
		
		private function onResizeHandler( e:Event ):void
		{
			onResize( stage.stageWidth, stage.stageHeight );
		}
		
		override public function onResize( width:int, height:int ):void 
		{
			if ( width < 50 )
			{
				width = 50;
			}
			if ( height < 50 )
			{
				height = 50;
			}
			super.onResize( width, height );
			_renderer.setViewport( 0, 0, width, height );
		}
		
		override public function onIdle():void 
		{
			measureTime();
			
			var appTime: Number = getTimer();
			update( appTime );
			
			if ( moveCamera() || moveObject() )
			{
				_culler.computeVisibleSet( _scene );
				
				if ( skybox )
				{
					skybox.position = _camera.position
					skybox.update();
				}
			}
			
			if ( moveObject() )
			{
				_scene.update( appTime );
			}
			
			draw( appTime );
			updateFrameCount();
		}
		
		private var _numVisibleObjects:int = 0;
		public function get numVisibleObjects():int
		{
			return _numVisibleObjects;
		}
		
		protected function update( appTime: Number ): void
		{
			// hook
		}
		
		protected function draw( appTime: Number ): void
		{
			if ( _renderer.preDraw() )
			{
				_renderer.clearBuffers();
				
				if( _skybox )
				{
					_renderer.drawVisual( _skybox );
				}
				//TODO render prioritization so this can be done between solid and alpha blended geometry
				_renderer.drawVisibleSet( _culler.visibleSet );
				
				_numVisibleObjects = _culler.visibleSet.numVisible;
				_renderer.postDraw();
				_renderer.displayColorBuffer();
			}
		}
		
		protected function initialize(): void
		{
			// hook
		}
		
		public function get scene():Node 
		{
			return _scene;
		}
		
		public function get skybox():SkyboxGeometry
		{
			return _skybox;
		}
		
		public function set skybox( skybox:SkyboxGeometry ):void
		{
			_skybox = skybox;
		}
		
		public function get camera():Camera
		{
			return _camera;
		}
		
		public function set camera( camera:Camera ):void
		{
			_camera = camera;
		}
		
		override protected function onMouseDown(e:MouseEvent):Boolean 
		{
			// TODO add granular pick levels
			/*
			var x:Number = e.localX;
			var y:Number = e.localY;
			_height = renderer.height;
			
			var viewport:Array = renderer.getViewport();
			var time:uint = getTimer();
			
			if ( _renderer.getPickRay( x, _height - 1 - y, _pickOrigin, _pickDirection ) )
			{
				_picker.execute( scene, _pickOrigin, _pickDirection, 0, Number.MAX_VALUE);
				
				if (_picker.records.length > 0)
				{
					var record:PickRecord = _picker.closestNonNegative;
					var object:Spatial = record.intersected;
					
					_tf.text = "Pick Records: " + _picker.records.length + "\nx: " + x + "\nheight: " + _height + "\norigin: " + _pickOrigin + "\ndirection: " + _pickDirection;
					
					
					for ( var i:int = 0; i < _picker.records.length; ++i )
					{
						_tf.appendText( "\n" );
						_tf.appendText( "\n=== Pick record " + i + " ===" );
						_tf.appendText( "\nRay t distance: " + _picker.records[i].t );
						_tf.appendText( "\nMesh polygon ID: " + _picker.records[i].triangle );
						_tf.appendText( "\nBarycentric coords: " + _picker.records[i].bary );
						_tf.appendText( "\nIntersected Mesh: " + _picker.records[i].intersected.name );
						
						_tf.appendText( "\n" );
					}
				}
				else
				{
					_tf.text = "Pick Records: 0\nx: " + x + "\nheight: " + (_height - 1) + "\norigin: " + _pickOrigin + "\ndirection: " + _pickDirection;
				}
				_tf.appendText( "\nTotal Time ms: " + (getTimer() - time) );
			}
			*/
			return super.onMouseDown(e);
		}
	}
}