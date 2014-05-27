package famous.views;

import famous.core.Context.NodeContext;
import famous.core.Entity;
import famous.core.EventHandler;
import famous.core.Transform;
import famous.core.OptionsManager;
import famous.transitions.Transitionable;

typedef FlexibleLayoutOptions = {
	?direction: Int,
	?transition: Bool,
	?ratios : Array<Dynamic>
};

/**
 * A layout which divides a context into sections based on a proportion
 *   of the total sum of ratios.  FlexibleLayout can either lay renderables
 *   out vertically or horizontally.
 */
class FlexibleLayout{
    public static var DIRECTION_X = 0;
    public static var DIRECTION_Y = 1;

    public static var DEFAULT_OPTIONS:FlexibleLayoutOptions = {
        direction: FlexibleLayout.DIRECTION_X,
        transition: false,
        ratios : []
    };

	var options:FlexibleLayoutOptions;
	var optionsManager:OptionsManager;

	var id:Int;

	var _ratios:Transitionable;
	var _nodes:Array<Dynamic>;

	var _cachedDirection:Int;
	var _cachedTotalLength:Null<Float>;
	var _cachedLengths:Array<Float>;
	var _cachedTransforms:Dynamic;
	var _ratiosDirty:Bool;

	var _eventOutput:EventHandler;
	
    /**
     * @constructor
     * @param {Options} [options] An object of configurable options.
     * @param {Number} [options.direction=0] Direction the FlexibleLayout instance should lay out renderables.
     * @param {Transition} [options.transition=false] The transiton that controls the FlexibleLayout instance's reflow.
     * @param {Ratios} [options.ratios=[]] The proportions for the renderables to maintain
     */
	public function new(?options:FlexibleLayoutOptions) {
        this.options = Reflect.copy(FlexibleLayout.DEFAULT_OPTIONS);
        this.optionsManager = new OptionsManager(this.options);
        if (options != null) this.setOptions(options);

        this.id = Entity.register(this);

        this._ratios = new Transitionable(this.options.ratios);
        this._nodes = [];

        this._cachedDirection = null;
        this._cachedTotalLength = null;
        this._cachedLengths = [];
        this._cachedTransforms = null;
        this._ratiosDirty = false;

        this._eventOutput = new EventHandler();
        EventHandler.setOutputHandler(this, this._eventOutput);
	}
	
    function _reflow(ratios:Array<Dynamic>, length:Float, direction:Int) {
        var currTransform;
        var translation:Float = 0;
        var flexLength = length;
        var ratioSum = 0;
        var ratio;
        var node;
        var i;

        this._cachedLengths = [];
        this._cachedTransforms = [];

        for (i in 0...ratios.length){
            ratio = ratios[i];
            node = this._nodes[i];

            if (!Std.is(ratio, Float)) {
				var size = node.getSize();
				if (size != null && size[direction] != null) {
					flexLength -= size[direction];
				}
            } else {
                ratioSum += ratio;
			}
        }

        for (i in 0...ratios.length){
            node = this._nodes[i];
            ratio = ratios[i];

            length = (Std.is(ratio, Float))
                ? flexLength * ratio / ratioSum
                : node.getSize()[direction];

            currTransform = (direction == FlexibleLayout.DIRECTION_X)
                ? Transform.translate(translation, 0, 0)
                : Transform.translate(0, translation, 0);

            this._cachedTransforms.push(currTransform);
            this._cachedLengths.push(length);

            translation += length;
        }
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
     * Patches the FlexibleLayouts instance's options with the passed-in ones.
     *
     * @method setOptions
     * @param {Options} options An object of configurable options for the FlexibleLayout instance.
     */
    public function setOptions(options) {
        this.optionsManager.setOptions(options);
    }

    /**
     * Sets the collection of renderables under the FlexibleLayout instance's control.  Also sets
     * the associated ratio values for sizing the renderables if given.
     *
     * @method sequenceFrom
     * @param {Array} sequence An array of renderables.
     */
    public function sequenceFrom(sequence:Array<Dynamic>) {
        this._nodes = sequence;

        if (this._ratios.get().length == 0) {
            var ratios = [];
            for (i in 0...this._nodes.length) ratios.push(1);
            this.setRatios(ratios);
        }
    }

    /**
     * Sets the associated ratio values for sizing the renderables.
     *
     * @method setRatios
     * @param {Array} ratios Array of ratios corresponding to the percentage sizes each renderable should be
     */
    public function setRatios(ratios:Dynamic, ?transition:Dynamic, ?callback:Void -> Void) {
        if (transition == null) transition = this.options.transition;
        var currRatios = this._ratios;
        if (currRatios.get().length == 0) transition = null;
        if (currRatios.isActive()) currRatios.halt();
        currRatios.set(ratios, transition, callback);
        this._ratiosDirty = true;
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
        var parentSize = context.size;
        var parentTransform = context.transform;
        var parentOrigin = context.origin;

        var ratios = this._ratios.get();
        var direction = this.options.direction;
        var length = parentSize[direction];
        var size;

        if (length != this._cachedTotalLength || this._ratiosDirty
				|| this._ratios.isActive() || direction != this._cachedDirection) {
            _reflow(ratios, length, direction);

            if (length != this._cachedTotalLength) {
				this._cachedTotalLength = length;
			}
            if (direction != this._cachedDirection) {
				this._cachedDirection = direction;
			}
            if (this._ratiosDirty) {
				this._ratiosDirty = false;
			}
        }

        var result = [];
        for (i in 0...ratios.length) {
            size = [null, null];
            length = this._cachedLengths[i];
            size[direction] = length;
            result.push({
                transform : this._cachedTransforms[i],
                size: size,
                target : this._nodes[i].render()
            });
        }

        if (parentSize != null && (parentOrigin[0] != 0 && parentOrigin[1] != 0)) {
            parentTransform = Transform.moveThen(
				[ -parentSize[0] * parentOrigin[0], -parentSize[1] * parentOrigin[1], 0], 
				parentTransform);
		}
		
        return {
            transform: parentTransform,
            size: parentSize,
            target: result
        };
    }	
}