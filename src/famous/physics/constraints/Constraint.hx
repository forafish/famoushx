package famous.physics.constraints;

import famous.core.EventHandler;

/**
 *  Allows for two circular bodies to collide and bounce off each other.
 */
class Constraint extends EventHandleable {

	var options:Dynamic;
	var _energy:Float;
	var _eventOutput:EventHandler;
	
    /**
     *  @constructor
     *  @uses EventHandler
     *  @param options {Object}
     */
	public function new() {
		this.options = this.options != null? this.options : { };
		this._energy = 0.0;
        this._eventOutput = null;
		
        this._eventOutput = new EventHandler();
        EventHandler.setOutputHandler(this, this._eventOutput);
	}
	
    /*
     * Setter for options.
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
     * Adds an impulse to a physics body's velocity due to the constraint
     *
     * @method applyConstraint
     */
    public function applyConstraint(targets:Array<Dynamic>, source:Dynamic, dt:Float) {};

    /**
     * Getter for energy
     *
     * @method getEnergy
     * @return energy {Number}
     */
    public function getEnergy(?target:Dynamic, ?source:Dynamic):Float {
        return this._energy;
    }

    /**
     * Setter for energy
     *
     * @method setEnergy
     * @param energy {Number}
     */
    public function setEnergy(energy:Float) {
        this._energy = energy;
    }
}