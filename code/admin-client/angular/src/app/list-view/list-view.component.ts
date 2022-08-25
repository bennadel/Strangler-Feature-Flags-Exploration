
// Import core angular modules.
import { Component } from "@angular/core";

// Import application modules.
import { ErrorService } from "~/app/services/error.service";
import { FeatureFlags } from "~/app/services/feature-flag.service";
import { FeatureFlagService } from "~/app/services/feature-flag.service";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

interface AllFeatureFlags {
	[key: string]: FeatureFlags.FeatureFlag;
}

@Component({
	selector: "app-list-view",
	templateUrl: "./list-view.component.html",
	styleUrls: [ "./list-view.component.less" ]
})
export class ListViewComponent {

	private featureFlagService: FeatureFlagService;
	private errorService: ErrorService;

	public allFeatureFlags: AllFeatureFlags | null;
	public errorMessage: string | null;
	public featureFlags: FeatureFlags.FeatureFlag[] | null;
	public isLoading: boolean;

	/**
	* I initialize the component with the given dependencies.
	*/
	constructor(
		errorService: ErrorService,
		featureFlagService: FeatureFlagService
		) {

		this.errorService = errorService;
		this.featureFlagService = featureFlagService;

		this.isLoading = false;
		this.allFeatureFlags = null;
		this.featureFlags = null;
		this.errorMessage = null;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get called once after the component inputs have been bound for the first time.
	*/
	public ngOnInit() : void {

		this.loadRemoteData();

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I load the remote data based on the current view-model.
	*/
	private loadRemoteData() : void {

		this.isLoading = true;

		this.featureFlagService.getAllFeatureFlags()
			.then(
				( response ) => {

					this.isLoading = false;
					this.allFeatureFlags = response.featureFlags;

					this.setFeatureFlags();

				},
				( error ) => {

					this.errorMessage = this.errorService.getMessage( error );
					this.errorService.handleError( error );

				}
			)
		;

	}


	/**
	* I set the feature flags based on the current view-model.
	*/
	private setFeatureFlags() : void {

		this.featureFlags = Object.values( this.allFeatureFlags ! );

	}

}
