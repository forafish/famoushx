package famous.examples.transitions;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.TweenTransition;

/**
 * TweenTransition
 * --------
 *
 * TweenTransition is a state maintainer for a smooth transition between
 * numerically-specified states.
 *
 * In this example, a surface is faded out based on a TweenTransition.
 */
class TweenTransitionTest {
	
	static function main() {
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
			transform: Transform.translate(0,0,0)
		});

		Transitionable.registerMethod('tween', TweenTransition);
		var transitionable = new Transitionable(1);

		modifier.opacityFrom(function() {
			return transitionable.get();
		});

		var transition = {
			method: 'tween',
			curve: "easeInOut",
			duration: 1500,
		};
		
		surface.on("click", function(_) {
			transitionable.set(0, transition);
		});

		mainContext.add(modifier).add(surface);

	}
	
}