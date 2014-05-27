package famous.examples.views;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.views.HeaderFooterLayout;

/**
 * HeaderFooterLayout with sized modifier
 * ---------------------------------------
 *
 * HeaderFooterLayout will respect the size of any parent
 * sizing.  When is sits below a modifier with a set size,
 * it will fit the size of the modifier instead of the
 * context's size.
 *
 * In this example, we have a HeaderFooterLayout sit below a 
 * sized modifier in the render tree with a rotation applied
 * as well.
 */
class HeaderFooterLayoutWithSizedModifierTest {

	static function main() {
		var mainContext = Engine.createContext();

		var layout = new HeaderFooterLayout({
			headerSize: 100,
			footerSize: 50
		});

		layout.header.add(new Surface({
			size: [null, 100],
			content: "Header",
			classes: ["red-bg"],
			properties: {
				lineHeight: "100px",
				textAlign: "center"
			}
		}));

		layout.content.add(new Surface({
			size: [null, null],
			content: "Content",
			classes: ["grey-bg"],
			properties: {
				lineHeight: '150px',
				textAlign: "center"
			}
		}));

		layout.footer.add(new Surface({
			size: [null, 50],
			content: "Footer",
			classes: ["red-bg"],
			properties: {
				lineHeight: "50px",
				textAlign: "center"
			}
		}));

		mainContext.add(new Modifier({
			transform: Transform.rotateZ(.7),
			size: [300, 300], 
			origin: [.5, .5]
		})).add(layout);
	}
	
}