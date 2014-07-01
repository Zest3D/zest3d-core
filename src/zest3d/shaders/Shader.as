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
package zest3d.shaders 
{
	import io.plugin.core.errors.IllegalArgumentError;
	import io.plugin.core.interfaces.IDisposable;
	import io.plugin.core.system.Assert;
	import zest3d.shaders.enum.SamplerCoordinateType;
	import zest3d.shaders.enum.SamplerFilterType;
	import zest3d.shaders.enum.SamplerType;
	import zest3d.shaders.enum.VariableSemanticType;
	import zest3d.shaders.enum.VariableType;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Shader implements IDisposable 
	{
		
		public static const MAX_PROFILES: int = 5;
		public static const MAX_ANISOTROPY: int = 16;
		
		protected var _numInputs: int;
		protected var _inputName: Vector.<String>;
		protected var _inputType: Vector.<VariableType>;
		protected var _inputSemantic: Vector.<VariableSemanticType>;
		
		protected var _numOutputs: int;
		protected var _outputName: Vector.<String>;
		protected var _outputType: Vector.<VariableType>;
		protected var _outputSemantic: Vector.<VariableSemanticType>;
		
		protected var _numConstants: int;
		protected var _constantName: Vector.<String>;
		protected var _numResteredUsed: Vector.<int>;
		
		protected var _numSamplers: int;
		protected var _samplerName: Vector.<String>;
		protected var _samplerType: Vector.<SamplerType>;
		protected var _filter: Vector.<SamplerFilterType>;
		
		protected var _coordinate: Array;
		
		protected var _lodBias: Vector.<Number>;
		protected var _anisotropy: Vector.<Number>;
		protected var _borderColor: Vector.<Array>;
		
		protected var _profileOwner: Boolean;
		protected var _baseRegister: Array;
		protected var _textureUnit: Array;
		protected var _program: Array;
		
		protected var _isDisposed:Boolean;
		
		public static const msNullString: String = "";
		
		
		public function Shader( programName: String, numInputs: int, numOutputs: int,
							numConstants: int, numSamplers: int, profileOwner: Boolean ) 
		{
			
			_baseRegister = [];
			_textureUnit = [];
			_program = [];
			
			_numInputs = numInputs;
			_numOutputs = numOutputs;
			_numConstants = numConstants;
			_numSamplers = numSamplers;
			
			Assert.isTrue( numOutputs > 0, "Shader must have at least one output." );
			var i: int;
			var dim: int;
			
			//TODO setName( ...
			if ( _numInputs > 0 )
			{
				_inputName = new Vector.<String>( _numInputs );
				_inputType = new Vector.<VariableType>( _numInputs );
				_inputSemantic = new Vector.<VariableSemanticType>( _numInputs );
			}
			
			
			_outputName = new Vector.<String>( _numOutputs );
			_outputType = new Vector.<VariableType>( _numOutputs );
			_outputSemantic = new Vector.<VariableSemanticType>( _numOutputs );
			
			if ( _numConstants > 0 )
			{
				_constantName = new Vector.<String>( _numConstants );
				_numResteredUsed = new Vector.<int>( _numConstants );
				if ( profileOwner )
				{
					for ( i = 0; i < MAX_PROFILES; ++i )
					{
						_baseRegister[ i ] = new Vector.<int>( _numConstants );
						//TODO memset at sizeof int*
					}
				}
				else
				{
					for ( i = 0; i < MAX_PROFILES; ++i )
					{
						_baseRegister[ i ] = null;
					}
				}
			}
			else
			{
				_constantName = null;
				_numResteredUsed = null;
				for ( i = 0; i < MAX_PROFILES; ++i )
				{
					_baseRegister[ i ] = null;
				}
			}
			
			if ( _numSamplers > 0 )
			{
				_samplerName = new Vector.<String>( _numSamplers );
				_samplerType = new Vector.<SamplerType>( _numSamplers );
				
				_filter = new Vector.<SamplerFilterType>( _numSamplers );
				_coordinate = [];
				_coordinate[ 0 ] = new Vector.<SamplerCoordinateType>( _numSamplers );
				_coordinate[ 1 ] = new Vector.<SamplerCoordinateType>( _numSamplers );
				_coordinate[ 2 ] = new Vector.<SamplerCoordinateType>( _numSamplers );
				
				_lodBias = new Vector.<Number>( _numSamplers );
				_anisotropy = new Vector.<Number>( _numSamplers );
				_borderColor = new Vector.<Array>( _numSamplers );
				
				for ( i = 0 ; i < _numSamplers; ++i )
				{
					_filter[ i ] = SamplerFilterType.NEAREST;
					_coordinate[ 0 ][ i ] = SamplerCoordinateType.CLAMP_EDGE;
					_coordinate[ 1 ][ i ] = SamplerCoordinateType.CLAMP_EDGE;
					_coordinate[ 2 ][ i ] = SamplerCoordinateType.CLAMP_EDGE;
					
					_lodBias[ i ] = 0;
					_anisotropy[ i ] = 1;
					_borderColor[ i ] = [ 0, 0, 0, 0 ];
				}
				
				if ( _profileOwner )
				{
					for ( i = 0; i < MAX_PROFILES; ++i )
					{
						_textureUnit[ i ] = new Vector.<int>( _numSamplers );
						//TODO memset at sizeof int* if using fastmem
					}
				}
				else
				{
					for ( i = 0; i < MAX_PROFILES; ++i )
					{
						_textureUnit[ i ] = null;
					}
				}
			}
			
			if ( profileOwner )
			{
				for ( i = 0; i < MAX_PROFILES; ++i )
				{
					_program[ i ] = "";
				}
			}
			else
			{
				for ( i = 0; i < MAX_PROFILES; ++i )
				{
					_program[ i ] = null;
				}
			}
		}
		
		public function dispose(): void
		{
			//TODO dispose of items
			
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function setInput( index: int, name: String, type: VariableType, semantic:VariableSemanticType ): void
		{
			if ( 0 <= index && index < _numInputs )
			{
				_inputName[ index ] = name;
				_inputType[ index ] = type;
				_inputSemantic[ index ] = semantic;
				return;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function setOutput( index: int, name: String, type: VariableType, semantic:VariableSemanticType): void
		{
			if ( 0 <= index && index < _numOutputs )
			{
				_outputName[ index ] = name;
				_outputType[ index ] = type;
				_outputSemantic[ index ] = semantic;
				return;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function setConstant( index: int, name:String, numRegisteredUsed: int ): void
		{
			if ( 0 <= index && index < _numConstants )
			{
				_constantName[ index ] = name;
				_numResteredUsed[ index ] = numRegisteredUsed;
				return;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function setSampler( index: int, name: String, type: SamplerType ): void
		{
			if ( 0 <= index &&  index < _numSamplers )
			{
				_samplerName[ index ] = name;
				_samplerType[ index ] = type;
				return;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function setFilter( index: int, filter:SamplerFilterType ): void
		{
			if ( 0 <= index && index < _numSamplers )
			{
				_filter[ index ] = filter;
				return;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function setCoordinate( index: int, dim: int, coordinate: SamplerCoordinateType ): void
		{
			if ( 0 <= index && index < _numSamplers )
			{
				if ( 0 <= dim && dim < 3 )
				{
					_coordinate[ dim ][ index ] = coordinate;
					return;
				}
				throw new IllegalArgumentError( "Invalid dimension." );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function setLODBias( index: int, lodBias: Number ): void
		{
			if ( 0 <= index && index < _numSamplers )
			{
				_lodBias[ index ] = lodBias;
				return;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function setAnisotropy( index: int, anisotropy: Number ): void
		{
			if ( 0 <= index && index < _numSamplers )
			{
				_anisotropy[ index ] = anisotropy;
				return;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function setBorderColor( index: int, borderColor: Array ): void
		{
			if ( 0 <= index && index < _numSamplers )
			{
				_borderColor[ index ] = borderColor;
				return;
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		
		public function setBaseRegister( profile: int, index: int, baseRegister: int ): void
		{
			if ( _profileOwner )
			{
				if ( 0 <= profile && profile  < MAX_PROFILES )
				{
					if ( 0 <= index && index < _numConstants )
					{
						_baseRegister[ profile ][ index ] = baseRegister;
						return;
					}
					throw new IllegalArgumentError( "Invalid index." );
				}
				throw new IllegalArgumentError( "Invalid proofile." );
			}
			throw new IllegalArgumentError( "You may not set profile data that you do not own." );
		}
		
		public function setTextureUnit( profile: int, index: int, textureUnit: int ): void
		{
			if ( _profileOwner )
			{
				if ( 0 <= profile  && profile  < MAX_PROFILES )
				{
					if ( 0 <= index &&  index < _numSamplers )
					{
						_textureUnit[ profile ][ index ] = textureUnit;
						return;
					}
					throw new IllegalArgumentError( "Invalid index." );
				}
				throw new IllegalArgumentError( "Invalid profile." );
			}
			throw new IllegalArgumentError( "You may not set profile data that you do not own." );
		}
		
		public function setProgram( profile: int, program: String ): void
		{
			if ( _profileOwner )
			{
				if ( 0 <= profile &&  profile < MAX_PROFILES )
				{
					_program[ profile ] = program;
					return;
				}
				throw new IllegalArgumentError( "Invalid profile." );
			}
			throw new IllegalArgumentError( "You may not set profile data that you do not own." );
		}
		
		public function setBaseRegisters( baseRegisters: Array ): void
		{
			if ( !_profileOwner )
			{
				for ( var i: int = 0; i < MAX_PROFILES; ++i )
				{
					_baseRegister[ i ] = baseRegisters[ i ];
				}
				return;
			}
			throw new IllegalArgumentError( "You already own the profile data." );
		}
		
		public function setTextureUnits( textureUnits: Array ): void
		{
			if ( !_profileOwner )
			{
				for ( var i: int = 0; i < MAX_PROFILES; ++i )
				{
					_textureUnit[ i ] = textureUnits[ i ];
				}
				return;
			}
			throw new IllegalArgumentError( "You already own the profile data." );
		}
		
		public function setPrograms( programs: Array ): void
		{
			if ( !_profileOwner )
			{
				for ( var i: int = 0; i < MAX_PROFILES; ++i )
				{
					_program[ i ] = programs[ i ];
				}
				return;
			}
			throw new IllegalArgumentError( "You already own the profile data." );
		}
		
		[Inline]
		public final function get numInputs(): int
		{
			return _numInputs;
		}
		
		public function getInputName( index: int ): String
		{
			if ( 0 <= index && index < _numInputs )
			{
				return _inputName[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getInputType( index: int ): VariableType
		{
			if ( 0 <= index && index < _numInputs )
			{
				return _inputType[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getInputSemantic( index: int ): VariableSemanticType
		{
			if ( 0 <= index && index < _numInputs )
			{
				return _inputSemantic[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		[Inline]
		public final function get numOutputs(): int
		{
			return _numOutputs;
		}
		
		public function getOutputName( index: int ): String
		{
			if ( 0 <= index && index < _numOutputs )
			{
				return _outputName[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getOutputType( index: int ): VariableType
		{
			if ( 0 <= index && index < _numOutputs )
			{
				return _outputType[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getOutputSemantic( index: int ): VariableSemanticType
		{
			if ( 0 <= index && index < _numOutputs )
			{
				return _outputSemantic[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		
		[Inline]
		public final function get numConstants(): int
		{
			return _numConstants;
		}
		
		public function getConstantName( index: int ): String
		{
			if ( 0 <= index && index < _numConstants )
			{
				return _constantName[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getNumRegistersUsed( index: int ): int
		{
			if ( 0 <= index && index < _numConstants )
			{
				return _numResteredUsed[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		
		[Inline]
		public final function get numSamplers(): int
		{
			return _numSamplers;
		}
		
		public function getSamplerName( index: int ): String
		{
			if ( 0 <= index && index < _numSamplers )
			{
				return _samplerName[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getSamplerType( index: int ): SamplerType
		{
			if ( 0 <= index && index < _numSamplers )
			{
				return _samplerType[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getFilter( index: int ): SamplerFilterType
		{
			if ( 0 <= index && index < _numSamplers )
			{
				return _filter[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getCoordinate( index: int, dim: int ):SamplerCoordinateType
		{
			if ( 0 <= index && index < _numSamplers )
			{
				if ( 0 <= dim && dim < 3 )
				{
					return _coordinate[ dim ][ index ];
				}
				throw new IllegalArgumentError( "Invalid dimension." );
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getLodBias( index: int ): Number
		{
			if ( 0 <= index && index < _numSamplers )
			{
				return _lodBias[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getAnisotropy( index: int ): Number
		{
			if ( 0 <= index && index < _numSamplers )
			{
				return _anisotropy[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		public function getBorderColor( index: int ): Array
		{
			if ( 0 <= index && index < _numSamplers )
			{
				return _borderColor[ index ];
			}
			throw new IllegalArgumentError( "Invalid index." );
		}
		
		
		
		public function getBaseRegister( profile: int, index: int ): int
		{
			if ( 0 <= profile && profile < MAX_PROFILES )
			{
				if ( 0 <= index && index < _numConstants )
				{
					return _baseRegister[ profile ][ index ];
				}
				throw new IllegalArgumentError( "Invalid index." );
			}
			throw new IllegalArgumentError( "Invalid profile." );
		}
		
		public function getTextureUnit( profile: int, index: int ): int
		{
			if ( 0 <= profile && profile < MAX_PROFILES )
			{
				if ( 0 <= index && index < _numSamplers )
				{
					return _textureUnit[ profile][ index ];
				}
				throw new IllegalArgumentError( "Invalid index." );
			}
			throw new IllegalArgumentError( "Invalid profile." );
		}
		
		public function getProgram( profile: int ): String
		{
			if ( 0 <= profile && profile < MAX_PROFILES )
			{
				return _program[ profile ];
			}
			throw new IllegalArgumentError( "Invalid profile." );
		}
		
	}

}