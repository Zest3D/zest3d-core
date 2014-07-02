package zest3d.applications 
{
	import plugin.core.graphics.Color;
	import plugin.core.interfaces.IDisposable;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.AVector;
	import plugin.math.algebra.HMatrix;
	import plugin.math.base.MathHelper;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Spatial;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class WinApplicationExt extends WinApplication implements IDisposable 
	{
		
		protected var _camera:Camera;
		protected var _worldAxis:Vector.<AVector>;
		protected var _trnSpeed:Number;
		protected var _trnSpeedFactor:Number;
		protected var _rotSpeed:Number;
		protected var _rotSpeedFactor:Number;
		protected var _upArrowPressed:Boolean;
		protected var _downArrowPressed:Boolean;
		protected var _leftArrowPressed:Boolean;
		protected var _rightArrowPressed:Boolean;
		protected var _pgUpPressed:Boolean;
		protected var _pgDownPressed:Boolean;
		protected var _homePressed:Boolean;
		protected var _endPressed:Boolean;
		protected var _insertPressed:Boolean;
		protected var _deletePressed:Boolean;
		protected var _cameraMoveable:Boolean;
		
		protected var _motionObject:Spatial;
		
		protected var _doRoll:int;
		protected var _doYaw:int;
		protected var _doPitch:int;
		
		protected var _xTrack0:Number;
		protected var _yTrack0:Number;
		protected var _xTrack1:Number;
		protected var _yTrack1:Number;
		
		protected var _saveRotate:HMatrix;
		protected var _useTrackBall:Boolean;
		protected var _trackBallDown:Boolean;
		
		private var _isDisposed:Boolean;
		
		public function WinApplicationExt( width:int, height:int, clearColor:Color ) 
		{
			_isDisposed = false;
			
			super( width, height, clearColor );
			
			_trnSpeed = 0;
			_rotSpeed = 0;
			_upArrowPressed = false;
			_downArrowPressed = false;
			_leftArrowPressed = false;
			_rightArrowPressed = false;
			_pgUpPressed = false;
			_pgDownPressed = false;
			_homePressed = false;
			_endPressed = false;
			_insertPressed = false;
			_deletePressed = false;
			_cameraMoveable = false;
			
			_doRoll = 0;
			_doYaw = 0;
			_doPitch = 0;
			_xTrack0 = 0;
			_xTrack1 = 0;
			_yTrack0 = 0;
			_yTrack1 = 0;
			_useTrackBall = true;
			_trackBallDown = false;
			
			
			_worldAxis = new Vector.<AVector>( 3, true );
			_worldAxis[0] = AVector.ZERO;
			_worldAxis[1] = AVector.ZERO;
			_worldAxis[2] = AVector.ZERO;
		}
		
		override public function get isDisposed():Boolean 
		{
			return _isDisposed;
		}
		
		// event callbacks
		override public function onInitialize():Boolean 
		{
			if ( !super.onInitialize() )
			{
				return false;
			}
			
			_camera = new Camera();
			_renderer.camera = _camera;
			_motionObject = null;
			return true;
		}
		
		override public function onTerminate():void 
		{
			_renderer.camera.dispose();
			_motionObject.dispose();
			
			_renderer.camera = null;
			_motionObject = null;
			
			super.onTerminate();
		}
		
		override public function onKeyDown(key:String, x:int, y:int):Boolean 
		{
			if ( super.onKeyDown(key, x, y) )
			{
				return true;
			}
			
			switch( key )
			{
				case 't':
						if ( _cameraMoveable )
						{
							_trnSpeed /= _trnSpeedFactor;
						}
						return true;
					break;
				case 'T':
						if ( _cameraMoveable )
						{
							_trnSpeed *= _trnSpeedFactor;
						}
						return true;
					break;
				case 'r':
						if ( _cameraMoveable )
						{
							_rotSpeed / _rotSpeedFactor;
						}
						return true;
					break;
				case 'R':
						if ( _cameraMoveable )
						{
							_rotSpeed *= _rotSpeedFactor;
						}
						return true;
					break;
				case '?':
						resetTime();
						return true;
					break;
			}
			return false;
		}
		
		override public function onSpecialKeyDown(key:int, x:int, y:int):Boolean 
		{
			if (_cameraMoveable)
			{
				if (key == KEY_LEFT_ARROW)
				{
					_leftArrowPressed = true;
					return true;
				}
				if (key == KEY_RIGHT_ARROW)
				{
					_rightArrowPressed = true;
					return true;
				}
				if (key == KEY_UP_ARROW)
				{
					_upArrowPressed = true;
					return true;
				}
				if (key == KEY_DOWN_ARROW)
				{
					_downArrowPressed = true;
					return true;
				}
				if (key == KEY_PAGE_UP)
				{
					_pgUpPressed = true;
					return true;
				}
				if (key == KEY_PAGE_DOWN)
				{
					_pgDownPressed = true;
					return true;
				}
				if (key == KEY_HOME)
				{
					_homePressed = true;
					return true;
				}
				if (key == KEY_END)
				{
					_endPressed = true;
					return true;
				}
				if (key == KEY_INSERT)
				{
					_insertPressed = true;
					return true;
				}
				if (key == KEY_DELETE)
				{
					_deletePressed = true;
					return true;
				}
			}
			
			if (_motionObject)
			{
				if (key == KEY_F1)
				{
					_doRoll = -1;
					return true;
				}
				if (key == KEY_F2)
				{
					_doRoll = 1;
					return true;
				}
				if (key == KEY_F3)
				{
					_doYaw = -1;
					return true;
				}
				if (key == KEY_F4)
				{
					_doYaw = 1;
					return true;
				}
				if (key == KEY_F5)
				{
					_doPitch = -1;
					return true;
				}
				if (key == KEY_F6)
				{
					_doPitch = 1;
					return true;
				}
			}
			return false;
		}
		
		override public function onSpecialKeyUp(key:int, x:int, y:int):Boolean 
		{
			if (_cameraMoveable)
			{
				if (key == KEY_LEFT_ARROW)
				{
					_leftArrowPressed = false;
					return true;
				}
				if (key == KEY_RIGHT_ARROW)
				{
					_rightArrowPressed = false;
					return true;
				}
				if (key == KEY_UP_ARROW)
				{
					_upArrowPressed = false;
					return true;
				}
				if (key == KEY_DOWN_ARROW)
				{
					_downArrowPressed = false;
					return true;
				}
				if (key == KEY_PAGE_UP)
				{
					_pgUpPressed = false;
					return true;
				}
				if (key == KEY_PAGE_DOWN)
				{
					_pgDownPressed = false;
					return true;
				}
				if (key == KEY_HOME)
				{
					_homePressed = false;
					return true;
				}
				if (key == KEY_END)
				{
					_endPressed = false;
					return true;
				}
				if (key == KEY_INSERT)
				{
					_insertPressed = false;
					return true;
				}
				if (key == KEY_DELETE)
				{
					_deletePressed = false;
					return true;
				}
			}
			
			if (_motionObject)
			{
				if (key == KEY_F1)
				{
					_doRoll = 0;
					return true;
				}
				if (key == KEY_F2)
				{
					_doRoll = 0;
					return true;
				}
				if (key == KEY_F3)
				{
					_doYaw = 0;
					return true;
				}
				if (key == KEY_F4)
				{
					_doYaw = 0;
					return true;
				}
				if (key == KEY_F5)
				{
					_doPitch = 0;
					return true;
				}
				if (key == KEY_F6)
				{
					_doPitch = 0;
					return true;
				}
			}
			return false;
		}
		
		override public function onMouseClick(button:int, state:int, x:int, y:int, modifiers:uint):Boolean 
		{
			if ( !_useTrackBall
			  || button != MOUSE_LEFT_BUTTON
			  || !_motionObject )
			{
				return false;
			}
			
			var mult:Number = 1 / (_width >= _height ? _height : _width);
			
			if ( state == MOUSE_DOWN )
			{
				_trackBallDown = true;
				_saveRotate = _motionObject.localTransform.rotate;
				_xTrack0 = (2 * x - _width) * mult;
				_yTrack0 = (2 * (_height - 1 - y) - _height) * mult;
			}
			else
			{
				_trackBallDown = false;
			}
			return true;
		}
		
		override public function onMotion( button:int, x:int, y:int, modifiers:uint ):Boolean
		{
			if( !_useTrackBall
				||  button != MOUSE_LEFT_BUTTON
				||  !_trackBallDown
				||  !_motionObject )
				{
					return false;
				}
				
				// Get the ending point.
				var mult:Number = 1/( _width >= _height ? _height : _width );
				_xTrack0 = (2 * x - _width) * mult;
				_yTrack0 = (2 * (_height - 1 - y) - _height) * mult;
				
				// Update the object's local rotation.
				rotateTrackBall(_xTrack0, _yTrack0, _xTrack1, _yTrack1);
				return true;
		}
		
		protected function initializeCameraMotion( trnSpeed:Number, rotSpeed:Number, trnSpeedFactor:Number = 2,
												   rotSpeedFactor:Number = 2 ):void
		{
			_cameraMoveable = true;
			
			_trnSpeed = trnSpeed;
			_rotSpeed = rotSpeed;
			_trnSpeedFactor = trnSpeedFactor;
			_rotSpeedFactor = rotSpeedFactor;
			
			_worldAxis[0] = _camera.dVector;
			_worldAxis[1] = _camera.uVector;
			_worldAxis[2] = _camera.rVector;
		}
		
		protected function moveCamera():Boolean
		{
			if (!_cameraMoveable)
			{
				return false;
			}
			
			var moved:Boolean = false;
			
			if (_upArrowPressed)
			{
				moveForward();
				moved = true;
			}
			
			if (_downArrowPressed)
			{
				moveBackward();
				moved = true;
			}
			
			if (_homePressed)
			{
				moveUp();
				moved = true;
			}
			
			if (_endPressed)
			{
				moveDown();
				moved = true;
			}
			
			if (_leftArrowPressed)
			{
				turnLeft();
				moved = true;
			}
			
			if (_rightArrowPressed)
			{
				turnRight();
				moved = true;
			}
			
			if (_pgUpPressed)
			{
				lookUp();
				moved = true;
			}
			
			if (_pgDownPressed)
			{
				lookDown();
				moved = true;
			}
			
			if (_insertPressed)
			{
				moveRight();
				moved = true;
			}
			
			if (_deletePressed)
			{
				moveLeft();
				moved = true;
			}
			
			return moved;
		}
		
		protected function moveForward():void
		{
			var pos:APoint = _camera.position;
			pos.addAVectorEq( _worldAxis[0].scale( _trnSpeed ) );
			_camera.position = pos;
		}
		
		protected function moveBackward():void
		{
			var pos:APoint = _camera.position;
			pos.subtractAVectorEq( _worldAxis[0].scale( _trnSpeed ) );
			_camera.position = pos;
		}
		
		protected function moveUp():void
		{
			var pos:APoint = _camera.position;
			pos.addAVectorEq( _worldAxis[1].scale( _trnSpeed ) );
			_camera.position = pos;
		}
		
		protected function moveDown():void
		{
			var pos:APoint = _camera.position;
			pos.subtractAVectorEq( _worldAxis[1].scale( _trnSpeed ) );
			_camera.position = pos;
		}
		
		protected function moveLeft():void
		{
			var pos:APoint = _camera.position;
			pos.subtractAVectorEq( _worldAxis[2].scale( _trnSpeed ) );
			_camera.position = pos;
		}
		
		public function moveRight():void
		{
			var pos:APoint = _camera.position;
			pos.addAVectorEq( _worldAxis[2].scale( _trnSpeed ) );
			_camera.position = pos;
		}
		
		protected function turnLeft():void
		{
			var incr:HMatrix = HMatrix.fromAxisAngle( _worldAxis[1], _rotSpeed );
			
			_worldAxis[0] = incr.multiplyAVector( _worldAxis[0] );
			_worldAxis[2] = incr.multiplyAVector( _worldAxis[2] );
			
			var dVector:AVector = incr.multiplyAVector( _camera.dVector );
			var uVector:AVector = incr.multiplyAVector( _camera.uVector );
			var rVector:AVector = incr.multiplyAVector( _camera.rVector );
			_camera.setAxes( dVector, uVector, rVector );
		}
		
		protected function turnRight():void
		{
			var incr:HMatrix = HMatrix.fromAxisAngle( _worldAxis[1], -_rotSpeed );
			
			_worldAxis[0] = incr.multiplyAVector( _worldAxis[0] );
			_worldAxis[2] = incr.multiplyAVector( _worldAxis[2] );
			
			var dVector:AVector = incr.multiplyAVector( _camera.dVector );
			var uVector:AVector = incr.multiplyAVector( _camera.uVector );
			var rVector:AVector = incr.multiplyAVector( _camera.rVector );
			_camera.setAxes( dVector, uVector, rVector );
		}
		
		protected function lookUp():void
		{
			var incr:HMatrix = HMatrix.fromAxisAngle( _worldAxis[2], _rotSpeed );
			
			var dVector:AVector = incr.multiplyAVector( _camera.dVector );
			var uVector:AVector = incr.multiplyAVector( _camera.uVector );
			var rVector:AVector = incr.multiplyAVector( _camera.rVector );
			_camera.setAxes( dVector, uVector, rVector );
		}
		
		protected function lookDown():void
		{
			var incr:HMatrix = HMatrix.fromAxisAngle( _worldAxis[2], -_rotSpeed );
			
			var dVector:AVector = incr.multiplyAVector( _camera.dVector );
			var uVector:AVector = incr.multiplyAVector( _camera.uVector );
			var rVector:AVector = incr.multiplyAVector( _camera.rVector );
			_camera.setAxes( dVector, uVector, rVector );
		}
		
		protected function initializeObjectMotion( motionObject:Spatial ):void
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
		
		public function rotateTrackBall( x0:Number, y0:Number, x1:Number, y1:Number ):void
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
		
	}

}