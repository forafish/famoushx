package famous.examples.surfaces;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.surfaces.ContainerSurface;
import famous.views.ScrollView;

/**
 * ContainerSurface
 * ----------------
 * ContainerSurface is an object designed to contain surfaces and 
 * set properties to be applied to all of them at once.
 * A container surface will enforce these properties on the 
 * surfaces it contains:
 * 
 * - size (clips contained surfaces to its own width and height)
 * 
 * - origin
 * 
 * - its own opacity and transform, which will be automatically 
 *   applied to  all Surfaces contained directly and indirectly.
 *
 * In this example we have a ContainerSurface that contains a Scrollview.
 * Because the ContainerSurface creates its own context the
 * Scrollview will behave according to the size of the ContainerSurface
 * it exists within.  The ContainerSurface having the an overflow of
 * 'hidden' means that the scrollview overflow will be hidden.
 */
class ContainerSurfaceTest {

	static function main() {
		var mainContext = Engine.createContext();

		var container = new ContainerSurface({
			size: [400, 400],
			properties: {
				overflow: 'hidden'
			}
		});

		var surfaces = [];
		var scrollview = new ScrollView();

		var temp;
		for (i in 0...100) {
			temp = new Surface({
				size: [null, 50],
				content: 'I am surface: ' + (i + 1),
				classes: ['red-bg'],
				properties: {
					textAlign: 'center',
					lineHeight: '50px'
				}
			});

			temp.pipe(scrollview);
			surfaces.push(temp);
		}

		scrollview.sequenceFrom(surfaces);
		container.add(scrollview);

		mainContext.add(new Modifier({origin: [.5, .5]})).add(container);
	}
	
}