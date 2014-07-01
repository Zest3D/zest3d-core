package zest3d.applications 
{
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import zest3d.scenegraph.Culler;
	import zest3d.scenegraph.Node;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class Game extends Stage3DApplication implements IDisposable 
	{
		
		private var _scene:Node;
		private var _culler:Culler;
		
		public function Game()
		{
			_culler = new Culler();
		}
		
		override public function onInitialize():Boolean 
		{
			if ( !super.onInitialize() )
			{
				return false;
			}
			
			_camera.setFrustumFOV( 90, getAspectRatio(), .1, 1000 );
			var camPosition:APoint = new APoint( 0, 0, -5 );
			
			var dVector:AVector = AVector.UNIT_Z;
			var uVector:AVector = AVector.UNIT_Y_NEGATIVE;
			var rVector:AVector = dVector.crossProduct( uVector );
			
			_camera.setFrame( camPosition, dVector, uVector, rVector );
			
			createScene();
			initialize();
			_scene.update();
			
			_culler.camera = _camera;
			_culler.computeVisibleSet( _scene );
			
			initializeCameraMotion( 0.01, 0.01 );
			initializeObjectMotion( _scene );
			
			return true;
		}
		
		override public function onTerminate():void
		{
			//TODO
			super.onTerminate();
		}
		
		override public function onIdle():void 
		{
			measureTime();
			update();
			
			if ( moveCamera() )
			{
				_culler.computeVisibleSet( _scene );
			}
			
			if ( moveObject() )
			{
				_scene.update();
				_culler.computeVisibleSet( _scene );
			}
			
			if ( _renderer.preDraw() )
			{
				_renderer.clearBuffers();
				_renderer.drawVisibleSet( _culler.visibleSet );
				_renderer.postDraw();
				_renderer.displayColorBuffer();
			}
			updateFrameCount();
		}
		
		protected function update():void
		{
			// stub
		}
		
		protected function initialize():void
		{
			// stub
		}
		
		override public function onKeyDown(key:String, x:int, y:int):Boolean 
		{
			return super.onKeyDown(key, x, y);
		}
		
		private function createScene():void
		{
			_scene = new Node();
		}
		
		public function get scene():Node 
		{
			return _scene;
		}
		
		public function get culler():Culler 
		{
			return _culler;
		}
	}

}