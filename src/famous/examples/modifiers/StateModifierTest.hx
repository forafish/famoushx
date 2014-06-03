package famous.examples.modifiers;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.transitions.Transitionable;
import famous.transitions.TweenTransition;
import famous.modifiers.Draggable;
import famous.modifiers.StateModifier;

class StateModifierTest {
	
	static function main() {
		// create the main context
		var mainContext = Engine.createContext();
		
		var mySurface = new Surface({
			size: [100, 100],
			properties: {
				backgroundColor: '#fa5c4f',
				lineHeight: '100px',
				textAlign: 'center',
				color: '#eee'
			},
			content: 'Click Me'
		});

		var myModifier = new StateModifier({
			origin: [0.5, 0.5]
		});
	   
		mainContext.add(myModifier).add(mySurface);

		Engine.on('click', function(event) {
			myModifier.halt();
			myModifier.setTransform(
				Transform.rotateZ(Math.random() * Math.PI / 2),
				{ curve: 'easeOut', duration: 5000 }
			);
		});
	}
	
}