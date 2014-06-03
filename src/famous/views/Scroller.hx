package famous.views;

import famous.core.Entity;
import famous.core.EventHandler;
import famous.core.Group;
import famous.core.OptionsManager;
import famous.core.Transform;
import famous.core.ViewSequence;
import famous.utilities.Utility;

typedef ScrollerOptions = {
	?direction: Int,
	?margin: Int,
	?clipSize: Null<Int>,
	?groupScroll: Bool
};

/**
 * Scroller lays out a collection of renderables, and will browse through them based on
 * accessed position. Scroller also broadcasts an 'edgeHit' event, with a position property of the location of the edge,
 * when you've hit the 'edges' of it's renderable collection.
 */
class Scroller extends EventHandleable {
	
	static public var DEFAULT_OPTIONS:ScrollerOptions = {
        direction: Utility.Direction.Y,
        margin: 0,
        clipSize: null,
        groupScroll: false
    };
	
	var options:Dynamic;
	var _optionsManager:OptionsManager;
	
	var _node:Dynamic;
	var _position:Dynamic; // Int or Array<Int>

	// used for shifting nodes
	var _positionOffset:Int;

	var _positionGetter:Void -> Array<Int>;
	var _outputFunction:Float -> Matrix4;
	var _masterOutputFunction:Float -> Matrix4;

	var _onEdge:Int; // -1 for top, 1 for bottom
	
	var group:Group;
	
	var _entityId:Int;
	var _size:Array<Null<Int>>;
	var _contextSize:Array<Null<Int>>;
	
	var _eventInput:EventHandler;
	var _eventOutput:EventHandler;
			
    /**
     * @constructor
      * @event error
     * @param {Options} [options] An object of configurable options.
     * @param {Number} [options.direction=Utility.Direction.Y] Using the direction helper found in the famous Utility
     * module, this option will lay out the Scroller instance's renderables either horizontally
     * (x) or vertically (y). Utility's direction is essentially either zero (X) or one (Y), so feel free
     * to just use integers as well.
     * @param {Number} [clipSize=undefined] The size of the area (in pixels) that Scroller will display content in.
     * @param {Number} [margin=undefined] The size of the area (in pixels) that Scroller will process renderables' associated calculations in.
     */
	public function new(?options:ScrollerOptions) {
        this.options = Reflect.copy(DEFAULT_OPTIONS);
        this._optionsManager = new OptionsManager(this.options);
        if (options != null) this._optionsManager.setOptions(options);

        this._node = null;
        this._position = 0;

        // used for shifting nodes
        this._positionOffset = 0;

        this._positionGetter = null;
        this._outputFunction = null;
        this._masterOutputFunction = null;
        this.outputFrom();

        this._onEdge = 0; // -1 for top, 1 for bottom
		
        this.group = new Group();
        this.group.add({render: _innerRender});
		
        this._entityId = Entity.register(this);
        this._size = [null, null];
        this._contextSize = [null, null];
		
        this._eventInput = new EventHandler();
        this._eventOutput = new EventHandler();
		
        EventHandler.setInputHandler(this, this._eventInput);
        EventHandler.setOutputHandler(this, this._eventOutput);
	}
	
    function _sizeForDir(size:Array<Null<Int>>) {
        if (size == null) size = this._contextSize;
        var dimension = (this.options.direction == Utility.Direction.X) ? 0 : 1;
        return (size[dimension] == null) ? this._contextSize[dimension] : size[dimension];
    }

    function _output(node:Dynamic, offset:Float, target:Dynamic) {
        var size = node.getSize != null ? node.getSize() : this._contextSize;
        var transform = this._outputFunction(offset);
        target.push({transform: transform, target: node.render()});
        return _sizeForDir(size);
    }

    function _getClipSize() {
        if (this.options.clipSize) return this.options.clipSize;
        else return _sizeForDir(this._contextSize);
    }

    /**
     * Patches the Scroller instance's options with the passed-in ones.
     * @method setOptions
     * @param {Options} options An object of configurable options for the Scroller instance.
     */
    public function setOptions(options:Dynamic) {
        this._optionsManager.setOptions(options);

        if (this.options.groupScroll) {
          this.group.pipe(this._eventOutput);
        }
        else {
          this.group.unpipe(this._eventOutput);
        }
    }

    /**
     * Tells you if the Scroller instance is on an edge.
     * @method onEdge
     * @return {Boolean} Whether the Scroller instance is on an edge or not.
     */
    public function onEdge() {
        return this._onEdge;
    }

    /**
     * Allows you to overwrite the way Scroller lays out it's renderables. Scroller will
     * pass an offset into the function. By default the Scroller instance just translates each node
     * in it's direction by the passed-in offset.
     * Scroller will translate each renderable down
     * @method outputFrom
     * @param {Function} fn A function that takes an offset and returns a transform.
     * @param {Function} [masterFn]
     */
    public function outputFrom(?fn:Float -> Matrix4, ?masterFn:Float -> Matrix4) {
        if (fn == null) {
            fn = function(offset) {
                return (this.options.direction == Utility.Direction.X) ? Transform.translate(offset, 0) : Transform.translate(0, offset);
            };
            if (masterFn == null) masterFn = fn;
        }
        this._outputFunction = fn;
        this._masterOutputFunction = masterFn != null ? masterFn : function(offset) {
            return Transform.inverse(fn(-offset));
        };
    }

    /**
     * The Scroller instance's method for reading from an external position. Scroller uses
     * the external position to actually scroll through it's renderables.
     * @method positionFrom
     * @param {Getter} position Can be either a function that returns a position,
     * or an object with a get method that returns a position.
     */
    public function positionFrom(position:Dynamic) {
        if (Reflect.isFunction(position)) {
			this._positionGetter = position;
		}
        else if (position != null && position.get) {
			this._positionGetter = position.get.bind(position);
		}
        else {
            this._positionGetter = null;
            this._position = position;
        }
        if (this._positionGetter != null) this._position = this._positionGetter();
    };

    /**
     * Sets the collection of renderables under the Scroller instance's control.
     *
     * @method sequenceFrom
     * @param {Array|ViewSequence} items Either an array of renderables or a Famous viewSequence.
     * @chainable
     */
    public function sequenceFrom(node:Dynamic) {
        if (Std.is(node, Array)) node = new ViewSequence({array: node});
        this._node = node;
        this._positionOffset = 0;
    }

    /**
     * Returns the width and the height of the Scroller instance.
     *
     * @method getSize
     * @return {Array} A two value array of the Scroller instance's current width and height (in that order).
     */
    public function getSize(?actual:Bool) {
        return actual ? this._contextSize : this._size;
    }

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {number} Render spec for this component
     */
    public function render() {
        if (this._node == null) return null;
        if (this._positionGetter != null) this._position = this._positionGetter();
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
    public function commit(context) {
        var transform = context.transform;
        var opacity = context.opacity;
        var origin = context.origin;
        var size = context.size;

        // reset edge detection on size change
        if (!this.options.clipSize != null && (size[0] != this._contextSize[0] || size[1] !=this._contextSize[1])) {
            this._onEdge = 0;
            this._contextSize[0] = size[0];
            this._contextSize[1] = size[1];

            if (this.options.direction == Utility.Direction.X) {
                this._size[0] = _getClipSize();
                this._size[1] = null;
            }
            else {
                this._size[0] = null;
                this._size[1] = _getClipSize();
            }
        }

        var scrollTransform = this._masterOutputFunction(-this._position);

        return {
            transform: Transform.multiply(transform, scrollTransform),
            size: size,
            opacity: opacity,
            origin: origin,
            target: this.group.render()
        };
    }

    function _normalizeState() {
        var nodeSize = _sizeForDir(this._node.getSize());
        var nextNode = this._node != null && this._node.getNext ? this._node.getNext() : null;
        while (nextNode != null && this._position + this._positionOffset >= nodeSize) {
            this._positionOffset -= nodeSize;
            this._node = nextNode;
            nodeSize = _sizeForDir(this._node.getSize());
            nextNode = this._node && this._node.getNext ? this._node.getNext() : null;
        }
        var prevNode = this._node != null && this._node.getPrevious ? this._node.getPrevious() : null;
        while (prevNode != null && this._position + this._positionOffset < 0) {
            var prevNodeSize = _sizeForDir(prevNode.getSize());
            this._positionOffset += prevNodeSize;
            this._node = prevNode;
            prevNode = this._node && this._node.getPrevious ? this._node.getPrevious() : null;
        }
    }

    function _innerRender() {
        var size = null;
        var position = this._position;
        var result = [];

        this._onEdge = 0;

        var offset = -this._positionOffset;
        var clipSize = _getClipSize();
        var currNode:Dynamic = this._node;
        while (currNode && offset - position < clipSize + this.options.margin) {
            offset += _output(currNode, offset, result);
            currNode = currNode.getNext != null? currNode.getNext() : null;
        }

        var sizeNode:Dynamic = this._node;
        var nodesSize = _sizeForDir(sizeNode.getSize());
        if (offset < clipSize) {
            while (sizeNode != null && nodesSize < clipSize) {
                sizeNode = sizeNode.getPrevious();
                if (sizeNode != null) nodesSize += _sizeForDir(sizeNode.getSize());
            }
            sizeNode = this._node;
            while (sizeNode != null && nodesSize < clipSize) {
                sizeNode = sizeNode.getNext();
                if (sizeNode != null) nodesSize += _sizeForDir(sizeNode.getSize());
            }
        }

        var edgeSize = (nodesSize != null && nodesSize < clipSize) ? nodesSize : clipSize;

        if (currNode == null && offset - position <= edgeSize) {
            this._onEdge = 1;
            this._eventOutput.emit('edgeHit', {
                position: offset - edgeSize
            });
        }
        else if (!this._node.getPrevious() && position <= 0) {
            this._onEdge = -1;
            this._eventOutput.emit('edgeHit', {
                position: 0
            });
        }

        // backwards
        currNode = (this._node != null && this._node.getPrevious != null) ? this._node.getPrevious() : null;
        offset = -this._positionOffset;
        if (currNode != null) {
            size = currNode.getSize != null ? currNode.getSize() : this._contextSize;
            offset -= _sizeForDir(size);
        }

        while (currNode != null && ((offset - position) > -(_getClipSize() + this.options.margin))) {
            _output(currNode, offset, result);
            currNode = currNode.getPrevious ? currNode.getPrevious() : null;
            if (currNode) {
                size = currNode.getSize ? currNode.getSize() : this._contextSize;
                offset -= _sizeForDir(size);
            }
        }

        _normalizeState();
        return result;
    }	
}