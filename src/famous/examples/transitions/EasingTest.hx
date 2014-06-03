package famous.examples.transitions;

import famous.core.Engine;
import famous.core.Modifier;
import famous.core.Surface;
import famous.core.Transform;
import famous.surfaces.ContainerSurface;
import famous.views.ScrollView;
import famous.transitions.Easing;
import famous.transitions.Transitionable;

/**
 * Easing
 * --------
 *
 * Easing is a library of curves which map an animation
 * explicitly as a function of time.
 *
 * In this example we have a red ball that transitions from
 * the top of the box to the middle based on various easing
 * curves.
 */
class EasingTest {
	
	static function main() {
		// create the main context
		var mainContext = Engine.createContext();

	   //create the dot
		var surface = new Surface({
			size:[100,100],
			classes: ['red-bg']
		});

		var modifier:Modifier = new Modifier({
			origin: [.5,.5],
			transform: Transform.translate(100,-240,0)
		});

		mainContext.add(modifier).add(surface);

		//This is where the meat is
		function _playCurve(curve:EaseFunction, data:Dynamic){
			modifier.setTransform(Transform.translate(100,-240,0));
			modifier.setTransform(
				Transform.translate(100,0,0), 
				{curve: curve, duration: 1000}
			);
		}

		//Create a scroll view to let the user play with the different easing curves available.
		var curves = [];
		for(curve in Easing.cuves.keys()){
			var surface = new Surface({
				size:[200,40],
				content: "<h3>" + curve + "</h3>",
				properties: {color:"#3cf"}
			});

			curves.push(surface);
			surface.on("click", 
				_playCurve.bind(Easing.cuves[curve])
			);
		}

		//this will hold and clip the scroll view
		var scrollContainer = new ContainerSurface({
			size: [200,480],
			properties: {
				overflow:"hidden",
				border: "1px solid rgba(255,255,255, .8)",
				borderRadius: "10px 0px 0px 10px"
			}
		});

		//the actual scroll view
		var scrollView = new ScrollView({
			clipSize: 460
		});

		//set where the items come from 
		scrollView.sequenceFrom(curves);

		//give the scroll view input
		scrollContainer.pipe(scrollView);

		//add the scrollview to the scroll container
		scrollContainer.add(new Modifier({transform: Transform.translate(20,0,0)})).add(scrollView);
		
		//finally add the scroll container to the context
		mainContext.add(new Modifier({origin: [.5,.5], transform: Transform.translate(-240,0,0)})).add(scrollContainer);

	}
	
}