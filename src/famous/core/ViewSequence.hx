package famous.core;

/**
 * Helper object used to iterate through items sequentially. Used in
 *   views that deal with layout.  A ViewSequence object conceptually points
 *   to a node in a linked list.
 */
class ViewSequence {

	public var _:Backing;
	public var index:Int;

	public var _previousNode:Dynamic;
	public var _nextNode:Dynamic;

    /**
     * @constructor
     * @param {Object|Array} options Options object, or content array.
     * @param {Number} [options.index] starting index.
     * @param {Number} [options.array] Array of elements to populate the ViewSequence
     * @param {Object} [options._] Optional backing store (internal
     * @param {Boolean} [options.loop] Whether to wrap when accessing elements just past the end
     *   (or beginning) of the sequence.
     */
	public function new(options:Dynamic) {
        if (options == null) {
			options = [];
		}
        if (Std.is(options, Array)) {
			options = {array: options};
		}

        this._ = null;
        this.index = (options.index != null)? options.index : 0;

        if (options.array != null) {
			this._ = new Backing(options.array);
		}
        else if (options._ != null) {
			this._ = options._;
		}

        if (this.index == this._.firstIndex) {
			this._.firstNode = this;
		}
        if (this.index == this._.firstIndex + this._.array.length - 1) {
			this._.lastNode = this;
		}

        if (options.loop != null) {
			this._.loop = options.loop;
		}

        this._previousNode = null;
        this._nextNode = null;
	}
	
    /**
     * Return ViewSequence node previous to this node in the list, respecting looping if applied.
     *
     * @method getPrevious
     * @return {ViewSequence} previous node.
     */
    public function getPrevious():ViewSequence {
        if (this.index == this._.firstIndex) {
            if (this._.loop) {
                this._previousNode = (this._.lastNode != null)? this._.lastNode 
					: new ViewSequence({_: this._, index: this._.firstIndex + this._.array.length - 1});
                this._previousNode._nextNode = this;
            }
            else {
                this._previousNode = null;
            }
        }
        else if (this._previousNode == null) {
            this._previousNode = new ViewSequence({_: this._, index: this.index - 1});
            this._previousNode._nextNode = this;
        }
        return this._previousNode;
    }

    /**
     * Return ViewSequence node next after this node in the list, respecting looping if applied.
     *
     * @method getNext
     * @return {ViewSequence} previous node.
     */
    public function getNext():ViewSequence {
        if (this.index == this._.firstIndex + this._.array.length - 1) {
            if (this._.loop) {
                this._nextNode = (this._.firstNode != null)? this._.firstNode 
					: new ViewSequence({_: this._, index: this._.firstIndex});
                this._nextNode._previousNode = this;
            }
            else {
                this._nextNode = null;
            }
        }
        else if (this._nextNode == null) {
            this._nextNode = new ViewSequence({_: this._, index: this.index + 1});
            this._nextNode._previousNode = this;
        }
        return this._nextNode;
    }

    /**
     * Return index of this ViewSequence node.
     *
     * @method getIndex
     * @return {Number} index
     */
    public function getIndex() {
        return this.index;
    }

    /**
     * Return printable version of this ViewSequence node.
     *
     * @method toString
     * @return {string} this index as a string
     */
    public function toString() {
        return '' + this.index;
    }

    /**
     * Add one or more objects to the beginning of the sequence.
     *
     * @method unshift
     * @param {...Object} value arguments array of objects
     */
    public function unshift(values:Array<ViewSequence>) {
		for (v in values) {
			this._.array.unshift(v);
		}
        this._.firstIndex -= values.length;
    }

    /**
     * Add one or more objects to the end of the sequence.
     *
     * @method push
     * @param {...Object} value arguments array of objects
     */
    public function push(values:Array<ViewSequence>) {
		for (v in values) {
			this._.array.push(v);
		}
    }

    /**
     * Remove objects from the sequence
     *
     * @method splice
     * @param {Number} index starting index for removal
     * @param {Number} howMany how many elements to remove
     * @param {...Object} value arguments array of objects
     */
	public function splice(index:Int, howMany:Int, values:Array<ViewSequence>) {
        this._.array.splice(index - this._.firstIndex, howMany);
		for (i in 0...values.length) {
			this._.array.insert(index - this._.firstIndex + i, values[i]);
		}
        this._.reindex(index, howMany, values.length);
    };


    /**
     * Exchange this element's sequence position with another's.
     *
     * @method swap
     * @param {ViewSequence} other element to swap with.
     */
	public function swap(other:ViewSequence) {
        var otherValue = other.get();
        var myValue = this.get();
        this._.setValue(this.index, otherValue);
        this._.setValue(other.index, myValue);

        var myPrevious = this._previousNode;
        var myNext = this._nextNode;
        var myIndex = this.index;
        var otherPrevious = other._previousNode;
        var otherNext = other._nextNode;
        var otherIndex = other.index;

        this.index = otherIndex;
        this._previousNode = (otherPrevious == this) ? other : otherPrevious;
        if (this._previousNode != null) {
			this._previousNode._nextNode = this;
		}
        this._nextNode = (otherNext == this) ? other : otherNext;
        if (this._nextNode != null) {
			this._nextNode._previousNode = this;
		}

        other.index = myIndex;
        other._previousNode = (myPrevious == other) ? this : myPrevious;
        if (other._previousNode != null) {
			other._previousNode._nextNode = other;
		}
        other._nextNode = (myNext == other) ? this : myNext;
        if (other._nextNode != null) {
			other._nextNode._previousNode = other;
		}

        if (this.index == this._.firstIndex) {
			this._.firstNode = this;
		}
        else if (this.index == this._.firstIndex + this._.array.length - 1) {
			this._.lastNode = this;
		}
		
        if (other.index == this._.firstIndex) {
			this._.firstNode = other;
		}
        else if (other.index == this._.firstIndex + this._.array.length - 1) {
			this._.lastNode = other;
		}
    }
	
	/**
     * Return value of this ViewSequence node.
     *
     * @method get
     * @return {Object} value of thiss
     */
    public function get() {
        return this._.getValue(this.index);
    }

   /**
     * Call getSize() on the contained View.
     *
     * @method getSize
     * @return {Array.Number} [width, height]
     */
	public function getSize():Array<Float> {
        var target = this.get();
        return target != null? target.getSize() : null;
    }

    /**
     * Generate a render spec from the contents of this component.
     * Specifically, this will render the value at the current index.
     * @private
     * @method render
     * @return {number} Render spec for this component
     */
    public function render() {
        var target = this.get();
        return target != null? target.render() : null;
    }
}

// constructor for internal storage
class Backing {
	public var array:Array<ViewSequence>;
	public var firstIndex:Int;
	public var loop:Bool;
	public var firstNode:ViewSequence;
	public var lastNode:ViewSequence;
	
	public function new(array:Array<ViewSequence>) {
        this.array = array;
        this.firstIndex = 0;
        this.loop = false;
        this.firstNode = null;
        this.lastNode = null;
	}
	
    // Get value "i" slots away from the first index.
    public function getValue(i:Int) {
        var _i = i - this.firstIndex;
        if (_i < 0 || _i >= this.array.length) return null;
        return this.array[_i];
    }

    // Set value "i" slots away from the first index.
    public function setValue(i:Int, value:Dynamic) {
        this.array[i - this.firstIndex] = value;
    }

    // After splicing into the backing store, restore the indexes of each node correctly.
    public function reindex(start:Int, removeCount:Int, insertCount:Int) {
		if (this.array[0] == null) {
			return;
		}
		
        var i = 0;
        var index = this.firstIndex;
        var indexShiftAmount = insertCount - removeCount;
        var node = this.firstNode;

        // find node to begin
        while (index < start - 1) {
            node = node.getNext();
            index++;
        }
        // skip removed nodes
        var spliceStartNode = node;
        for (i in 0...removeCount) {
            node = node.getNext();
            if (node != null) {
				node._previousNode = spliceStartNode;
			}
        }
        var spliceResumeNode = node != null? node.getNext() : null;
        // generate nodes for inserted items
        spliceStartNode._nextNode = null;
        node = spliceStartNode;
        for (i in 0...insertCount) {
			node = node.getNext();
		}
        index += insertCount;
        // resume the chain
        if (node != spliceResumeNode) {
            node._nextNode = spliceResumeNode;
            if (spliceResumeNode != null) {
				spliceResumeNode._previousNode = node;
			}
        }
        if (spliceResumeNode != null) {
            node = spliceResumeNode;
            index++;
            while (node != null && index < this.array.length + this.firstIndex) {
                if (node._nextNode != null) {
					node.index += indexShiftAmount;
				}
                else {
					node.index = index;
				}
                node = node.getNext();
                index++;
            }
        }
    }
}