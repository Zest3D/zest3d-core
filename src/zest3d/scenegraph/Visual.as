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
	import zest3d.datatypes.Bound;
	import zest3d.resources.enum.AttributeType;
	import zest3d.resources.enum.AttributeUsageType;
	import zest3d.resources.IndexBuffer;
	import zest3d.resources.VertexBuffer;
	import zest3d.resources.VertexFormat;
	import zest3d.scenegraph.enum.PrimitiveType;
	import zest3d.scenegraph.enum.UpdateType;
	import zest3d.shaders.VisualEffectInstance;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Visual extends Spatial implements IDisposable 
	{
		
		protected var _type: PrimitiveType;
		protected var _vFormat: VertexFormat;
		protected var _vBuffer: VertexBuffer;
		protected var _iBuffer: IndexBuffer;
		protected var _modelBound: Bound;
		protected var _effect: VisualEffectInstance;
		
		public function Visual( type: PrimitiveType, vFormat: VertexFormat, vBuffer: VertexBuffer, iBuffer: IndexBuffer = null ) 
		{
			_type = type;
			_vFormat = vFormat;
			_vBuffer = vBuffer;
			_iBuffer = iBuffer;
			_modelBound = new Bound();
			
			updateModelSpace( UpdateType.MODEL_BOUND_ONLY );
		}
		
		override public function dispose():void 
		{
			/*
			if ( _effect )
			{
				_effect.dispose();
				_effect = null;
			}
			
			_modelBound.dispose();
			_iBuffer.dispose();
			_vBuffer.dispose();
			_vFormat.dispose();
			
			
			_modelBound = null;
			_iBuffer = null;
			_vBuffer = null;
			_vFormat = null;
			*/
			super.dispose();
		}
		
		[Inline]
		public final function get primitiveType(): PrimitiveType
		{
			return _type;
		}
		
		[Inline]
		public final function set vertexFormat( vFormat: VertexFormat ): void
		{
			_vFormat = vFormat;
		}
		
		[Inline]
		public final function get vertexFormat(): VertexFormat
		{
			return _vFormat;
		}
		
		[Inline]
		public final function set vertexBuffer( vBuffer: VertexBuffer ): void
		{
			_vBuffer = vBuffer;
		}
		
		[Inline]
		public final function get vertexBuffer(): VertexBuffer
		{
			return _vBuffer;
		}
		
		[Inline]
		public final function set indexBuffer( iBuffer: IndexBuffer ): void
		{
			_iBuffer = iBuffer;
		}
		
		[Inline]
		public final function get indexBuffer(): IndexBuffer
		{
			return _iBuffer;
		}
		
		[Inline]
		public final function get modelBound(): Bound
		{
			return _modelBound;
		}
		
		
		[Inline]
		public final function set effect( effect: VisualEffectInstance ): void
		{
			_effect = effect;
		}
		
		[Inline]
		public final function get effect(): VisualEffectInstance
		{
			return _effect;
		}
		
		
		
		// virtual
		public function updateModelSpace( type: UpdateType ): void
		{
			updateModelBound();
		}
		
		// virtual
		override protected function updateWorldBound():void 
		{
			_modelBound.transformBy( worldTransform, worldBound );
		}
		
		// virtual
		protected function updateModelBound(): void
		{
			var numVertices: int = _vBuffer.numElements;
			var stride: int = _vFormat.stride;
			
			var posIndex: int = _vFormat.getIndex( AttributeUsageType.POSITION );
			if ( posIndex == -1 )
			{
				Assert.isTrue( false, "Update requires vertex positions." );
			}
			
			var posType: AttributeType = _vFormat.getAttributeType( posIndex );
			
			if ( posType != AttributeType.FLOAT3 &&
				 posType != AttributeType.FLOAT4 )
			{
				Assert.isTrue( false, "Positions must be 3-tuples or 4-tuples" );
			}
			
			//TODO revise the offset systems (i.e. pointers etc)
			//var posOffset: int = _vFormat.getOffset( posIndex );
			
			_modelBound.computeFromData( numVertices, stride, _vBuffer.data );
			
		}
		
		// virtual
		override public function getVisibleSet(culler:Culler, noCull:Boolean):void 
		{
			culler.insert( this );
		}
		
		//{ NAME SUPPORT
		override public function getObjectByName(name:String):Object 
		{
			var found: Object = super.getObjectByName(name);
			if ( found )
			{
				return found;
			}
			
			
			//PLUGIN_GET_OBJECT_BY_NAME( _vFormat, name, found );
			if (_vFormat)
			{
				found = _vFormat.getObjectByName(name);
				if (found)
				{
					return found;
				}
			}
			
			//PLUGIN_GET_OBJECT_BY_NAME( _vBuffer, name, found );
			if (_vBuffer)
			{
				found = _vBuffer.getObjectByName(name);
				if (found)
				{
					return found;
				}
			}
			
			//PLUGIN_GET_OBJECT_BY_NAME( _iBuffer, name, found );
			if (_iBuffer)
			{
				found = _iBuffer.getObjectByName(name);
				if (found)
				{
					return found;
				}
			}
			
			//PLUGIN_GET_OBJECT_BY_NAME( _effect, name, found );
			if (_effect)
			{
				found = _effect.getObjectByName(name);
				if (found)
				{
					return found;
				}
			}
			
			return null;
		}
		
		override public function getAllObjectsByName(name:String, objects:Vector.<Object>):void 
		{
			super.getAllObjectsByName(name, objects);
			
			PLUGIN_GET_ALL_OBJECTS_BY_NAME( _vFormat, name, objects );
			PLUGIN_GET_ALL_OBJECTS_BY_NAME( _vBuffer, name, objects );
			PLUGIN_GET_ALL_OBJECTS_BY_NAME( _iBuffer, name, objects );
			PLUGIN_GET_ALL_OBJECTS_BY_NAME( _effect, name, objects );
		}
		//}
	}

}