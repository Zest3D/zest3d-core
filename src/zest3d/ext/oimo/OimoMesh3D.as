package zest3d.ext.oimo
{
	import com.element.oimo.physics.collision.shape.Shape;
	import com.element.oimo.physics.collision.shape.ShapeConfig;
	import com.element.oimo.physics.dynamics.RigidBody;
	import io.plugin.math.algebra.AVector;
	import zest3d.scenegraph.TriMesh;
	
	public class OimoMesh3D
	{
		public var rigidBody:RigidBody
		public var mesh:TriMesh;
		public var shape:Shape;
		
		public function OimoMesh3D( shape:Shape, mesh:TriMesh, type:uint = 0x0 )
		{
			this.shape = shape;
			this.mesh = mesh;
			rigidBody = new RigidBody();
			rigidBody.addShape(shape);
			rigidBody.setupMass(type);
		}
		
		public function set friction(num:Number):void
		{
			shape.friction = num;
		}
		public function set restitution(num:Number):void
		{
			shape.restitution = num;
		}
		
		public function getPosition():AVector
		{
			return new AVector(rigidBody.position.x, rigidBody.position.y, rigidBody.position.z);
		}
		
		public function setPosition(x:Number = 0, y:Number = 0, z:Number = 0):void
		{
			rigidBody.position.x = x;
			rigidBody.position.y = y;
			rigidBody.position.z = z;
		}
		
		public function get x():Number
		{
			return rigidBody.position.x;
		}
		
		public function set x(num:Number):void
		{
			rigidBody.position.x = num;
		}
		
		public function get y():Number
		{
			return rigidBody.position.y;
		}
		
		public function set y(num:Number):void
		{
			rigidBody.position.y = num;
		}
		
		public function get z():Number
		{
			return rigidBody.position.z;
		}
		
		public function set z(num:Number):void
		{
			rigidBody.position.z = num;
		}
	}
}