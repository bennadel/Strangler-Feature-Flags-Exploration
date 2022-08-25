
// Import core angular modules.
import { Component } from "@angular/core";

// Import application modules.
import { FeatureFlagService } from "~/app/services/feature-flag.service";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@Component({
	selector: "app-root",
	templateUrl: "./app.component.html",
	styleUrls: [ "./app.component.less" ]
})
export class AppComponent {
	
	private featureFlagService: FeatureFlagService;

	/**
	* I initialize the ROOT component with the given dependencies.
	*/
	constructor( featureFlagService: FeatureFlagService ) {

		this.featureFlagService = featureFlagService;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get called once after the component inputs have been bound for the first time.
	*/
	public ngOnInit() : void {

		// For the demo, as we make changes to the feature flag configuration, we want to
		// announce those changes to the top window so that the non-admin view can update
		// in order to apply the new targeting to the demo users.
		this.featureFlagService.events.subscribe(
			( event ) => {

				// SECURITY: I couldn't get any origin other than "*" to work. Chrome kept
				// blocking my cross-origin requests during development (when Angular is
				// running on a different port). As such, for now, I'm using the wildcard.
				window.top!.postMessage( "adminReloaded", "*" );

			}
		);

	}

}
