package famous.core;

import famous.core.EventEmitter.HandlerFunc;
import famous.core.Transform.Matrix4;
import famous.transitions.Transitionable;

typedef NodeContext = {
		?allocator: ElementAllocator,
		?transform: Matrix4,
		?opacity: Float,
		?origin: Array<Float>,
		?align: Array<Float>,
		?size: Array<Float>
	};
	
/**
 * The top-level container for a Famous-renderable piece of the document.
 *   It is directly updated by the process-wide Engine object, and manages one
 *   render tree root, which can contain other renderables.
 */
class Context {
	
	static var _originZeroZero:Array<Float> = [0, 0];
	
	static function _getElementSize(element:js.html.Element):Array<Float> {
        return [element.clientWidth, element.clientHeight];
    }
	
	public var container:Dynamic; // js.html.Node or js.html.Element;
	
	var _allocator:ElementAllocator;

	var _node:RenderNode;
	var _eventOutput:EventHandler;
	var _size:Array<Float>;

	var _perspectiveState:Transitionable;
	var _perspective:Dynamic;

	var _nodeContext:NodeContext;
	
    /**
     * @constructor
     * @private
     * @param {Node} container Element in which content will be inserted
     */
	public function new(container:js.html.Node) {
        this.container = container;
        this._allocator = new ElementAllocator(container);

        this._node = new RenderNode();
        this._eventOutput = new EventHandler();
        this._size = _getElementSize(this.container);

        this._perspectiveState = new Transitionable(0);
        this._perspective = null;

        this._nodeContext = {
            allocator: this._allocator,
            transform: Transform.identity,
            opacity: 1,
            origin: _originZeroZero,
            size: this._size
        };

        this._eventOutput.on('resize', function(_) {
            this.setSize(_getElementSize(this.container));
        });

	}
	
    // Note: Unused
    public function getAllocator():ElementAllocator {
        return this._allocator;
    }

    /**
     * Add renderables to this Context's render tree.
     *
     * @method add
     *
     * @param {Object} obj renderable object
     * @return {RenderNode} RenderNode wrapping this object, if not already a RenderNode
     */
    public function add(obj:Dynamic):RenderNode {
        return this._node.add(obj);
    }

    /**
     * Move this Context to another containing document element.
     *
     * @method migrate
     *
     * @param {Node} container Element to which content will be migrated
     */
	public function migrate(container:Dynamic) {
        if (container == this.container) {
			return;
		}
        this.container = container;
        this._allocator.migrate(container);
    }

    /**
     * Gets viewport size for Context.
     *
     * @method getSize
     *
     * @return {Array.Number} viewport size as [width, height]
     */
    public function getSize():Array<Float> {
        return this._size;
    }

    /**
     * Sets viewport size for Context.
     *
     * @method setSize
     *
     * @param {Array.Number} size [width, height].  If unspecified, use size of root document element.
     */
    public function setSize(size:Array<Float>) {
        if (size == null) {
			size = _getElementSize(this.container);
		}
        this._size[0] = size[0];
        this._size[1] = size[1];
    }

    /**
     * Commit this Context's content changes to the document.
     *
     * @private
     * @method update
     * @param {Object} contextParameters engine commit specification
     */
    public function update(?contextParameters:NodeContext) {
        if (contextParameters != null) {
            if (contextParameters.transform != null) {
				this._nodeContext.transform = contextParameters.transform;
			}
            if (contextParameters.opacity != null) {
				this._nodeContext.opacity = contextParameters.opacity;
			}
            if (contextParameters.origin != null) {
				this._nodeContext.origin = contextParameters.origin;
			}
			if (contextParameters.align != null) {
				this._nodeContext.align = contextParameters.align;
			}
            if (contextParameters.size != null) {
				this._nodeContext.size = contextParameters.size;
			}
        }
        var perspective = this._perspectiveState.get();
        if (perspective != this._perspective) {
            this.container.style.perspective = perspective != null ? perspective.toFixed() + 'px' : '';
            untyped this.container.style.webkitPerspective = perspective != null ? perspective.toFixed() : '';
            this._perspective = perspective;
        }

        this._node.commit(this._nodeContext);
    }

    /**
     * Get current perspective of this context in pixels.
     *
     * @method getPerspective
     * @return {Number} depth perspective in pixels
     */
    public function getPerspective():Float {
        return this._perspectiveState.get();
    }

    /**
     * Set current perspective of this context in pixels.
     *
     * @method setPerspective
     * @param {Number} perspective in pixels
     * @param {Object} [transition] Transitionable object for applying the change
     * @param {function(Object)} callback function called on completion of transition
     */
    public function setPerspective(perspective:Float, ?transition:Transitionable, ?callback:Void -> Void) {
        return this._perspectiveState.set(perspective, transition, callback);
    }

    /**
     * Trigger an event, sending to all downstream handlers
     *   listening for provided 'type' key.
     *
     * @method emit
     *
     * @param {string} type event type key (for example, 'click')
     * @param {Object} event event data
     * @return {EventHandler} this
     */
    public function emit(type:String, ?event:Dynamic):EventEmitter {
        return this._eventOutput.emit(type, event);
    }

    /**
     * Bind a callback function to an event type handled by this object.
     *
     * @method "on"
     *
     * @param {string} type event type key (for example, 'click')
     * @param {function(string, Object)} handler callback
     * @return {EventHandler} this
     */
    public function on(type:String, handler:HandlerFunc):EventEmitter {
        return this._eventOutput.on(type, handler);
    }

    /**
     * Unbind an event by type and handler.
     *   This undoes the work of "on".
     *
     * @method removeListener
     *
     * @param {string} type event type key (for example, 'click')
     * @param {function} handler function object to remove
     * @return {EventHandler} internal event handler object (for chaining)
     */
    public function removeListener(type:String, handler:HandlerFunc):EventEmitter {
        return this._eventOutput.removeListener(type, handler);
    }

    /**
     * Add event handler object to set of downstream handlers.
     *
     * @method pipe
     *
     * @param {EventHandler} target event handler target object
     * @return {EventHandler} passed event handler
     */
	public function pipe(target:EventHandler):EventHandler {
        return this._eventOutput.pipe(target);
    }

    /**
     * Remove handler object from set of downstream handlers.
     *   Undoes work of "pipe".
     *
     * @method unpipe
     *
     * @param {EventHandler} target target handler object
     * @return {EventHandler} provided target
     */
    public function unpipe(target:EventHandler):EventEmitter {
        return this._eventOutput.unpipe(target);
    }
	
}