package famous.inputs;

import famous.core.EventEmitter.HandlerFunc;
import famous.core.EventHandler;

typedef MouseSyncOptions = {
	?direction: Null<Int>,
	?rails: Bool,
	?scale: Float,
	?propogate: Bool
};

typedef MouseSyncPayload = {
	delta: Dynamic, // Float or Array<Float>
	position: Null<Float>,
	velocity: Null<Float>,
	clientX: Null<Float>,
	clientY: Null<Float>,
	offsetX: Null<Float>,
	offsetY: Null<Float>,
}

/**
 * Handles piped in mouse drag events. Outputs an object with two
 *   properties, position and velocity.
 *   Emits 'start', 'update' and 'end' events with DOM event passthroughs,
 *   with position, velocity, and a delta key.
 */
class MouseSync implements Dynamic {

    static public var DIRECTION_X = 0;
    static public var DIRECTION_Y = 1;
	
	static public var MINIMUM_TICK_TIME = 8;
	
    static public var DEFAULT_OPTIONS:MouseSyncOptions = {
        direction: null,
        rails: false,
        scale: 1,
        propogate: true  // events piped to document on mouseleave
    };

	
	var options:MouseSyncOptions;
	
	var _payload:MouseSyncPayload;
		
	var _prevCoord:Array<Float>;
    var _prevTime:Null<Float>;
    var _position:Dynamic; // Float or Array<Float>;
	
	var _eventInput:EventHandler;
	var _eventOutput:EventHandler;
	
    /**
     * @constructor
     * @param [options] {Object}             default options overrides
     * @param [options.direction] {Number}   read from a particular axis
     * @param [options.rails] {Boolean}      read from axis with greatest differential
     * @param [options.propogate] {Boolean}  add listened to document on mouseleave
     */
	public function new(?options:MouseSyncOptions) {
		this.options = Reflect.copy(MouseSync.DEFAULT_OPTIONS);
        if (options != null) {
			this.setOptions(options);
		}

        this._eventInput = new EventHandler();
        this._eventOutput = new EventHandler();

        EventHandler.setInputHandler(this, this._eventInput);
        EventHandler.setOutputHandler(this, this._eventOutput);

        this._eventInput.on('mousedown', _handleStart);
        this._eventInput.on('mousemove', _handleMove);
        this._eventInput.on('mouseup', _handleEnd);

        if (this.options.propogate) {
			this._eventInput.on('mouseleave', _handleLeave);
		}
        else {
			this._eventInput.on('mouseleave', _handleEnd);		
		}
		
        this._payload = {
            delta    : null,
            position : null,
            velocity : null,
            clientX  : null,
            clientY  : null,
            offsetX  : null,
            offsetY  : null,
        };

        this._position = null;      // to be deprecated
        this._prevCoord = null;
        this._prevTime = null;
	}
	
    function _clearPayload() {
        var payload = this._payload;
        payload.delta    = null;
        payload.position = null;
        payload.velocity = null;
        payload.clientX  = null;
        payload.clientY  = null;
        payload.offsetX  = null;
        payload.offsetY  = null;
    }

    function _handleStart(event:Dynamic) {
        event.preventDefault(); // prevent drag
        _clearPayload();

        var x = event.clientX;
        var y = event.clientY;

        this._prevCoord = [x, y];
        this._prevTime = Date.now().getTime();
		
        this._position = (this.options.direction != null) ? 0 : [0, 0];

        var payload = this._payload;
		payload.position = this._position;
        payload.clientX = x;
        payload.clientY = y;
        payload.offsetX = event.offsetX;
        payload.offsetY = event.offsetY;

        this._eventOutput.emit('start', payload);
    }

    function _handleMove(event:Dynamic) {
        if (this._prevCoord == null) return;

        var prevCoord = this._prevCoord;
        var prevTime = this._prevTime;

        var x:Float = event.clientX;
        var y:Float = event.clientY;

        var currTime = Date.now().getTime();

        var diffX = x - prevCoord[0];
        var diffY = y - prevCoord[1];

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

        if (this.options.direction == MouseSync.DIRECTION_X) {
            nextDelta = scale * diffX;
            nextVel = scale * velX;
            this._position += nextDelta;
        }
        else if (this.options.direction == MouseSync.DIRECTION_Y) {
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
        payload.position = this._position;
        payload.velocity = nextVel;
        payload.clientX  = x;
        payload.clientY  = y;
        payload.offsetX  = event.offsetX;
        payload.offsetY  = event.offsetY;

        this._eventOutput.emit('update', payload);

        this._prevCoord = [x, y];
        this._prevTime = currTime;
    }

    function _handleEnd(event:Dynamic) {
        if (this._prevCoord == null) return;

        this._eventOutput.emit('end', this._payload);
        this._prevCoord = null;
        this._prevTime = null;
    }

    // handle 'mouseup' and 'mousemove'
    function _handleLeave(event:Dynamic) {
        if (this._prevCoord == null) return;

        var boundMove:HandlerFunc = null;
        var boundEnd:HandlerFunc = null;
		
		boundMove= function(event) {
			_handleMove(event);
		}
        boundEnd = function(event) {
            _handleEnd(event);
            js.Browser.document.removeEventListener('mousemove', boundMove);
            js.Browser.document.removeEventListener('mouseup', boundEnd);
        };

        js.Browser.document.addEventListener('mousemove', boundMove);
        js.Browser.document.addEventListener('mouseup', boundEnd);
    }

    /**
     * Return entire options dictionary, including defaults.
     *
     * @method getOptions
     * @return {Object} configuration options
     */
    public function getOptions():MouseSyncOptions {
        return this.options;
    }

    /**
     * Set internal options, overriding any default options
     *
     * @method setOptions
     *
     * @param [options] {Object}             default options overrides
     * @param [options.direction] {Number}   read from a particular axis
     * @param [options.rails] {Boolean}      read from axis with greatest differential
     * @param [options.propogate] {Boolean}  add listened to document on mouseleave
     */
    public function setOptions(options:MouseSyncOptions) {
        if (options.direction != null) {
			this.options.direction = options.direction;
		}
        if (options.rails != null) {
			this.options.rails = options.rails;
		}
        if (options.scale != null) {
			this.options.scale = options.scale;
		}
        if (options.propogate != null) {
			this.options.propogate = options.propogate;
		}
    };	
}