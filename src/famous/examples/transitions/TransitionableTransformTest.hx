package famous.examples.transitions;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.TransitionableTransform;

/**
 * TransitionableTransform
 * --------
 *
 * TransitionableTransform is a class for transitioning 
 * the state of a Transform by transitioning its translate,
 * scale, skew and rotate components independently.
 *
 * In this example, there is a surface having its scale
 * affected by a TransitionableTransform.
 */
class TransitionableTransformTest {
	
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

		var transitionableTransform = new TransitionableTransform();
		
		var modifier = new Modifier({
			origin: [.5,.5],
			transform: transitionableTransform
		});

		surface.on("click", function(data){
			transitionableTransform.setScale([3,3,1], {duration: 3000});
		});

		mainContext.add(modifier).add(surface);
	}
	
}