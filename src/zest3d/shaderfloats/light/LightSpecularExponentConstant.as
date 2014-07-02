package zest3d.shaderfloats.light 
{
	import plugin.core.interfaces.IDisposable;
	import zest3d.scenegraph.Camera;
	import zest3d.scenegraph.Light;
	import zest3d.scenegraph.Visual;
	import zest3d.shaderfloats.ShaderFloat;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class LightSpecularExponentConstant extends ShaderFloat implements IDisposable
	{
		protected var _light:Light;
		
		public function LightSpecularExponentConstant( light:Light ) 
		{
			super( 1 );
			_light = light;
			_allowUpdater = true;
		}
		
		override public function update(visual:Visual, camera:Camera):void 
		{
			var tuple: Array = [ _light.exponent, 0, 0, 0 ];
			_data.position = 0;
			
			for ( var i: int = 0; i < 4; ++i )
			{
				_data.writeFloat( tuple[ i ] );
			}
		}
	}

}