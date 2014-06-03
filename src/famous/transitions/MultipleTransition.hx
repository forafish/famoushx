package famous.transitions;

import famous.utilities.Utility;

/**
 * Transition meta-method to support transitioning multiple
 *   values with scalar-only methods.
 */
class MultipleTransition {
	
	static public var SUPPORTS_MULTIPLE = true;
	
	var method:Class<Dynamic>;
	var _instances:Array<Dynamic>;
	var state:Array<Dynamic>;
    /**
     * @constructor
     *
     * @param {Object} method Transionable class to multiplex
     */
	public function new(method:Class<Dynamic>) {
        this.method = method;
        this._instances = [];
        this.state = [];
	}
	
    /**
     * Get the state of each transition.
     *
     * @method get
     *
     * @return state {Number|Array} state array
     */
    public function get() {
        for (i in 0...this._instances.length) {
            this.state[i] = this._instances[i].get();
        }
        return this.state;
    }

    /**
     * Set the end states with a shared transition, with optional callback.
     *
     * @method set
     *
     * @param {Number|Array} endState Final State.  Use a multi-element argument for multiple transitions.
     * @param {Object} transition Transition definition, shared among all instances
     * @param {Function} callback called when all endStates have been reached.
     */
    public function set(endState:Array<Dynamic>, ?transition:Dynamic, ?callback:Void -> Void) {
        var _allCallback = Utility.after(endState.length, callback);
        for (i in 0...endState.length) {
            if (this._instances[i] == null) this._instances[i] = Type.createInstance(this.method, []);
            this._instances[i].set(endState[i], transition, _allCallback);
        }
    }

    /**
     * Reset all transitions to start state.
     *
     * @method reset
     *
     * @param  {Number|Array} startState Start state
     */
    public function reset(startState:Array<Float>) {
        for (i in 0...startState.length) {
            if (this._instances[i] == null) this._instances[i] = Type.createInstance(this.method, []);
            this._instances[i].reset(startState[i]);
        }
    }	
}