
/**
* I intercept the form submission event in order to add the current window scroll to the
* form action URL (and current location). Then, on page load, I scroll the window back
* down to the desired offset. This allows the UI to remain "in place" across page loads.
*/
function setupFormScroll( selector ) {

	var desiredScroll = +window.location.hash.slice( 1 );

	// Scroll the user back down to the offset of the previous page rendering.
	if ( desiredScroll ) {

		window.scrollTo( 0, desiredScroll );

	}

	// Setup the submission handler to store the scroll.
	var form = document.querySelector( selector || "form" );

	form.addEventListener( "submit", handleSubmitEvent );


	function handleSubmitEvent( event ) {

		// If the form submission event is a "save" action, then we DO NOT want to re-
		// scroll the window down to the previous offset since any error message is going
		// to be shown at the top of the window.
		window.location.hash = isSaveEvent( event, "save" )
			? ""
			: window.pageYOffset
		;

		form.setAttribute( "action", window.location.href );

	}

}


function setupXEnterActions() {

	var inputs = document.querySelectorAll( "[x-enter-action]" );

	Array.from( inputs ).forEach(
		function iterator( input ) {

			input.addEventListener( "keydown", handleEnterEvent );

		}
	);


	function handleEnterEvent( event ) {

		if ( event.key !== "Enter" ) {

			return;

		}

		event.preventDefault();

		var action = event.target.getAttribute( "x-enter-action" );
		var button = document.querySelector( "button[value='" + action + "']" );

		button.click();		

	}

}


/**
* I try to determine if the given event is a "save" event vs. an in-place mutation.
*/
function isSaveEvent( event, saveValue ) {

	// CAUTION: The "event.submitter" property is a relatively new property in the form
	// submission event. As such, let's check to make sure it exists before we try to
	// reference its value. If the property does NOT exist, then we're going to consider
	// every submission a SAVE event; this way, the new property becomes a progressive
	// enhancement for newer browsers.
	return( ! event.submitter || ( event.submitter.value === saveValue ) );

}
