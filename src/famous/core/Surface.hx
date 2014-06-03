package famous.core;

import famous.core.Context.NodeContext;
import famous.core.EventEmitter.HandlerFunc;
import famous.core.Surface.SurfaceOptions;
import famous.core.Transform.Matrix4;

using famous.math.Utilities;

typedef SurfaceOptions = {
	?size:Array<Float>,
	?classes:Array<String>,
	?properties:DynamicMap, 
	?content:String 
	};

/**
 * A base class for viewable content and event
 *   targets inside a Famo.us application, containing a renderable document
 *   fragment. Like an HTML div, it can accept internal markup,
 *   properties, classes, and handle events.
 */
class Surface {
    static public var devicePixelRatio:Float = js.Browser.window.devicePixelRatio != null? js.Browser.window.devicePixelRatio : 1;
    static public var usePrefix:Bool = untyped js.Browser.document.createElement('div').style.webkitTransform != null;

    public var elementType = 'div';
    public var elementClass:Dynamic = 'famous-surface';

	var options:SurfaceOptions;

	var properties:DynamicMap;
	var content:Dynamic; // String or js.html.DocumentFragment
	var classList:Array<String>;
	var size:Array<Float>;

	var _classesDirty:Bool = true;
	var _stylesDirty:Bool = true;
	var _sizeDirty:Bool = true;
	var _contentDirty:Bool = true;

	var _dirtyClasses:Array<String> = [];

	var _matrix:Matrix4 = null;
	var _opacity:Float = 1;
	var _origin:Array<Float> = null;
	var _size:Array<Float> = null;

	var eventForwarder:js.html.EventListener;
	var eventHandler:EventHandler;

	var id:Int;

	var _currTarget:js.html.Element;
	
		
    /**
     * @constructor
     *
     * @param {Object} [options] default option overrides
     * @param {Array.Number} [options.size] [width, height] in pixels
     * @param {Array.string} [options.classes] CSS classes to set on inner content
     * @param {Array} [options.properties] string dictionary of HTML attributes to set on target div
     * @param {string} [options.content] inner (HTML) content of surface
     */
	public function new(?options:SurfaceOptions) {
        this.options = {};

        this.properties = {};
        this.content = "";
        this.classList = [];
        this.size = null;

        this._classesDirty = true;
        this._stylesDirty = true;
        this._sizeDirty = true;
        this._contentDirty = true;

        this._dirtyClasses = [];

        this._matrix = null;
        this._opacity = 1;
        this._origin = null;
        this._size = null;

        /** @ignore */
        this.eventForwarder = function eventForwarder(event) {
            this.emit(event.type, event);
        };
        this.eventHandler = new EventHandler();
        this.eventHandler.bindThis(this);

        this.id = Entity.register(this);

        if (options != null) {
			this.setOptions(options);
		}

        this._currTarget = null;
	}
	
    /**
     * Bind a callback function to an event type handled by this object.
     *
     * @method "on"
     *
     * @param {string} type event type key (for example, 'click')
     * @param {function(string, Object)} fn handler callback
     * @return {EventHandler} this
     */
    public function on(type:String, fn:HandlerFunc) {
        if (this._currTarget != null) {
			this._currTarget.addEventListener(type, this.eventForwarder);
		}
        this.eventHandler.on(type, fn);
    }

    /**
     * Unbind an event by type and handler.
     *   This undoes the work of "on"
     *
     * @method removeListener
     * @param {string} type event type key (for example, 'click')
     * @param {function(string, Object)} fn handler
     */
    public function removeListener(type:String, fn:HandlerFunc) {
        this.eventHandler.removeListener(type, fn);
    }

    /**
     * Trigger an event, sending to all downstream handlers
     *   listening for provided 'type' key.
     *
     * @method emit
     *
     * @param {string} type event type key (for example, 'click')
     * @param {Object} [event] event data
     * @return {EventHandler} this
     */
    public function emit(type:String, event:Dynamic):EventEmitter {
        if (event != null && event.origin == null) {
			event.origin = this;
		}
        var handled = this.eventHandler.emit(type, event);
        if (handled != null && event != null && event.stopPropagation != null) {
			event.stopPropagation();
		}
        return handled;
    }

    /**
     * Add event handler object to set of downstream handlers.
     *
     * @method pipe
     *
     * @param {EventHandler} target event handler target object
     * @return {EventHandler} passed event handler
     */
    public function pipe(target:Dynamic):EventHandler {
        return this.eventHandler.pipe(target);
    }

    /**
     * Remove handler object from set of downstream handlers.
     *   Undoes work of "pipe"
     *
     * @method unpipe
     *
     * @param {EventHandler} target target handler object
     * @return {EventHandler} provided target
     */
    public function unpipe(target:Dynamic):EventHandler {
        return this.eventHandler.unpipe(target);
    }

    /**
     * Return spec for this surface. Note that for a base surface, this is
     *    simply an id.
     *
     * @method render
     * @private
     * @return {Object} render spec for this surface (spec id)
     */
    public function render():Int {
        return this.id;
    };

    /**
     * Set CSS-style properties on this Surface. Note that this will cause
     *    dirtying and thus re-rendering, even if values do not change.
     *
     * @method setProperties
     * @param {Object} properties property dictionary of "key" => "value"
     */
    public function setProperties(properties:Dynamic) {
        for (n in Reflect.fields(properties)) {
            this.properties[n] = Reflect.field(properties, n);
        }
        this._stylesDirty = true;
    }

    /**
     * Get CSS-style properties on this Surface.
     *
     * @method getProperties
     *
     * @return {Object} Dictionary of this Surface's properties.
     */
    public function getProperties():DynamicMap {
        return this.properties;
    };

    /**
     * Add CSS-style class to the list of classes on this Surface. Note
     *   this will map directly to the HTML property of the actual
     *   corresponding rendered <div>.
     *
     * @method addClass
     * @param {string} className name of class to add
     */
    public function addClass(className:String) {
        if (this.classList.indexOf(className) < 0) {
            this.classList.push(className);
            this._classesDirty = true;
        }
    }

    /**
     * Remove CSS-style class from the list of classes on this Surface.
     *   Note this will map directly to the HTML property of the actual
     *   corresponding rendered <div>.
     *
     * @method removeClass
     * @param {string} className name of class to remove
     */
    public function removeClass(className:String) {
        var i = this.classList.indexOf(className);
        if (i >= 0) {
            this._dirtyClasses.push(this.classList.splice(i, 1)[0]);
            this._classesDirty = true;
        }
    }

    /**
     * Reset class list to provided dictionary.
     * @method setClasses
     * @param {Array.string} classList
     */
    public function setClasses(classList:Array<String>) {
        var removal = [];
        for (clazz in this.classList) {
            if (classList.indexOf(clazz) < 0) removal.push(clazz);
        }
        for (clazz in removal) {
			this.removeClass(clazz);
		}
        // duplicates are already checked by addClass()
        for (clazz in classList) {
			this.addClass(clazz);
		}
    }

    /**
     * Get array of CSS-style classes attached to this div.
     *
     * @method getClasslist
     * @return {Array.string} array of class names
     */
    public function getClassList():Array<String> {
        return this.classList;
    };

    /**
     * Set or overwrite inner (HTML) content of this surface. Note that this
     *    causes a re-rendering if the content has changed.
     *
     * @method setContent
     * @param {string} content HTML content
     */
    public function setContent(content:Dynamic) {
        if (this.content != content) {
            this.content = content;
            this._contentDirty = true;
        }
    };

    /**
     * Return inner (HTML) content of this surface.
     *
     * @method getContent
     *
     * @return {string} inner (HTML) content
     */
    public function getContent():Dynamic {
        return this.content;
    };

    /**
     * Set options for this surface
     *
     * @method setOptions
     * @param {Object} [options] overrides for default options.  See constructor.
     */
    public function setOptions(options:SurfaceOptions) {
        if (options.size != null) {
			this.setSize(options.size);
		}
        if (options.classes != null) {
			this.setClasses(options.classes);
		}
        if (options.properties != null) {
			this.setProperties(options.properties);
		}
        if (options.content != null) {
			this.setContent(options.content);
		}
    }

    //  Attach Famous event handling to document events emanating from target
    //    document element.  This occurs just after deployment to the document.
    //    Calling this enables methods like #on and #pipe.
    function _addEventListeners(target:js.html.Element) {
        for (k in this.eventHandler.listeners.keys()) {
            target.addEventListener(k, this.eventForwarder);
        }
    }

    //  Detach Famous event handling from document events emanating from target
    //  document element.  This occurs just before recall from the document.
    function _removeEventListeners(target:js.html.Element) {
        for (k in this.eventHandler.listeners.keys()) {
            target.removeEventListener(k, this.eventForwarder);
        }
    }

    //  Apply to document all changes from removeClass() since last setup().
    function _cleanupClasses(target:js.html.Element) {
        for (clazz in this._dirtyClasses) {
			target.classList.remove(clazz);
		}
        this._dirtyClasses = [];
    }

    // Apply values of all Famous-managed styles to the document element.
    //  These will be deployed to the document on call to #setup().
    function _applyStyles(target:js.html.Element) {
        for (k in this.properties.keys()) {
            Reflect.setField(target.style, k, this.properties[k]);
        }
    }

    // Clear all Famous-managed styles from the document element.
    // These will be deployed to the document on call to #setup().
    function _cleanupStyles(target:js.html.Element) {
        for (k in this.properties.keys()) {
			Reflect.setField(target.style, k, '');
        }
    }

    /**
     * Return a Matrix's webkit css representation to be used with the
     *    CSS3 -webkit-transform style.
     *    Example: -webkit-transform: matrix3d(1,0,0,0,0,1,0,0,0,0,1,0,716,243,0,1)
     *
     * @method _formatCSSTransform
     * @private
     * @param {FamousMatrix} m matrix
     * @return {string} matrix3d CSS style representation of the transform
     */
    static function _formatCSSTransform(m:Matrix4):String {
        m[12] = Math.round(m[12] * devicePixelRatio) / devicePixelRatio;
        m[13] = Math.round(m[13] * devicePixelRatio) / devicePixelRatio;

        var result = 'matrix3d(';
        for (i in 0...15) {
            result += (m[i] < 0.000001 && m[i] > -0.000001) ? '0,' : m[i] + ',';
        }
        result += m[15] + ')';
        return result;
    }

    /**
     * Directly apply given FamousMatrix to the document element as the
     *   appropriate webkit CSS style.
     *
     * @method setMatrix
     *
     * @static
     * @private
     * @param {Element} element document element
     * @param {FamousMatrix} matrix
     */
    static var _setMatrix:Dynamic -> Matrix4 -> Void =
		if (js.Browser.navigator.userAgent.toLowerCase().indexOf('firefox') > -1) {
			function(element:Dynamic, matrix:Matrix4) {
				element.style.zIndex = Std.int(matrix[14] * 1000000) | 0;    // fix for Firefox z-buffer issues
				element.style.transform = _formatCSSTransform(matrix);
			}
		}
		else if (usePrefix) {
			function(element:Dynamic, matrix:Matrix4) {
				element.style.webkitTransform = _formatCSSTransform(matrix);
			}
		}
		else {
			function(element:Dynamic, matrix:Matrix4) {
				element.style.transform = _formatCSSTransform(matrix);
			}
		}

    // format origin as CSS percentage string
    static function _formatCSSOrigin(origin:Array<Float>):String {
        return (100 * origin[0]) + '% ' + (100 * origin[1]) + '%';
    }

     // Directly apply given origin coordinates to the document element as the
     // appropriate webkit CSS style.
    static var _setOrigin:Dynamic -> Array<Float> -> Void = usePrefix ? function(element, origin) {
        element.style.webkitTransformOrigin = _formatCSSOrigin(origin);
    } : function(element, origin) {
        element.style.transformOrigin = _formatCSSOrigin(origin);
    };

     // Shrink given document element until it is effectively invisible.
	static var _setInvisible:Dynamic -> Void = usePrefix ? function(element) {
        element.style.webkitTransform = 'scale3d(0.0001,0.0001,1)';
        element.style.opacity = 0;
    } : function(element) {
        element.style.transform = 'scale3d(0.0001,0.0001,1)';
        element.style.opacity = 0;
    };

	static function _xyNotEquals(a:Array<Float>, b:Array<Float>) {
        return (a != null && b != null) ? (a[0] != b[0] || a[1] != b[1]) : a != b;
    }

    /**
     * One-time setup for an element to be ready for commits to document.
     *
     * @private
     * @method setup
     *
     * @param {ElementAllocator} allocator document element pool for this context
     */
    public function setup(allocator:Dynamic) {
        var target:js.html.Element = allocator.allocate(this.elementType);
        if (this.elementClass != null) {
            if (Std.is(this.elementClass, Array)) {
				var clazzes:Array<String> = cast this.elementClass;
                for (clazz in clazzes) {
                    target.classList.add(clazz);
                }
            }
            else {
                target.classList.add(this.elementClass);
            }
        }
        target.style.display = '';
        _addEventListeners(target);
        this._currTarget = target;
        this._stylesDirty = true;
        this._classesDirty = true;
        this._sizeDirty = true;
        this._contentDirty = true;
        this._matrix = null;
        this._opacity = null;
        this._origin = null;
        this._size = null;
    }

    /**
     * Apply changes from this component to the corresponding document element.
     * This includes changes to classes, styles, size, content, opacity, origin,
     * and matrix transforms.
     *
     * @private
     * @method commit
     * @param {Context} context commit context
     */
    public function commit(context:NodeContext) {
        if (this._currTarget == null) {
			this.setup(context.allocator);
		}
        var target = this._currTarget;

        var matrix = context.transform;
        var opacity = context.opacity;
        var origin = context.origin;
        var size = context.size;

        if (this._classesDirty) {
            _cleanupClasses(target);
            var classList = this.getClassList();
            for (clazz in classList) {
				target.classList.add(clazz);
			}
            this._classesDirty = false;
        }

        if (this._stylesDirty) {
            _applyStyles(target);
            this._stylesDirty = false;
        }

        if (this._contentDirty) {
            this.deploy(target);
            this.eventHandler.emit('deploy');
            this._contentDirty = false;
        }
		
        if (this.size != null) {
            var origSize = size;
            size = [this.size[0], this.size[1]];
            if (size[0] == null && origSize[0] != 0) size[0] = origSize[0];
            if (size[1] == null && origSize[1] != 0) size[1] = origSize[1];
        }
		
		if (Math.isNaN(size[0])) size[0] = target.clientWidth;
        if (Math.isNaN(size[1])) size[1] = target.clientHeight;
		
        if (_xyNotEquals(this._size, size)) {
            if (this._size == null) this._size = [0, 0];
            this._size[0] = size[0];
            this._size[1] = size[1];
            this._sizeDirty = true;
        }

        if (matrix == null && this._matrix != null) {
            this._matrix = null;
            this._opacity = 0;
            _setInvisible(target);
            return;
        }

        if (this._opacity != opacity) {
            this._opacity = opacity;
            target.style.opacity = (opacity >= 1) ? '0.999999' : Std.string(opacity);
        }

        if (_xyNotEquals(this._origin, origin) || Transform.notEquals(this._matrix, matrix) || this._sizeDirty) {
            if (matrix == null) {
				matrix = Transform.identity;
			}
            this._matrix = matrix;
            var aaMatrix = matrix;
            if (origin != null) {
                if (this._origin == null) {
					this._origin = [0, 0];
				}
                this._origin[0] = origin[0];
                this._origin[1] = origin[1];
                aaMatrix = Transform.thenMove(matrix, [-this._size[0] * origin[0], -this._size[1] * origin[1], 0]);
                _setOrigin(target, origin);
            }
            _setMatrix(target, aaMatrix);
        }

        if (this._sizeDirty != null) {
            if (this._size != null) {
                target.style.width = (this.size != null && Math.isNaN(this.size[0])) ? '' : this._size[0] + 'px';
                target.style.height = (this.size != null && Math.isNaN(this.size[1])) ?  '' : this._size[1] + 'px';
            }
            this._sizeDirty = false;
        }
    }

    /**
     *  Remove all Famous-relevant attributes from a document element.
     *    This is called by SurfaceManager's detach().
     *    This is in some sense the reverse of .deploy().
     *
     * @private
     * @method cleanup
     * @param {ElementAllocator} allocator
     */
    public function cleanup(allocator:Dynamic) {
        var i = 0;
        var target = this._currTarget;
        this.eventHandler.emit('recall');
        this.recall(target);
        target.style.display = 'none';
        target.style.width = '';
        target.style.height = '';
        this._size = null;
        _cleanupStyles(target);
        var classList = this.getClassList();
        _cleanupClasses(target);
        for (clazz in classList) {
			target.classList.remove(clazz);
		}
        if (this.elementClass != null) {
            if (Std.is(this.elementClass, Array)) {
				var clazzes:Array<String> = cast this.elementClass;
                for (clazz in clazzes) {
                    target.classList.remove(clazz);
                }
            }
            else {
                target.classList.remove(this.elementClass);
            }
        }
        _removeEventListeners(target);
        this._currTarget = null;
        allocator.deallocate(target);
        _setInvisible(target);
    }

    /**
     * Place the document element that this component manages into the document.
     *
     * @private
     * @method deploy
     * @param {Node} target document parent of this container
     */
    public function deploy(target:Dynamic) {
        var content = this.getContent();
        if (Std.is(content, js.html.Node)) {
            while (target.hasChildNodes()) {
				target.removeChild(target.firstChild);
			}
            target.appendChild(content);
        }
        else {
			target.innerHTML = cast content; // String
		}
    }

    /**
     * Remove any contained document content associated with this surface
     *   from the actual document.
     *
     * @private
     * @method recall
     */
    public function recall(target:Dynamic) {
        var df = js.Browser.document.createDocumentFragment();
        while (target.hasChildNodes()) {
			df.appendChild(target.firstChild);
		}
        this.setContent(df);
    }

    /**
     *  Get the x and y dimensions of the surface.
     *
     * @method getSize
     * @param {boolean} actual return computed size rather than provided
     * @return {Array.Number} [x,y] size of surface
     */
    public function getSize(actual:Bool):Array<Float> {
        return actual ? this._size : (this.size != null? this.size : this._size);
    }

    /**
     * Set x and y dimensions of the surface.
     *
     * @method setSize
     * @param {Array.Number} size as [width, height]
     */
    public function setSize(size:Array<Float>) {
        this.size = (size != null)? [size[0], size[1]] : null;
        this._sizeDirty = true;
    }
}