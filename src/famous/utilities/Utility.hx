package famous.utilities;

import js.Browser;
import js.html.DocumentFragment;
import js.html.XMLHttpRequest;

/**
 * This namespace holds standalone functionality.
 *  Currently includes name mapping for transition curves,
 *  name mapping for origin pairs, and the after() function.
 */
class Utility {
	public static var Direction = { X: 0, Y: 1, Z: 2 };
	
    /**
     * Return wrapper around callback function. Once the wrapper is called N
     *   times, invoke the callback function. Arguments and scope preserved.
     *
     * @method after
     *
     * @param {number} count number of calls before callback function invoked
     * @param {Function} callback wrapped callback function
     *
     * @return {function} wrapped callback with coundown feature
     */
    static public function after(count:Int, callback:Void->Void) {
        var counter = count;
        return function() {
            counter--;
            if (counter == 0) {
				callback();
			}
        }
    }

    /**
     * Load a URL and return its contents in a callback
     *
     * @method loadURL
     *
     * @param {string} url URL of object
     * @param {function} callback callback to dispatch with content
     */
    static public function loadURL(url:String, callback:String->Void) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function onreadystatechange(_) {
            if (xhr.readyState == 4) {
                if (callback != null) {
					callback(xhr.responseText);
				}
            }
        };
        xhr.open('GET', url);
        xhr.send();
    }

    /**
     * Create a document fragment from a string of HTML
     *
     * @method createDocumentFragmentFromHTML
     *
     * @param {string} html HTML to convert to DocumentFragment
     *
     * @return {DocumentFragment} DocumentFragment representing input HTML
     */
    static public function createDocumentFragmentFromHTML(html):js.html.DocumentFragment {
        var element = js.Browser.document.createElement('div');
        element.innerHTML = html;
        var result = js.Browser.document.createDocumentFragment();
        while (element.hasChildNodes()) {
			result.appendChild(element.firstChild);
		}
        return result;
    }
	
}