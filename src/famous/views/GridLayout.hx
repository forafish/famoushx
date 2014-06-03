package famous.views;

import famous.core.Context.NodeContext;
import famous.core.Engine;
import famous.core.Entity;
import famous.core.DynamicMap;
import famous.core.RenderNode;
import famous.core.Transform;
import famous.core.ViewSequence;
import famous.core.EventHandler;
import famous.core.Modifier;
import famous.core.OptionsManager;
import famous.transitions.Transitionable;
import famous.transitions.TransitionableTransform;
import famous.views.GridLayout.GridLayoutOption;

typedef GridLayoutOption = {
	?dimensions: Array<Int>, // [rows, cols]
	?transition: Bool,
	?gutterSize: Array<Int>
};

/**
 * A layout which divides a context into several evenly-sized grid cells.
 *   If dimensions are provided, the grid is evenly subdivided with children
 *   cells representing their own context, otherwise the cellSize property is used to compute
 *   dimensions so that items of cellSize will fit.
 */
class GridLayout {

    static public var DEFAULT_OPTIONS:GridLayoutOption = {
        dimensions: [1, 1],
        transition: false,
        gutterSize: [0, 0]
    };
	
	var options:GridLayoutOption;
	var optionsManager:OptionsManager;

	var id:Int;

	var _modifiers: Array<Modifier>;
	var _states:Array<Dynamic>;
	var _contextSizeCache:Array<Float>;
	var _dimensionsCache:Array<Float>;
	var _activeCount:Int;

	var _eventOutput:EventHandler;

	var sequence:ViewSequence;
	
	/**
     * @constructor
     * @param {Options} [options] An object of configurable options.
     * @param {Array.Number} [options.dimensions=[1, 1]] A two value array which specifies the amount of columns
     * and rows in your Gridlayout instance.
     * @param {Array.Number} [options.cellSize=[250, 250]]  A two-value array which specifies the width and height
     * of each cell in your Gridlayout instance.
     * @param {Transition} [options.transition=false] The transiton that controls the Gridlayout instance's reflow.
     */
	public function new(?options:GridLayoutOption) {
        this.options = Reflect.copy(GridLayout.DEFAULT_OPTIONS);
        this.optionsManager = new OptionsManager(this.options);
        if (options != null) {
			this.setOptions(options);
		}

        this.id = Entity.register(this);

        this._modifiers = [];
        this._states = [];
        this._contextSizeCache = [0, 0];
        this._dimensionsCache = [0, 0];
        this._activeCount = 0;

        this._eventOutput = new EventHandler();
        EventHandler.setOutputHandler(this, this._eventOutput);
		
	}
	
    function _reflow(size:Array<Float>, cols:Int, rows:Int) {
        var usableSize = [size[0], size[1]];
        usableSize[0] -= this.options.gutterSize[0] * (cols - 1);
        usableSize[1] -= this.options.gutterSize[1] * (rows - 1);

        var rowSize = Math.round(usableSize[1] / rows);
        var colSize = Math.round(usableSize[0] / cols);

        var currY = 0;
        var currX;
        var currIndex = 0;
        for (i in 0...rows) {
            currX = 0;
            for (j in 0...cols) {
                if (this._modifiers[currIndex] == null) {
                    _createModifier(currIndex, [colSize, rowSize], [currX, currY, 0], 1);
                }
                else {
                    _animateModifier(currIndex, [colSize, rowSize], [currX, currY, 0], 1);
                }

                currIndex++;
                currX += colSize + this.options.gutterSize[0];
            }

            currY += rowSize + this.options.gutterSize[1];
        }

        this._dimensionsCache = [this.options.dimensions[0], this.options.dimensions[1]];
        this._contextSizeCache = [size[0], size[1]];

        this._activeCount = rows * cols;
		
		// the rest modifiers
        for (i in this._activeCount...this._modifiers.length) {
			_animateModifier(i, [Math.round(colSize), Math.round(rowSize)], [0, 0], 0);
		}

        this._eventOutput.emit('reflow');
    }

    function _createModifier(index:Int, size:Array<Float>, position:Vector3, opacity:Float) {
        var transitionItem = {
            transform: new TransitionableTransform(Reflect.callMethod(null, Transform.translate, position)),
            opacity: new Transitionable(opacity),
            size: new Transitionable(size)
        };

        var modifier = new Modifier({
            transform: transitionItem.transform,
            opacity: transitionItem.opacity,
            size: transitionItem.size
        });

        this._states[index] = transitionItem;
        this._modifiers[index] = modifier;
    }

    function _animateModifier(index:Int, size:Dynamic, position:Vector3, opacity:Dynamic) {
        var currState = this._states[index];

        var currSize = currState.size;
        var currOpacity = currState.opacity;
        var currTransform = currState.transform;

        var transition = this.options.transition;

        currTransform.halt();
        currOpacity.halt();
        currSize.halt();

        currTransform.setTranslate(position, transition);
        currSize.set(size, transition);
        currOpacity.set(opacity, transition);
    }

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {Object} Render spec for this component
     */
    public function render() {
        return this.id;
    }

    /**
     * Patches the GridLayout instance's options with the passed-in ones.
     *
     * @method setOptions
     * @param {Options} options An object of configurable options for the GridLayout instance.
     */
    public function setOptions(options:DynamicMap) {
        return this.optionsManager.setOptions(options);
    }

    /**
     * Sets the collection of renderables under the Gridlayout instance's control.
     *
     * @method sequenceFrom
     * @param {Array|ViewSequence} sequence Either an array of renderables or a Famous viewSequence.
     */
    public function sequenceFrom(sequence:Dynamic) {
        if (Std.is(sequence, Array)) {
			sequence = new ViewSequence(sequence);
		}
        this.sequence = sequence;
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
        var opacity = context.opacity;
        var origin = context.origin;
        var size = context.size;

        var cols = this.options.dimensions[0];
        var rows = this.options.dimensions[1];

        if (size[0] != this._contextSizeCache[0]
			|| size[1] != this._contextSizeCache[1] 
			|| cols != this._dimensionsCache[0] 
			|| rows != this._dimensionsCache[1]) {
            _reflow(size, cols, rows);
        }

        var sequence = this.sequence;
        var result = [];
        var currIndex = 0;
        while (sequence != null && (currIndex < this._modifiers.length)) {
            var item = sequence.get();
            var modifier = this._modifiers[currIndex];
            if (currIndex >= this._activeCount && this._states[currIndex].opacity.isActive()) {
                this._modifiers.splice(currIndex, 1);
                this._states.splice(currIndex, 1);
            }
            if (item != null) {
                result[currIndex] = modifier.modify({
                    origin: origin,
                    target: item.render()
                });
            }
            sequence = sequence.getNext();
            currIndex++;
        }

        if (size != null) {
			transform = Transform.moveThen([-size[0]*origin[0], -size[1]*origin[1], 0], transform);
		}
        return {
            transform: transform,
            opacity: opacity,
            size: size,
            target: result
        };
    }
}