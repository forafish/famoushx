package famous.transitions;

typedef TransitionCurve = {
	duration: Float, 
	curve: Dynamic // Cuve function or name
}

/**
 * A state maintainer for a smooth transition between
 *    numerically-specified states. Example numeric states include floats or
 *    Transform objects.
 *
 * An initial state is set with the constructor or set(startState). A
 *    corresponding end state and transition are set with set(endState,
 *    transition). Subsequent calls to set(endState, transition) begin at
 *    the last state. Calls to get(timestamp) provide the interpolated state
 *    along the way.
 *
 * Note that there is no event loop here - calls to get() are the only way
 *    to find state projected to the current (or provided) time and are
 *    the only way to trigger callbacks. Usually this kind of object would
 *    be part of the render() path of a visible component.
 */
class Transitionable {
		
    public static var transitionMethods:Map<String, Class<Dynamic>> = new Map();
	public static var transitionId:Int = 0;
	
	var currentAction:Dynamic;
	var actionQueue:Array<Dynamic>;
	var callbackQueue:Array<Void -> Void>;

	var id:Int;
	var state:Dynamic;
	var velocity:Float;
	var _callback:Void -> Void;
	var _engineInstance:Dynamic;
	var _currentMethod:Dynamic;

    /**
     * @constructor
     * @param {number|Array.Number|Object.<number|string, number>} start
     *    beginning state
     */
	public function new(start:Dynamic) {
        this.currentAction = null;
        this.actionQueue = [];
        this.callbackQueue = [];

		this.id = transitionId++;
        this.state = 0;
        this.velocity = null;
        this._callback = null;
        this._engineInstance = null;
        this._currentMethod = null;

        this.set(start);
	}
	
    static public function registerMethod(name:String, engineClass:Class<Dynamic>) {
        if (!transitionMethods.exists(name)) {
            transitionMethods[name] = engineClass;
            return true;
        }
        else return false;
    }

	static public function unregisterMethod(name:String) {
        if (transitionMethods.exists(name)) {
            transitionMethods.remove(name);
            return true;
        }
        else return false;
    }
	
    function _loadNext() {
        if (this._callback != null) {
            var callback = this._callback;
            this._callback = null;
            callback();
        }
        if (this.actionQueue.length <= 0) {
            this.set(this.get()); // no update required
            return;
        }
        this.currentAction = this.actionQueue.shift();
        this._callback = this.callbackQueue.shift();

        var method:Dynamic = null;
        var endValue = this.currentAction[0];
        var transition = this.currentAction[1];
        if (Std.is(transition, Dynamic) && transition.method != null) {
            method = transition.method;
            if (Std.is(method, String)) {
				method = transitionMethods[method];
			}
        }
        else {
            method = TweenTransition;
        }

        if (this._currentMethod != method) {
            if (!Reflect.isObject(endValue) || method.SUPPORTS_MULTIPLE == true || endValue.length <= Std.int(method.SUPPORTS_MULTIPLE)) {
				var a = 1;
                this._engineInstance = Type.createInstance(method, []);
            } else {
				var b = 1;
                this._engineInstance = new MultipleTransition(method);
            }
            this._currentMethod = method;
        }

        this._engineInstance.reset(this.state, this.velocity);
        if (this.velocity != null) {
			transition.velocity = this.velocity;
		}
        this._engineInstance.set(endValue, transition, _loadNext);
    }
	
    /**
     * Add transition to end state to the queue of pending transitions. Special
     *    Use: calling without a transition resets the object to that state with
     *    no pending actions
     *
     * @method set
     *
     * @param {number|FamousMatrix|Array.Number|Object.<number, number>} endState
     *    end state to which we interpolate
     * @param {transition=} transition object of type {duration: number, curve:
     *    f[0,1] -> [0,1] or name}. If transition is omitted or false, change will be
     *    instantaneous.
     * @param {function()=} callback Zero-argument function to call on observed
     *    completion (t=1)
     */
    public function set(endState:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        if (transition == null || transition == false) {
            this.reset(endState);
            if (callback != null) callback();
            return this;
        }

        var action = [endState, transition];
        this.actionQueue.push(action);
        this.callbackQueue.push(callback);
        if (this.currentAction == null) {
			_loadNext();
		}
        return this;
    }

    /**
     * Cancel all transitions and reset to a stable state
     *
     * @method reset
     *
     * @param {number|Array.Number|Object.<number, number>} startState
     *    stable state to set to
     */
    public function reset(startState:Dynamic, ?startVelocity:Float) {
        this._currentMethod = null;
        this._engineInstance = null;
        this.state = startState;
        this.velocity = startVelocity;
        this.currentAction = null;
        this.actionQueue = [];
        this.callbackQueue = [];
    };

    /**
     * Add delay action to the pending action queue queue.
     *
     * @method delay
     *
     * @param {number} duration delay time (ms)
     * @param {function} callback Zero-argument function to call on observed
     *    completion (t=1)
     */
	public function delay(duration:Float, callback:Void->Void) {
        this.set(this._engineInstance.get(), {duration: duration,
            curve: function() {
                return 0;
            }},
            callback);
    }

    /**
     * Get interpolated state of current action at provided time. If the last
     *    action has completed, invoke its callback.
     *
     * @method get
     *
     * @param {number=} timestamp Evaluate the curve at a normalized version of this
     *    time. If omitted, use current time. (Unix epoch time)
     * @return {number|Object.<number|string, number>} beginning state
     *    interpolated to this point in time.
     */
    public function get(?timestamp:Float):Dynamic {
        if (this._engineInstance != null) {
            if (this._engineInstance.getVelocity != null)
                this.velocity = this._engineInstance.getVelocity();
            this.state = this._engineInstance.get(timestamp);
        }
        return this.state;
    }

    /**
     * Is there at least one action pending completion?
     *
     * @method isActive
     *
     * @return {boolean}
     */
	public function isActive() {
        return this.currentAction != null;
    }

    /**
     * Halt transition at current state and erase all pending actions.
     *
     * @method halt
     */
    public function halt() {
        this.set(this.get());
    }
}