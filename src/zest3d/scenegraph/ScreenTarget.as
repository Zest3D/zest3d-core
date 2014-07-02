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
	import plugin.core.interfaces.IDisposable;
	import plugin.core.system.Assert;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.AVector;
	import zest3d.resources.enum.AttributeType;
	import zest3d.resources.enum.AttributeUsageType;
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexBufferAccessor;
	import zest3d.resources.VertexFormat;
	import zest3d.shaders.enum.VertexShaderProfileType;
	import zest3d.shaders.VertexShader;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class ScreenTarget implements IDisposable 
	{
		
		private var _isDisposed:Boolean;
		
		public function ScreenTarget() 
		{
			_isDisposed = false;
		}
		
		public function dispose(): void
		{
			_isDisposed = true;
		}
		
		public static function createCamera(): Camera
		{
			var camera: Camera = new Camera( false );
			camera.setFrustum( [0, 1, 0, 1, 0, 1] );
			camera.setFrame( APoint.ORIGIN, AVector.UNIT_Z, AVector.UNIT_Y, AVector.UNIT_X );
			return camera;
		}
		
		public static function createRectangle(vFormat: VertexFormat, rtWidth: int,
				rtHeight: int, xMin: Number, xMax: Number, yMin: Number, yMax: Number,
				zValue: Number ): TriMesh
		{
			
			if ( validFormat(vFormat) && validSizes( rtWidth, rtHeight ))
			{
				//TODO check shader type
				if ( VertexShader.profile == VertexShaderProfileType.AGAL_1_0 ||
					 VertexShader.profile == VertexShaderProfileType.AGAL_2_0 )
				{
					var tc0: Array = [0, 1];
					var tc1: Array = [1, 1];
					var tc2: Array = [1, 0];
					var tc3: Array = [0, 0];
				}
				else
				{
					var dx: Number = 0.5 * (xMax - xMin) / (rtWidth - 1);
					var dy: Number = 0.5 * (yMax - yMin) / (rtHeight - 1);
					xMin -= dx;
					xMax -= dx;
					yMin += dy;
					yMax += dy;
					tc0 = [0, 1];
					tc1 = [1, 1];
					tc2 = [1, 0];
					tc2 = [0, 0];
				}
				
				var stride: int = vFormat.stride;
				var vBuffer: VertexBuffer = new VertexBuffer( 4, stride );
				var vba: VertexBufferAccessor = new VertexBufferAccessor( vFormat, vBuffer );
				vba.setPositionAt( 0, [ xMin, yMin, zValue ] );
				vba.setPositionAt( 1, [ xMax, yMin, zValue ] );
				vba.setPositionAt( 2, [ xMax, yMax, zValue ] );
				vba.setPositionAt( 3, [ xMin, yMax, zValue ] );
				
				vba.setTCoordAt( 0, 0, tc0 );
				vba.setTCoordAt( 0, 1, tc1 );
				vba.setTCoordAt( 0, 2, tc2 );
				vba.setTCoordAt( 0, 3, tc3 );
				
				var iBuffer: IndexBuffer = new IndexBuffer( 6, 2 );
				iBuffer.setIndexAt( 0, 0 );
				iBuffer.setIndexAt( 1, 1 );
				iBuffer.setIndexAt( 2, 2 );
				
				iBuffer.setIndexAt( 3, 0 );
				iBuffer.setIndexAt( 4, 2 );
				iBuffer.setIndexAt( 5, 3 );
				
				return new TriMesh( vFormat, vBuffer, iBuffer );
				
			}
			throw new Error( "Invalid ScreenTarget rectangle" );
		}
		
		public static function createPositions( rtWidth: int, rtHeight: int, xMin: Number, xMax: Number, yMin: Number, yMax: Number,
				zValue: Number, positions: Array ): Boolean
		{
			if ( validSizes( rtWidth, rtHeight ) )
			{
				if ( VertexShader.profile == VertexShaderProfileType.AGAL_1_0 ||
					 VertexShader.profile == VertexShaderProfileType.AGAL_2_0 )
				{
					xMin = 0;
					xMax = 1;
					yMin = 0;
					yMax = 1;
				}
				else
				{
					var dx: Number = 0.5 * (xMax - xMin)/(rtWidth - 1);
					var dy: Number = 0.5 * (yMax - yMin) / (rtHeight - 1);
					xMin -= dx;
					xMax -= dx;
					yMin += dy;
					yMax += dy;
				}
				positions[0] = [ xMin, yMin, zValue ];
				positions[1] = [ xMax, yMin, zValue ];
				positions[2] = [ xMax, yMax, zValue ];
				positions[3] = [ xMin, yMax, zValue ];
				
				return true;
			}
			return false;
		}
		
		public static function createTCoords( tCoords: Array ): void
		{
			if ( VertexShader.profile == VertexShaderProfileType.AGAL_1_0 ||
				 VertexShader.profile == VertexShaderProfileType.AGAL_2_0 )
			{
				tCoords[0] = [0, 0];
				tCoords[1] = [1, 0];
				tCoords[2] = [1, 1];
				tCoords[3] = [0, 1];
			}
			else
			{
				tCoords[0] = [0, 1];
				tCoords[1] = [1, 1];
				tCoords[2] = [1, 0];
				tCoords[3] = [0, 0];
			}
		}
		
		private static function validSizes( rtWidth: int, rtHeight: int ): Boolean
		{
			if ( rtWidth > 0 && rtHeight > 0 )
			{
				return true;
			}
			Assert.isTrue( false, "Invalid dimensions" );
			return false;
		}
		
		private static function validFormat( vFormat: VertexFormat ): Boolean
		{
			var index: int;
			index = vFormat.getIndex( AttributeUsageType.POSITION, 0 );
			if ( index < 0 )
			{
				Assert.isTrue( false, "Format must have positions." );
				return false;
			}
			
			if ( vFormat.getAttributeType( index ) != AttributeType.FLOAT3 )
			{
				Assert.isTrue( false, "Positions must be 3 tuples." );
				return false;
			}
			
			index = vFormat.getIndex( AttributeUsageType.TEXCOORD, 0 )
			if( index < 0 )
			{
				Assert.isTrue( false, "Format must have texture coordinates." );
				return false;
			}
			
			if ( vFormat.getAttributeType( index ) != AttributeType.FLOAT2 )
			{
				Assert.isTrue( false, "Texture coordinates in unit 0 must be 2 tuples." );
				return false;
			}
			
			return true;
		}
		
		public function get isDisposed():Boolean 
		{
			return _isDisposed;
		}
	}

}