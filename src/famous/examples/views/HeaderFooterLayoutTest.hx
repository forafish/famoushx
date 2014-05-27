package famous.examples.views;

import famous.core.Engine;
import famous.core.Surface;
import famous.views.HeaderFooterLayout;

/**
 * HeaderFooterLayout
 * ------------------
 *
 * HeaderFooterLayout is a layout which will arrange three renderables
 * into a header and footer area of defined size and a content area
 * of flexible size.
 *
 * In this example we create a basic HeaderFooterLayout and define a 
 * size for the header and footer
 */
class HeaderFooterLayoutTest {

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
				lineHeight: js.Browser.window.innerHeight - 150 + 'px',
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

		mainContext.add(layout);
	}
	
}