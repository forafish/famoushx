package famous.examples.modifiers;

import famous.core.Engine;
import famous.core.Surface;
import famous.core.Transform;
import famous.modifiers.StateModifier;
import famous.transitions.Easing;

class HaltWithChainingTest {
	
	static function main() {
		var mainContext = Engine.createContext();

		var surface = new Surface({
		  size: [100, 100],
		  content: 'click me to halt',
		  properties: {
			color: 'white',
			textAlign: 'center',
			backgroundColor: '#FA5C4F'
		  }
		});

		var stateModifier = new StateModifier({
		  origin: [0.5, 0]
		});

		mainContext.add(stateModifier).add(surface);

		stateModifier.setTransform(
		  Transform.translate(0, 400, 0),
		  { duration : 8000, curve: 'linear' }
		);

		surface.on('click', function(event) {
		  stateModifier.halt();
		  surface.setContent('halted');
		  stateModifier.setTransform(
			Transform.translate(0, 400, 0),
			{ duration : 400, curve: Easing.outBounce }
		  );
		});
	}
	
}