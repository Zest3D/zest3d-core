package zest3d.memory.enum 
{
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class PoolType 
	{
		
		public static const APOINT:PoolType 		= new PoolType( "APoint", 0 );
		public static const AVECTOR:PoolType 		= new PoolType( "AVector", 1 );
		public static const AXISANGLE:PoolType 		= new PoolType( "AxisAngle", 2 );
		public static const HMATRIX:PoolType 		= new PoolType( "HMatrix", 3 );
		public static const HPLANE:PoolType 		= new PoolType( "HPlane", 4 );
		public static const HPOINT:PoolType 		= new PoolType( "HPoint", 5 );
		public static const HQUATERNION:PoolType 	= new PoolType( "HQuaternion", 6 );
		
		private var _type:String;
		private var _index:int;
		public function PoolType(type:String, index:int) 
		{
			_type = type;
			_index = index;
		}
		
		public function get type():String 
		{
			return _type;
		}
		
		public function get index():int 
		{
			return _index;
		}
		
	}

}