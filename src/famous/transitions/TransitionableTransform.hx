package famous.transitions;

import famous.core.Transform;
import famous.utilities.Utility;

/**
 * A class for transitioning the state of a Transform by transitioning
 * its translate, scale, skew and rotate components independently.
 */
class TransitionableTransform {

    var _final:Matrix4;
    var translate:Transitionable;
    var rotate:Transitionable;
    var skew:Transitionable;
    var scale:Transitionable;
	
    /**
     * @constructor
     *
     * @param [transform=Transform.identity] {Transform} The initial transform state
     */
	public function new(?transform:Matrix4) {
        this._final = Transform.identity.slice(0);
        this.translate = new Transitionable([0, 0, 0]);
        this.rotate = new Transitionable([0, 0, 0]);
        this.skew = new Transitionable([0, 0, 0]);
        this.scale = new Transitionable([1, 1, 1]);

        if (transform != null) this.set(transform);
	}
	
    function _build() {
        return Transform.build({
            translate: this.translate.get(),
            rotate: this.rotate.get(),
            skew: this.skew.get(),
            scale: this.scale.get()
        });
    }

    /**
     * An optimized way of setting only the translation component of a Transform
     *
     * @method setTranslate
     * @chainable
     *
     * @param translate {Array}     New translation state
     * @param [transition] {Object} Transition definition
     * @param [callback] {Function} Callback
     * @return {TransitionableTransform}
     */
    public function setTranslate(translate:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        this.translate.set(translate, transition, callback);
        this._final = this._final.slice(0);
        this._final[12] = translate[0];
        this._final[13] = translate[1];
        if (translate[2] != null) {
			this._final[14] = translate[2];
		}
        return this;
    }

    /**
     * An optimized way of setting only the scale component of a Transform
     *
     * @method setTranslate
     * @chainable
     *
     * @param scale {Array}         New scale state
     * @param [transition] {Object} Transition definition
     * @param [callback] {Function} Callback
     * @return {TransitionableTransform}
     */
    public function setScale(scale:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        this.scale.set(scale, transition, callback);
        this._final = this._final.slice(0);
        this._final[0] = scale[0];
        this._final[5] = scale[1];
        if (scale[2] != null) {
			this._final[10] = scale[2];
		}
        return this;
    }

    /**
     * An optimized way of setting only the rotational component of a Transform
     *
     * @method setTranslate
     * @chainable
     *
     * @param eulerAngles {Array}   Euler angles for new rotation state
     * @param [transition] {Object} Transition definition
     * @param [callback] {Function} Callback
     * @return {TransitionableTransform}
     */
    public function setRotate(eulerAngles:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        this.rotate.set(eulerAngles, transition, callback);
        this._final = _build();
        this._final = Transform.build({
            translate: this.translate.get(),
            rotate: eulerAngles,
            scale: this.scale.get(),
            skew: this.skew.get()
        });
        return this;
    }

    /**
     * An optimized way of setting only the skew component of a Transform
     *
     * @method setTranslate
     * @chainable
     *
     * @param skewAngles {Array}    New skew state
     * @param [transition] {Object} Transition definition
     * @param [callback] {Function} Callback
     * @return {TransitionableTransform}
     */
	public function setSkew(skewAngles:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        this.skew.set(skewAngles, transition, callback);
        this._final = Transform.build({
            translate: this.translate.get(),
            rotate: this.rotate.get(),
            scale: this.scale.get(),
            skew: skewAngles
        });
        return this;
    }

    /**
     * Setter for a TransitionableTransform with optional parameters to transition
     * between Transforms
     *
     * @method setTranslate
     * @chainable
     *
     * @param transform {Array}     New transform state
     * @param [transition] {Object} Transition definition
     * @param [callback] {Function} Callback
     * @return {TransitionableTransform}
     */
    public function set(transform:Matrix4, ?transition:Dynamic, ?callback:Void -> Void) {
        this._final = transform;
        var components = Transform.interpret(transform);

        var _callback = callback != null ? Utility.after(4, callback) : null;
        this.translate.set(components.translate, transition, _callback);
        this.rotate.set(components.rotate, transition, _callback);
        this.skew.set(components.skew, transition, _callback);
        this.scale.set(components.scale, transition, _callback);
        return this;
    }

    /**
     * Sets the default transition to use for transitioning betwen Transform states
     *
     * @method setDefaultTransition
     *
     * @param transition {Object} Transition definition
     */
    /*
	public function setDefaultTransition(transition:Dynamic) {
        this.translate.setDefault(transition);
        this.rotate.setDefault(transition);
        this.skew.setDefault(transition);
        this.scale.setDefault(transition);
    }
	*/
	
    /**
     * Getter. Returns the current state of the Transform
     *
     * @method get
     *
     * @return {Transform}
     */
    public function get() {
        if (this.isActive()) {
            return _build();
        }
        else return this._final;
    }

    /**
     * Get the destination state of the Transform
     *
     * @method getFinal
     *
     * @return Transform {Transform}
     */
    public function getFinal() {
        return this._final;
    }

    /**
     * Determine if the TransitionalTransform is currently transitioning
     *
     * @method isActive
     *
     * @return {Boolean}
     */
    public function isActive():Bool {
        return this.translate.isActive() || this.rotate.isActive() || this.scale.isActive() || this.skew.isActive();
    }

    /**
     * Halts the transition
     *
     * @method halt
     */
    public function halt() {
        this._final = this.get();
        this.translate.halt();
        this.rotate.halt();
        this.skew.halt();
        this.scale.halt();
    }
}