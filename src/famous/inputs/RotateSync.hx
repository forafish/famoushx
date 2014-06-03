package famous.inputs;
import famous.core.OptionsManager;

typedef RotateSyncOptions = {
	scale: Float
};

/**
 * Handles piped in two-finger touch events to increase or decrease scale via pinching / expanding.
 *   Emits 'start', 'update' and 'end' events an object with position, velocity, touch ids, and angle.
 *   Useful for determining a rotation factor from initial two-finger touch.
 */
class RotateSync extends TwoFingerSync {
	
	static public var DEFAULT_OPTIONS:RotateSyncOptions = {
        scale : 1
    };

	var options:Dynamic;
	
	var _previousAngle:Float = 0;
	
    /**
     * @constructor
     * @param {Object} options default options overrides
     * @param {Number} [options.scale] scale velocity by this factor
     */
	public function new(?options:RotateSyncOptions) {
		super();
		
        this.options = Reflect.copy(RotateSync.DEFAULT_OPTIONS);
        if (options != null) this.setOptions(options);

        this._angle = 0;
        this._previousAngle = 0;
	}
	
    override public function _startUpdate(event:js.html.TouchEvent) {
        this._angle = 0;
        this._previousAngle = TwoFingerSync.calculateAngle(this.posA, this.posB);
        var center = TwoFingerSync.calculateCenter(this.posA, this.posB);
        this._eventOutput.emit('start', {
            count: event.touches.length,
            angle: this._angle,
            center: center,
            touches: [this.touchAId, this.touchBId]
        });
    }

    override public function _moveUpdate(diffTime:Float) {
        var scale = this.options.scale;

        var currAngle = TwoFingerSync.calculateAngle(this.posA, this.posB);
        var center = TwoFingerSync.calculateCenter(this.posA, this.posB);

        var diffTheta = scale * (currAngle - this._previousAngle);
        var velTheta = diffTheta / diffTime;

        this._angle += diffTheta;

        this._eventOutput.emit('update', {
            delta : diffTheta,
            velocity: velTheta,
            angle: this._angle,
            center: center,
            touches: [this.touchAId, this.touchBId]
        });

        this._previousAngle = currAngle;
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
    public function setOptions(options) {
        if (options.scale != null) this.options.scale = options.scale;
    }
}