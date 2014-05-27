package famous.views;

import famous.core.Surface;
import famous.core.Transform;
import famous.core.OptionsManager;
import famous.core.RenderNode;
import famous.transitions.Transitionable;
import famous.views.Flipper.FlipperOptions;

typedef FlipperOptions =  {
	transition:Bool,
	direction:Int
};

/**
 * Allows you to link two renderables as front and back sides that can be
 *  'flipped' back and forth along a chosen axis. Rendering optimizations are
 *  automatically handled.
 */
class Flipper {
    static public var DIRECTION_X = 0;
    static public var DIRECTION_Y = 1;

    static public var SEPERATION_LENGTH = 1;

    static public var DEFAULT_OPTIONS = {
        transition: true,
        direction: Flipper.DIRECTION_X
    };

	var options:FlipperOptions;
	var _optionsManager:OptionsManager;

	var angle:Transitionable;

	var frontNode:Surface;
	var backNode:Surface;

	var flipped:Bool;
	
    /**
     * @constructor
     * @param {Options} [options] An object of options.
     * @param {Transition} [options.transition=true] The transition executed when flipping your Flipper instance.
     */
	public function new(?options:FlipperOptions) {
        this.options = Reflect.copy(Flipper.DEFAULT_OPTIONS);
        this._optionsManager = new OptionsManager(this.options);
        if (options != null) this.setOptions(options);

        this.angle = new Transitionable(0);

        this.frontNode = null;
        this.backNode = null;

        this.flipped = false;
	}
	
    /**
     * Toggles the rotation between the front and back renderables
     *
     * @method flip
     * @param {Object} [transition] Transition definition
     * @param {Function} [callback] Callback
     */
    public function flip(?transition:Dynamic, ?callback:Void -> Void) {
        var angle = this.flipped ? 0 : Math.PI;
        this.setAngle(angle, transition, callback);
        this.flipped = !this.flipped;
    };

    /**
     * Basic setter to the angle
     *
     * @method setAngle
     * @param {Number} angle
     * @param {Object} [transition] Transition definition
     * @param {Function} [callback] Callback
     */
    public function setAngle(angle:Float, ?transition:Dynamic, ?callback:Void -> Void) {
        if (transition == null) transition = this.options.transition;
        if (this.angle.isActive()) this.angle.halt();
        this.angle.set(angle, transition, callback);
    }

    /**
     * Patches the Flipper instance's options with the passed-in ones.
     *
     * @method setOptions
     * @param {Options} options An object of configurable options for the Flipper instance.
     */
    public function setOptions(options) {
        return this._optionsManager.setOptions(options);
    }

    /**
     * Adds the passed-in renderable to the view associated with the 'front' of the Flipper instance.
     *
     * @method setFront
     * @chainable
     * @param {Object} node The renderable you want to add to the front.
     */
    public function setFront(node:Surface) {
        this.frontNode = node;
    }

    /**
     * Adds the passed-in renderable to the view associated with the 'back' of the Flipper instance.
     *
     * @method setBack
     * @chainable
     * @param {Object} node The renderable you want to add to the back.
     */
    public function setBack(node:Surface) {
        this.backNode = node;
    }

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {Number} Render spec for this component
     */
	public function render() {
        var angle = this.angle.get();

        var frontTransform;
        var backTransform;

        if (this.options.direction == Flipper.DIRECTION_X) {
            frontTransform = Transform.rotateY(angle);
            backTransform = Transform.rotateY(angle + Math.PI);
        }
        else {
            frontTransform = Transform.rotateX(angle);
            backTransform = Transform.rotateX(angle + Math.PI);
        }

        var result = [];
        if (this.frontNode != null){
            result.push({
                transform: frontTransform,
                target: this.frontNode.render()
            });
        }

        if (this.backNode != null){
            result.push({
                transform: Transform.moveThen([0, 0, SEPERATION_LENGTH], backTransform),
                target: this.backNode.render()
            });
        }

        return result;
    }	
}