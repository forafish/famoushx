package famous.core;

import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.TransitionableTransform;

typedef ModifyOptions = {
	?transform: Dynamic, // Matrix4 or Function or TransitionableTransform
	?opacity: Dynamic, // Float or Function or Transitionable
	?origin: Dynamic, // Array<Float> or Function
	?align: Dynamic,
	?size: Dynamic, // Array<Float> or Function or Transitionable
	?target: Dynamic
};

/**
 *  A collection of visual changes to be
 *    applied to another renderable component. This collection includes a
 *    transform matrix, an opacity constant, a size, an origin specifier.
 *    Modifier objects can be added to any RenderNode or object
 *    capable of displaying renderables.  The Modifier's children and descendants
 *    are transformed by the amounts specified in the Modifier's properties.
 */
class Modifier {
	var _transformGetter:Void -> Matrix4;
	var _opacityGetter:Void -> Float = null;
	var _originGetter:Void -> Array<Float>;
	var _alignGetter:Void -> Array<Float>;
	var _sizeGetter:Void -> Array<Float>;

	/* TODO: remove this when deprecation complete */
	var _legacyStates:Dynamic;

	var _output:ModifyOptions;
 
    /**
    * @constructor
     * @param {Object} [options] overrides of default options
     * @param {Transform} [options.transform] affine transformation matrix
     * @param {Number} [options.opacity]
     * @param {Array.Number} [options.origin] origin adjustment
     * @param {Array.Number} [options.size] size to apply to descendants
     */
	public function new(?options:ModifyOptions) {
        this._transformGetter = null;
        this._opacityGetter = null;
        this._originGetter = null;
		this._alignGetter = null;
        this._sizeGetter = null;

        /* TODO: remove this when deprecation complete */
        this._legacyStates = {};

        this._output = {
            transform: Transform.identity,
            opacity: 1,
            origin: null,
			align: null,
            size: null,
            target: null
        };

        if (options != null) {
            if (options.transform != null) {
				this.transformFrom(options.transform);
			}
            if (options.opacity != null) {
				this.opacityFrom(options.opacity);
			}
            if (options.origin != null) {
				this.originFrom(options.origin);
			}
			if (options.align != null) {
				this.alignFrom(options.align);
			}
            if (options.size != null) {
				this.sizeFrom(options.size);
			}
        }
		
	}
	
    /**
     * Function, object, or static transform matrix which provides the transform.
     *   This is evaluated on every tick of the engine.
     *
     * @method transformFrom
     *
     * @param {Object} transform transform provider object
     * @return {Modifier} this
     */
    public function transformFrom(transform:Dynamic):Modifier {
        if (Reflect.isFunction(transform)) {
			this._transformGetter = transform;
		}
        else if (Reflect.isObject(transform) && transform.get != null) {
			this._transformGetter = transform.get.bind(transform);
		}
        else {
            this._transformGetter = null;
            this._output.transform = transform;
        }
        return this;
    }

    /**
     * Set function, object, or number to provide opacity, in range [0,1].
     *
     * @method opacityFrom
     *
     * @param {Object} opacity provider object
     * @return {Modifier} this
     */
    public function opacityFrom(opacity:Dynamic):Modifier {
        if (Reflect.isFunction(opacity)) {
			this._opacityGetter = opacity;
		}
        else if (Reflect.isObject(opacity) && opacity.get != null) {
			this._opacityGetter = opacity.get.bind(opacity);
		}
        else {
            this._opacityGetter = null;
            this._output.opacity = opacity;
        }
        return this;
    }

    /**
     * Set function, object, or numerical array to provide origin, as [x,y],
     *   where x and y are in the range [0,1].
     *
     * @method originFrom
     *
     * @param {Object} origin provider object
     * @return {Modifier} this
     */

    public function originFrom(origin:Dynamic):Modifier {
        if (Reflect.isFunction(origin)) {
			this._originGetter = origin;
		}
        else if (Reflect.isObject(origin) && origin.get != null) {
			this._originGetter = origin.get.bind(origin);
		}
        else {
            this._originGetter = null;
            this._output.origin = origin;
        }
        return this;
    }

    /**
     * Set function, object, or numerical array to provide align, as [x,y],
     *   where x and y are in the range [0,1].
     *
     * @method alignFrom
     *
     * @param {Object} align provider object
     * @return {Modifier} this
     */
    public function alignFrom(align:Dynamic):Modifier {
        if (Reflect.isFunction(align)) {
			this._alignGetter = align;
		}
        else if (Reflect.isObject(align) && align.get != null) {
			this._alignGetter = align.get.bind(align);
		}
        else {
            this._alignGetter = null;
            this._output.align = align;
        }
        return this;
    }
	
    /**
     * Set function, object, or numerical array to provide size, as [width, height].
     *
     * @method sizeFrom
     *
     * @param {Object} size provider object
     * @return {Modifier} this
     */
    public function sizeFrom(size:Dynamic):Modifier {
        if (Reflect.isFunction(size)) {
			this._sizeGetter = size;
		}
        else if (size.get != null) {
			this._sizeGetter = size.get.bind(size);
		}
        else {
            this._sizeGetter = null;
            this._output.size = size;
        }
        return this;
    }

     /**
     * Deprecated: Prefer transformFrom with static Transform, or use a TransitionableTransform.
     * @deprecated
     * @method setTransform
     *
     * @param {Transform} transform Transform to transition to
     * @param {Transitionable} transition Valid transitionable object
     * @param {Function} callback callback to call after transition completes
     * @return {Modifier} this
     */
    public function setTransform(transform:Dynamic, ?transition:Dynamic, ?callback:Void->Void):Modifier {
        if (transition != null || this._legacyStates.transform != null) {
            if (this._legacyStates.transform == null) {
                this._legacyStates.transform = new TransitionableTransform(this._output.transform);
            }
            if (this._transformGetter == null) {
				this.transformFrom(this._legacyStates.transform);
			}

            this._legacyStates.transform.set(transform, transition, callback);
            return this;
        }
        else return this.transformFrom(transform);
    }

    /**
     * Deprecated: Prefer opacityFrom with static opacity array, or use a Transitionable with that opacity.
     * @deprecated
     * @method setOpacity
     *
     * @param {Number} opacity Opacity value to transition to.
     * @param {Transitionable} transition Valid transitionable object
     * @param {Function} callback callback to call after transition completes
     * @return {Modifier} this
     */
    public function setOpacity(opacity:Dynamic, ?transition:Transitionable, ?callback:Void->Void):Modifier {
        if (transition != null || this._legacyStates.opacity != null) {
            if (this._legacyStates.opacity == null) {
                this._legacyStates.opacity = new Transitionable(this._output.opacity);
            }
            if (this._opacityGetter == null) {
				this.opacityFrom(this._legacyStates.opacity);
			}

            return this._legacyStates.opacity.set(opacity, transition, callback);
        }
        else return this.opacityFrom(opacity);
    }

    /**
     * Deprecated: Prefer originFrom with static origin array, or use a Transitionable with that origin.
     * @deprecated
     * @method setOrigin
     *
     * @param {Array.Number} origin two element array with values between 0 and 1.
     * @param {Transitionable} transition Valid transitionable object
     * @param {Function} callback callback to call after transition completes
     * @return {Modifier} this
     */
    public function setOrigin(origin:Dynamic, ?transition:Transitionable, ?callback:Void->Void):Modifier {
        /* TODO: remove this if statement when deprecation complete */
        if (transition != null || this._legacyStates.origin != null) {

            if (this._legacyStates.origin == null) {
                this._legacyStates.origin = new Transitionable(this._output.origin != null? this._output.origin : [0, 0]);
            }
            if (this._originGetter == null) {
				this.originFrom(this._legacyStates.origin);
			}

            this._legacyStates.origin.set(origin, transition, callback);
            return this;
        }
        else return this.originFrom(origin);
    }

    /**
     * Deprecated: Prefer alignFrom with static align array, or use a Transitionable with that align.
     * @deprecated
     * @method setAlign
     *
     * @param {Array.Number} align two element array with values between 0 and 1.
     * @param {Transitionable} transition Valid transitionable object
     * @param {Function} callback callback to call after transition completes
     * @return {Modifier} this
     */
    public function setAlign(align:Dynamic, ?transition:Transitionable, ?callback:Void -> Void) {
        /* TODO: remove this if statement when deprecation complete */
        if (transition != null || this._legacyStates.align != null) {
            if (this._legacyStates.align == null) {
                this._legacyStates.align = new Transitionable(this._output.align != null? this._output.align : [0, 0]);
            }
            if (this._alignGetter == null) {
				this.alignFrom(this._legacyStates.align);
			}

            this._legacyStates.align.set(align, transition, callback);
            return this;
        }
        else return this.alignFrom(align);
    }
	
    /**
     * Deprecated: Prefer sizeFrom with static origin array, or use a Transitionable with that size.
     * @deprecated
     * @method setSize
     * @param {Array.Number} size two element array of [width, height]
     * @param {Transitionable} transition Valid transitionable object
     * @param {Function} callback callback to call after transition completes
     * @return {Modifier} this
     */
    public function setSize(size:Dynamic, ?transition:Transitionable, ?callback:Void->Void):Modifier {
        if (size != null && (transition != null || this._legacyStates.size != null)) {
            if (this._legacyStates.size == null) {
                this._legacyStates.size = new Transitionable(this._output.size != null? this._output.size : [0, 0]);
            }
            if (this._sizeGetter == null) {
				this.sizeFrom(this._legacyStates.size);
			}

            this._legacyStates.size.set(size, transition, callback);
            return this;
        }
        else return this.sizeFrom(size);
    }

    /**
     * Deprecated: Prefer to stop transform in your provider object.
     * @deprecated
     * @method halt
     */
    public function halt() {
        if (this._legacyStates.transform != null) {
			this._legacyStates.transform.halt();
		}
        if (this._legacyStates.opacity != null) {
			this._legacyStates.opacity.halt();
		}
        if (this._legacyStates.origin != null) {
			this._legacyStates.origin.halt();
		}
		if (this._legacyStates.align != null) {
			this._legacyStates.align.halt();
		}
        if (this._legacyStates.size != null) {
			this._legacyStates.size.halt();
		}
        this._transformGetter = null;
        this._opacityGetter = null;
        this._originGetter = null;
		this._alignGetter = null;
        this._sizeGetter = null;
    }

    /**
     * Deprecated: Prefer to use your provided transform or output of your transform provider.
     * @deprecated
     * @method getTransform
     * @return {Object} transform provider object
     */
    public function getTransform():Matrix4 {
        return this._transformGetter();
    }

    /**
     * Deprecated: Prefer to determine the end state of your transform from your transform provider
     * @deprecated
     * @method getFinalTransform
     * @return {Transform} transform matrix
     */
    public function getFinalTransform():Matrix4 {
        return this._legacyStates.transform ? this._legacyStates.transform.getFinal() : this._output.transform;
    }

    /**
     * Deprecated: Prefer to use your provided opacity or output of your opacity provider.
     * @deprecated
     * @method getOpacity
     * @return {Object} opacity provider object
     */
    public function getOpacity():Float {
        return this._opacityGetter();
    }
	
    /**
     * Deprecated: Prefer to use your provided origin or output of your origin provider.
     * @deprecated
     * @method getOrigin
     * @return {Object} origin provider object
     */
    public function getOrigin():Dynamic {
        return this._originGetter();
    }

    /**
     * Deprecated: Prefer to use your provided align or output of your align provider.
     * @deprecated
     * @method getAlign
     * @return {Object} align provider object
     */
    public function getAlign():Dynamic {
        return this._alignGetter();
    }

    /**
     * Deprecated: Prefer to use your provided size or output of your size provider.
     * @deprecated
     * @method getSize
     * @return {Object} size provider object
     */
    public function getSize():Array<Float> {
        return (this._sizeGetter != null)? this._sizeGetter() : this._output.size;
    }

    // call providers on tick to receive render spec elements to apply
	private function _update() {
        if (this._transformGetter != null) {
			this._output.transform = this._transformGetter();
		}
        if (this._opacityGetter != null) {
			this._output.opacity = this._opacityGetter();
		}
        if (this._originGetter != null) {
			this._output.origin = this._originGetter();
		}
        if (this._sizeGetter != null) {
			this._output.size = this._sizeGetter();
		}
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
    public function modify(target:Dynamic):ModifyOptions {
        _update();
        this._output.target = target;
        return this._output;
    }
	
}