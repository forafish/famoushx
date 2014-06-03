package famous.core;

import famous.core.Context.NodeContext;
import famous.core.Surface.SurfaceOptions;

/**
 * A Context designed to contain surfaces and set properties
 *   to be applied to all of them at once.
 *   This is primarily used for specific performance improvements in the rendering engine.
 *   Private.
 */
class Group extends Surface {
	/** @const */
	public static var SIZE_ZERO:Array<Float> = [0, 0];
	
	var _shouldRecalculateSize:Bool;
	var _container:js.html.Node;
	var context:Context;
	var _groupSize:Array<Float>;
	
    /**
     * @constructor
     * @param {Object} [options] Surface options array (see Surface})
     */
	public function new(?options:SurfaceOptions) {
        super(options);
		
		this.elementType = 'div';
		this.elementClass = 'famous-group';
	
        this._shouldRecalculateSize = false;
        this._container = js.Browser.document.createDocumentFragment();
        this.context = new Context(this._container);
        this.setContent(this._container);
        this._groupSize = [null, null];
	}
	
    /**
     * Add renderables to this component's render tree.
     *
     * @method add
     * @private
     * @param {Object} obj renderable object
     * @return {RenderNode} Render wrapping provided object, if not already a RenderNode
     */
    public function add(obj:Dynamic):RenderNode {
        return this.context.add(obj);
    }

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {Number} Render spec for this component
     */
    override public function render() {
        return super.render();
    }

    /**
     * Place the document element this component manages into the document.
     *
     * @private
     * @method deploy
     * @param {Node} target document parent of this container
     */
    override public function deploy(target:js.html.Element) {
        this.context.migrate(target);
    }

    /**
     * Remove this component and contained content from the document
     *
     * @private
     * @method recall
     *
     * @param {Node} target node to which the component was deployed
     */
    override public function recall(target:js.html.Element) {
        this._container = js.Browser.document.createDocumentFragment();
        this.context.migrate(this._container);
    }

    /**
     * Apply changes from this component to the corresponding document element.
     *
     * @private
     * @method commit
     *
     * @param {Object} context update spec passed in from above in the render tree.
     */
    override public function commit(context:NodeContext) {
        var transform = context.transform;
        var origin = context.origin;
        var opacity = context.opacity;
        var size = context.size;
        super.commit({
            allocator: context.allocator,
            transform: Transform.thenMove(transform, [-origin[0] * size[0], -origin[1] * size[1], 0]),
            opacity: opacity,
            origin: origin,
            size: Group.SIZE_ZERO
        });
        if (size[0] != this._groupSize[0] || size[1] != this._groupSize[1]) {
            this._groupSize[0] = size[0];
            this._groupSize[1] = size[1];
            this.context.setSize(size);
        }
        this.context.update({
            transform: Transform.translate(-origin[0] * size[0], -origin[1] * size[1], 0),
            origin: origin,
            size: size
        });
    }
	
}