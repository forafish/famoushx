package famous.examples.modifiers;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.TweenTransition;
import famous.modifiers.Draggable;

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

		//show a grid for reference
		var grid = new Surface({
			size: [481,481],
			classes: ['graph']
		});

		var draggable = new Draggable({
			snapX: 40, 
			snapY: 40, 
			xRange: [-220, 220],
			yRange: [-220, 220]
		});

		var surface = new Surface({
			size: [40, 40],
			content: 'drag',
			classes: ['red-bg'],
			properties: {
				lineHeight: '40px',
				textAlign: 'center',
				cursor: 'pointer'
			}
		});

		draggable.subscribe(surface);

		var node = mainContext.add(new Modifier({origin:[0.5,0.5]}));
		node.add(grid);
		node.add(draggable).add(surface);
	}
	
}