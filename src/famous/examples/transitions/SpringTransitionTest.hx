package famous.examples.transitions;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.SpringTransition;

/**
 * SpringTransition
 * --------
 *
 * SpringTransition is a method of transitioning between two values (numbers,
 * or arrays of numbers) with a bounce. The transition will overshoot the target
 * state depending on the parameters of the transition.
 *
 * In this example, there is a surface attached to a SpringTransition.
 */
class SpringTransitionTest {
	
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

		Transitionable.registerMethod('spring', SpringTransition);
		var transition = {
			method: "spring",
			period: 1000,
			dampingRatio: .1,
			velocity: 0
		}

		surface.on("click", function(event){
			modifier.setTransform(Transform.translate(0,0,0),transition);
		});
		
		mainContext.add(modifier).add(surface);
	}
	
}