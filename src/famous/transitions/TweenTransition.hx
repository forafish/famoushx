package famous.transitions;

typedef CurveFunc = Float -> Float;

typedef CurveOptions = {
	?curve:Dynamic, // String or CurveFunc
	?duration:Float, 
	?speed:Float,
	?velocity:Float
}

/**
 *
 * A state maintainer for a smooth transition between
 *    numerically-specified states.  Example numeric states include floats or
 *    Transfornm objects.
 *
 *    An initial state is set with the constructor or set(startValue). A
 *    corresponding end state and transition are set with set(endValue,
 *    transition). Subsequent calls to set(endValue, transition) begin at
 *    the last state. Calls to get(timestamp) provide the _interpolated state
 *    along the way.
 *
 *   Note that there is no event loop here - calls to get() are the only way
 *    to find out state projected to the current (or provided) time and are
 *    the only way to trigger callbacks. Usually this kind of object would
 *    be part of the render() path of a visible component.
 */
class TweenTransition {
	
    /**
     * Transition curves mapping independent variable t from domain [0,1] to a
     *    range within [0,1]. Includes functions 'linear', 'easeIn', 'easeOut',
     *    'easeInOut', 'easeOutBounce', 'spring'.
     *
     * @property {object} Curve
     * @final
     */
	static var Curves = {
        linear: function(t:Float) {
            return t;
        },
        easeIn: function(t:Float) {
            return t*t;
        },
        easeOut: function(t:Float) {
            return t*(2-t);
        },
        easeInOut: function(t:Float) {
            if (t <= 0.5) return 2*t*t;
            else return -2*t*t + 4*t - 1;
        },
        easeOutBounce: function(t:Float) {
            return t*(3 - 2*t);
        },
        spring: function(t:Float) {
            return (1 - t) * Math.sin(6 * Math.PI * t) + t;
        }
    };


    static var SUPPORTS_MULTIPLE = true;
    static var DEFAULT_OPTIONS:CurveOptions = {
        curve: TweenTransition.Curves.linear,
        duration: 500,
        speed: 0 /* considered only if positive */
    };

	static var registeredCurves:Map<String, CurveFunc> = new Map();
	
	// Register all the default curves
	static var _staticInitDefaultCuves = (function() {
		TweenTransition.registerCurve('linear', TweenTransition.Curves.linear);
		TweenTransition.registerCurve('easeIn', TweenTransition.Curves.easeIn);
		TweenTransition.registerCurve('easeOut', TweenTransition.Curves.easeOut);
		TweenTransition.registerCurve('easeInOut', TweenTransition.Curves.easeInOut);
		TweenTransition.registerCurve('easeOutBounce', TweenTransition.Curves.easeOutBounce);
		TweenTransition.registerCurve('spring', TweenTransition.Curves.spring);
		return null;
	})();
	
	var options:CurveOptions;
	var _startTime:Float;
	var _startValue:Dynamic; // Float or Array<Float>
	var _updateTime:Float;
	var _endValue:Float;
	var _curve:CurveFunc;
	var _duration:Float;
	var _active:Bool;
	var _callback:Void -> Void;
	var _startVelocity:Dynamic; // Float or Array<Float>
	var state:Dynamic; // Float or Array<Float>
	var velocity:Dynamic; // Float or Array<Float>
		
    /**
     * @class TweenTransition
     * @constructor
     *
     * @param {Object} options TODO
     *    beginning state
     */
	public function new(options:Dynamic) {
        this.options = Reflect.copy(TweenTransition.DEFAULT_OPTIONS);
        if (options != null) {
			this.setOptions(options);
		}

        this._startTime = 0;
        this._startValue = 0;
        this._updateTime = 0;
        this._endValue = 0;
        this._curve = null;
        this._duration = 0;
        this._active = false;
        this._callback = null;
        this.state = 0;
        this.velocity = null;
	}
	
    /**
     * Add "unit" curve to internal dictionary of registered curves.
     *
     * @method registerCurve
     *
     * @static
     *
     * @param {string} curveName dictionary key
     * @param {unitCurve} curve function of one numeric variable mapping [0,1]
     *    to range inside [0,1]
     * @return {boolean} false if key is taken, else true
     */
    static public function registerCurve(curveName:String, curve:CurveFunc) {
        if (registeredCurves[curveName] == null) {
            registeredCurves[curveName] = curve;
            return true;
        }
        else {
            return false;
        }
    }

    /**
     * Remove object with key "curveName" from internal dictionary of registered
     *    curves.
     *
     * @method unregisterCurve
     *
     * @static
     *
     * @param {string} curveName dictionary key
     * @return {boolean} false if key has no dictionary value
     */
    static public function unregisterCurve(curveName:String):Bool {
        if (registeredCurves[curveName] != null) {
            registeredCurves.remove(curveName);
            return true;
        }
        else {
            return false;
        }
    }

    /**
     * Retrieve function with key "curveName" from internal dictionary of
     *    registered curves. Default curves are defined in the
     *    TweenTransition.Curves array, where the values represent
     *    unitCurve functions.
     *
     * @method getCurve
     *
     * @static
     *
     * @param {string} curveName dictionary key
     * @return {unitCurve} curve function of one numeric variable mapping [0,1]
     *    to range inside [0,1]
     */
    static public function getCurve(curveName:String):CurveFunc {
        var curve = registeredCurves[curveName];
        if (curve != null) {
			return curve;
		}
        else throw 'curve not registered';
    }

    /**
     * Retrieve all available curves.
     *
     * @method getCurves
     *
     * @static
     *
     * @return {object} curve functions of one numeric variable mapping [0,1]
     *    to range inside [0,1]
     */
	static public function getCurves():Map<String, CurveFunc> {
        return registeredCurves;
    }

     // Interpolate: If a linear function f(0) = a, f(1) = b, then return f(t)
    function _interpolate(a:Float, b:Float, t:Float):Float {
        return ((1 - t) * a) + (t * b);
    }

    function _clone<T>(obj:T):T {
        if (Reflect.isObject(obj)) {
            if (Std.is(obj, Array)) {
				var result = Type.createInstance(Type.getClass(obj), []);
				untyped {
					for (ii in 0...obj.length) {
						result.push(obj[ii]);
					}
				}
				return result;
			}
            else {
				return Type.createInstance(Type.getClass(obj), []);
			}
        }
        else return obj;
    }

    // Fill in missing properties in "transition" with those in defaultTransition, and
    //   convert internal named curve to function object, returning as new
    //   object.
    function _normalize(transition:CurveOptions, defaultTransition:CurveOptions):CurveOptions {
        var result:CurveOptions = {curve: defaultTransition.curve};
        if (defaultTransition.duration != null) {
			result.duration = defaultTransition.duration;
		}
        if (defaultTransition.speed != null) {
			result.speed = defaultTransition.speed;
		}
        if (Reflect.isObject(transition)) {
            if (transition.duration != null) {
				result.duration = transition.duration;
			}
            if (transition.curve != null) {
				result.curve = transition.curve;
			}
            if (transition.speed != null) {
				result.speed = transition.speed;
			}
        }
        if (Std.is(result.curve, String)) {
			result.curve = TweenTransition.getCurve(result.curve);
		}
        return result;
    }

    /**
     * Set internal options, overriding any default options.
     *
     * @method setOptions
     *
     *
     * @param {Object} options options object
     * @param {Object} [options.curve] function mapping [0,1] to [0,1] or identifier
     * @param {Number} [options.duration] duration in ms
     * @param {Number} [options.speed] speed in pixels per ms
     */
    public function setOptions(options:CurveOptions) {
        if (options.curve != null) {
			this.options.curve = options.curve;
		}
        if (options.duration != null) {
			this.options.duration = options.duration;
		}
        if (options.speed != null) {
			this.options.speed = options.speed;
		}
    }

    /**
     * Add transition to end state to the queue of pending transitions. Special
     *    Use: calling without a transition resets the object to that state with
     *    no pending actions
     *
     * @method set
     *
     *
     * @param {number|FamousMatrix|Array.Number|Object.<number, number>} endValue
     *    end state to which we _interpolate
     * @param {transition=} transition object of type {duration: number, curve:
     *    f[0,1] -> [0,1] or name}. If transition is omitted, change will be
     *    instantaneous.
     * @param {function()=} callback Zero-argument function to call on observed
     *    completion (t=1)
     */
    public function set(endValue:Dynamic, ?transition:CurveOptions, ?callback:Void -> Void) {
        if (transition == null) {
            this.reset(endValue);
            if (callback != null) {
				callback();
			}
            return;
        }

        this._startValue = _clone(this.get());
        transition = _normalize(transition, this.options);
        if (transition.speed != null && transition.speed > 0) {
            if (Std.is(this._startValue, Array)) {
				var startValue:Array<Int> = cast this._startValue;
                var variance:Float = 0;
                for (i in startValue) {
					variance += (endValue[i] - startValue[i]) * (endValue[i] - startValue[i]);
				}
                transition.duration = Math.sqrt(variance) / transition.speed;
            }
            else {
				var startValue:Float = cast this._startValue;
                transition.duration = Math.abs(endValue - startValue) / transition.speed;
            }
        }

        this._startTime = Date.now().getTime();
        this._endValue = _clone(endValue);
        this._startVelocity = _clone(transition.velocity);
        this._duration = transition.duration;
        this._curve = transition.curve;
        this._active = true;
        this._callback = callback;
    }

    /**
     * Cancel all transitions and reset to a stable state
     *
     * @method reset
     *
     * @param {number|Array.Number|Object.<number, number>} startValue
     *    starting state
     * @param {number} startVelocity
     *    starting velocity
     */
	public function reset(startValue:Float = 0, startVelocity:Float = 0) {
        if (this._callback != null) {
            var callback = this._callback;
            this._callback = null;
            callback();
        }
        this.state = _clone(startValue);
        this.velocity = _clone(startVelocity);
        this._startTime = 0;
        this._duration = 0;
        this._updateTime = 0;
        this._startValue = this.state;
        this._startVelocity = this.velocity;
        this._endValue = this.state;
        this._active = false;
    }

    /**
     * Get current velocity
     *
     * @method getVelocity
     *
     * @returns {Number} velocity
     */
    public function getVelocity():Float {
        return this.velocity;
    }

    /**
     * Get interpolated state of current action at provided time. If the last
     *    action has completed, invoke its callback.
     *
     * @method get
     *
     *
     * @param {number=} timestamp Evaluate the curve at a normalized version of this
     *    time. If omitted, use current time. (Unix epoch time)
     * @return {number|Object.<number|string, number>} beginning state
     *    _interpolated to this point in time.
     */
    public function get(?timestamp:Float):Dynamic {
        this.update(timestamp);
        return this.state;
    }

    function _calculateVelocity(current:Dynamic, start:Dynamic, curve:CurveFunc, duration:Float, t:Float) {
        var velocity:Dynamic;
        var eps = 1e-7;
        var speed = (curve(t) - curve(t - eps)) / eps;
        if (Std.is(current, Array)) {
            velocity = [];
            for (i in 0...current.length) {
				if (Std.is(current[i], Float)) {
					velocity[i] = speed * (current[i] - start[i]) / duration;
				} else {
					velocity[i] = 0;
				}
			}
        } else {
			var _current:Float = cast current;
			var _start:Float = cast start;
			velocity = speed * (_current - _start) / duration;
		}
        return velocity;
    }

    function _calculateState(start:Dynamic, end:Dynamic, t:Float) {
        var state:Dynamic;
        if (Std.is(start, Array)) {
            state = [];
            for (i in 0...start.length) {
				if (Std.is(start[i], Float)) {
					state[i] = _interpolate(start[i], end[i], t);
				} else {
					state[i] = start[i];
				}
			}
        } else {
			var _start:Float = cast start;
			var _end:Float = cast end;
			state = _interpolate(_start, _end, t);
		}
        return state;
    }

    /**
     * Update internal state to the provided timestamp. This may invoke the last
     *    callback and begin a new action.
     *
     * @method update
     *
     *
     * @param {number=} timestamp Evaluate the curve at a normalized version of this
     *    time. If omitted, use current time. (Unix epoch time)
     */
    public function update(?timestamp:Float) {
        if (!this._active) {
            if (this._callback != null) {
                var callback = this._callback;
                this._callback = null;
                callback();
            }
            return;
        }

        if (timestamp == null) {
			timestamp = Date.now().getTime();
		}
        if (this._updateTime >= timestamp) {
			return;
		}
        this._updateTime = timestamp;

        var timeSinceStart = timestamp - this._startTime;
        if (timeSinceStart >= this._duration) {
            this.state = this._endValue;
            this.velocity = _calculateVelocity(this.state, this._startValue, this._curve, this._duration, 1);
            this._active = false;
        }
        else if (timeSinceStart < 0) {
            this.state = this._startValue;
            this.velocity = this._startVelocity;
        }
        else {
            var t = timeSinceStart / this._duration;
            this.state = _calculateState(this._startValue, this._endValue, this._curve(t));
            this.velocity = _calculateVelocity(this.state, this._startValue, this._curve, this._duration, t);
        }
    }

    /**
     * Is there at least one action pending completion?
     *
     * @method isActive
     *
     *
     * @return {boolean}
     */
    public function isActive() {
        return this._active;
    }

    /**
     * Halt transition at current state and erase all pending actions.
     *
     * @method halt
     *
     */
    public function halt() {
        this.reset(this.get());
    }
	
    static function customCurve(?v1:Float, ?v2:Float):CurveFunc {
        v1 = v1 == null? v1 : 0; 
		v2 = v2 == null? v2 : 0;
        return function(t:Float) {
            return v1*t + (-2*v1 - v2 + 3)*t*t + (v1 + v2 - 2)*t*t*t;
        };
    }
	
}

