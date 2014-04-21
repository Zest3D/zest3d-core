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
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import io.plugin.core.graphics.Color;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import io.plugin.math.algebra.HMatrix;
	import io.plugin.math.base.MathHelper;
	import io.plugin.utils.KeyMapper;
	import zest3d.renderers.agal.AGALRenderer;
	import zest3d.renderers.agal.AGALRendererInput;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Spatial;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class AGALApplication extends WindowApplication implements IDisposable 
	{
		
		protected var _camera: Camera;
		protected var _worldAxis: Array;
		protected var _trnSpeed: Number;
		protected var _trnSpeedFactor: Number;
		protected var _rotSpeed: Number;
		protected var _rotSpeedFactor: Number;
		protected var _cameraMoveable: Boolean;
		
		protected var _motionObject: Spatial;
		protected var _doRoll: int;
		protected var _doYaw: int;
		protected var _doPitch: int;
		
		protected var _xTrack0: Number;
		protected var _yTrack0: Number;
		protected var _xTrack1: Number;
		protected var _yTrack1: Number;
		
		protected var _saveRotate: HMatrix;
		protected var _useTrackBall: Boolean;
		protected var _trackBallDown: Boolean;
		
		private var _keyMapper: KeyMapper;
		
		
		public function AGALApplication( clearColor: Color ) 
		{
			super( clearColor );
			
			_numMultisamples = 2;
			
			_trnSpeed = 0;
			_rotSpeed = 0;
			_doRoll = 0;
			_doYaw = 0;
			_doPitch = 0;
			_xTrack0 = 0;
			_yTrack0 = 0;
			_xTrack1 = 0;
			_yTrack1 = 0;
			
			_worldAxis = [];
			_worldAxis[ 0 ] = AVector.ZERO;
			_worldAxis[ 1 ] = AVector.ZERO;
			_worldAxis[ 2 ] = AVector.ZERO;
			
		}
		
		override protected function onAddedToStage(e:Event):void 
		{
			stage.stage3Ds[ 0 ].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated );
			stage.stage3Ds[ 0 ].requestContext3D();
		}
		
		protected function onContext3DCreated( e: Event ): void
		{
			stage.stage3Ds[ 0 ].removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated );
			
			var stage3D: Stage3D = Stage3D( e.currentTarget );
			stage3D.context3D.enableErrorChecking = true;
			
			var rendererInput: AGALRendererInput = new AGALRendererInput( stage3D.context3D );
			
			_renderer = new AGALRenderer( rendererInput, stage.stageWidth, stage.stageHeight, _colorFormat, _depthStencilFormat, 2 );
			
			if ( onInitialize() )
			{
				onPreidle();
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
			
		}
		
		private var count:int;
		protected function onEnterFrame( e: Event ): void
		{
			onIdle();
			/*
			if ( count > 0 )
			{
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
			count++;*/
		}
		
		override public function onInitialize():Boolean 
		{
			if ( !super.onInitialize() )
			{
				return false;
			}
			
			_camera = new Camera();
			_renderer.camera = _camera;
			
			_keyMapper = new KeyMapper( stage );
			_keyMapper.addKeyDown( Keyboard.W, dummy, false );
			_keyMapper.addKeyDown( Keyboard.S, dummy, false );
			_keyMapper.addKeyDown( Keyboard.HOME, dummy, false );
			_keyMapper.addKeyDown( Keyboard.END, dummy, false );
			_keyMapper.addKeyDown( Keyboard.LEFT, dummy, false );
			_keyMapper.addKeyDown( Keyboard.RIGHT, dummy, false );
			_keyMapper.addKeyDown( Keyboard.UP, dummy, false );
			_keyMapper.addKeyDown( Keyboard.DOWN, dummy, false );
			_keyMapper.addKeyDown( Keyboard.A, dummy, false );
			_keyMapper.addKeyDown( Keyboard.D, dummy, false );
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMotion );
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp );
			
			return true;
		}
		
		protected function onMouseDown( e:MouseEvent ): Boolean
		{
			/*if ( !_useTrackBall )
			{
				return false;
			}*/
			_leftButtonPressed = true;
			
			var height: int = stage.stageHeight
			var width: int = stage.stageWidth;
			
			var x: Number = e.stageX;
			var y: Number = e.stageY;
			
			var mult: Number = 1 / ( width >= height ? height : width );
			
			_saveRotate = _motionObject.localTransform.rotate;
			_xTrack0 = ( 2 * x - width ) * mult;
			_yTrack0 = ( 2 * (height - 1 - y ) - height ) * mult;
			
			return false;
		}
		
		protected function onMouseUp( e: MouseEvent ): void
		{
			_leftButtonPressed = false;
		}
		
		protected var _leftButtonPressed: Boolean;
		protected function onMotion( e: MouseEvent ): Boolean
		{
			if ( !_leftButtonPressed )
			{
				return false;
			}
			
			var height: int = stage.stageHeight
			var width: int = stage.stageWidth;
			var x: Number = e.stageX;
			var y: Number = e.stageY;
			
			/*
			if ( !_useTrackBall ||
				 !_trackBallDown ||
				 !_motionObject )
			{
				return false;
			}
			*/
			
			
			var mult: Number = 1 / ( width >= height ? height : width );
			_xTrack1 = ( 2 * x - width ) * mult;
			_yTrack1 = ( 2 * ( height - 1 - y ) - height ) * mult;
			
			rotateTrackBall( _xTrack0, _yTrack0, _xTrack1, _yTrack1 );
			
			return true;
		}
		
		private function dummy(): void
		{
		}
		
		override public function onTerminate():void 
		{
			_renderer.camera = null;
			
			_camera.dispose();
			_camera = null;
			
			_motionObject.dispose();
			_motionObject = null;
			
			super.onTerminate();
		}
		
		protected function rotateTrackBall( x0: Number, y0: Number, x1: Number, y1: Number ): void
		{
			
			if ( (x0 == x1 && y0 == y1 ) || !_camera )
			{
				return;
			}
			
			var length: Number = Math.sqrt( x0 * x0 + y0 * y0 );
			var invLength: Number;
			var z0: Number;
			var z1: Number;
			
			if ( length > 1 )
			{
				invLength = 1 / length;
				x0 *= invLength;
				y0 *= invLength;
				z0 = 0;
			}
			else
			{
				z0 = 1 - x0 * x0 - y0 * y0;
				z0 = ( z0 <= 0 ? 0 : Math.sqrt( z0 ) );
			}
			z0 *= -1;
			
			var vec0: AVector = new AVector( z0, y0, x0 );
			
			length = Math.sqrt( x1 * x1 + y1 * y1 );
			if ( length > 1 )
			{
				invLength = 1 / length;
				x1 *= invLength;
				y1 *= invLength;
				z1 = 0;
			}
			else
			{
				z1 = 1 - x1 * x1 - y1 * y1;
				z1 = (z1 <= 0 ? 0 : Math.sqrt( z1 ) );
			}
			z1 *= -1;
			
			var vec1: AVector = new AVector( z1, y1, x1 );
			
			var axis: AVector = vec0.crossProduct( vec1 );
			var dot: Number = vec0.dotProduct( vec1 );
			var angle: Number;
			
			if ( axis.normalize() > MathHelper.ZERO_TOLLERANCE )
			{
				angle = Math.acos( dot );
			}
			else
			{
				if ( dot < 0 )
				{
					invLength = MathHelper.invSqrt( x0 * x0 + y0 * y0);
					axis.x = y0 * invLength;
					axis.y = -x0 * invLength;
					axis.z = 0;
					angle = Math.PI;
				}
				else
				{
					axis = AVector.UNIT_X;
					angle = 0;
				}
			}
			
			var worldAxis: AVector = _camera.dVector.scale( axis.x )
							   .add( _camera.uVector.scale( axis.y ) )
							   .add( _camera.rVector.scale( axis.z ) );
			
			var trackRotate: HMatrix = HMatrix.fromAxisAngle( worldAxis, angle );
			
			var parent: Spatial = _motionObject.parent;
			var localRot: HMatrix;
			
			if ( parent )
			{
				var parWorRotate: HMatrix = parent.worldTransform.rotate;
				localRot = parWorRotate.transposeTimes( trackRotate ).multiply( parWorRotate ).multiply( _saveRotate );
			}
			else
			{
				localRot = trackRotate.multiply( _saveRotate );
			}
			
			localRot.orthonormalize();
			
			_motionObject.localTransform.rotate = localRot;
		}
		
		protected function initializeCameraMotion( trnSpeed: Number, rotSpeed: Number, trnSpeedFactor: Number = 2, rotSpeedFactor: Number = 2 ): void
		{
			_cameraMoveable = true;
			
			_trnSpeed = trnSpeed;
			_rotSpeed = rotSpeed;
			_trnSpeedFactor = trnSpeedFactor;
			_rotSpeedFactor = rotSpeedFactor;
			
			_worldAxis[ 0 ] = _camera.dVector;
			_worldAxis[ 1 ] = _camera.uVector;
			_worldAxis[ 2 ] = _camera.rVector;
		}
		
		protected function moveCamera(): Boolean
		{
			if ( !_cameraMoveable )
			{
				return false;
			}
			
			var bMoved: Boolean = false;
			
			if( _keyMapper.isKeyDown( Keyboard.W) )
			{
				moveForward();
				bMoved = true;
			}
			
			if ( _keyMapper.isKeyDown( Keyboard.S ) )
			{
				moveBackward();
				bMoved = true;
			}
			
			if ( _keyMapper.isKeyDown( Keyboard.HOME ) )
			{
				moveUp();
				bMoved = true;
			}
			
			if ( _keyMapper.isKeyDown( Keyboard.END ) )
			{
				moveDown();
				bMoved = true;
			}
			
			if ( _keyMapper.isKeyDown( Keyboard.LEFT ) )
			{
				turnLeft();
				bMoved = true;
			}
			
			if ( _keyMapper.isKeyDown( Keyboard.RIGHT ) )
			{
				turnRight();
				bMoved = true;
			}
			
			if ( _keyMapper.isKeyDown( Keyboard.UP ) )
			{
				lookUp();
				bMoved = true;
			}
			
			if ( _keyMapper.isKeyDown( Keyboard.DOWN ) )
			{
				lookDown();
				bMoved = true;
			}
			
			if ( _keyMapper.isKeyDown( Keyboard.D ) )
			{
				moveRight();
				bMoved = true;
			}
			
			if ( _keyMapper.isKeyDown( Keyboard.A ) )
			{
				moveLeft();
				bMoved = true;
			}
			
			if ( bMoved )
			{
				onCameraMotion();
			}
			return bMoved;
		}
		
		protected function onCameraMotion(): void
		{
			
		}
		
		protected function moveForward(): void
		{
			var pos: APoint = _camera.position;
			var worldAxis: AVector = _worldAxis[ 0 ];
			
			pos.addAVectorEq( worldAxis.scale( _trnSpeed ) );
			
			_camera.position = pos;
		}
		
		protected function moveBackward(): void
		{
			var pos: APoint = _camera.position;
			var worldAxis: AVector = _worldAxis[ 0 ];
			
			pos.subtractAVectorEq( worldAxis.scale( _trnSpeed ) );
			
			_camera.position = pos;
		}
		
		protected function moveUp(): void
		{
			var pos: APoint = _camera.position;
			var worldAxis: AVector = _worldAxis[ 1 ];
			
			pos.addAVectorEq( worldAxis.scale( _trnSpeed ) );
			
			_camera.position = pos;
		}
		
		protected function moveDown(): void
		{
			var pos: APoint = _camera.position;
			var worldAxis: AVector = _worldAxis[ 1 ];
			
			pos.subtractAVectorEq( worldAxis.scale( _trnSpeed ) );
			
			_camera.position = pos;
		}
		
		protected function moveLeft(): void
		{
			var pos: APoint = _camera.position;
			var worldAxis: AVector = _worldAxis[ 2 ];
			
			pos.subtractAVectorEq( worldAxis.scale( _trnSpeed ) );
			
			_camera.position = pos;
		}
		
		protected function moveRight(): void
		{
			var pos: APoint = _camera.position;
			var worldAxis: AVector = _worldAxis[ 2 ];
			
			pos.addAVectorEq( worldAxis.scale( _trnSpeed ) );
			
			_camera.position = pos;
		}
		
		protected function turnLeft(): void
		{
			var incr: HMatrix = HMatrix.fromAxisAngle( _worldAxis[ 1 ], _rotSpeed );
			_worldAxis[ 0 ] = incr.multiplyAVector( _worldAxis[ 0 ] );
			_worldAxis[ 2 ] = incr.multiplyAVector( _worldAxis[ 2 ] );
			
			var dVector:AVector = incr.multiplyAVector( _camera.dVector );
			var uVector:AVector = incr.multiplyAVector( _camera.uVector );
			var rVector:AVector = incr.multiplyAVector( _camera.rVector );
			
			_camera.setAxes( dVector, uVector, rVector );
		}
		
		protected function turnRight(): void
		{
			var incr: HMatrix = HMatrix.fromAxisAngle( _worldAxis[ 1 ], -_rotSpeed );
			_worldAxis[ 0 ] = incr.multiplyAVector( _worldAxis[ 0 ] );
			_worldAxis[ 2 ] = incr.multiplyAVector( _worldAxis[ 2 ] );
			
			var dVector:AVector = incr.multiplyAVector( _camera.dVector );
			var uVector:AVector = incr.multiplyAVector( _camera.uVector );
			var rVector:AVector = incr.multiplyAVector( _camera.rVector );
			
			_camera.setAxes( dVector, uVector, rVector );
		}
		
		protected function lookUp(): void
		{
			var incr: HMatrix = HMatrix.fromAxisAngle( _worldAxis[ 2 ], _rotSpeed );
			
			var dVector:AVector = incr.multiplyAVector( _camera.dVector );
			var uVector:AVector = incr.multiplyAVector( _camera.uVector );
			var rVector:AVector = incr.multiplyAVector( _camera.rVector );
			
			_camera.setAxes( dVector, uVector, rVector );
		}
		
		protected function lookDown(): void
		{
			var incr: HMatrix = HMatrix.fromAxisAngle( _worldAxis[ 2 ], -_rotSpeed );
			
			var dVector:AVector = incr.multiplyAVector( _camera.dVector );
			var uVector:AVector = incr.multiplyAVector( _camera.uVector );
			var rVector:AVector = incr.multiplyAVector( _camera.rVector );
			
			_camera.setAxes( dVector, uVector, rVector );
		}
		
		protected function initializeObjectMotion( motionObject: Spatial ): void
		{
			_motionObject = motionObject;
		}
		
		protected function moveObject():Boolean
		{
			if ( !_cameraMoveable || !_motionObject )
			{
				return false;
			}
			
			if ( !_trackBallDown )
			{
				return true;
			}
			
			var parent: Spatial = _motionObject.parent;
			var axis: AVector;
			var angle: Number;
			var rot: HMatrix;
			var incr: HMatrix;
			
			var axisTuple: Array;
			
			if ( _doRoll )
			{
				rot = _motionObject.localTransform.rotate;
				angle = _doRoll * _rotSpeed;
				if ( parent )
				{
					axisTuple = parent.worldTransform.rotate.getColumn( 0 );
					axis = AVector.fromTuple( axisTuple );
				}
				else
				{
					axis = AVector.UNIT_X;
				}
				
				incr = HMatrix.fromAxisAngle( axis, angle );
				rot = incr.multiply( rot );
				rot.orthonormalize();
				_motionObject.localTransform.rotate = rot;
				
				return true;
			}
			
			if ( _doYaw )
			{
				rot = _motionObject.localTransform.rotate;
				angle = _doYaw * _rotSpeed;
				if ( parent )
				{
					axisTuple = parent.worldTransform.rotate.getColumn( 1 );
					axis = AVector.fromTuple( axisTuple );
				}
				else
				{
					axis = AVector.UNIT_Y;
				}
				
				incr = HMatrix.fromAxisAngle( axis, angle );
				rot = incr.multiply( rot );
				rot.orthonormalize();
				
				_motionObject.localTransform.rotate = rot;
				
				return true;
			}
			
			if ( _doPitch )
			{
				rot = _motionObject.localTransform.rotate;
				angle = _doPitch * _rotSpeed;
				
				if ( parent )
				{
					axisTuple = parent.worldTransform.rotate.getColumn( 2 );
					axis = AVector.fromTuple( axisTuple );
				}
				else
				{
					axis = AVector.UNIT_Z;
				}
				
				incr = HMatrix.fromAxisAngle( axis, angle );
				rot = incr.multiply( rot );
				rot.orthonormalize();
				
				_motionObject.localTransform.rotate = rot;
				
				return true;
			}
			
			return false;
		}
		
	}

}