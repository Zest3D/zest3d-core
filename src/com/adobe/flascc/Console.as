package com.adobe.flascc 
{
	import flash.display.Sprite;
	import zest3d.ext.bullet.collision.dispatch.BulletCollisionObject;
	import zest3d.ext.bullet.dynamics.BulletDynamicsWorld;

	import AWPC_Run.CModule;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class Console extends Sprite 
	{
		
		private var _physicsWorld:BulletDynamicsWorld;
		
		public function Console(physicsWorld:BulletDynamicsWorld)
		{
			CModule.rootSprite = this;
			_physicsWorld = physicsWorld;
		}
		public function collisionCallback(obj1:uint, mpt:uint, obj2:uint) : void {
			var obj:BulletCollisionObject = _physicsWorld.collisionObjects[obj1.toString()];
			if(obj) obj.collisionCallback(mpt,_physicsWorld.collisionObjects[obj2.toString()]);
		}
		public function rayCastCallback(obj1:uint, mpt:uint, obj2:uint) : void {
			var obj:BulletCollisionObject = _physicsWorld.collisionObjects[obj1.toString()];
			if(obj) obj.rayCastCallback(mpt,_physicsWorld.collisionObjects[obj2.toString()]);
		}
		
	}

}