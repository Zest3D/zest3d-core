package zest3d.memory {
	import plugin.core.pool.Pool;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.AVector;
	import plugin.math.algebra.AxisAngle;
	import plugin.math.algebra.HMatrix;
	import plugin.math.algebra.HPlane;
	import plugin.math.algebra.HPoint;
	import plugin.math.algebra.HQuaternion;
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class PoolRegistry
	{
		public static const APOINT:Pool 		= new Pool(APoint, 		[], 				200, 20);
		public static const AVECTOR:Pool 		= new Pool(AVector, 	[],					200, 20);
		public static const AXISANGLE:Pool  	= new Pool(AxisAngle, 	[getAVector()],		 50, 10);
		public static const HMATRIX:Pool  		= new Pool(HMatrix, 	[],					200, 20);
		public static const HPLANE:Pool 		= new Pool(HPlane, 		[getAVector()],		 30, 10);
		public static const HPOINT:Pool 		= new Pool(HPoint, 		[],					200, 20);
		public static const HQUATERNION:Pool	= new Pool(HQuaternion, [],					200, 20);
		
		// helpers
		public static function getAPoint():APoint
		{
			return APOINT.pop();
		}
		
		public static function returnAPoint( o:APoint ):void
		{
			return APOINT.push(o);
		}
		
		public static function getAVector():AVector
		{
			return AVECTOR.pop();
		}
		
		public static function returnAVector( o:AVector ):void
		{
			return AVECTOR.push(o);
		}
		
		public static function getAxisAngle():AxisAngle
		{
			return AXISANGLE.pop();
		}
		
		public static function returnAxisAngle( o:AVector ):void
		{
			return AXISANGLE.push(o);
		}
		
		public static function getHMatrix():HMatrix
		{
			return HMATRIX.pop();
		}
		
		public static function returnHMatrix( o:HMatrix ):void
		{
			return HMATRIX.push(o);
		}
		
		public static function getHPlane():HPlane
		{
			return HPLANE.pop();
		}
		
		public static function returnHPlane( o:HPlane ):void
		{
			return HPLANE.push(o);
		}
		
		public static function getHPoint():HPoint
		{
			return HPOINT.pop();
		}
		
		public static function returnHPoint( o:HPoint ):void
		{
			return HPOINT.push(o);
		}
		
		public static function getHQuaternion():HQuaternion
		{
			return HQUATERNION.pop();
		}
		
		public static function returnHQuaternion( o:HQuaternion ):void
		{
			return HQUATERNION.push(o);
		}
	}

}