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
package zest3d.primitives 
{
	import zest3d.resources.enum.AttributeType;
	import zest3d.resources.enum.AttributeUsageType;
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.enum.UpdateType;
	import zest3d.scenegraph.TriMesh;
	import zest3d.shaders.states.CullState;
	
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class Primitive extends TriMesh 
	{
		
		public function Primitive( vFormat:VertexFormat, vertexBuffer:VertexBuffer, indexBuffer:IndexBuffer ) 
		{
			super( vFormat, vertexBuffer, indexBuffer );
			updateModelSpaceVBA();
		}
		
		protected function updateModelSpaceVBA():void
		{
			trace( "has normals " + _vba.hasNormal() );
			
			if ( _vba.hasTangent() || _vba.hasBinormal() )
			{
				if ( _vba.hasTCoord(0) )
				{
					updateModelSpace( UpdateType.USE_TCOORD_CHANNEL );
				}
				else
				{
					updateModelSpace( UpdateType.USE_GEOMETRY );
				}
			}
		}
		
		protected function generateVertexFormat( hasTexCoords:Boolean  = false, hasNormals:Boolean  = false, hasBinormals:Boolean = false, hasTangents:Boolean  = false ):VertexFormat
		{
			var numAttributes:Number = 0;
			var index:Number = 0;
			var offset:Number = 0;
			var stride:Number = 0;
			
			numAttributes++;
			
			if ( hasTexCoords )
			{
				numAttributes++;
			}
			if ( hasNormals)
			{
				numAttributes++;
			}
			if ( hasBinormals )
			{
				numAttributes++;
			}
			if ( hasTangents )
			{
				numAttributes++;
			}
			var vFormat:VertexFormat = new VertexFormat( numAttributes );
			
			// positions
			vFormat.setAttribute( index, 0, offset, AttributeUsageType.POSITION, AttributeType.FLOAT3, 0 );
			offset += 12;
			stride += 12;
			index++;
			
			// texcoords
			if ( hasTexCoords )
			{
				vFormat.setAttribute( index, 0, offset, AttributeUsageType.TEXCOORD, AttributeType.FLOAT2, 0 );
				offset += 2*4;
				index++;
				stride += 8;
			}
			
			// normals
			if ( hasNormals )
			{
				vFormat.setAttribute( index, 0, offset, AttributeUsageType.NORMAL, AttributeType.FLOAT3, 0 );
				offset += 3*4;
				index++;
				stride += 12;
			}
			
			// binormals
			if ( hasBinormals )
			{
				vFormat.setAttribute( index, 0, offset, AttributeUsageType.BINORMAL, AttributeType.FLOAT3, 0 );
				offset += 3*4;
				index++;
				stride += 12;
			}
			
			
			// tangents
			if ( hasTangents )
			{
				vFormat.setAttribute( index, 0, offset, AttributeUsageType.TANGENT, AttributeType.FLOAT3, 0 );
				offset += 3*4;
				index++;
				stride += 12;
			}
			
			vFormat.stride = stride;
			
			return vFormat;
		}
		
		public function set bothSides( value:Boolean ):void
		{
			var i:int;
			var cullState:CullState;
			if ( value )
			{
				for ( i = 0; i < effect.numPasses; ++i )
				{
					cullState = effect.getPass( i ).cullState;
					cullState.enabled = false;
				}
			}
			else
			{
				for ( i = 0; i < effect.numPasses; ++i )
				{
					cullState = effect.getPass( i ).cullState;
					cullState.enabled = true;
				}
			}
		}
	}
}