package famous.inputs;

import famous.core.EventHandler;

/**
 * Helper to PinchSync, RotateSync, and ScaleSync.  Generalized handling of
 *   two-finger touch events.
 *   This class is meant to be overridden and not used directly.
 */
class TwoFingerSync extends EventHandleable {

	var _eventInput:EventHandler;
	var _eventOutput:EventHandler;
	
	var touchAEnabled:Bool;
	var touchAId:Int;
	var posA:Array<Int>;
	var timestampA:Float;
	
	var touchBEnabled:Bool;
	var touchBId:Int;
	var posB:Array<Int>;
	var timestampB:Float;
	
    /**
     * @constructor
     */
	public function new() {
        this._eventInput = new EventHandler();
        this._eventOutput = new EventHandler();

        EventHandler.setInputHandler(this, this._eventInput);
        EventHandler.setOutputHandler(this, this._eventOutput);

        this.touchAEnabled = false;
        this.touchAId = 0;
        this.posA = null;
        this.timestampA = 0;
        this.touchBEnabled = false;
        this.touchBId = 0;
        this.posB = null;
        this.timestampB = 0;

        this._eventInput.on('touchstart', this.handleStart);
        this._eventInput.on('touchmove', this.handleMove);
        this._eventInput.on('touchend', this.handleEnd);
        this._eventInput.on('touchcancel', this.handleEnd);		
	}
	
    static function calculateAngle(posA, posB) {
        var diffX = posB[0] - posA[0];
        var diffY = posB[1] - posA[1];
        return Math.atan2(diffY, diffX);
    }

	static function calculateDistance(posA, posB) {
        var diffX = posB[0] - posA[0];
        var diffY = posB[1] - posA[1];
        return Math.sqrt(diffX * diffX + diffY * diffY);
    }

	static function calculateCenter(posA, posB) {
        return [(posA[0] + posB[0]) / 2.0, (posA[1] + posB[1]) / 2.0];
    }

    private function handleStart(event:js.html.TouchEvent) {
        for (touch in event.changedTouches) {
            if (!this.touchAEnabled) {
                this.touchAId = touch.identifier;
                this.touchAEnabled = true;
                this.posA = [touch.pageX, touch.pageY];
                this.timestampA = Date.now().getTime();
            }
            else if (!this.touchBEnabled) {
                this.touchBId = touch.identifier;
                this.touchBEnabled = true;
                this.posB = [touch.pageX, touch.pageY];
                this.timestampB = Date.now().getTime();
                this._startUpdate(event);
            }
        }
    };

	private function _startUpdate(event:js.html.TouchEvent) {
		throw "Need to be implemented in sub class";
	}
	
    private function handleMove(event:js.html.TouchEvent) {
        if (!(this.touchAEnabled && this.touchBEnabled)) return;
        var prevTimeA = this.timestampA;
        var prevTimeB = this.timestampB;
        var diffTime:Float = 0;
        for (touch in event.changedTouches) {
            if (touch.identifier == this.touchAId) {
                this.posA = [touch.pageX, touch.pageY];
                this.timestampA = Date.now().getTime();
                diffTime = this.timestampA - prevTimeA;
            }
            else if (touch.identifier == this.touchBId) {
                this.posB = [touch.pageX, touch.pageY];
                this.timestampB = Date.now().getTime();
                diffTime = this.timestampB - prevTimeB;
            }
        }
        if (diffTime > 0) this._moveUpdate(diffTime);
    }
	
	private function _moveUpdate(diff:Float) {
		throw "Need to be implemented in sub class";
	}
	
    private function handleEnd(event:js.html.TouchEvent) {
        for (touch in event.changedTouches) {
            if (touch.identifier == this.touchAId || touch.identifier == this.touchBId) {
                if (this.touchAEnabled && this.touchBEnabled) {
                    this._eventOutput.emit('end', {
                        touches : [this.touchAId, this.touchBId],
                        angle   : this._angle
                    });
                }
                this.touchAEnabled = false;
                this.touchAId = 0;
                this.touchBEnabled = false;
                this.touchBId = 0;
            }
        }
    }
	
	private var _angle:Float = 0;
}