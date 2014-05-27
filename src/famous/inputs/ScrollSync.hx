package famous.inputs;

import famous.core.Engine;
import famous.core.EventHandler;

typedef ScrollSyncOptions = {
	?direction: Null<Int>,
	?minimumEndSpeed: Float,
	?rails: Bool,
	?scale: Float,
	?stallTime: Float,
	?lineHeight: Int
}

typedef ScrollSyncPayload = {
	delta: Dynamic, // Float or Array<Float>
	position: Null<Float>,
	velocity: Null<Float>,
	slip: Bool,
	clientX: Null<Float>,
	clientY: Null<Float>,
	offsetX: Null<Float>,
	offsetY: Null<Float>,
}

/**
 * Handles piped in mousewheel events.
 *   Emits 'start', 'update', and 'end' events with payloads including:
 *   delta: change since last position,
 *   position: accumulated deltas,
 *   velocity: speed of change in pixels per ms,
 *   slip: true (unused).
 *
 *   Can be used as delegate of GenericSync.
 */
class ScrollSync implements Dynamic {
    static public var DIRECTION_X = 0;
    static public var DIRECTION_Y = 1;
	
	static public var MINIMUM_TICK_TIME = 8;
	
    static public var DEFAULT_OPTIONS:ScrollSyncOptions = {
        direction: null,
        minimumEndSpeed: Math.POSITIVE_INFINITY,
        rails: false,
        scale: 1,
        stallTime: 50,
        lineHeight: 40
    };
	
	var options:ScrollSyncOptions;
	
	var _payload:ScrollSyncPayload;

	var _position:Dynamic; // Float or Array<Float>
	var _prevTime:Null<Float>;
	var _prevVel:Float;
	
	var _inProgress:Bool;
	var _loopBound:Bool;

	var _eventInput:EventHandler;
	var _eventOutput:EventHandler;

	/**
     * @constructor
     * @param {Object} [options] overrides of default options
     * @param {Number} [options.direction] Pay attention to x changes (ScrollSync.DIRECTION_X),
     *   y changes (ScrollSync.DIRECTION_Y) or both (undefined)
     * @param {Number} [options.minimumEndSpeed] End speed calculation floors at this number, in pixels per ms
     * @param {boolean} [options.rails] whether to snap position calculations to nearest axis
     * @param {Number | Array.Number} [options.scale] scale outputs in by scalar or pair of scalars
     * @param {Number} [options.stallTime] reset time for velocity calculation in ms
     */
	public function new(?options:ScrollSyncOptions) {
		this.options = Reflect.copy(ScrollSync.DEFAULT_OPTIONS);
        if (options != null) {
			this.setOptions(options);
		}

        this._eventInput = new EventHandler();
        this._eventOutput = new EventHandler();

        EventHandler.setInputHandler(this, this._eventInput);
        EventHandler.setOutputHandler(this, this._eventOutput);
		
        this._eventInput.on('mousewheel', _handleMove);
        this._eventInput.on('wheel', _handleMove);

        this._payload = {
            delta    : null,
            position : null,
            velocity : null,
            slip     : true,
            clientX  : null,
            clientY  : null,
            offsetX  : null,
            offsetY  : null,
        };
		
        this._position = (this.options.direction == null) ? [0,0] : 0;
        this._prevTime = null;
        this._prevVel = null;
        this._inProgress = false;
        this._loopBound = false;
	}
	
    function _newFrame(event) {
        if (this._inProgress && (Date.now().getTime() - this._prevTime) > this.options.stallTime) {
            this._position = (this.options.direction == null) ? [0,0] : 0;
            this._inProgress = false;

            var finalVel = (Math.abs(this._prevVel) >= this.options.minimumEndSpeed)
                ? this._prevVel
                : 0;

            var payload = this._payload;
            payload.position = this._position;
            payload.velocity = finalVel;
            payload.slip = true;

            this._eventOutput.emit('end', payload);
        }
    }

    function _handleMove(event:Dynamic) {
        event.preventDefault();

        if (!this._inProgress) {
            this._inProgress = true;

            var payload = this._payload;
            payload.slip = true;
            payload.position = this._position;
            payload.clientX = event.clientX;
            payload.clientY = event.clientY;
            payload.offsetX = event.offsetX;
            payload.offsetY = event.offsetY;
            this._eventOutput.emit('start', payload);
            if (!this._loopBound) {
                Engine.on('prerender', _newFrame);
                this._loopBound = true;
            }
        }

        var currTime = Date.now().getTime();
        var prevTime = this._prevTime != null? this._prevTime : currTime;

        var diffX = (event.wheelDeltaX != null) ? event.wheelDeltaX : -event.deltaX;
        var diffY = (event.wheelDeltaY != null) ? event.wheelDeltaY : -event.deltaY;

        if (event.deltaMode == 1) { // units in lines, not pixels
            diffX *= this.options.lineHeight;
            diffY *= this.options.lineHeight;
        }

        if (this.options.rails) {
            if (Math.abs(diffX) > Math.abs(diffY)) diffY = 0;
            else diffX = 0;
        }

        var diffTime = Math.max(currTime - prevTime, MINIMUM_TICK_TIME); // minimum tick time

        var velX = diffX / diffTime;
        var velY = diffY / diffTime;

        var scale = this.options.scale;
        var nextVel:Dynamic;
        var nextDelta:Dynamic;

        if (this.options.direction == ScrollSync.DIRECTION_X) {
            nextDelta = scale * diffX;
            nextVel = scale * velX;
            this._position += nextDelta;
        }
        else if (this.options.direction == ScrollSync.DIRECTION_Y) {
            nextDelta = scale * diffY;
            nextVel = scale * velY;
            this._position += nextDelta;
        }
        else {
            nextDelta = [scale * diffX, scale * diffY];
            nextVel = [scale * velX, scale * velY];
            this._position[0] += nextDelta[0];
            this._position[1] += nextDelta[1];
        }

        var payload = this._payload;
        payload.delta    = nextDelta;
        payload.velocity = nextVel;
        payload.position = this._position;
        payload.slip     = true;

        this._eventOutput.emit('update', payload);

        this._prevTime = currTime;
        this._prevVel = nextVel;
    }

    /**
     * Return entire options dictionary, including defaults.
     *
     * @method getOptions
     * @return {Object} configuration options
     */
    public function getOptions():ScrollSyncOptions {
        return this.options;
    }

    /**
     * Set internal options, overriding any default options
     *
     * @method setOptions
     *
     * @param {Object} [options] overrides of default options
     * @param {Number} [options.minimimEndSpeed] If final velocity smaller than this, round down to 0.
     * @param {Number} [options.stallTime] ms of non-motion before 'end' emitted
     * @param {Number} [options.rails] whether to constrain to nearest axis.
     * @param {Number} [options.direction] ScrollSync.DIRECTION_X, DIRECTION_Y -
     *    pay attention to one specific direction.
     * @param {Number} [options.scale] constant factor to scale velocity output
     */
    public function setOptions(options:ScrollSyncOptions) {
        if (options.direction != null) {
			this.options.direction = options.direction;
		}
        if (options.minimumEndSpeed != null) {
			this.options.minimumEndSpeed = options.minimumEndSpeed;
		}
        if (options.rails != null) {
			this.options.rails = options.rails;
		}
        if (options.scale != null) {
			this.options.scale = options.scale;
		}
        if (options.stallTime != null) {
			this.options.stallTime = options.stallTime;
		}
    }
}