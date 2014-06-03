package famous.transitions;
import famous.core.DynamicMap;

/** Receives and returns a number between [0,1]. */
typedef EaseFunction = Float -> Float;

/*
 * A library of curves which map an animation explicitly as a function of time.
 */
class Easing {
	static public var cuves:DynamicMap = {
		inQuad: Easing.inQuad,
		outQuad: Easing.outQuad,
		inOutQuad: Easing.inOutQuad,
		inCubic: Easing.inCubic,
		outCubic: Easing.outCubic,
		inOutCubic: Easing.inOutCubic,
		inQuart: Easing.inQuart,
		outQuart: Easing.outQuart,
		inOutQuart: Easing.inOutQuart,
		inQuint: Easing.inQuint,
		outQuint: Easing.outQuint,
		inOutQuint: Easing.inOutQuint,
		inSine: Easing.inSine,
		outSine: Easing.outSine,
		inOutSine: Easing.inOutSine,
		inExpo: Easing.inExpo,
		outExpo: Easing.outExpo,
		inOutExpo: Easing.inOutExpo,
		inCirc: Easing.inCirc,
		outCirc: Easing.outCirc,
		inOutCirc: Easing.inOutCirc,
		inElastic: Easing.inElastic,
		outElastic: Easing.outElastic,
		inOutElastic: Easing.inOutElastic,
		inBack: Easing.inBack,
		outBack: Easing.outBack,
		inOutBack: Easing.inOutBack,
		inBounce: Easing.inBounce,
		outBounce: Easing.outBounce,
		inOutBounce: Easing.inOutBounce,
	};
	
	/**
	 * @property inQuad
	 * @static
	 */
	static public function inQuad(t:Float) {
		return t*t;
	}

	/**
	 * @property outQuad
	 * @static
	 */
	static public function outQuad(t:Float) {
		return -(t-=1)*t+1;
	}

	/**
	 * @property inOutQuad
	 * @static
	 */
	static public function inOutQuad(t:Float) {
		if ((t/=.5) < 1) return .5*t*t;
		return -.5*((--t)*(t-2) - 1);
	}

	/**
	 * @property inCubic
	 * @static
	 */
	static public function inCubic(t:Float) {
		return t*t*t;
	}

	/**
	 * @property outCubic
	 * @static
	 */
	static public function outCubic(t:Float) {
		return ((--t)*t*t + 1);
	}

	/**
	 * @property inOutCubic
	 * @static
	 */
	static public function inOutCubic(t:Float) {
		if ((t/=.5) < 1) return .5*t*t*t;
		return .5*((t-=2)*t*t + 2);
	}

	/**
	 * @property inQuart
	 * @static
	 */
	static public function inQuart(t:Float) {
		return t*t*t*t;
	}

	/**
	 * @property outQuart
	 * @static
	 */
	static public function outQuart(t:Float) {
		return -((--t)*t*t*t - 1);
	}

	/**
	 * @property inOutQuart
	 * @static
	 */
	static public function inOutQuart(t:Float) {
		if ((t/=.5) < 1) return .5*t*t*t*t;
		return -.5 * ((t-=2)*t*t*t - 2);
	}

	/**
	 * @property inQuint
	 * @static
	 */
	static public function inQuint(t:Float) {
		return t*t*t*t*t;
	}

	/**
	 * @property outQuint
	 * @static
	 */
	static public function outQuint(t:Float) {
		return ((--t)*t*t*t*t + 1);
	}

	/**
	 * @property inOutQuint
	 * @static
	 */
	static public function inOutQuint(t:Float) {
		if ((t/=.5) < 1) return .5*t*t*t*t*t;
		return .5*((t-=2)*t*t*t*t + 2);
	}

	/**
	 * @property inSine
	 * @static
	 */
	static public function inSine(t:Float) {
		return -1.0*Math.cos(t * (Math.PI/2)) + 1.0;
	}

	/**
	 * @property outSine
	 * @static
	 */
	static public function outSine(t:Float) {
		return Math.sin(t * (Math.PI/2));
	}

	/**
	 * @property inOutSine
	 * @static
	 */
	static public function inOutSine(t:Float) {
		return -.5*(Math.cos(Math.PI*t) - 1);
	}

	/**
	 * @property inExpo
	 * @static
	 */
	static public function inExpo(t:Float) {
		return (t==0) ? 0.0 : Math.pow(2, 10 * (t - 1));
	}

	/**
	 * @property outExpo
	 * @static
	 */
	static public function outExpo(t:Float) {
		return (t==1.0) ? 1.0 : (-Math.pow(2, -10 * t) + 1);
	}

	/**
	 * @property inOutExpo
	 * @static
	 */
	static public function inOutExpo(t:Float) {
		if (t==0) return 0.0;
		if (t==1.0) return 1.0;
		if ((t/=.5) < 1) return .5 * Math.pow(2, 10 * (t - 1));
		return .5 * (-Math.pow(2, -10 * --t) + 2);
	}

	/**
	 * @property inCirc
	 * @static
	 */
	static public function inCirc(t:Float) {
		return -(Math.sqrt(1 - t*t) - 1);
	}

	/**
	 * @property outCirc
	 * @static
	 */
	static public function outCirc(t:Float) {
		return Math.sqrt(1 - (--t)*t);
	}

	/**
	 * @property inOutCirc
	 * @static
	 */
	static public function inOutCirc(t:Float) {
		if ((t/=.5) < 1) return -.5 * (Math.sqrt(1 - t*t) - 1);
		return .5 * (Math.sqrt(1 - (t-=2)*t) + 1);
	}

	/**
	 * @property inElastic
	 * @static
	 */
	static public function inElastic(t:Float) {
		var s=1.70158;var p=0.0;var a=1.0;
		if (t==0) return 0.0;  if (t==1) return 1.0;  if (p == 0) p=0.3;
		s = p/(2*Math.PI) * Math.asin(1.0/a);
		return -(a*Math.pow(2,10*(t-=1)) * Math.sin((t-s)*(2*Math.PI)/ p));
	}

	/**
	 * @property outElastic
	 * @static
	 */
	static public function outElastic(t:Float) {
		var s=1.70158;var p=0.0;var a=1.0;
		if (t==0) return 0.0;  if (t==1) return 1.0;  if (p == 0) p=0.3;
		s = p/(2*Math.PI) * Math.asin(1.0/a);
		return a*Math.pow(2,-10*t) * Math.sin((t-s)*(2*Math.PI)/p) + 1.0;
	}

	/**
	 * @property inOutElastic
	 * @static
	 */
	static public function inOutElastic(t:Float) {
		var s=1.70158;var p=0.0;var a=1.0;
		if (t==0) return 0.0;  if ((t/=.5)==2) return 1.0;  if (p==0) p=(0.3*1.5);
		s = p/(2*Math.PI) * Math.asin(1.0/a);
		if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin((t-s)*(2*Math.PI)/p));
		return a*Math.pow(2,-10*(t-=1)) * Math.sin((t-s)*(2*Math.PI)/p)*.5 + 1.0;
	}

	/**
	 * @property inBack
	 * @static
	 */
	static public function inBack(t:Float, ?s:Float) {
		if (s == null) s = 1.70158;
		return t*t*((s+1)*t - s);
	}

	/**
	 * @property outBack
	 * @static
	 */
	static public function outBack(t:Float, ?s:Float) {
		if (s == null) s = 1.70158;
		return ((--t)*t*((s+1)*t + s) + 1);
	}

	/**
	 * @property inOutBack
	 * @static
	 */
	static public function inOutBack(t:Float, ?s:Float) {
		if (s == null) s = 1.70158;
		if ((t/=.5) < 1) return .5*(t*t*(((s*=(1.525))+1)*t - s));
		return .5*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2);
	}

	/**
	 * @property inBounce
	 * @static
	 */
	static public function inBounce(t:Float) {
		return 1.0 - Easing.outBounce(1.0-t);
	}

	/**
	 * @property outBounce
	 * @static
	 */
	static public function outBounce(t:Float) {
		if (t < (1/2.75)) {
			return (7.5625*t*t);
		} else if (t < (2/2.75)) {
			return (7.5625*(t-=(1.5/2.75))*t + .75);
		} else if (t < (2.5/2.75)) {
			return (7.5625*(t-=(2.25/2.75))*t + .9375);
		} else {
			return (7.5625*(t-=(2.625/2.75))*t + .984375);
		}
	}

	/**
	 * @property inOutBounce
	 * @static
	 */
	static public function inOutBounce(t:Float) {
		if (t < .5) return Easing.inBounce(t*2) * .5;
		return Easing.outBounce(t*2-1.0) * .5 + .5;
	}
}