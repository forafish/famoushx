package famous.views;

import famous.core.Modifier;
import famous.core.RenderNode;
import famous.core.Transform;
import famous.core.View;
import famous.transitions.Transitionable;

typedef RenderControllerOptions = {
	inTransition: Bool,
	outTransition: Bool,
	overlap: Bool
};
	
/**
 * A dynamic view that can show or hide different renerables with transitions.
 */
class RenderController extends View {

    static public var DEFAULT_OPTIONS:RenderControllerOptions = {
        inTransition: true,
        outTransition: true,
        overlap: true
    };

    static public var DefaultMap = {
        transform: function() {
            return Transform.identity;
        },
        opacity: function(progress) {
            return progress;
        },
        origin: null
    };
    
	var _showing:Int;
	var _outgoingRenderables:Array<Dynamic>;
	var _nextRenderable:Dynamic;

	var _renderables:Array<Dynamic>;
	var _nodes:Array<RenderNode>;
	var _modifiers:Array<Modifier>;
	var _states:Array<Dynamic>;

	var inTransformMap:Void -> Matrix4;
	var inOpacityMap:Dynamic -> Float;
	var inOriginMap:Void -> Array<Float>;
	var outTransformMap:Void -> Matrix4;
	var outOpacityMap:Dynamic -> Float;
	var outOriginMap:Void -> Array<Float>;

	var _output:Array<Dynamic>;
		
	/**
     * @constructor
     * @param {Options} [options] An object of configurable options.
     * @param {Transition} [inTransition=true] The transition in charge of showing a renderable.
     * @param {Transition} [outTransition=true]  The transition in charge of removing your previous renderable when
     * you show a new one, or hiding your current renderable.
     * @param {Boolean} [overlap=true] When showing a new renderable, overlap determines if the
      out transition of the old one executes concurrently with the in transition of the new one,
       or synchronously beforehand.
     */
	public function new(options:RenderControllerOptions) {
		super(options);
		this.setOptions(Reflect.copy(RenderController.DEFAULT_OPTIONS));
		
        this._showing = -1;
        this._outgoingRenderables = [];
        this._nextRenderable = null;

        this._renderables = [];
        this._nodes = [];
        this._modifiers = [];
        this._states = [];

        this.inTransformMap = RenderController.DefaultMap.transform;
        this.inOpacityMap = RenderController.DefaultMap.opacity;
        this.inOriginMap = RenderController.DefaultMap.origin;
        this.outTransformMap = RenderController.DefaultMap.transform;
        this.outOpacityMap = RenderController.DefaultMap.opacity;
        this.outOriginMap = RenderController.DefaultMap.origin;

        this._output = [];
	}
	
    function _mappedState(map:Dynamic, state:Transitionable) {
        return Reflect.callMethod(this, map, [state.get()]);
    }

    /**
     * As your RenderController shows a new renderable, it executes a transition in. This transition in
     *  will affect a default interior state and modify it as you bring renderables in and out. However, if you want to control
     *  the transform, opacity, and origin state yourself, you may call certain methods (such as inTransformFrom) to obtain state from an outside source,
     *  that may either be a function or a Famous transitionable. inTransformFrom sets the accessor for the state of
     *  the transform used in transitioning in renderables.
     *
     * @method inTransformFrom
     * @param {Function|Transitionable} transform  A function that returns a transform from outside closure, or a
     * a transitionable that manages a full transform (a sixteen value array).
     * @chainable
     */
    public function inTransformFrom(transform:Dynamic) {
        if (Reflect.isFunction(transform)) {
			this.inTransformMap = transform;
		}
        else if (transform != null && transform.get != null) {
			this.inTransformMap = transform.get.bind(transform);
		}
        else throw 'inTransformFrom takes only function or getter object';
        //TODO: tween transition
        return this;
    }

    /**
     * inOpacityFrom sets the accessor for the state of the opacity used in transitioning in renderables.
     * @method inOpacityFrom
     * @param {Function|Transitionable} opacity  A function that returns an opacity from outside closure, or a
     * a transitionable that manages opacity (a number between zero and one).
     * @chainable
     */
    public function inOpacityFrom(opacity:Dynamic) {
        if (Reflect.isFunction(opacity)) {
			this.inOpacityMap = opacity;
		}
        else if (opacity != null && opacity.get != null) {
			this.inOpacityMap = opacity.get.bind(opacity);
		}
        else throw 'inOpacityFrom takes only function or getter object';
        //TODO: tween opacity
        return this;
    }

    /**
     * inOriginFrom sets the accessor for the state of the origin used in transitioning in renderables.
     * @method inOriginFrom
     * @param {Function|Transitionable} origin A function that returns an origin from outside closure, or a
     * a transitionable that manages origin (a two value array of numbers between zero and one).
     * @chainable
     */
    public function inOriginFrom(origin:Dynamic) {
        if (Reflect.isFunction(origin)) {
			this.inOriginMap = origin;
		}
        else if (origin != null && origin.get != null) {
			this.inOriginMap = origin.get.bind(origin);
		}
        else throw 'inOriginFrom takes only function or getter object';
        //TODO: tween origin
        return this;
    }
	
    /**
     * outTransformFrom sets the accessor for the state of the transform used in transitioning out renderables.
     * @method show
     * @param {Function|Transitionable} transform  A function that returns a transform from outside closure, or a
     * a transitionable that manages a full transform (a sixteen value array).
     * @chainable
     */
    public function outTransformFrom(transform:Dynamic) {
        if (Reflect.isFunction(transform)) {
			this.outTransformMap = transform;
		}
        else if (transform != null && transform.get != null) {
			this.outTransformMap = transform.get.bind(transform);
		}
        else throw 'inTransformFrom takes only function or getter object';
        //TODO: tween transition
        return this;
    }

    /**
     * outOpacityFrom sets the accessor for the state of the opacity used in transitioning out renderables.
     * @method inOpacityFrom
     * @param {Function|Transitionable} opacity  A function that returns an opacity from outside closure, or a
     * a transitionable that manages opacity (a number between zero and one).
     * @chainable
     */
    public function outOpacityFrom(opacity:Dynamic) {
        if (Reflect.isFunction(opacity)) {
			this.outOpacityMap = opacity;
		}
        else if (opacity != null && opacity.get != null) {
			this.outOpacityMap = opacity.get.bind(opacity);
		}
        else throw 'inOpacityFrom takes only function or getter object';
        //TODO: tween opacity
        return this;
    }

    /**
     * outOriginFrom sets the accessor for the state of the origin used in transitioning out renderables.
     * @method inOriginFrom
     * @param {Function|Transitionable} origin A function that returns an origin from outside closure, or a
     * a transitionable that manages origin (a two value array of numbers between zero and one).
     * @chainable
     */
    public function outOriginFrom(origin:Dynamic) {
        if (Reflect.isFunction(origin)) {
			this.outOriginMap = origin;
		}
        else if (origin != null && origin.get != null) {
			this.outOriginMap = origin.get.bind(origin);
		}
        else throw 'inOriginFrom takes only function or getter object';
        //TODO: tween origin
        return this;
    };

    /**
     * Show displays the targeted renderable with a transition and an optional callback to
     * execute afterwards.
     * @method show
     * @param {Object} renderable The renderable you want to show.
     * @param {Transition} [transition] Overwrites the default transition in to display the
     * passed-in renderable.
     * @param {function} [callback] Executes after transitioning in the renderable.
     * @chainable
     */
    public function show(renderable:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        if (renderable == null) {
            return this.hide(callback);
        }

        if (Reflect.isFunction(transition)) {
            callback = transition;
            transition = null;
        }

        if (this._showing >= 0) {
            if (this.options.overlap) {
				this.hide();
			}
            else {
                if (this._nextRenderable != null) {
                    this._nextRenderable = renderable;
                }
                else {
                    this._nextRenderable = renderable;
                    this.hide(function() {
                        if (this._nextRenderable == renderable) {
							this.show(this._nextRenderable, callback);
						}
                        this._nextRenderable = null;
                    });
                }
                return null;
            }
        }

        var state:Transitionable = null;

        // check to see if we should restore
        var renderableIndex = this._renderables.indexOf(renderable);
        if (renderableIndex >= 0) {
            this._showing = renderableIndex;
            state = this._states[renderableIndex];
            state.halt();

            var outgoingIndex = this._outgoingRenderables.indexOf(renderable);
            if (outgoingIndex >= 0) this._outgoingRenderables.splice(outgoingIndex, 1);
        }
        else {
            state = new Transitionable(0);
			
            var modifier = new Modifier({
                transform: this.inTransformMap != null? _mappedState.bind(this.inTransformMap, state) : null,
                opacity: this.inOpacityMap != null? _mappedState.bind(this.inOpacityMap, state) : null,
                origin: this.inOriginMap != null? _mappedState.bind(this.inOriginMap, state) : null
            });
            var node = new RenderNode();
            node.add(modifier).add(renderable);

            this._showing = this._nodes.length;
            this._nodes.push(node);
            this._modifiers.push(modifier);
            this._states.push(state);
            this._renderables.push(renderable);
        }

        if (transition == null) {
			transition = this.options.inTransition;
		}
        state.set(1, transition, callback);
    };

    /**
     * Hide hides the currently displayed renderable with an out transition.
     * @method hide
     * @param {Transition} [transition] Overwrites the default transition in to hide the
     * currently controlled renderable.
     * @param {function} [callback] Executes after transitioning out the renderable.
     * @chainable
     */
    public function hide(?transition:Dynamic, ?callback:Void -> Void) {
        if (this._showing < 0) return;
        var index:Int = this._showing;
        this._showing = -1;

        if (Reflect.isFunction(transition)) {
            callback = transition;
            transition = null;
        }

        var node = this._nodes[index];
        var modifier = this._modifiers[index];
        var state = this._states[index];
        var renderable = this._renderables[index];

        modifier.transformFrom(this.outTransformMap != null? _mappedState.bind(this.outTransformMap, state) : null);
        modifier.opacityFrom(this.outOpacityMap != null? _mappedState.bind(this.outOpacityMap, state) : null);
        modifier.originFrom(this.outOriginMap != null? _mappedState.bind(this.outOriginMap, state) : null);

        if (this._outgoingRenderables.indexOf(renderable) < 0) {
			this._outgoingRenderables.push(renderable);
		}

        if (transition == null) {
			transition = this.options.outTransition;
		}
        state.halt();
        state.set(0, transition, function(node, modifier, state, renderable) {
            if (this._outgoingRenderables.indexOf(renderable) >= 0) {
                var index = this._nodes.indexOf(node);
                this._nodes.splice(index, 1);
                this._modifiers.splice(index, 1);
                this._states.splice(index, 1);
                this._renderables.splice(index, 1);
                this._outgoingRenderables.splice(this._outgoingRenderables.indexOf(renderable), 1);

                if (this._showing >= index) {
					this._showing--;
				}
            }
            if (callback != null) {
				callback();
			}
        }.bind(node, modifier, state, renderable));
    };

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {number} Render spec for this component
     */
    override public function render() {
        var result = this._output;
        if (result.length > this._nodes.length) {
			result.splice(this._nodes.length, result.length - this._nodes.length);
		}
        for (i in 0...this._nodes.length) {
			if (i >= this._nodes.length) break; // ugly fix for hide/splice nodes in loop
            result[i] = this._nodes[i].render();
        }
        return result;
    }	
}