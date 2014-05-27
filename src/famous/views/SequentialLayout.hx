package famous.views;

import famous.core.Options;
import famous.core.OptionsManager;
import famous.core.RenderNode;
import famous.core.Transform;
import famous.core.ViewSequence;
import famous.utilities.Utility;

typedef SequentialLayoutOptions = {
	?direction: Int,
	?defaultItemSize: Array<Float>
};
	
/**
 * SequentialLayout will lay out a collection of renderables sequentially in the specified direction.
 */
class SequentialLayout {

    static public var DEFAULT_OPTIONS:SequentialLayoutOptions = {
        direction: Utility.Direction.Y,
        defaultItemSize: [50, 50]
    }

    public function DEFAULT_OUTPUT_FUNCTION(input:ViewSequence, offset:Float, index:Int) {
        var transform = (this.options.direction == Utility.Direction.X) 
			? Transform.translate(offset, 0) 
			: Transform.translate(0, offset);
        return {
            transform: transform,
            target: input.render()
        };
    }

	var _items:ViewSequence;
	var _size:Array<Float>;
	var _outputFunction:ViewSequence -> Float -> Int -> Dynamic;

	var options:Dynamic;
	var optionsManager:OptionsManager;
	
    /**
     * @constructor
     * @param {Options} [options] An object of configurable options.
     * @param {Number} [options.direction=Utility.Direction.Y] Using the direction helper found in the famous Utility
     * module, this option will lay out the SequentialLayout instance's renderables either horizontally
     * (x) or vertically (y). Utility's direction is essentially either zero (X) or one (Y), so feel free
     * to just use integers as well.
     * @param {Array.Number} [options.defaultItemSize=[50, 50]] In the case where a renderable layed out
     * under SequentialLayout's control doesen't have a getSize method, SequentialLayout will assign it
     * this default size. (Commonly a case with Views).
     */
	public function new(?options:SequentialLayoutOptions) {
        this._items = null;
        this._size = null;
        this._outputFunction = DEFAULT_OUTPUT_FUNCTION;

        this.options = Reflect.copy(SequentialLayout.DEFAULT_OPTIONS);
        this.optionsManager = new OptionsManager(this.options);

        if (options != null) {
			this.setOptions(options);
		}
	}
	
    /**
     * Returns the width and the height of the SequentialLayout instance.
     *
     * @method getSize
     * @return {Array} A two value array of the SequentialLayout instance's current width and height (in that order).
     */
    public function getSize() {
        if (this._size == null) this.render(); // hack size in
        return this._size;
    }

    /**
     * Sets the collection of renderables under the SequentialLayout instance's control.
     *
     * @method sequenceFrom
     * @param {Array|ViewSequence} items Either an array of renderables or a Famous viewSequence.
     * @chainable
     */
    public function sequenceFrom(items:Dynamic) {
        if (Std.is(items, Array)) {
			items = new ViewSequence(items);
		}
        this._items = items;
        return this;
    }

    /**
     * Patches the SequentialLayout instance's options with the passed-in ones.
     *
     * @method setOptions
     * @param {Options} options An object of configurable options for the SequentialLayout instance.
     * @chainable
     */
    public function setOptions(options) {
        this.optionsManager.setOptions(options);
        return this;
    }

    /**
     * setOutputFunction is used to apply a user-defined output transform on each processed renderable.
     *  For a good example, check out SequentialLayout's own DEFAULT_OUTPUT_FUNCTION in the code.
     *
     * @method setOutputFunction
     * @param {Function} outputFunction An output processer for each renderable in the SequentialLayout
     * instance.
     * @chainable
     */
    public function setOutputFunction(outputFunction) {
        this._outputFunction = outputFunction;
        return this;
    }

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {number} Render spec for this component
     */
    public function render() {
        var length:Float = 0;
        var girth:Null<Int> = 0;

        var lengthDim = (this.options.direction == Utility.Direction.X) ? 0 : 1;
        var girthDim = (this.options.direction == Utility.Direction.X) ? 1 : 0;

        var currentNode = this._items;
        var result = [];
        while (currentNode != null) {
            var item = currentNode.get();

            var itemSize:Array<Float> = null;
            if (item != null && item.getSize != null) {
				itemSize = item.getSize();
			}
            if (itemSize == null) {
				itemSize = this.options.defaultItemSize;
			}
            if (itemSize[girthDim] != null) {
				girth = Std.int(Math.max(girth, itemSize[girthDim]));
			}

            var output = this._outputFunction(item, length, result.length);
            result.push(output);

            if (itemSize[lengthDim] != null) {
				length += itemSize[lengthDim];
			}
            currentNode = currentNode.getNext();
        }

        if (girth == 0) girth = null;

        if (this._size == null) this._size = [0, 0];
        this._size[lengthDim] = length;
        this._size[girthDim] = girth;

        return {
            size: this.getSize(),
            target: result
        };
    }	
}