package famous.inputs;
import famous.inputs.PinchSync.PinchSyncOptions;
import js.html.Location;

typedef PinchSyncOptions = {
	?scale:Null<Float>
};

/**
 * Handles piped in two-finger touch events to change position via pinching / expanding.
 *   Emits 'start', 'update' and 'end' events with
 *   position, velocity, touch ids, and distance between fingers.
 */
class PinchSync extends TwoFingerSync {
    
	static public var DEFAULT_OPTIONS:PinchSyncOptions = {
        scale : 1
    };
	
	var options:PinchSyncOptions;
	
	var _displacement:Float;
    var _previousDistance:Float;
		
	/**
	 * @constructor
	 * @param {Object} options default options overrides
	 * @param {Number} [options.scale] scale velocity by this factor
	 */
	public function new(?options:PinchSyncOptions) {
		super();
		
        this.options = Reflect.copy(PinchSync.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        this._displacement = 0;
        this._previousDistance = 0;
	}
	
    override private function _startUpdate(event:js.html.TouchEvent) {
        this._previousDistance = TwoFingerSync.calculateDistance(this.posA, this.posB);
        this._displacement = 0;

        this._eventOutput.emit('start', {
            count: event.touches.length,
            touches: [this.touchAId, this.touchBId],
            distance: null,// this._dist,
            center: TwoFingerSync.calculateCenter(this.posA, this.posB)
        });
    }

    override private function _moveUpdate(diffTime:Float) {
        var currDist = TwoFingerSync.calculateDistance(this.posA, this.posB);
        var center = TwoFingerSync.calculateCenter(this.posA, this.posB);

        var scale = this.options.scale;
        var delta = scale * (currDist - this._previousDistance);
        var velocity = delta / diffTime;

        this._previousDistance = currDist;
        this._displacement += delta;

        this._eventOutput.emit('update', {
            delta : delta,
            velocity: velocity,
            distance: currDist,
            displacement: this._displacement,
            center: center,
            touches: [this.touchAId, this.touchBId]
        });
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

    /**
     * Set internal options, overriding any default options
     *
     * @method setOptions
     *
     * @param {Object} [options] overrides of default options
     * @param {Number} [options.scale] scale velocity by this factor
     */
    public function setOptions(options:Dynamic) {
        if (options.scale != null) {
			this.options.scale = options.scale;
		}
    }	
}