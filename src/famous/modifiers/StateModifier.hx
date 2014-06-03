package famous.modifiers;

import famous.core.Modifier;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.TransitionableTransform;

/**
 *  A collection of visual changes to be
 *    applied to another renderable component, strongly coupled with the state that defines
 *    those changes. This collection includes a
 *    transform matrix, an opacity constant, a size, an origin specifier, and an alignment specifier.
 *    StateModifier objects can be added to any RenderNode or object
 *    capable of displaying renderables.  The StateModifier's children and descendants
 *    are transformed by the amounts specified in the modifier's properties.
 */
class StateModifier {
	var _transformState:TransitionableTransform;
	var _opacityState:Transitionable;
	var _originState:Transitionable;
	var _alignState:Transitionable;
	var _sizeState:Transitionable;

	var _modifier:Modifier;

	var _hasOrigin:Bool;
	var _hasAlign:Bool;
	var _hasSize:Bool;

    /**
     * @constructor
     * @param {Object} [options] overrides of default options
     * @param {Transform} [options.transform] affine transformation matrix
     * @param {Number} [options.opacity]
     * @param {Array.Number} [options.origin] origin adjustment
     * @param {Array.Number} [options.align] align adjustment
     * @param {Array.Number} [options.size] size to apply to descendants
     */
	public function new(?options:ModifyOptions) {
        this._transformState = new TransitionableTransform(Transform.identity);
        this._opacityState = new Transitionable(1);
        this._originState = new Transitionable([0, 0]);
        this._alignState = new Transitionable([0, 0]);
        this._sizeState = new Transitionable([0, 0]);

        this._modifier = new Modifier({
            transform: this._transformState,
            opacity: this._opacityState,
            origin: null,
            align: null,
            size: null
        });

        this._hasOrigin = false;
        this._hasAlign = false;
        this._hasSize = false;

        if (options != null) {
            if (options.transform != null) this.setTransform(options.transform);
            if (options.opacity != null) this.setOpacity(options.opacity);
            if (options.origin != null) this.setOrigin(options.origin);
            if (options.align != null) this.setAlign(options.align);
            if (options.size != null) this.setSize(options.size);
        }		
	}
	
    /**
     * Set the transform matrix of this modifier, either statically or
     *   through a provided Transitionable.
     *
     * @method setTransform
     *
     * @param {Transform} transform Transform to transition to.
     * @param {Transitionable} [transition] Valid transitionable object
     * @param {Function} [callback] callback to call after transition completes
     * @return {StateModifier} this
     */
    public function setTransform(transform:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        this._transformState.set(transform, transition, callback);
        return this;
    }

    /**
     * Set the opacity of this modifier, either statically or
     *   through a provided Transitionable.
     *
     * @method setOpacity
     *
     * @param {Number} opacity Opacity value to transition to.
     * @param {Transitionable} transition Valid transitionable object
     * @param {Function} callback callback to call after transition completes
     * @return {StateModifier} this
     */
    public function setOpacity(opacity:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        this._opacityState.set(opacity, transition, callback);
        return this;
    }

    /**
     * Set the origin of this modifier, either statically or
     *   through a provided Transitionable.
     *
     * @method setOrigin
     *
     * @param {Array.Number} origin two element array with values between 0 and 1.
     * @param {Transitionable} transition Valid transitionable object
     * @param {Function} callback callback to call after transition completes
     * @return {StateModifier} this
     */
    public function setOrigin(origin:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        if (origin == null) {
            if (this._hasOrigin) {
                this._modifier.originFrom(null);
                this._hasOrigin = false;
            }
            return this;
        }
        else if (!this._hasOrigin) {
            this._hasOrigin = true;
            this._modifier.originFrom(this._originState);
        }
        this._originState.set(origin, transition, callback);
        return this;
    }

    /**
     * Set the alignment of this modifier, either statically or
     *   through a provided Transitionable.
     *
     * @method setAlign
     *
     * @param {Array.Number} align two element array with values between 0 and 1.
     * @param {Transitionable} transition Valid transitionable object
     * @param {Function} callback callback to call after transition completes
     * @return {StateModifier} this
     */
    public function setAlign(align:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        if (align == null) {
            if (this._hasAlign) {
                this._modifier.alignFrom(null);
                this._hasAlign = false;
            }
            return this;
        }
        else if (!this._hasAlign) {
            this._hasAlign = true;
            this._modifier.alignFrom(this._alignState);
        }
        this._alignState.set(align, transition, callback);
        return this;
    }

    /**
     * Set the size of this modifier, either statically or
     *   through a provided Transitionable.
     *
     * @method setSize
     *
     * @param {Array.Number} size two element array with values between 0 and 1.
     * @param {Transitionable} transition Valid transitionable object
     * @param {Function} callback callback to call after transition completes
     * @return {StateModifier} this
     */
    public function setSize(?size:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        if (size == null) {
            if (this._hasSize) {
                this._modifier.sizeFrom(null);
                this._hasSize = false;
            }
            return this;
        }
        else if (!this._hasSize) {
            this._hasSize = true;
            this._modifier.sizeFrom(this._sizeState);
        }
        this._sizeState.set(size, transition, callback);
        return this;
    }

    /**
     * Stop the transition.
     *
     * @method halt
     */
    public function halt() {
        this._transformState.halt();
        this._opacityState.halt();
        this._originState.halt();
        this._alignState.halt();
        this._sizeState.halt();
    }

    /**
     * Get the current state of the transform matrix component.
     *
     * @method getTransform
     * @return {Object} transform provider object
     */
    public function getTransform() {
        return this._transformState.get();
    }

    /**
     * Get the destination state of the transform component.
     *
     * @method getFinalTransform
     * @return {Transform} transform matrix
     */
    public function getFinalTransform() {
        return this._transformState.getFinal();
    }

    /**
     * Get the current state of the opacity component.
     *
     * @method getOpacity
     * @return {Object} opacity provider object
     */
    public function getOpacity() {
        return this._opacityState.get();
    }

    /**
     * Get the current state of the origin component.
     *
     * @method getOrigin
     * @return {Object} origin provider object
     */
    public function getOrigin() {
        return this._hasOrigin ? this._originState.get() : null;
    }

    /**
     * Get the current state of the align component.
     *
     * @method getAlign
     * @return {Object} align provider object
     */
    public function getAlign() {
        return this._hasAlign ? this._alignState.get() : null;
    }

    /**
     * Get the current state of the size component.
     *
     * @method getSize
     * @return {Object} size provider object
     */
    public function getSize() {
        return this._hasSize ? this._sizeState.get() : null;
    }

    /**
     * Return render spec for this StateModifier, applying to the provided
     *    target component.  This is similar to render() for Surfaces.
     *
     * @private
     * @method modify
     *
     * @param {Object} target (already rendered) render spec to
     *    which to apply the transform.
     * @return {Object} render spec for this StateModifier, including the
     *    provided target
     */
    public function modify(target:Dynamic):ModifyOptions {
        return this._modifier.modify(target);
    }
	
}