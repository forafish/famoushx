package famous.examples.transitions;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.TweenTransition;

/**
 * Transitionable
 * --------
 *
 * Transitionable is  state maintainer for a smooth transition between
 * numerically-specified states. Example numeric states include floats or
 * Matrix objects. Transitionables form the basis
 * of Transform objects.
 */
class TransitionableTest {
	
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

		//set the initial value of the transtionable to the left side of the screen
		var maxOffset = 100;

		//create our transitionable
		var transitionable = new Transitionable(-maxOffset);

		//this controls the position of surface
		var modifier = new Modifier({
			origin: [.5,.5]
		});

		modifier.transformFrom(function() {
			return Transform.translate(transitionable.get(), 0, 0);
		});

		surface.on("click", function(event){
			transitionable.set(maxOffset, {curve: "easeInOut", duration: 1000});
		});

		mainContext.add(modifier).add(surface);

	}
	
}