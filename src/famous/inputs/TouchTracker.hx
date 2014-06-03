package famous.inputs;

import famous.core.DynamicMap;
import famous.core.EventHandler;
import famous.core.EventEmitter;

typedef TouchData = {
	x: Int,
	y: Int,
	identifier : Int,
	//origin: Dynamic,
	timestamp: Float,
	count: Int,
	history: Array<TouchData>
};

/**
 * Helper to TouchSync – tracks piped in touch events, organizes touch
 *   events by ID, and emits track events back to TouchSync.
 *   Emits 'trackstart', 'trackmove', and 'trackend' events upstream.
 */
class TouchTracker {
	var selective:Bool;
	var touchHistory:Map<Int, Array<TouchData>>;

	public var on:String -> HandlerFunc -> EventEmitter;

	var eventInput:EventHandler;
	var eventOutput:EventHandler;

    /**
     * @constructor
     * @param {Boolean} selective if false, save state for each touch.
     */
	public function new(?selective:Bool) {
        this.selective = selective;
        this.touchHistory = new Map();

        this.eventInput = new EventHandler();
        this.eventOutput = new EventHandler();

        EventHandler.setInputHandler(this, this.eventInput);
        EventHandler.setOutputHandler(this, this.eventOutput);

        this.eventInput.on('touchstart', _handleStart);
        this.eventInput.on('touchmove', _handleMove);
        this.eventInput.on('touchend', _handleEnd);
        this.eventInput.on('touchcancel', _handleEnd);
        this.eventInput.on('unpipe', _handleUnpipe);
	}
	
    function _timestampTouch(touch:js.html.Touch, event:js.html.TouchEvent, history:Dynamic):TouchData {
        return {
            x: touch.clientX,
            y: touch.clientY,
            identifier : touch.identifier,
            //origin: event.origin,
            timestamp: Date.now().getTime(),
            count: event.touches.length,
            history: history
        };
    }

    function _handleStart(event:js.html.TouchEvent) {
        for (touch in event.changedTouches) {
            var data = _timestampTouch(touch, event, null);
            this.eventOutput.emit('trackstart', data);
            if (!this.selective && this.touchHistory[touch.identifier] == null) {
				this.track(data);
			}
        }
    }

    function _handleMove(event:js.html.TouchEvent) {
        for (touch in event.changedTouches) {
            var history = this.touchHistory[touch.identifier];
            if (history != null) {
                var data = _timestampTouch(touch, event, history);
                this.touchHistory[touch.identifier].push(data);
                this.eventOutput.emit('trackmove', data);
            }
        }
    }

    function _handleEnd(event:js.html.TouchEvent) {
        for (touch in event.changedTouches) {
            var history = this.touchHistory[touch.identifier];
            if (history != null) {
                var data = _timestampTouch(touch, event, history);
                this.eventOutput.emit('trackend', data);
                this.touchHistory.remove(touch.identifier);
            }
        }
    }

    function _handleUnpipe(event:js.html.TouchEvent) {
        for (k in this.touchHistory.keys()) {
            var history = this.touchHistory[k];
            this.eventOutput.emit('trackend', {
                x: history[history.length - 1].x,
                y: history[history.length - 1].y,
                identifier: history[history.length - 1].identifier,
                timestamp: Date.now().getTime(),
                count: 0,
                history: history
            });
            this.touchHistory.remove(k);
        }
    }
	
    /**
     * Record touch data, if selective is false.
     * @private
     * @method track
     * @param {Object} data touch data
     */
    public function track(data:TouchData) {
        this.touchHistory[data.identifier] = [data];
    }
	
}