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
package zest3d.controllers 
{
	import plugin.core.interfaces.IDisposable;
	import plugin.math.algebra.APoint;
	import plugin.math.algebra.HMatrix;
	import plugin.math.algebra.HQuaternion;
	import zest3d.datatypes.Transform;
	import zest3d.scenegraph.Spatial;
	
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class KeyframeController extends TransformController implements IDisposable 
	{
		
		protected var _numCommonTimes: int;
		protected var _commonTimes: Array;
		
		protected var _numTranslations: int;
		protected var _translationTimes: Array;
		protected var _translations: Vector.<APoint>;
		
		protected var _numRotations: int;
		protected var _rotationTimes: Array;
		protected var _rotations: Vector.<HQuaternion>;
		
		protected var _numScales: int;
		protected var _scaleTimes: Array;
		protected var _scales: Vector.<Number>;
		
		// key cache
		protected var _tLastIndex: int;
		protected var _rLastIndex: int;
		protected var _sLastIndex: int;
		protected var _cLastIndex: int;
		
		private var _trn: APoint = new APoint();
		private var _rot: HMatrix = new HMatrix();
		private var _scale: Number = 0;
		private var _key: KeyInfo = new KeyInfo();
		private var _quat: HQuaternion = new HQuaternion();
		
		public function KeyframeController( numCommonTimes: int, numTranslations: int, numRotations: int,
									numScales: int, localTransform: Transform ) 
		{
			super( localTransform );
			
			_tLastIndex = 0;
			_rLastIndex = 0;
			_sLastIndex = 0;
			_cLastIndex = 0;
			
			_translationTimes = [];
			_rotationTimes = [];
			_scaleTimes = [];
			
			
			var i: int;
			
			if ( numCommonTimes > 0 )
			{
				_numCommonTimes = numCommonTimes;
				_commonTimes = [];
				
				if ( numTranslations > 0 )
				{
					_numTranslations = numTranslations;
					_translationTimes = _commonTimes;
					_translations = new Vector.<APoint>( _numTranslations );
					for ( i = 0; i < _numTranslations; ++i )
					{
						_translations[ i ] = new APoint();
					}
				}
				
				if ( numRotations > 0 )
				{
					_numRotations = numRotations;
					_rotationTimes = _commonTimes;
					_rotations = new Vector.<HQuaternion>( _numRotations );
					for ( i = 0; i < _numRotations; ++i )
					{
						_rotations[ i ] = new HQuaternion();
					}
				}
				
				if ( numScales > 0 )
				{
					_numScales = numScales;
					_scaleTimes = _commonTimes;
					_scales = new Vector.<Number>( _numScales );
					for ( i = 0; i < _numScales; ++i )
					{
						_scales[ i ] = 0;
					}
				}
			}
			else
			{
				_numCommonTimes = 0;
				_commonTimes = [];
				
				if ( numTranslations > 0 )
				{
					_numTranslations = numTranslations;
					_translations = new Vector.<APoint>( _numTranslations );
					for ( i = 0; i < _numTranslations; ++i )
					{
						_translationTimes[ i ] = 0;
						_translations[ i ] = new APoint();
					}
				}
				
				if ( numRotations > 0 )
				{
					_numRotations = numRotations;
					_rotations = new Vector.<HQuaternion>( _numRotations );
					for ( i = 0; i < _numRotations; ++i )
					{
						_rotationTimes[ i ] = 0;
						_rotations[ i ] = new HQuaternion();
					}
				}
				
				if ( numScales > 0 )
				{
					_numScales = numScales;
					_scales = new Vector.<Number>( _numScales );
					for ( i = 0; i < _numScales; ++i )
					{
						_scaleTimes[ i ] = 0;
						_scales[ i ] = 0;
					}
				}
			}
		}
		
		override public function dispose():void 
		{
			_rotations = null;
			_translations = null;
			_scales = null;
			
			_commonTimes = null;
			_translationTimes = null;
			_rotationTimes = null;
			_scaleTimes = null;
			
			_trn.dispose();
			_rot.dispose();
			_key.dispose();
			_quat.dispose();
			
			_trn = null;
			_rot = null;
			_key = null;
			_quat = null;
			
			super.dispose();
		}
		
		[Inline]
		public final function get numCommonTimes(): int
		{
			return _numCommonTimes;
		}
		
		[Inline]
		public final function get commonTimes(): Array
		{
			return _commonTimes;
		}
		
		[Inline]
		public final function get numTranslations(): int
		{
			return _numTranslations;
		}
		
		[Inline]
		public final function get translationTimes(): Array
		{
			return _translationTimes;
		}
		
		[Inline]
		public final function get translations(): Vector.<APoint>
		{
			return _translations;
		}
		
		[Inline]
		public final function get numRotations(): int
		{
			return _numRotations;
		}
		
		[Inline]
		public final function get rotationTimes(): Array
		{
			return _rotationTimes;
		}
		
		[Inline]
		public final function get rotations(): Vector.<HQuaternion>
		{
			return _rotations;
		}
		
		[Inline]
		public final function get numScales(): int
		{
			return _numScales;
		}
		
		[Inline]
		public final function get scaleTimes(): Array
		{
			return _scaleTimes;
		}
		
		[Inline]
		public final function get scales(): Vector.<Number>
		{
			return _scales;
		}
		
		override public function update(applicationTime:Number):Boolean 
		{
			
			//return super.update(application);
			if ( !super.update( applicationTime ) )
			{
				return false;
			}
			
			var ctrlTime: Number = getControlTime( applicationTime );
			_key.set( ctrlTime, _numCommonTimes, _commonTimes, _cLastIndex, 0, 0, 0 );
			
			if ( _numCommonTimes > 0 )
			{
				getKeyInfo( _key );
				
				if ( _numTranslations > 0 )
				{
					_localTransform.translate = getTranslate( _key.normTime, _key.i0, _key.i1 );;
				}
				
				if ( _numRotations > 0 )
				{
					_localTransform.rotate = getRotate( _key.normTime, _key.i0, _key.i1 );
				}
				
				if ( _numScales > 0 )
				{
					_localTransform.uniformScale = getScale( _key.normTime, _key.i0, _key.i1 );
				}
			}
			else
			{
				if ( _numTranslations > 0 )
				{
					_key.set( ctrlTime, _numTranslations, _translationTimes, _tLastIndex, 0, 0, 0 );
					getKeyInfo( _key );
					
					_localTransform.translate = getTranslate( _key.normTime, _key.i0, _key.i1 );;
				}
				
				if ( _numRotations > 0 )
				{
					_key.set( ctrlTime, _numRotations, _rotationTimes, _rLastIndex, 0, 0, 0 );
					getKeyInfo( _key );
					
					_localTransform.rotate = getRotate( _key.normTime, _key.i0, _key.i1 );
				}
				
				if ( _numScales > 0 )
				{
					_key.set( ctrlTime, _numScales, _scaleTimes, _rLastIndex, 0, 0, 0 );
					getKeyInfo( _key );
					
					_localTransform.uniformScale = getScale( _key.normTime, _key.i0, _key.i1 );;
				}
			}
			var spatial: Spatial = _object as Spatial;
			spatial.localTransform = _localTransform;
			return true;
		}
		
		protected static function getKeyInfo( keyInfo: KeyInfo ): void
		{
			if ( keyInfo.ctrlTime <= keyInfo.times[ 0 ] )
			{
				keyInfo.normTime = 0;
				keyInfo.lastIndex = 0;
				keyInfo.i0 = 0;
				keyInfo.i1 = 0;
				return;
			}
			
			if ( keyInfo.ctrlTime >= keyInfo.times[ keyInfo.numTimes - 1 ] )
			{
				keyInfo.normTime = 0;
				keyInfo.lastIndex = keyInfo.numTimes -1;
				keyInfo.i0 = keyInfo.lastIndex;
				keyInfo.i1 = keyInfo.lastIndex;
				return;
			}
			
			var nextIndex: int;
			if ( keyInfo.ctrlTime > keyInfo.times[ keyInfo.lastIndex ] )
			{
				nextIndex = keyInfo.lastIndex + 1;
				while ( keyInfo.ctrlTime >= keyInfo.times[ nextIndex ] )
				{
					keyInfo.lastIndex = nextIndex;
					++nextIndex;
				}
				
				keyInfo.i0 = keyInfo.lastIndex;
				keyInfo.i1 = nextIndex;
				keyInfo.normTime = ( keyInfo.ctrlTime - keyInfo.times[ keyInfo.i0 ] ) / ( keyInfo.times[ keyInfo.i1 ] - keyInfo.times[ keyInfo.i0 ] );
			}
			else if ( keyInfo.ctrlTime < keyInfo.times[ keyInfo.lastIndex ] )
			{
				nextIndex = keyInfo.lastIndex - 1;
				while ( keyInfo.ctrlTime <= keyInfo.times[ nextIndex ] )
				{
					keyInfo.lastIndex = nextIndex;
					--nextIndex;
				}
				
				keyInfo.i0 = nextIndex;
				keyInfo.i1 = keyInfo.lastIndex;
				keyInfo.normTime = ( keyInfo.ctrlTime - keyInfo.times[ keyInfo.i0 ] ) / ( keyInfo.times[ keyInfo.i1 ] - keyInfo.times[ keyInfo.i0 ] );
			}
			else
			{
				keyInfo.normTime = 0;
				keyInfo.i0 = keyInfo.lastIndex;
				keyInfo.i1 = keyInfo.lastIndex;
			}
		}
		
		protected function getTranslate( normTime: Number, i0: int, i1: int ): APoint
		{
			return _translations[ i0 ].addAVector( _translations[ i1 ].subtract( _translations[ i0 ] ).scale( normTime ) );
		}
		
		protected function getRotate( normTime: Number, i0: int, i1: int ): HMatrix
		{
			_quat.slerp( normTime, _rotations[ i0 ], _rotations[ i1 ] );
			return _quat.toRotationMatrix();
		}
		
		protected function getScale( normTime: Number, i0: int, i1: int ): Number
		{
			return _scales[ i0 ] + normTime * ( _scales[ i1 ] - _scales[ i0 ] );
		}
		
	}

}