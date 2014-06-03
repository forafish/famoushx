package famous.modifiers;

import famous.core.OptionsManager;
import famous.transitions.Transitionable;

typedef FaderOptions = {
	cull: Bool,
	transition: Bool,
	pulseInTransition: Bool,
	pulseOutTransition: Bool
};

/**
 * Modifier that allows you to fade the opacity of affected renderables in and out.
 */
class Fader {
    static public var DEFAULT_OPTIONS:FaderOptions = {
        cull: false,
        transition: true,
        pulseInTransition: true,
        pulseOutTransition: true
    };
	
	var options:Dynamic;
	var _optionsManager:OptionsManager;
	
	var transitionHelper:Transitionable;

    /**
     * @constructor
     * @param {Object} [options] options configuration object.
     * @param {Boolean} [options.cull=false] Stops returning affected renderables up the tree when they're fully faded when true.
     * @param {Transition} [options.transition=true] The main transition for showing and hiding.
     * @param {Transition} [options.pulseInTransition=true] Controls the transition to a pulsed state when the Fader instance's pulse
     * method is called.
     * @param {Transition} [options.pulseOutTransition=true]Controls the transition back from a pulsed state when the Fader instance's pulse
     * method is called.
     */
	public function new(?options:FaderOptions, ?startState:Dynamic) {
		this.options = Reflect.copy(Fader.DEFAULT_OPTIONS);
        this._optionsManager = new OptionsManager(this.options);

        if (options != null) this.setOptions(options);

        if (startState == null) startState = 0;
        this.transitionHelper = new Transitionable(startState);
	}
	
    /**
     * Set internal options, overriding any default options
     *
     * @method setOptions
     *
     * @param {Object} [options] overrides of default options.  See constructor.
     */
    public function setOptions(options) {
        return this._optionsManager.setOptions(options);
    }

    /**
     * Fully displays the Fader instance's associated renderables.
     *
     * @method show
     * @param {Transition} [transition] The transition that coordinates setting to the new state.
     * @param {Function} [callback] A callback that executes once you've transitioned to the fully shown state.
     */
    public function show(transition, callback) {
        transition = transition != null? transition : this.options.transition;
        this.set(1, transition, callback);
    }

    /**
     * Fully fades the Fader instance's associated renderables.
     *
     * @method hide
     * @param {Transition} [transition] The transition that coordinates setting to the new state.
     * @param {Function} [callback] A callback that executes once you've transitioned to the fully faded state.
     */
    public function hide(?transition:Dynamic, ?callback:Void -> Void) {
        transition = transition != null? transition : this.options.transition;
        this.set(0, transition, callback);
    }

    /**
     * Manually sets the opacity state of the fader to the passed-in one. Executes with an optional
     * transition and callback.
     *
     * @method set
     * @param {Number} state A number from zero to one: the amount of opacity you want to set to.
     * @param {Transition} [transition] The transition that coordinates setting to the new state.
     * @param {Function} [callback] A callback that executes once you've finished executing the pulse.
     */
    public function set(state:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        this.halt();
        this.transitionHelper.set(state, transition, callback);
    }

    /**
     * Halt the transition
     *
     * @method halt
     */
    public function halt() {
        this.transitionHelper.halt();
    }

    /**
     * Tells you if your Fader instance is above its visibility threshold.
     *
     * @method isVisible
     * @return {Boolean} Whether or not your Fader instance is visible.
     */
    public function isVisible() {
        return (this.transitionHelper.get() > 0);
    }

    /**
     * Return render spec for this Modifier, applying to the provided
     *    target component.  This is similar to render() for Surfaces.
     *
     * @private
     * @method modify
     *
     * @param {Object} target (already rendered) render spec to
     *    which to apply the transform.
     * @return {Object} render spec for this Modifier, including the
     *    provided target
     */
    public function modify(target) {
        var currOpacity = this.transitionHelper.get();
        if (this.options.cull && currOpacity == null) return null;
        else return {opacity: currOpacity, target: target};
    }
	
}