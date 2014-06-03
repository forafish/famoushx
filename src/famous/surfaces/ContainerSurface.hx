package famous.surfaces;

import famous.core.Context;
import famous.core.Surface;

/**
 * ContainerSurface is an object designed to contain surfaces and
 *   set properties to be applied to all of them at once.
 *   This extends the Surface class.
 *   A container surface will enforce these properties on the
 *   surfaces it contains:
 *
 *   size (clips contained surfaces to its own width and height);
 *
 *   origin;
 *
 *   its own opacity and transform, which will be automatically
 *   applied to  all Surfaces contained directly and indirectly.
 */
class ContainerSurface extends Surface {

	var _container:js.html.Element;
	var _shouldRecalculateSize:Bool;
	
	var context:Context;
	
    /**
    * @constructor
     * @param {Array.Number} [options.size] [width, height] in pixels
     * @param {Array.string} [options.classes] CSS classes to set on all inner content
     * @param {Array} [options.properties] string dictionary of HTML attributes to set on target div
     * @param {string} [options.content] inner (HTML) content of surface (should not be used)
     */
	public function new(?options:SurfaceOptions) {
		super(options);
		
        this._container = js.Browser.document.createElement('div');
        this._container.classList.add('famous-group');
        this._container.classList.add('famous-container-group');
        this._shouldRecalculateSize = false;
		
        this.context = new Context(this._container);
        this.setContent(this._container);
	}
	
    /**
     * Add renderables to this object's render tree
     *
     * @method add
     *
     * @param {Object} obj renderable object
     * @return {RenderNode} RenderNode wrapping this object, if not already a RenderNode
     */
    public function add(obj:Dynamic) {
        return this.context.add(obj);
    }

    /**
     * Return spec for this surface.  Note: Can result in a size recalculation.
     *
     * @private
     * @method render
     *
     * @return {Object} render spec for this surface (spec id)
     */
    override public function render() {
        if (this._sizeDirty) this._shouldRecalculateSize = true;
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
        this._shouldRecalculateSize = true;
        return super.deploy(target);
    }

    /**
     * Apply changes from this component to the corresponding document element.
     * This includes changes to classes, styles, size, content, opacity, origin,
     * and matrix transforms.
     *
     * @private
     * @method commit
     * @param {Context} context commit context
     * @param {Transform} transform unused TODO
     * @param {Number} opacity  unused TODO
     * @param {Array.Number} origin unused TODO
     * @param {Array.Number} size unused TODO
     * @return {undefined} TODO returns an undefined value
     */
    override public function commit(context:NodeContext) {
        var previousSize = this._size != null ? [this._size[0], this._size[1]] : null;
        super.commit(context);
        if (this._shouldRecalculateSize || (previousSize != null && (this._size[0] != previousSize[0] || this._size[1] != previousSize[1]))) {
            this.context.setSize();
            this._shouldRecalculateSize = false;
        }
        this.context.update();
    }	
}