package famous.examples.transitions;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.WallTransition;

/**
 * WallTransition
 * --------
 *
 * WallTransition is a method of transitioning between two values (numbers,
 * or arrays of numbers) with a bounce. Unlike a SpringTransition
 * The transition will not overshoot the target, but bounce back against it.
 * The behavior of the bounce is specified by the transition options.
 *
 * In this example, there is a surface attached to a WallTransition.
 */
class WallTransitionTest {
	
	static function main() {
		// create the main context
		var mainContext = Engine.createContext();

		var surface = new Surface({
			size:[100,100],
			content: 'Click Me',
			classes: ['red-bg'],
			properties: {
				textAlign: 'center',
				lineHeight: '100px'
			}
		});

		var modifier = new Modifier({
			origin: [.5,.5],
			transform: Transform.translate(0,-240,0)
		});

		Transitionable.registerMethod('wall', WallTransition);

		var transition = {
			method: 'wall',
			period: 1000,
			dampingRatio : 0,
			velocity: 0,
			restitution : .5 //how bouncy the wall is
		};

		surface.on("click", function(event){
			modifier.setTransform(Transform.translate(0,0,0),transition);
		});

		mainContext.add(modifier).add(surface);
	}
	
}