package famous.core;
import famous.core.Context.NodeContext;
import famous.core.Transform.Matrix4;
import famous.core.Transform.Vector3;

/**
 * This object translates the rendering instructions ("render specs")
 *   that renderable components generate into document update
 *   instructions ("update specs").  Private.
 */
class SpecParser {
	static var _instance = new SpecParser();
	
	public var result:Map<Int, NodeContext>;
	
    /**
     * @class SpecParser
     * @constructor
     */
	public function new() {
		this.result = new Map();
	}
	
    /**
     * Convert a render spec coming from the context's render chain to an
     *    update spec for the update chain. This is the only major entry point
     *    for a consumer of this class.
     *
     * @method parse
     * @static
     * @private
     *
     * @param {renderSpec} spec input render spec
     * @param {Object} context context to do the parse in
     * @return {Object} the resulting update spec (if no callback
     *   specified, else none)
     */
    static public function parseSpec(spec, context):Map<Int, NodeContext> {
        return SpecParser._instance.parse(spec, context);
    }

    /**
     * Convert a renderSpec coming from the context's render chain to an update
     *    spec for the update chain. This is the only major entrypoint for a
     *    consumer of this class.
     *
     * @method parse
     *
     * @private
     * @param {renderSpec} spec input render spec
     * @param {Context} context
     * @return {updateSpec} the resulting update spec
     */
    public function parse(spec:Dynamic, context:NodeContext):Map<Int, NodeContext> {
        this.reset();
        this._parseSpec(spec, context, Transform.identity);
        return this.result;
    };

    /**
     * Prepare SpecParser for re-use (or first use) by setting internal state
     *  to blank.
     *
     * @private
     * @method reset
     */
    public function reset() {
        this.result = new Map();
    };

    // Multiply matrix M by vector v
	static function _vecInContext(v:Vector3, m:Matrix4) {
        return [
            v[0] * m[0] + v[1] * m[4] + v[2] * m[8],
            v[0] * m[1] + v[1] * m[5] + v[2] * m[9],
            v[0] * m[2] + v[1] * m[6] + v[2] * m[10]
        ];
    }

    var _originZeroZero:Array<Float> = [0, 0];

    // From the provided renderSpec tree, recursively compose opacities,
    //    origins, transforms, and sizes corresponding to each surface id from
    //    the provided renderSpec tree structure. On completion, those
    //    properties of 'this' object should be ready to use to build an
    //    updateSpec.
    public function _parseSpec(spec:Dynamic, parentContext:NodeContext, sizeContext:Dynamic) {
        var id:Int;
        var target:js.html.Element;
        var transform:Matrix4;
        var opacity:Float;
        var origin:Array<Float>;
		var align:Dynamic;
        var size:Array<Float>;

        if (Std.is(spec, Int)) {
            id = spec;
            transform = parentContext.transform;
			align = parentContext.align != null? parentContext.align : parentContext.origin;
            if (parentContext.size != null && parentContext.origin != null 
					&& (align[0] != null || align[1] != null)) {
                var alignAdjust = [align[0] * parentContext.size[0], align[1] * parentContext.size[1], 0];
                transform = Transform.thenMove(transform, _vecInContext(alignAdjust, sizeContext));
            }
            this.result[id] = {
                transform: transform,
                opacity: parentContext.opacity,
                origin: parentContext.origin != null? parentContext.origin : _originZeroZero,
				align: parentContext.align != null? parentContext.align : (parentContext.origin != null? parentContext.origin : _originZeroZero),
                size: parentContext.size
            };
        }
        else if (spec == null) { // placed here so 0 will be cached earlier
            return;
        }
        else if (Std.is(spec, Array)) {
            for (i in cast(spec, Array<Dynamic>)) {
                this._parseSpec(i, parentContext, sizeContext);
            }
        }
        else {
            target = spec.target;
            transform = parentContext.transform;
            opacity = parentContext.opacity;
            origin = parentContext.origin;
			align = parentContext.align;
            size = parentContext.size;
            var nextSizeContext = sizeContext;

            if (spec.opacity != null) {
				opacity = parentContext.opacity * spec.opacity;
			}
            if (spec.transform != null) {
				transform = Transform.multiply(parentContext.transform, spec.transform);
			}
            if (spec.origin != null) {
                origin = spec.origin;
                nextSizeContext = parentContext.transform;
            }
			if (spec.align != null) {
				align = spec.align;
			}
            if (spec.size != null) {
                var parentSize = parentContext.size;
                size = [
                    spec.size[0] != null ? spec.size[0] : parentSize[0],
                    spec.size[1] != null ? spec.size[1] : parentSize[1]
                ];
                if (parentSize != null) {
                    if (align == null) align = origin;
                    if (align != null && (align[0] != null || align[1] != null)) {
						transform = Transform.thenMove(transform, _vecInContext([align[0] * parentSize[0], align[1] * parentSize[1], 0], sizeContext));
					}
                    if (origin != null && (origin[0] != null || origin[1] != null)) {
						transform = Transform.moveThen([-origin[0] * size[0], -origin[1] * size[1], 0], transform);
					}
                }
                nextSizeContext = parentContext.transform;
                origin = null;
				align = null;
            }

            this._parseSpec(target, {
                transform: transform,
                opacity: opacity,
                origin: origin,
				align: align,
                size: size
            }, nextSizeContext);
        }
    }
}