package famous.core;

import famous.core.Context.NodeContext;
import famous.core.SpecParser;

/**
 * A wrapper for inserting a renderable component (like a Modifer or
 *   Surface) into the render tree.
 */
class RenderNode {
	var _object:Dynamic;
	var _child:Dynamic; // Array or single
	var _hasMultipleChildren:Bool;
	var _isRenderable:Bool;
	var _isModifier:Bool;

	var _resultCache:Map<Int, NodeContext>;
	var _prevResults:Map<Int, NodeContext>;

	var _childResult:Dynamic;

    /**
     * @constructor
     *
     * @param {Object} object Target renderable component
     */
	public function new(?object:Dynamic)  {
        this._object = null;
        this._child = null;
        this._hasMultipleChildren = false;
        this._isRenderable = false;
        this._isModifier = false;

        this._resultCache = new Map();
        this._prevResults = new Map();

        this._childResult = null;

        if (object != null) this.set(object);
	}
	
    /**
     * Append a renderable to the list of this node's children.
     *   This produces a new RenderNode in the tree.
     *   Note: Does not double-wrap if child is a RenderNode already.
     *
     * @method add
     * @param {Object} child renderable object
     * @return {RenderNode} new render node wrapping child
     */
    public function add(child:Dynamic):RenderNode {
        var childNode = Std.is(child, RenderNode)? child : new RenderNode(child);
        if (Std.is(this._child, Array)) {
			this._child.push(childNode);
		}
        else if (this._child != null) {
            this._child = [this._child, childNode];
            this._hasMultipleChildren = true;
            this._childResult = []; // to be used later
        }
        else {
			this._child = childNode;
		}

        return childNode;
    }

    /**
     * Return the single wrapped object.  Returns null if this node has multiple child nodes.
     *
     * @method get
     *
     * @return {Ojbect} contained renderable object
     */
    public function get():Dynamic {
        return this._object != null? this._object : (this._hasMultipleChildren ? null : (this._child ? this._child.get() : null));
    }

    /**
     * Overwrite the list of children to contain the single provided object
     *
     * @method set
     * @param {Object} child renderable object
     * @return {RenderNode} this render node, or child if it is a RenderNode
     */
    public function set(child:Dynamic):RenderNode {
        this._childResult = null;
        this._hasMultipleChildren = false;
        this._isRenderable = child.render != null? true : false;
        this._isModifier = child.modify != null? true : false;
        this._object = child;
        this._child = null;
        if (Std.is(child, RenderNode)) {
			return child;
		}
        else {
			return this;
		}
    };

    /**
     * Get render size of contained object.
     *
     * @method getSize
     * @return {Array.Number} size of this or size of single child.
     */
    public function getSize():Array<Float> {
        var result = null;
        var target = this.get();
        if (target != null && target.getSize != null) {
			result = target.getSize();
		}
        if (result == null && this._child != null && this._child.getSize != null) {
			result = this._child.getSize();
		}
        return result;
    }

    // apply results of rendering this subtree to the document
    function _applyCommit(spec:Dynamic, context:NodeContext, cacheStorage:Map<Int, NodeContext>) {
        var result = SpecParser.parseSpec(spec, context);
        for (id in result.keys()) {
            var childNode = Entity.get(id);
            var commitParams = result[id];
            commitParams.allocator = context.allocator;
            var commitResult = childNode.commit(commitParams);
            if (commitResult != null) {
				_applyCommit(commitResult, context, cacheStorage);
			}
            else {
				cacheStorage[id] = commitParams;
			}
        }
    }

    /**
     * Commit the content change from this node to the document.
     *
     * @private
     * @method commit
     * @param {Context} context render context
     */
    public function commit(context:NodeContext) {
        // free up some divs from the last loop
        for (id in this._prevResults.keys()) {
            if (this._resultCache[id] == null) {
                var object = Entity.get(id);
                if (object.cleanup != null) {
					object.cleanup(context.allocator);
				}
            }
        }

        this._prevResults = this._resultCache;
        this._resultCache = new Map();
        _applyCommit(this.render(), context, this._resultCache);
    }

    /**
     * Generate a render spec from the contents of the wrapped component.
     *
     * @private
     * @method render
     *
     * @return {Object} render specification for the component subtree
     *    only under this node.
     */
    public function render() {
        if (this._isRenderable) {
			return this._object.render();
		}

        var result = null;
        if (this._hasMultipleChildren) {
            result = this._childResult;
            var children:Array<Dynamic> = cast this._child;
            for (i in 0...children.length) {
                result[i] = children[i].render();
            }
        }
        else if (this._child != null) {
			result = this._child.render();
		}

        return this._isModifier ? this._object.modify(result) : result;
    }	
}