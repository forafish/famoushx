package famous.core;
import famous.core.Transform.Matrix4;

/**
 * Builds and renders a scene graph based on a declarative structure definition.
 * See the Scene examples in the examples distribution (http://github.com/Famous/examples.git).
 */
class Scene {
	
	static var _MATRIX_GENERATORS:Dynamic = {
        'translate': Transform.translate,
        'rotate': Transform.rotate,
        'rotateX': Transform.rotateX,
        'rotateY': Transform.rotateY,
        'rotateZ': Transform.rotateZ,
        'rotateAxis': Transform.rotateAxis,
        'scale': Transform.scale,
        'skew': Transform.skew,
        'matrix3d': function(_) {
            return _;
        }
    };
	
	var id:Dynamic;
	var _objects:Array<Dynamic>;

	var node:RenderNode;
	var _definition:Dynamic;
	
    /**
     * @constructor
     * @param {Object} definition in the format of a render spec.
     */
	public function new(definition:Dynamic) {
        this.id = null;
        this._objects = null;

        this.node = new RenderNode();
        this._definition = null;

        if (definition != null) {
			this.load(definition);
		}
	}
	
    /**
     * Clone this scene
     *
     * @method create
     * @return {Scene} deep copy of this scene
     */
    public function create() {
        return new Scene(this._definition);
    }

    function _resolveTransformMatrix(matrixDefinition:Dynamic) {
        for (type in Reflect.fields(_MATRIX_GENERATORS)) {
            if (Reflect.hasField(matrixDefinition, type)) {
                var val = Reflect.field(matrixDefinition, type);
				var args:Array<Dynamic> = Std.is(val, Array)? val : [val];
                return Reflect.callMethod(null, Reflect.field(_MATRIX_GENERATORS, type), args);
            }
        }
		return null;
    }

    // parse transform into tree of render nodes, doing matrix multiplication
    // when available
    function _parseTransform(definition:Dynamic) {
        var transformDefinition = definition.transform;
        var opacity = definition.opacity;
        var origin = definition.origin;
        var size = definition.size;
        var transform = Transform.identity;
        if (Std.is(transformDefinition, Array)) {
			var transformArr:Array<Dynamic> = cast transformDefinition;
            if (transformArr.length == 16 && Std.is(transformArr[0], Float)) {
                transform = transformDefinition;
            }
            else {
				var transformMatrixes:Array<Matrix4> = cast transformArr;
                for (m in transformMatrixes) {
                    transform = Transform.multiply(transform, _resolveTransformMatrix(m));
                }
            }
        }
        else if (Reflect.isObject(transformDefinition)) {
            transform = _resolveTransformMatrix(transformDefinition);
        }

        var result = new Modifier({
            transform: transform,
            opacity: opacity,
            origin: origin,
            size: size
        });
        return result;
    }

    function _parseArray(definition:Array<Dynamic>) {
        var result = new RenderNode();
        for (k in definition) {
            var obj = _parse(k);
            if (obj != null) {
				result.add(obj);
			}
        }
        return result;
    }

    // parse object directly into tree of RenderNodes
    function _parse(definition:Dynamic) {
        var result;
        var id;
        if (Std.is(definition, Array)) {
            result = _parseArray(definition);
        } 
		else {
            id = this._objects.length;
            if (definition.render != null && Reflect.isFunction(definition.render)) {
                result = definition;
            }
            else if (definition.target != null) {
                var targetObj = _parse(definition.target);
                var obj = _parseTransform(definition);

                result = new RenderNode(obj);
                result.add(targetObj);
                if (definition.id != null) {
					this.id[definition.id] = obj;
				}
            }
            else if (definition.id != null) {
                result = new RenderNode();
                this.id[definition.id] = result;
            }
        }
        this._objects[id] = result;
        return result;
    }

    /**
     * Builds and renders a scene graph based on a canonical declarative scene definition.
     * See examples/Scene/example.js.
     *
     * @method load
     * @param {Object} definition definition in the format of a render spec.
     */
    public function load(definition:Dynamic) {
        this._definition = definition;
        this.id = {};
        this._objects = [];
        this.node.set(_parse(definition));
    }

    /**
     * Add renderables to this component's render tree
     *
     * @method add
     *
     * @param {Object} obj renderable object
     * @return {RenderNode} Render wrapping provided object, if not already a RenderNode
     */
    public function add(child:Dynamic):RenderNode {
        return this.node.add(child);
    }

    /**
     * Generate a render spec from the contents of this component.
     *
     * @private
     * @method render
     * @return {number} Render spec for this component
     */
    public function render() {
        return this.node.render();
    }
}