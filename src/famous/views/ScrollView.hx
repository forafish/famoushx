package famous.views;

import famous.core.EventHandler;
import famous.core.OptionsManager;
import famous.core.ViewSequence;
import famous.views.Scroller;
import famous.utilities.Utility;
import famous.inputs.GenericSync;
import famous.inputs.ScrollSync;
import famous.inputs.TouchSync;
import famous.physics.forces.Drag;
import famous.physics.bodies.Particle;
import famous.physics.forces.Spring;
import famous.physics.PhysicsEngine;
import famous.views.ScrollView;

typedef ScrollViewOptions = {
	?direction: Int,
	?rails: Bool,
	?friction: Float,
	?drag: Float,
	?edgeGrip: Float,
	?edgePeriod: Int,
	?edgeDamp: Float,
	?margin: Int,       // mostly safe
	?paginated: Bool,
	?pagePeriod: Int,
	?pageDamp: Float,
	?pageStopSpeed: Float,
	?pageSwitchSpeed: Float,
	?speedLimit: Int,
	?groupScroll: Bool,
	?clipSize:Float,
};

/**
 * Scrollview will lay out a collection of renderables sequentially in the specified direction, and will
 * allow you to scroll through them with mousewheel or touch events.
 */
class ScrollView {
    /** @const */
    static public var TOLERANCE = 0.5;
	
    static public var DEFAULT_OPTIONS:ScrollViewOptions = {
        direction: Utility.Direction.Y,
        rails: true,
        friction: 0.001,
        drag: 0.0001,
        edgeGrip: 0.5,
        edgePeriod: 300,
        edgeDamp: 1,
        margin: 1000,       // mostly safe
        paginated: false,
        pagePeriod: 500,
        pageDamp: 0.8,
        pageStopSpeed: 10,
        pageSwitchSpeed: 0.5,
        speedLimit: 10,
        groupScroll: false
    };
	
    /** @enum */
    static public var SpringStates = {
        NONE: 0,
        EDGE: 1,
        PAGE: 2
    };

	var options:Dynamic;
	var _optionsManager:OptionsManager;

	var _node:Dynamic;

	var _physicsEngine:PhysicsEngine;
	var _particle:Particle;

	var spring:Spring;

	var drag:Drag;
	var friction:Drag;

	var sync:GenericSync;

	var _eventInput:EventHandler;
	var _eventOutput:EventHandler;

	var _touchCount:Int;
	var _springState:Int;
	var _onEdge:Int; // -1 for top, 1 for bottom
	var _pageSpringPosition:Int;
	var _edgeSpringPosition:Int;
	var _touchVelocity:Null<Float>;
	var _earlyEnd:Bool;
	var _needsPaginationCheck:Bool;

	var _scroller:Scroller;

    /**
     * @constructor
     * @param {Options} [options] An object of configurable options.
     * @param {Number} [options.direction=Utility.Direction.Y] Using the direction helper found in the famous Utility
     * module, this option will lay out the Scrollview instance's renderables either horizontally
     * (x) or vertically (y). Utility's direction is essentially either zero (X) or one (Y), so feel free
     * to just use integers as well.
     * @param {Boolean} [options.rails=true] When true, Scrollview's genericSync will only process input in it's primary access.
     * @param {Number} [clipSize=null] The size of the area (in pixels) that Scrollview will display content in.
     * @param {Number} [margin=null] The size of the area (in pixels) that Scrollview will process renderables' associated calculations in.
     * @param {Number} [friction=0.001] Input resistance proportional to the velocity of the input.
     * Controls the feel of the Scrollview instance at low velocities.
     * @param {Number} [drag=0.0001] Input resistance proportional to the square of the velocity of the input.
     * Affects Scrollview instance more prominently at high velocities.
     * @param {Number} [edgeGrip=0.5] A coefficient for resistance against after-touch momentum.
     * @param {Number} [egePeriod=300] Sets the period on the spring that handles the physics associated
     * with hitting the end of a scrollview.
     * @param {Number} [edgeDamp=1] Sets the damping on the spring that handles the physics associated
     * with hitting the end of a scrollview.
     * @param {Boolean} [paginated=false] A paginated scrollview will scroll through items discretely
     * rather than continously.
     * @param {Number} [pagePeriod=500] Sets the period on the spring that handles the physics associated
     * with pagination.
     * @param {Number} [pageDamp=0.8] Sets the damping on the spring that handles the physics associated
     * with pagination.
     * @param {Number} [pageStopSpeed=Infinity] The threshold for determining the amount of velocity
     * required to trigger pagination. The lower the threshold, the easier it is to scroll continuosly.
     * @param {Number} [pageSwitchSpeed=1] The threshold for momentum-based velocity pagination.
     * @param {Number} [speedLimit=10] The highest scrolling speed you can reach.
     */	
	public function new(?options:ScrollViewOptions) {
        this.options = Reflect.copy(ScrollView.DEFAULT_OPTIONS);
        this._optionsManager = new OptionsManager(this.options);

        this._node = null;

        this._physicsEngine = new PhysicsEngine();
        this._particle = new Particle();
        this._physicsEngine.addBody(this._particle);

        this.spring = new Spring({anchor: [0, 0, 0]});

        this.drag = new Drag({forceFunction: Drag.FORCE_FUNCTIONS.QUADRATIC});
        this.friction = new Drag({forceFunction: Drag.FORCE_FUNCTIONS.LINEAR});

        this.sync = new GenericSync(['scroll', 'touch'], {direction : this.options.direction});

        this._eventInput = new EventHandler();
        this._eventOutput = new EventHandler();

        this._eventInput.pipe(this.sync);
        this.sync.pipe(this._eventInput);

        EventHandler.setInputHandler(this, this._eventInput);
        EventHandler.setOutputHandler(this, this._eventOutput);

        this._touchCount = 0;
        this._springState = 0;
        this._onEdge = 0; // -1 for top, 1 for bottom
        this._pageSpringPosition = 0;
        this._edgeSpringPosition = 0;
        this._touchVelocity = null;
        this._earlyEnd = false;
        this._needsPaginationCheck = false;

        this._scroller = new Scroller();
        this._scroller.positionFrom(this.getPosition);

        this.setOptions(options);

        _bindEvents();		
	}
	
    function _handleStart(event:Dynamic) {
        this._touchCount = event.count;
        if (event.count == null) this._touchCount = 1;

        _detachAgents();
        this.setVelocity(0);
        this._touchVelocity = 0;
        this._earlyEnd = false;
    }

    function _handleMove(event:Dynamic) {
        var velocity = -event.velocity;
        var delta = -event.delta;

        if (this._onEdge != 0 && event.slip) {
            if ((velocity < 0 && this._onEdge < 0) || (velocity > 0 && this._onEdge > 0)) {
                if (!this._earlyEnd) {
                    _handleEnd(event);
                    this._earlyEnd = true;
                }
            }
            else if (this._earlyEnd && (Math.abs(velocity) > Math.abs(this.getVelocity()))) {
                _handleStart(event);
            }
        }
        if (this._earlyEnd) return;
        this._touchVelocity = velocity;

        if (event.slip) this.setVelocity(velocity);
        else this.setPosition(this.getPosition() + delta);
    }

    function _handleEnd(event) {
        this._touchCount = event.count != null? event.count : 0;
        if (this._touchCount == 0) {
            _detachAgents();
            if (this._onEdge != 0) _setSpring(this._edgeSpringPosition, SpringStates.EDGE);
            _attachAgents();
            var velocity:Float = -event.velocity;
            var speedLimit:Float = this.options.speedLimit;
            if (event.slip) speedLimit *= this.options.edgeGrip;
            if (velocity < -speedLimit) velocity = -speedLimit;
            else if (velocity > speedLimit) velocity = speedLimit;
            this.setVelocity(velocity);
            this._touchVelocity = null;
            this._needsPaginationCheck = true;
        }
    }

    function _bindEvents() {
        this._eventInput.bindThis(this);
        this._eventInput.on('start', _handleStart);
        this._eventInput.on('update', _handleMove);
        this._eventInput.on('end', _handleEnd);

        this._scroller.on('edgeHit', function(data) {
            this._edgeSpringPosition = data.position;
        });
    }

    function _attachAgents() {
        if (this._springState != 0) this._physicsEngine.attach([this.spring], this._particle);
        else this._physicsEngine.attach([this.drag, this.friction], this._particle);
    }

    function _detachAgents() {
        this._springState = SpringStates.NONE;
        this._physicsEngine.detachAll();
    }

    function _nodeSizeForDirection(node:Dynamic) {
        var direction = this.options.direction;
        var nodeSize = (node.getSize() != null? node.getSize() : this._scroller.getSize())[direction];
        if (nodeSize == null) nodeSize = this._scroller.getSize()[direction];
        return nodeSize;
    }

    function _handleEdge(edgeDetected:Int) {
        if (this._onEdge != 0 && edgeDetected != 0) {
            this.sync.setOptions({scale: this.options.edgeGrip});
            if (this._touchCount == 0 && this._springState != SpringStates.EDGE) {
                _setSpring(this._edgeSpringPosition, SpringStates.EDGE);
            }
        }
        else if (this._onEdge > 0 && edgeDetected == 0) {
            this.sync.setOptions({scale: 1});
            if (this._springState != 0 && Math.abs(this.getVelocity()) < 0.001) {
                // reset agents, detaching the spring
                _detachAgents();
                _attachAgents();
            }
        }
        this._onEdge = edgeDetected;
    }

    function _handlePagination() {
        if (!this._needsPaginationCheck) return;

        if (this._touchCount != 0) return;
        if (this._springState == SpringStates.EDGE) return;

        var velocity = this.getVelocity();
        if (Math.abs(velocity) >= this.options.pageStopSpeed) return;

        var position = this.getPosition();
        var velocitySwitch = Math.abs(velocity) > this.options.pageSwitchSpeed;

        // parameters to determine when to switch
        var nodeSize = _nodeSizeForDirection(this._node);
        var positionNext = position > 0.5 * nodeSize;
        var velocityNext = velocity > 0;

        if ((positionNext && !velocitySwitch) || (velocitySwitch && velocityNext)) this.goToNextPage();
        else _setSpring(0, SpringStates.PAGE);

        this._needsPaginationCheck = false;
    }

    function _setSpring(position, springState) {
        var springOptions = {};
        if (springState == SpringStates.EDGE) {
            this._edgeSpringPosition = position;
            springOptions = {
                anchor: [this._edgeSpringPosition, 0, 0],
                period: this.options.edgePeriod,
                dampingRatio: this.options.edgeDamp
            };
        }
        else if (springState == SpringStates.PAGE) {
            this._pageSpringPosition = position;
            springOptions = {
                anchor: [this._pageSpringPosition, 0, 0],
                period: this.options.pagePeriod,
                dampingRatio: this.options.pageDamp
            };
        }

        this.spring.setOptions(springOptions);
        if (springState != 0 && this._springState == 0) {
            _detachAgents();
            this._springState = springState;
            _attachAgents();
        }
        this._springState = springState;
    }

    function _normalizeState() {
        var position = this.getPosition();
        var nodeSize = _nodeSizeForDirection(this._node);
        var nextNode = this._node.getNext();

        while (position > nodeSize + TOLERANCE && nextNode) {
            _shiftOrigin(-nodeSize);
            position -= nodeSize;
            this._scroller.sequenceFrom(nextNode);
            this._node = nextNode;
            nextNode = this._node.getNext();
            nodeSize = _nodeSizeForDirection(this._node);
        }

        var previousNode = this._node.getPrevious();
        var previousNodeSize;

        while (position < -TOLERANCE && previousNode) {
            previousNodeSize = _nodeSizeForDirection(previousNode);
            this._scroller.sequenceFrom(previousNode);
            this._node = previousNode;
            _shiftOrigin(previousNodeSize);
            position += previousNodeSize;
            previousNode = this._node.getPrevious();
        }
    }

    function _shiftOrigin(amount) {
        this._edgeSpringPosition += amount;
        this._pageSpringPosition += amount;
        this.setPosition(this.getPosition() + amount);
        if (this._springState == SpringStates.EDGE) {
            this.spring.setOptions({anchor: [this._edgeSpringPosition, 0, 0]});
        }
        else if (this._springState == SpringStates.PAGE) {
            this.spring.setOptions({anchor: [this._pageSpringPosition, 0, 0]});
        }
    }

    public function outputFrom() {
        return this._scroller.outputFrom();
    }

    /**
     * Returns the position associated with the Scrollview instance's current node
     *  (generally the node currently at the top).
     * @method getPosition
     * @param {number} [node] If specified, returns the position of the node at that index in the
     * Scrollview instance's currently managed collection.
     * @return {number} The position of either the specified node, or the Scrollview's current Node,
     * in pixels translated.
     */
    public function getPosition() {
        return this._particle.getPosition1D();
    }

    /**
     * Sets position of the physics particle that controls Scrollview instance's "position"
     * @method setPosition
     * @param {number} x The amount of pixels you want your scrollview to progress by.
     */
    public function setPosition(x:Float) {
        this._particle.setPosition1D(x);
    }

    /**
     * Returns the Scrollview instance's velocity.
     * @method getVelocity
     * @return {Number} The velocity.
     */

    public function getVelocity() {
        return this._touchCount > 0? this._touchVelocity : this._particle.getVelocity1D();
    }

    /**
     * Sets the Scrollview instance's velocity. Until affected by input or another call of setVelocity
     *  the Scrollview instance will scroll at the passed-in velocity.
     * @method setVelocity
     * @param {number} v TThe magnitude of the velocity.
     */
    public function setVelocity(v) {
		this._touchVelocity = v;
        this._particle.setVelocity1D(v);
    }

    /**
     * Patches the Scrollview instance's options with the passed-in ones.
     * @method setOptions
     * @param {Options} options An object of configurable options for the Scrollview instance.
     */
    public function setOptions(options:Dynamic) {
        if (options != null) {
            if (options.direction != null) {
                if (options.direction == 'x') options.direction = Utility.Direction.X;
                else if (options.direction == 'y') options.direction = Utility.Direction.Y;
            }

            this._scroller.setOptions(options);
            this._optionsManager.setOptions(options);
        }

        this.drag.setOptions({strength: this.options.drag});
        this.friction.setOptions({strength: this.options.friction});

        this.spring.setOptions({
            period: this.options.edgePeriod,
            dampingRatio: this.options.edgeDamp
        });

        this.sync.setOptions({
            rails: this.options.rails,
            direction: (this.options.direction == Utility.Direction.X) ? GenericSync.DIRECTION_X : GenericSync.DIRECTION_Y
        });
    }

    /**
     * goToPreviousPage paginates your Scrollview instance backwards by one item.
     * @method goToPreviousPage
     * @return {ViewSequence} The previous node.
     */
    public function goToPreviousPage() {
        if (this._node == null) return null;
        var previousNode = this._node.getPrevious();
        if (previousNode != null) {
            var currentPosition = this.getPosition();
            var previousNodeSize = _nodeSizeForDirection(previousNode);
            this._scroller.sequenceFrom(previousNode);
            this._node = previousNode;
            var previousSpringPosition = (currentPosition < TOLERANCE) ? -previousNodeSize : 0;
            _setSpring(previousSpringPosition, SpringStates.PAGE);
            _shiftOrigin(previousNodeSize);
        }
        this._eventOutput.emit('pageChange', {direction: -1});
        return previousNode;
    }

    /**
     * goToNextPage paginates your Scrollview instance forwards by one item.
     * @method goToNextPage
     * @return {ViewSequence} The next node.
     */
    public function goToNextPage() {
        if (this._node == null) return null;
        var nextNode = this._node.getNext();
        if (nextNode != null) {
            var currentPosition = this.getPosition();
            var currentNodeSize = _nodeSizeForDirection(this._node);
            var nextNodeSize = _nodeSizeForDirection(nextNode);
            this._scroller.sequenceFrom(nextNode);
            this._node = nextNode;
            var nextSpringPosition = (currentPosition > currentNodeSize - TOLERANCE) ? currentNodeSize + nextNodeSize : currentNodeSize;
            _setSpring(nextSpringPosition, SpringStates.PAGE);
            _shiftOrigin(-currentNodeSize);
        }
        this._eventOutput.emit('pageChange', {direction: 1});
        return nextNode;
    }

    /**
     * Sets the collection of renderables under the Scrollview instance's control, by
     *  setting its current node to the passed in ViewSequence. If you
     *  pass in an array, the Scrollview instance will set its node as a ViewSequence instantiated with
     *  the passed-in array.
     *
     * @method sequenceFrom
     * @param {Array|ViewSequence} node Either an array of renderables or a Famous viewSequence.
     */
    public function sequenceFrom(node:Dynamic) {
        if (Std.is(node, Array)) node = new ViewSequence({array: node});
        this._node = node;
        return this._scroller.sequenceFrom(node);
    }

    /**
     * Returns the width and the height of the Scrollview instance.
     *
     * @method getSize
     * @return {Array} A two value array of the Scrollview instance's current width and height (in that order).
     */
    public function getSize() {
        return this._scroller.getSize();
    }

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {number} Render spec for this component
     */
    public function render() {
        if (this._node == null) return null;

        _normalizeState();
        _handleEdge(this._scroller.onEdge());
        if (this.options.paginated) _handlePagination();

        return this._scroller.render();
    }
	
}