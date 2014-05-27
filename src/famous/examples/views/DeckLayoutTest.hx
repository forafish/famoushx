package famous.examples.views;

import famous.core.Engine;
import famous.core.Surface;
import famous.core.Modifier;
import famous.views.DeckLayout;

/**
 * Deck
 * -----------
 *
 * Deck is a SequentialLayout that can be open and closed
 * with defined animations.
 *
 * In this example, we can see that when we click we end up
 * opening the decks so that their contents expand outwards.
 */
class DeckLayoutTest {

	static function main() {
		var mainContext = Engine.createContext();

		var surfaces = [];
		var myLayout = new DeckLayout({
			//itemSpacing: 10,
			transition: {
				method: 'spring',
				period: 300,
				dampingRatio: 0.5
			},
			stackRotation: 0.02
		});

		myLayout.sequenceFrom(surfaces);

		for(i in 0...5) {
			var temp = new Surface({
				size: [100, 200],
				classes: ['test'],
				properties: {
					backgroundColor: 'hsla(' + ((i*5 + i)*15 % 360) + ', 60%, 50%, 0.8)'
				},
				content: Std.string(i)
			});

			temp.on('click', function(event) {
				myLayout.toggle();
			});
			surfaces.push(temp);
		}

		var containerModifier = new Modifier({
			origin: [0.5, 0.5]
		});

		mainContext.add(containerModifier).add(myLayout);
	}
	
}