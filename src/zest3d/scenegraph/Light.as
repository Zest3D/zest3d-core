/**
 * Plugin.IO - http://www.plugin.io
 * Copyright (c) 2013
 *
 * Geometric Tools, LLC
 * Copyright (c) 1998-2012
 * 
 * Distributed under the Boost Software License, Version 1.0.
 * http://www.boost.org/LICENSE_1_0.txt
 */
package zest3d.scenegraph 
{
	import io.plugin.core.graphics.Color;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.Assert;
	import io.plugin.math.algebra.APoint;
	import io.plugin.math.algebra.AVector;
	import zest3d.scenegraph.enum.LightType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Light implements IDisposable 
	{
		
		public var position: APoint;
		public var dVector: AVector;
		public var uVector: AVector;
		public var rVector: AVector;
		
		public var ambient: Color;
		public var diffuse: Color;
		public var specular: Color;
		
		public var constant: Number;
		public var linear: Number;
		public var quadratic: Number;
		public var intensity: Number;
		
		private var _angle: Number;
		public var cosAngle: Number;
		public var sinAngle: Number;
		public var exponent: Number;
		
		protected var _type: LightType;
		
		private var _isDisposed:Boolean;
		
		public function Light(type: LightType = null) 
		{
			_type = type ||= LightType.AMBIENT;
			ambient = new Color( 0, 0, 0, 1 );
			diffuse = new Color( 0, 0, 0, 1 );
			specular = new Color( 0, 0, 0, 1 );
			constant = 1;
			linear = 0;
			quadratic = 0;
			intensity = 1;
			angle = Math.PI;
			cosAngle = -1;
			exponent = 1;
			position = APoint.ORIGIN;
			dVector = AVector.UNIT_Z_NEGATIVE;
			uVector = AVector.UNIT_Y;
			rVector = AVector.UNIT_X;
			
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_type = null;
			
			ambient.dispose();
			diffuse.dispose();
			specular.dispose();
			
			position.dispose();
			dVector.dispose();
			uVector.dispose();
			rVector.dispose();
			
			ambient = null;
			diffuse = null;
			specular = null;
			
			position = null;
			dVector = null;
			uVector = null;
			rVector = null;
			
			_isDisposed = true;
		}
		
		[Inline]
		public final function set type( type: LightType ): void
		{
			_type = type;
		}
		
		[Inline]
		public final function get type(): LightType
		{
			return _type;
		}
		
		[Inline]
		public final function get angle(): Number
		{
			return _angle;
		}
		
		public function set angle( value: Number ): void
		{
			Assert.isTrue( 0 < value && value <= Math.PI, "Angle out of range." );
			_angle = value;
			cosAngle = Math.cos( value );
			sinAngle = Math.sin( value );
		}
		
		public function set direction( direction: AVector ): void
		{
			dVector = direction;
			AVector.generateOrthonormalBasis( uVector, rVector, dVector );
		}
		
		[Inline]
		public final function get isDisposed():Boolean 
		{
			return _isDisposed;
		}
		
	}

}