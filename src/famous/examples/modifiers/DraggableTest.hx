package famous.examples.transitions;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.TweenTransition;

/**
 * Draggable
 * -----------
 *
 * Draggable is a modifier that allows a renderable to be
 * responsive to drag behavior.
 *
 * In this example we can see that the red surface is draggable
 * because it sits behind a draggable modifier.  It has boundaries
 * and snaps because of the options set on the draggable modifier.
 */
class DraggableTest {
	
	static function main() {
		var mainContext = Engine.createContext();

		mainContext.add(modifier).add(surface);

	}
	
}