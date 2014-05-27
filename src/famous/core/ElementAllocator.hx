package famous.core;

/**
 * Internal helper object to Context that handles the process of
 *   creating and allocating DOM elements within a managed div.
 *   Private.
 */
class ElementAllocator {

	public var container:js.html.Node;
	public var detachedNodes:Map<String, Array<js.html.Node>>;
	public var nodeCount:Int;

    /**
     * @constructor
     * @private
     * @param {Node} container document element in which Famo.us content will be inserted
     */
	public function new(container:js.html.Node) {
        if (container == null) {
			container = js.Browser.document.createDocumentFragment();
		}
        this.container = container;
        this.detachedNodes = new Map();
        this.nodeCount = 0;
	}
	
    /**
     * Move the document elements from their original container to a new one.
     *
     * @private
     * @method migrate
     *
     * @param {Node} container document element to which Famo.us content will be migrated
     */
    public function migrate(container:js.html.Node) {
        var oldContainer = this.container;
        if (container == oldContainer) {
			return;
		}

        if (Std.is(oldContainer, js.html.DocumentFragment)) {
            container.appendChild(oldContainer);
        } else {
            while (oldContainer.hasChildNodes()) {
                container.appendChild(oldContainer.removeChild(oldContainer.firstChild));
            }
        }

        this.container = container;
    }

    /**
     * Allocate an element of specified type from the pool.
     *
     * @private
     * @method allocate
     *
     * @param {string} type type of element, e.g. 'div'
     * @return {Node} allocated document element
     */
    public function allocate(type:String):js.html.Node {
        type = type.toLowerCase();
        if (!this.detachedNodes.exists(type)) {
			this.detachedNodes[type] = [];
		}
        var nodeStore = this.detachedNodes[type];
        var result;
        if (nodeStore.length > 0) {
            result = nodeStore.pop();
        }
        else {
            result = js.Browser.document.createElement(type);
            this.container.appendChild(result);
        }
        this.nodeCount++;
        return result;
    }

    /**
     * De-allocate an element of specified type to the pool.
     *
     * @private
     * @method deallocate
     *
     * @param {Node} element document element to deallocate
     */
    public function deallocate(element:js.html.Node) {
        var nodeType = element.nodeName.toLowerCase();
        var nodeStore = this.detachedNodes[nodeType];
        nodeStore.push(element);
        this.nodeCount--;
    }

    /**
     * Get count of total allocated nodes in the document.
     *
     * @private
     * @method getNodeCount
     *
     * @return {Number} total node count
     */
    public function getNodeCount():Int {
        return this.nodeCount;
    }	
}