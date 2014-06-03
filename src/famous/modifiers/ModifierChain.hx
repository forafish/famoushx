package famous.modifiers;

import famous.core.Modifier;

/**
 * A class to add and remove a chain of modifiers
 *   at a single point in the render tree
 */
class ModifierChain {

	var _chain:Array<Modifier>;
	
    /**
     * @constructor
     */
	public function new(?modifiers:Array<Modifier>) {
		this._chain = [];
        if (modifiers != null) {
			for (modifier in modifiers) {
				addModifier(modifier);
			}
		}
	}
	
    /**
     * Add a modifier, or comma separated modifiers, to the modifier chain.
     *
     * @method addModifier
     *
     * @param {...Modifier*} varargs args list of Modifiers
     */
    public function addModifier(modifier:Modifier) {
        this._chain.push(modifier);
    }

    /**
     * Remove a modifier from the modifier chain.
     *
     * @method removeModifier
     *
     * @param {Modifier} modifier
     */
    public function removeModifier(modifier:Modifier) {
        var index = this._chain.indexOf(modifier);
        if (index < 0) return;
        this._chain.splice(index, 1);
    }

    /**
     * Return render spec for this Modifier, applying to the provided
     *    target component.  This is similar to render() for Surfaces.
     *
     * @private
     * @method modify
     *
     * @param {Object} input (already rendered) render spec to
     *    which to apply the transform.
     * @return {Object} render spec for this Modifier, including the
     *    provided target
     */
    public function modify(input:Dynamic):ModifyOptions {
        var result = input;
        for (modifier in this._chain) {
            result = modifier.modify(result);
        }
        return result;
    }	
}