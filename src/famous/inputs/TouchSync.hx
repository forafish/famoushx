package famous.inputs;

import famous.core.EventHandler;
import famous.core.EventEmitter;
import famous.inputs.TouchTracker;

typedef TouchSyncOptions =  {
	?direction: Int,
	?rails: Bool,
	?scale: Float,
};

typedef TouchSyncPayload = {
	delta    : Dynamic, // Array<Float> or Float for single direction
	position : Dynamic, // Array<Float> or Float for single direction
	velocity : Dynamic, // Array<Float> or Float for single direction
	clientX  : Null<Int>,
	clientY  : Null<Int>,
	count    : Int,
	touch    : Null<Int>
};
		
/**
 * Handles piped in touch events. Emits 'start', 'update', and 'events'
 *   events with position, velocity, acceleration, and touch id.
 *   Useful for dealing with inputs on touch devices.
 */
class TouchSync extends EventHandleable {
    static public var DIRECTION_X = 0;
    static public var DIRECTION_Y = 1;

    static public var MINIMUM_TICK_TIME = 8;

    static public var DEFAULT_OPTIONS:TouchSyncOptions = {
        direction: null,
        rails: false,
        scale: 1
    };

	var options:TouchSyncOptions;

	var _eventOutput:EventHandler;
	var _touchTracker:TouchTracker;

	var _payload:TouchSyncPayload;
	
	var _position:Dynamic;  // Float or Array<Float> to be deprecated
		
    /**
     * @constructor
     *
     * @param [options] {Object}             default options overrides
     * @param [options.direction] {Number}   read from a particular axis
     * @param [options.rails] {Boolean}      read from axis with greatest differential
     * @param [options.scale] {Number}       constant factor to scale velocity output
     */
	public function new(?options:TouchSyncOptions) {
        this.options =  Reflect.copy(TouchSync.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        this._eventOutput = new EventHandler();
        this._touchTracker = new TouchTracker();

        EventHandler.setOutputHandler(this, this._eventOutput);
        EventHandler.setInputHandler(this, this._touchTracker);

        this._touchTracker.on('trackstart', _handleStart);
        this._touchTracker.on('trackmove', _handleMove);
        this._touchTracker.on('trackend', _handleEnd);

        this._payload = {
            delta    : null,
            position : null,
            velocity : null,
            clientX  : null,
            clientY  : null,
            count    : 0,
            touch    : null,
        };

        this._position = null; // to be deprecated
	}
	
    function _clearPayload() {
        var payload = this._payload;
        payload.position = null;
        payload.velocity = null;
        payload.clientX  = null;
        payload.clientY  = null;
        payload.count    = null;
        payload.touch    = null;
    }

    // handle 'trackstart'
    function _handleStart(data:TouchData) {
        _clearPayload();

        this._position = (this.options.direction != null) ? 0 : [0, 0];

        var payload = this._payload;
        payload.count = data.count;
        payload.touch = data.identifier;

        this._eventOutput.emit('start', payload);
    }

    // handle 'trackmove'
    function _handleMove(data:TouchData) {
        var history = data.history;

        var currHistory = history[history.length - 1];
        var prevHistory = history[history.length - 2];

        var prevTime = prevHistory.timestamp;
        var currTime = currHistory.timestamp;

        var diffX = currHistory.x - prevHistory.x;
        var diffY = currHistory.y - prevHistory.y;

        if (this.options.rails) {
            if (Math.abs(diffX) > Math.abs(diffY)) diffY = 0;
            else diffX = 0;
        }

        var diffTime = Math.max(currTime - prevTime, MINIMUM_TICK_TIME);

        var velX = diffX / diffTime;
        var velY = diffY / diffTime;

        var scale = this.options.scale;
        var nextVel:Dynamic;
        var nextDelta:Dynamic;

        if (this.options.direction == TouchSync.DIRECTION_X) {
            nextDelta = scale * diffX;
            nextVel = scale * velX;
            this._position += nextDelta;
        }
        else if (this.options.direction == TouchSync.DIRECTION_Y) {
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
        payload.clientX  = data.x;
        payload.clientY  = data.y;
        payload.count    = data.count;
        payload.touch    = data.identifier;

        this._eventOutput.emit('update', payload);
    }

    // handle 'trackend'
    function _handleEnd(data:TouchData) {
        var nextVel:Dynamic = (this.options.direction != null) ? 0 : [0, 0];
        var history = data.history;
        var count = data.count;
        if (history.length > 1) {
            var currHistory = history[history.length - 1];
            var prevHistory = history[history.length - 2];

            var prevTime = prevHistory.timestamp;
            var currTime = currHistory.timestamp;

            var diffX = currHistory.x - prevHistory.x;
            var diffY = currHistory.y - prevHistory.y;

            if (this.options.rails) {
                if (Math.abs(diffX) > Math.abs(diffY)) diffY = 0;
                else diffX = 0;
            }

            var diffTime = Math.max(currTime - prevTime, MINIMUM_TICK_TIME);
            var velX = diffX / diffTime;
            var velY = diffY / diffTime;
            var scale = this.options.scale;

            if (this.options.direction == TouchSync.DIRECTION_X) nextVel = scale * velX;
            else if (this.options.direction == TouchSync.DIRECTION_Y) nextVel = scale * velY;
            else nextVel = [scale * velX, scale * velY];
        }

        var payload = this._payload;
        payload.velocity = nextVel;
        payload.clientX  = data.x;
        payload.clientY  = data.y;
        payload.count    = count;
        payload.touch    = data.identifier;

        this._eventOutput.emit('end', payload);
    }

    /**
     * Set internal options, overriding any default options
     *
     * @method setOptions
     *
     * @param [options] {Object}             default options overrides
     * @param [options.direction] {Number}   read from a particular axis
     * @param [options.rails] {Boolean}      read from axis with greatest differential
     * @param [options.scale] {Number}       constant factor to scale velocity output
     */
    public function setOptions(options) {
        if (options.direction != null) this.options.direction = options.direction;
        if (options.rails != null) this.options.rails = options.rails;
        if (options.scale != null) this.options.scale = options.scale;
    }

    /**
     * Return entire options dictionary, including defaults.
     *
     * @method getOptions
     * @return {Object} configuration options
     */
    public function getOptions() {
        return this.options;
    }
}