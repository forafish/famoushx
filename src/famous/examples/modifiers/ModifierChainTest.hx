package famous.examples.modifiers;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.TweenTransition;
import famous.modifiers.Draggable;
import famous.modifiers.ModifierChain;

/**
 * ModifierChain
 * -------------
 * 
 * ModifierChain is a class to add and remove a chain of modifiers
 * at a single point in the render tree.  Because it add exists 
 * in a single element, it has slight performance benefits over 
 * chaining individual modifiers.
 *
 * In the example, you can see that on the click event we are able
 * to remove a modifier after it has been added to the render tree.
 */
class ModifierChainTest {
	
	static function main() {
		var mainContext = Engine.createContext();

		var modifierChain = new ModifierChain();

		var modifierOne = new Modifier({
			origin: [0.5, 0.5]
		});

		var modifierTwo = new Modifier({
			transform: Transform.translate(0, 100, 0)
		});
		
		var surface = new Surface({
			size: [200, -1],
			content: "Click me to remove the center origin modifier",
			classes: ["red-bg"],
			properties: {
				textAlign: "center",
			}
		});

		modifierChain.addModifier(modifierOne);
		modifierChain.addModifier(modifierTwo);
		mainContext.add(modifierChain).add(surface);

		surface.on('click', function(event) {
			modifierChain.removeModifier(modifierOne);
			surface.setContent('Success!');
		});

	}
	
}