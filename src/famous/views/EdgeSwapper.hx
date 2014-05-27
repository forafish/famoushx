package famous.views;

import famous.core.Context.NodeContext;
import famous.core.Entity;
import famous.core.EventHandler;
import famous.core.Transform;
import famous.transitions.CachedMap;
import famous.views.RenderController;

/**
 * Container which handles swapping renderables from the edge of its parent context.
 */
class EdgeSwapper {

	var _currentTarget:Dynamic;
	var _size:Array<Null<Float>>;

	var _controller:RenderController;

	var _eventInput:EventHandler;

	var _entityId:Int;
	
    /**
     * @constructor
     * @param {Options} [options] An object of configurable options.
     *   Takes the same options as RenderController.
     * @uses RenderController
     */
	public function new(?options:Dynamic) {
        this._currentTarget = null;
        this._size = [null, null];

        this._controller = new RenderController(options);
        this._controller.inTransformFrom(CachedMap.create(_transformMap.bind(0.0001)));
        this._controller.outTransformFrom(CachedMap.create(_transformMap.bind(-0.0001)));

        this._eventInput = new EventHandler();
        EventHandler.setInputHandler(this, this._eventInput);

        this._entityId = Entity.register(this);
        if (options) {
			this.setOptions(options);
		}
	}
	
    function _transformMap(zMax:Float, progress:Float) {
        return Transform.translate(this._size[0] * (1 - progress), 0, zMax * (1 - progress));
    }
	
    /**
     * Displays the passed-in content with the EdgeSwapper instance's default transition.
     *
     * @method show
     * @param {Object} content The renderable you want to display.
     */
    public function show(content:Dynamic) {
        // stop sending input to old target
        if (this._currentTarget != null) {
			this._eventInput.unpipe(this._currentTarget);
		}

        this._currentTarget = content;

        // start sending input to new target
        if (this._currentTarget != null && this._currentTarget.trigger != null) {
			this._eventInput.pipe(this._currentTarget);
		}

        this._controller.show(content);
    };

    /**
     * Patches the EdgeSwapper instance's options with the passed-in ones.
     *
     * @method setOptions
     * @param {Options} options An object of configurable options for the Edgeswapper instance.
     */
    public function setOptions(options:Dynamic) {
        this._controller.setOptions(options);
    }

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {number} Render spec for this component
     */
    public function render() {
        return this._entityId;
    }

    /**
     * Apply changes from this component to the corresponding document element.
     * This includes changes to classes, styles, size, content, opacity, origin,
     * and matrix transforms.
     *
     * @private
     * @method commit
     * @param {Context} context commit context
     */
    public function commit(context:NodeContext) {
        this._size[0] = context.size[0];
        this._size[1] = context.size[1];

        return {
            transform: context.transform,
            opacity: context.opacity,
            origin: context.origin,
            size: context.size,
            target: this._controller.render()
        };
    }
}