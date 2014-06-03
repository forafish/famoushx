package famous.surfaces;

import famous.core.Surface;

/**
 * A surface containing image content.
 *   This extends the Surface class.
 */
class ImageSurface extends Surface {

	var _imageUrl:String;
	
    /**
     * @constructor
     * @param {Object} [options] overrides of default options
     */
	public function new(?options:SurfaceOptions) {
        super(options);
		
		this.elementType = "img";
        this._imageUrl = null;
	}
	
    /**
     * Set content URL.  This will cause a re-rendering.
     * @method setContent
     * @param {string} imageUrl
     */
    override public function setContent(imageUrl:String) {
        this._imageUrl = imageUrl;
        this._contentDirty = true;
    }

    /**
     * Place the document element that this component manages into the document.
     *
     * @private
     * @method deploy
     * @param {Node} target document parent of this container
     */
    override public function deploy(target:Dynamic) {
        target.src = this._imageUrl != null? this._imageUrl : '';
    }

    /**
     * Remove this component and contained content from the document
     *
     * @private
     * @method recall
     *
     * @param {Node} target node to which the component was deployed
     */
    override public function recall(target) {
        target.src = '';
    }	
}