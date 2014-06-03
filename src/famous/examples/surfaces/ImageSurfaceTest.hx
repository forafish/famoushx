package famous.examples.surfaces;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.surfaces.ImageSurface;

/**
 * ImageSurface
 * ------------
 *
 * ImageSurface is the same interface as a regular Surface
 * except that it will create an img tag instead of a
 * div tag.  When you call setContent on an ImageSurface,
 * it will change the src property of the tag.
 *
 * In this example we have an ImageSurface with the
 * Famo.us logo as it's content.
 */
class ImageSurfaceTest {

	static function main() {
		var mainCtx = Engine.createContext();

		var image = new ImageSurface({
			size: [200, 200]
		});

		image.setContent("images/famous_logo.png");

		mainCtx.add(new Modifier({origin: [.5, .5]})).add(image);
	}
	
}