
// Import core angular modules.
import { ActivatedRoute } from "@angular/router";
import { Component } from "@angular/core";
import { Params } from "@angular/router";
import { Router } from "@angular/router";
import { Subscription } from "rxjs";

// Import application modules.
import { ErrorService } from "~/app/services/error.service";
import { FeatureFlags } from "~/app/services/feature-flag.service";
import { FeatureFlagService } from "~/app/services/feature-flag.service";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@Component({
	selector: "app-detail-view",
	templateUrl: "./detail-view.component.html",
	styleUrls: [ "./detail-view.component.less" ]
})
export class DetailViewComponent {

	private activatedRoute: ActivatedRoute;
	private errorService: ErrorService;
	private featureFlagService: FeatureFlagService;
	private featureFlagEventsSubscription: Subscription | null;
	private router: Router;

	public featureFlag: FeatureFlags.FeatureFlag | null;
	public isLoading: boolean;
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
		this.featureFlag = null;
		this.featureFlagEventsSubscription = null;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get called once when the component is being destroyed.
	*/
	public ngOnDestroy() : void {

		this.featureFlagEventsSubscription?.unsubscribe();

	}


	/**
	* I get called once after the component inputs have been bound for the first time.
	*/
	public ngOnInit() : void {

		// CAUTION: The observer callback will be fired immediately. As such, let's defer
		// any remote data fetching to the callback so that we don't end up loading data
		// more than once.
		this.activatedRoute.params.subscribe( this.handleRouteChange );

		// When the feature flag settings are changed in the child-routes, we want to
		// quietly reload our data in the background in order to show the new settings.
		this.featureFlagEventsSubscription = this.featureFlagService.events.subscribe(
			( event ) => {

				// NOTE: Normally, I'd want to check to see which key is associated with
				// the current event. However, in this demo, we know that this event is a
				// client-side event, so it will only ever apply to the currently-rendered
				// feature flag. As such, for the demo, we can skip any checks and keep
				// things simple.
				this.loadRemoteDataInBackground();

			}
		);

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

		this.featureFlagService
			.getFeatureFlag( this.key )
			.then(
				( response ) => {

					this.isLoading = false;
					this.featureFlag = response.featureFlag;

				},
				( error ) => {

					this.router.navigateByUrl( "/" );
					this.errorService.handleError( error );

				}
			)
		;

	}


	/**
	* I quietly reload the remote data in the background without setting the isLoading
	* flag.
	*/
	private loadRemoteDataInBackground() : void {

		this.featureFlagService
			.getFeatureFlag( this.key )
			.then(
				( response ) => {

					this.featureFlag = response.featureFlag;

				},
				( error ) => {

					this.errorService.handleError( error );

				}
			)
		;

	}

}
