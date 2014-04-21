package zest3d.scenegraph 
{
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import io.plugin.math.algebra.HMatrix;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class CameraNode extends Node implements IDisposable 
	{
		
		protected var _camera:Camera;
		
		public function CameraNode( camera:Camera = null ) 
		{
			_camera = camera;
			if ( _camera )
			{
				localTransform.translate = _camera.position;
				var rotation:HMatrix = HMatrix.fromTuple( _camera.dVector.toTuple(),
														  _camera.uVector.toTuple(),
														  _camera.rVector.toTuple(),
														  APoint.ORIGIN.toTuple(),
														  true );
				localTransform.rotate = rotation;
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
		}
		
		public function set camera( camera:Camera ):void
		{
			_camera = camera;
			
			localTransform.translate = _camera.position;
			var rotation:HMatrix = HMatrix.fromTuple( _camera.dVector.toTuple(),
													  _camera.uVector.toTuple(),
													  _camera.rVector.toTuple(),
													  APoint.ORIGIN.toTuple(),
													  true );
			localTransform.rotate = rotation;
			
			update();
		}
		
		[Inline]
		public final function get camera( ):Camera
		{
			return _camera;
		}
		
		// virtual
		override protected function updateWorldData(applicationTime:Number):void 
		{
			super.updateWorldData( applicationTime );
			if ( _camera )
			{
				var camPosition:APoint = worldTransform.translate;
				
				var col0:Array = worldTransform.rotate.getColumn( 0 );
				var col1:Array = worldTransform.rotate.getColumn( 1 );
				var col2:Array = worldTransform.rotate.getColumn( 2 );
				
				//TODO pool this object creation
				var camDVector:AVector = new AVector( col0[0], col0[1], col0[2] );
				var camUVector:AVector = new AVector( col1[0], col1[1], col1[2] );
				var camRVector:AVector = new AVector( col2[0], col2[1], col2[2] );
				
				_camera.setFrame( camPosition, camDVector, camUVector, camRVector );
			}
		}
	}

}