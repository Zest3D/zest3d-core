package zest3d.shaderfloats.frustum 
{
	import plugin.core.interfaces.IDisposable;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Visual;
	import zest3d.shaderfloats.ShaderFloat;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class DepthRangeConstant extends ShaderFloat implements IDisposable 
	{
		
		public function DepthRangeConstant() 
		{
			super( 1 );
			_allowUpdater = true;
		}
		
		override public function dispose():void 
		{
			super.dispose();
		}
		
		override public function update(visual:Visual, camera:Camera):void 
		{
			var range:Number = camera.dMax - camera.dMin;
			var invRange:Number = 1 / range;
			
			_data.writeFloat( camera.dMin );
			_data.writeFloat( camera.dMax );
			_data.writeFloat( range );
			_data.writeFloat( invRange );
		}
		
	}

}