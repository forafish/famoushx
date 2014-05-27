package famous.core;

import famous.core.Surface.SurfaceOption;

/**
 * Useful for quickly creating elements within applications
 *   with large event systems.  Consists of a RenderNode paired with
 *   an input EventHandler and an output EventHandler.
 *   Meant to be extended by the developer.
 */
 class View {

	static public var DEFAULT_OPTIONS = {}; // no defaults
	
	var _node:RenderNode;

	var _eventInput:EventHandler;
	var _eventOutput:EventHandler;

	var options:Dynamic;
	var _optionsManager:OptionsManager;

    /**
     * @uses EventHandler
     * @uses OptionsManager
     * @uses RenderNode
     * @constructor
     */
 	public function new(options:Dynamic) {
        this._node = new RenderNode();

        this._eventInput = new EventHandler();
        this._eventOutput = new EventHandler();
        EventHandler.setInputHandler(this, this._eventInput);
        EventHandler.setOutputHandler(this, this._eventOutput);

        this.options = Reflect.copy(View.DEFAULT_OPTIONS);
        this._optionsManager = new OptionsManager(this.options);

        if (options != null) {
			this.setOptions(options);
		}
	}
	
    /**
     * Look up options value by key
     * @method getOptions
     *
     * @param {string} key key
     * @return {Object} associated object
     */
    public function getOptions() {
        return this._optionsManager.value();
    }

    /*
     *  Set internal options.
     *  No defaults options are set in View.
     *
     *  @method setOptions
     *  @param {Object} options
     */
    public function setOptions(options:Dynamic) {
        this._optionsManager.setOptions(options);
    }

    /**
     * Add a child renderable to the view.
     *   Note: This is meant to be used by an inheriting class
     *   rather than from outside the prototype chain.
     *
     * @method add
     * @return {RenderNode}
     * @protected
     */
	public function add(child:Dynamic) {
        return this._node.add(child);
    }

    /**
     * Alias for add
     * @method _add
     */
	inline public function _add(child:Dynamic) {
		return add(child);
	}

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {number} Render spec for this component
     */
    public function render() {
        return this._node.render();
    }

    /**
     * Return size of contained element.
     *
     * @method getSize
     * @return {Array.Number} [width, height]
     */
	 public function getSize() {
        if (this._node != null && this._node.getSize != null) {
			var size = this._node.getSize();
            return size != null? size : this.options.size;
        } else {
			return this.options.size;
		}
    }
	
}