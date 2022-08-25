
// Import core angular modules.
import { ActivatedRoute } from "@angular/router";
import { Component } from "@angular/core";
import { Params } from "@angular/router";
import { Router } from "@angular/router";

// Import application modules.
import { ErrorService } from "~/app/services/error.service";
import { FeatureFlags } from "~/app/services/feature-flag.service";
import { FeatureFlagService } from "~/app/services/feature-flag.service";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@Component({
	selector: "app-delete-view",
	templateUrl: "./delete-view.component.html",
	styleUrls: [ "./delete-view.component.less" ]
})
export class DeleteViewComponent {

	private activatedRoute: ActivatedRoute;
	private errorService: ErrorService;
	private featureFlagService: FeatureFlagService;
	private router: Router;

	public errorMessage: string;
	public featureFlag: FeatureFlags.FeatureFlag | null;
	public isLoading: boolean;
	public isProcessing: boolean;
	public key: string;

	/**
	* I initialize the component with the given dependencies.
	*/
	constructor(
		activatedRoute: ActivatedRoute,
		errorService: ErrorService,
		featureFlagService: FeatureFlagService,
		router: Router
		) {

		this.activatedRoute = activatedRoute;
		this.errorService = errorService;
		this.featureFlagService = featureFlagService;
		this.router = router;

		this.key = "";
		this.isLoading = false;
		this.isProcessing = false;
		this.errorMessage = "";
		this.featureFlag = null;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I submit the request to delete the current feature flag.
	*/
	public deleteFeatureFlag() : void {

		if ( this.isProcessing ) {

			return;

		}

		this.isProcessing = true;
		this.errorMessage = "";

		this.featureFlagService
			.deleteFeatureFlag( this.key )
			.then(
				() => {

					this.router.navigateByUrl( "/" );

				},
				( error ) => {

					this.isProcessing = false;
					this.errorMessage = this.errorService.getMessage( error );
					this.errorService.handleError( error );

				}
			)
		;

	}


	/**
	* I get called once after the component inputs have been bound for the first time.
	*/
	public ngOnInit() : void {

		// CAUTION: The observer callback will be fired immediately. As such, let's defer
		// any remote data fetching to the callback so that we don't end up loading data
		// more than once.
		this.activatedRoute.params.subscribe( this.handleRouteChange );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I handle changes to the activated route, reloading data as necessary.
	*/
	private handleRouteChange = ( params: Params ) => {

		if ( params[ "key" ] !== this.key ) {

			this.key = params[ "key" ];
			this.loadRemoteData();

		}

	}


	/**
	* I load the remote data based on the current view-model.
	*/
	private loadRemoteData() : void {

		this.isLoading = true;
		this.featureFlag = null;

		this.featureFlagService
			.getFeatureFlag( this.key )
			.then(
				( response ) => {

					this.isLoading = false;
					this.featureFlag = response.featureFlag;

				},
				( error ) => {

					this.isLoading = false;
					this.errorMessage = this.errorService.getMessage( error );
					this.errorService.handleError( error );

				}
			)
		;

	}

}
