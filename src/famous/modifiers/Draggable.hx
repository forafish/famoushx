package famous.modifiers;

import famous.core.EventHandler;
import famous.core.Transform;
import famous.inputs.GenericSync;
import famous.math.Utilities;
import famous.transitions.Transitionable;

typedef DraggableOptions = {
	?projection  : Int,
	?scale       : Float,
	?xRange      : Array<Float>,
	?yRange      : Array<Float>,
	?snapX       : Float,
	?snapY       : Float,
	?transition  : Dynamic,
};

/**
 * Makes added render nodes responsive to drag beahvior.
 *   Emits events 'start', 'update', 'end'.
 */
class Draggable extends EventHandleable {
	
    //binary representation of directions for bitwise operations
    static var _direction = {
        x : 0x01,         //001
        y : 0x02          //010
    };

	static public var DIRECTION_X = _direction.x;
    static public var DIRECTION_Y = _direction.y;

    static public var DEFAULT_OPTIONS = {
        projection  : _direction.x | _direction.y,
        scale       : 1,
        xRange      : null,
        yRange      : null,
        snapX       : 0,
        snapY       : 0,
        transition  : {duration : 0}
    };
	
	var options:Dynamic;

	var _positionState:Transitionable;
	var _differential:Array<Float>;
	var _active:Bool;

	var sync:GenericSync;
	
	var eventOutput:EventHandler;

    /**
     * @constructor
     * @param {Object} [options] options configuration object.
     * @param {Number} [options.snapX] grid width for snapping during drag
     * @param {Number} [options.snapY] grid height for snapping during drag
     * @param {Array.Number} [options.xRange] maxmimum [negative, positive] x displacement from start of drag
     * @param {Array.Number} [options.yRange] maxmimum [negative, positive] y displacement from start of drag
     * @param {Number} [options.scale] one pixel of input motion translates to this many pixels of output drag motion
     * @param {Number} [options.projection] User should set to Draggable._direction.x or
     *    Draggable._direction.y to constrain to one axis.
     */
	public function new(?options:DraggableOptions) {
        this.options = Reflect.copy(Draggable.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        this._positionState = new Transitionable([0,0]);
        this._differential  = [0,0];
        this._active = true;

        this.sync = new GenericSync(['mouse', 'touch'], { scale : this.options.scale } );
		
        this.eventOutput = new EventHandler();
        EventHandler.setInputHandler(this,  this.sync);
        EventHandler.setOutputHandler(this, this.eventOutput);

        _bindEvents();
	}
	
    function _mapDifferential(differential:Array<Float>) {
        var opts        = this.options;
        var projection  = opts.projection;
        var snapX       = opts.snapX;
        var snapY       = opts.snapY;

        //axes
        var tx = (projection & _direction.x != 0) ? differential[0] : 0;
        var ty = (projection & _direction.y != 0) ? differential[1] : 0;

        //snapping
        if (snapX > 0) tx -= tx % snapX;
        if (snapY > 0) ty -= ty % snapY;

        return [tx, ty];
    }

    function _handleStart(event) {
        if (!this._active) return;
        if (this._positionState.isActive()) this._positionState.halt();
        this.eventOutput.emit('start', {position : this.getPosition()});
    }

    function _handleMove(event) {
        if (!this._active) return;

        var options = this.options;
        this._differential = event.position;
        var newDifferential = _mapDifferential(this._differential);

        //buffer the differential if snapping is set
        this._differential[0] -= newDifferential[0];
        this._differential[1] -= newDifferential[1];

        var pos = this.getPosition();

        //modify position, retain reference
        pos[0] += newDifferential[0];
        pos[1] += newDifferential[1];

        //handle bounding box
        if (options.xRange != null){
            var xRange = [options.xRange[0] + 0.5 * options.snapX, options.xRange[1] - 0.5 * options.snapX];
            pos[0] = Utilities.clamp(pos[0], xRange);
        }

        if (options.yRange != null){
            var yRange = [options.yRange[0] + 0.5 * options.snapY, options.yRange[1] - 0.5 * options.snapY];
            pos[1] = Utilities.clamp(pos[1], yRange);
        }

        this.eventOutput.emit('update', {position : pos});
    }

    function _handleEnd(event) {
        if (!this._active) return;
        this.eventOutput.emit('end', {position : this.getPosition()});
    }

    function _bindEvents() {
        this.sync.on('start', _handleStart);
        this.sync.on('update', _handleMove);
        this.sync.on('end', _handleEnd);
    }

    /**
     * Set internal options, overriding any default options
     *
     * @method setOptions
     *
     * @param {Object} [options] overrides of default options.  See constructor.
     */
    public function setOptions(options:Dynamic) {
        var currentOptions:Dynamic = this.options;
        if (options.projection != null) {
            var proj = options.projection;
            this.options.projection = 0;
            Lambda.iter(['x', 'y'], function(val) {
                if (proj.indexOf(val) != -1) currentOptions.projection |= Reflect.field(_direction, val);
            });
        }
        if (options.scale  != null) currentOptions.scale  = options.scale;
        if (options.xRange != null) currentOptions.xRange = options.xRange;
        if (options.yRange != null) currentOptions.yRange = options.yRange;
        if (options.snapX  != null) currentOptions.snapX  = options.snapX;
        if (options.snapY  != null) currentOptions.snapY  = options.snapY;
    }

    /**
     * Get current delta in position from where this draggable started.
     *
     * @method getPosition
     *
     * @return {array<number>} [x, y] position delta from start.
     */
    public function getPosition():Array<Float> {
        return this._positionState.get();
    }

    /**
     * Transition the element to the desired relative position via provided transition.
     *  For example, calling this with [0,0] will not change the position.
     *  Callback will be executed on completion.
     *
     * @method setRelativePosition
     *
     * @param {array<number>} position end state to which we interpolate
     * @param {transition} transition transition object specifying how object moves to new position
     * @param {function} callback zero-argument function to call on observed completion
     */
    public function setRelativePosition(position:Array<Float>, ?transition:Dynamic, ?callback:Void -> Void) {
        var currPos = this.getPosition();
        var relativePosition = [currPos[0] + position[0], currPos[1] + position[1]];
        this.setPosition(relativePosition, transition, callback);
    }

    /**
     * Transition the element to the desired absolute position via provided transition.
     *  Callback will be executed on completion.
     *
     * @method setPosition
     *
     * @param {array<number>} position end state to which we interpolate
     * @param {transition} transition transition object specifying how object moves to new position
     * @param {function} callback zero-argument function to call on observed completion
     */
    public function setPosition(position:Array<Float>, ?transition:Dynamic, ?callback:Void -> Void) {
        if (this._positionState.isActive()) this._positionState.halt();
        this._positionState.set(position, transition, callback);
    }

    /**
     * Set this draggable to respond to user input.
     *
     * @method activate
     *
     */
    public function activate() {
        this._active = true;
    }

    /**
     * Set this draggable to ignore user input.
     *
     * @method deactivate
     *
     */
    public function deactivate() {
        this._active = false;
    }

    /**
     * Switch the input response stage between active and inactive.
     *
     * @method toggle
     *
     */
    public function toggle() {
        this._active = !this._active;
    }

    /**
     * Return render spec for this Modifier, applying to the provided
     *    target component.  This is similar to render() for Surfaces.
     *
     * @private
     * @method modify
     *
     * @param {Object} target (already rendered) render spec to
     *    which to apply the transform.
     * @return {Object} render spec for this Modifier, including the
     *    provided target
     */
    public function modify(target:Dynamic):Dynamic {
        var pos = this.getPosition();
        return {
            transform: Transform.translate(pos[0], pos[1]),
            target: target
        };
    }
}