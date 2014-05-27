package famous.views;

import famous.core.Context;
import famous.core.Entity;
import famous.core.Options;
import famous.core.OptionsManager;
import famous.core.RenderNode;
import famous.core.Transform;

typedef HeaderFooterLayoutOptions = {
	?direction: Null<Int>,
	?headerSize: Null<Float>,
	?footerSize: Null<Float>,
	?defaultHeaderSize: Null<Float>,
	?defaultFooterSize: Null<Float>
};

/**
 * A layout which will arrange three renderables into a header and footer area of defined size,
  and a content area of flexible size.
 */
class HeaderFooterLayout {

    /**
     *  When used as a value for your HeaderFooterLayout's direction option, causes it to lay out horizontally.
     *
     *  @attribute DIRECTION_X
     *  @type Number
     *  @static
     *  @default 0
     *  @protected
     */
    static public var DIRECTION_X = 0;

    /**
     *  When used as a value for your HeaderFooterLayout's direction option, causes it to lay out vertically.
     *
     *  @attribute DIRECTION_Y
     *  @type Number
     *  @static
     *  @default 1
     *  @protected
     */
    static public var DIRECTION_Y = 1;

    static public var DEFAULT_OPTIONS:HeaderFooterLayoutOptions = {
        direction: HeaderFooterLayout.DIRECTION_Y,
        headerSize: null,
        footerSize: null,
        defaultHeaderSize: 0,
        defaultFooterSize: 0
    };
	
	var options:HeaderFooterLayoutOptions;
	var _optionsManager:OptionsManager;

	var _entityId:Int;

	public var header:RenderNode;
	public var footer:RenderNode;
	public var content:RenderNode;
	
    /**
     * @constructor
     * @param {Options} [options] An object of configurable options.
     * @param {Number} [options.direction=HeaderFooterLayout.DIRECTION_Y] A direction of HeaderFooterLayout.DIRECTION_X
     * lays your HeaderFooterLayout instance horizontally, and a direction of HeaderFooterLayout.DIRECTION_Y
     * lays it out vertically.
     * @param {Number} [options.headerSize=undefined]  The amount of pixels allocated to the header node
     * in the HeaderFooterLayout instance's direction.
     * @param {Number} [options.footerSize=undefined] The amount of pixels allocated to the footer node
     * in the HeaderFooterLayout instance's direction.
     */	
	public function new(options:HeaderFooterLayoutOptions) {
        this.options = Reflect.copy(HeaderFooterLayout.DEFAULT_OPTIONS);
        this._optionsManager = new OptionsManager(this.options);
        if (options != null) {
			this.setOptions(options);
		}

        this._entityId = Entity.register(this);

        this.header = new RenderNode();
        this.footer = new RenderNode();
        this.content = new RenderNode();
	}
	
    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {Object} Render spec for this component
     */
    public function render() {
        return this._entityId;
    }

    /**
     * Patches the HeaderFooterLayout instance's options with the passed-in ones.
     *
     * @method setOptions
     * @param {Options} options An object of configurable options for the HeaderFooterLayout instance.
     */
    public function setOptions(options:HeaderFooterLayoutOptions) {
        return this._optionsManager.setOptions(options);
    }

    function _resolveNodeSize(node:RenderNode, defaultSize:Float) {
        var nodeSize = node.getSize();
        return nodeSize != null? nodeSize[this.options.direction] : defaultSize;
    }

    function _outputTransform(offset:Float) {
        if (this.options.direction == HeaderFooterLayout.DIRECTION_X) {
			return Transform.translate(offset, 0, 0);
		}
        else return Transform.translate(0, offset, 0);
    }

    function _finalSize(directionSize, size) {
        if (this.options.direction == HeaderFooterLayout.DIRECTION_X) {
			return [directionSize, size[1]];
		}
        else return [size[0], directionSize];
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
        var transform = context.transform;
        var origin = context.origin;
        var size = context.size;
        var opacity = context.opacity;

        var headerSize = (this.options.headerSize != null)
			? this.options.headerSize
			: _resolveNodeSize(this.header, this.options.defaultHeaderSize);
        var footerSize = (this.options.footerSize != null)
			? this.options.footerSize 
			: _resolveNodeSize(this.footer, this.options.defaultFooterSize);
        var contentSize = size[this.options.direction] - headerSize - footerSize;

        if (size != null) {
			transform = Transform.moveThen([-size[0]*origin[0], -size[1]*origin[1], 0], transform);
		}

        var result:Array<Dynamic> = [
            {
                size: _finalSize(headerSize, size),
                target: this.header.render()
            },
            {
                transform: _outputTransform(headerSize),
                size: _finalSize(contentSize, size),
                target: this.content.render()
            },
            {
                transform: _outputTransform(headerSize + contentSize),
                size: _finalSize(footerSize, size),
                target: this.footer.render()
            }
        ];

        return {
            transform: transform,
            opacity: opacity,
            size: size,
            target: result
        };
    }
}