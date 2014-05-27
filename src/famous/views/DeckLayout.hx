package famous.views;

import famous.core.OptionsManager;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.utilities.Utility;
import famous.views.SequentialLayout;
import famous.core.ViewSequence;

typedef DeckLayoutOptions = {
	> SequentialLayoutOptions,
	?transition:Dynamic,
	?stackRotation:Float
}

/**
 * A Sequential Layout that can be opened and closed with animations.
 *
 *   Takes the same options as SequentialLayout
 *   as well as options for the open/close transition
 *   and the rotation you want your Deck instance to layout in.
 */
class DeckLayout extends SequentialLayout {
	
    static public var DEFAULT_OPTIONS:DeckLayoutOptions = {
        transition: {
            curve: 'easeOutBounce',
            duration: 500
        },
        stackRotation: 0.0
    };

	var state:Transitionable;
	var _isOpen:Bool;

    /**
     * @constructor
     * @extends SequentialLayout
     *
     * @param {Options} [options] An object of configurable options
     * @param {Transition} [options.transition={duration: 500, curve: 'easeOutBounce'}
     *   The transition that executes upon opening or closing your deck instance.
     * @param {Number} [stackRotation=0] The amount of rotation applied to the propogation
     *   of the Deck instance's stack of renderables.
     * @param {Object} [options.transition] A transition object for changing between states.
     * @param {Number} [options.direction] axis of expansion (Utility.Direction.X or .Y)
     */
	public function new(options:DeckLayoutOptions) {
        super(options);
        this.setOptions(Reflect.copy(DeckLayout.DEFAULT_OPTIONS));
		
        this.state = new Transitionable(0);
        this._isOpen = false;

        this.setOutputFunction(function(input:ViewSequence, offset:Float, index:Int):Dynamic {
            var state = _getState();
            var positionMatrix = (this.options.direction == Utility.Direction.X) 
				? Transform.translate(state * offset, 0, 0.001 * (state - 1) * offset) 
				: Transform.translate(0, state * offset, 0.001 * (state - 1) * offset);
            var output:Dynamic = input.render();
            if (this.options.stackRotation != null) {
                var amount = this.options.stackRotation * index * (1 - state);
                output = {
                    transform: Transform.rotateZ(amount),
                    origin: [0.5, 0.5],
                    target: output
                };
            }
            return {
                transform: positionMatrix,
                size: input.getSize(),
                target: output
            };
        });
	}
	
    /**
     * Returns the width and the height of the Deck instance.
     *
     * @method getSize
     * @return {Array} A two value array of Deck's current width and height (in that order).
     *   Scales as Deck opens and closes.
     */
    override public function getSize() {
        var originalSize = super.getSize();
        var firstSize:Array<Float> = this._items != null? this._items.get().getSize() : [0, 0];
        if (firstSize == null) firstSize = [0, 0];
        var state = _getState();
        var invState = 1 - state;
        return [
			firstSize[0] * invState + originalSize[0] * state,
			firstSize[1] * invState + originalSize[1] * state
		];
    }

    function _getState(?returnFinal:Bool) {
        if (returnFinal) return this._isOpen ? 1 : 0;
        else return this.state.get();
    }

    function _setState(pos:Dynamic, transition:Dynamic, callback:Void -> Void) {
        this.state.halt();
        this.state.set(pos, transition, callback);
    }

    /**
     * An accesor method to find out if the messaged Deck instance is open or closed.
     *
     * @method isOpen
     * @return {Boolean} Returns true if the instance is open or false if it's closed.
     */
    public function isOpen() {
        return this._isOpen;
    }

    /**
     * Sets the Deck instance to an open state.
     *
     * @method open
     * @param {function} [callback] Executes after transitioning to a fully open state.
     */
    public function open(?callback:Void -> Void) {
        this._isOpen = true;
       _setState(1, this.options.transition, callback);
    }

    /**
     * Sets the Deck instance to an open state.
     *
     * @method close
     * @param {function} [callback] Executes after transitioning to a fully closed state.
     */
    public function close(?callback:Void -> Void) {
        this._isOpen = false;
        _setState(0, this.options.transition, callback);
    }

    /**
     * Sets the Deck instance from its current state to the opposite state.
     *
     * @method close
     * @param {function} [callback] Executes after transitioning to the toggled state.
     */
    public function toggle(?callback:Void -> Void) {
        if (this._isOpen) this.close(callback);
        else this.open(callback);
    }
}