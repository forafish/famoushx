package famous.physics.forces;
import famous.core.EventHandler;
import famous.math.Vector;
import famous.physics.bodies.Body;


/**
 * Force base class.
 *
 * @class Force
 * @uses EventHandler
 * @constructor
 */
class Force extends EventHandleable {

	var force:Vector;
	var _energy:Float;
	var _eventOutput:EventHandler;
	
	var options:Dynamic;
	
    /**
     * Force base class.
     *
     * @class Force
     * @uses EventHandler
     * @constructor
     */
	public function new(?force:Float) {
        this.force = new Vector(force);
        this._energy = 0.0;
        this._eventOutput = null;
		
        this._eventOutput = new EventHandler();
        EventHandler.setOutputHandler(this, this._eventOutput);
	}
	
    /**
     * Basic setter for options
     *
     * @method setOptions
     * @param options {Objects}
     */
    public function setOptions(options:Dynamic) {
        for (key in Reflect.fields(options)) {
			this.options[cast key] = options[cast key];
		}
    }

    /**
     * Adds a force to a physics body's force accumulator.
     *
     * @method applyForce
     * @param body {Body}
     */
    public function applyForce(targets:Array<Body>, ?source:Body) {
        for (body in targets) {
			body.applyForce(this.force);
		}
    }

    /**
     * Getter for a force's potential energy.
     *
     * @method getEnergy
     * @return energy {Number}
     */
    public function getEnergy(?target:Body):Float {
        return this._energy;
    };

    /*
     * Setter for a force's potential energy.
     *
     * @method setEnergy
     * @param energy {Number}
     */
    public function setEnergy(energy:Float) {
        this._energy = energy;
    }
}