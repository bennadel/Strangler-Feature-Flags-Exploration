
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
	selector: "app-settings-view",
	templateUrl: "./settings-view.component.html",
	styleUrls: [ "./settings-view.component.less" ]
})
export class SettingsViewComponent {

	private activatedRoute: ActivatedRoute;
	private errorService: ErrorService;
	private featureFlagService: FeatureFlagService;
	private router: Router;

	public errorMessage: string | null;
	public featureFlag: FeatureFlags.FeatureFlag | null;
	public form: {
		name: string;
		description: string;
	};
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
		this.errorMessage = null;
		this.featureFlag = null;
		this.form = {
			name: "",
			description: ""
		};

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get called once after the component inputs have been bound for the first time.
	*/
	public ngOnInit() : void {

		// CAUTION: The observer callback will be fired immediately. As such, let's defer
		// any remote data fetching to the callback so that we don't end up loading data
		// more than once.
		this.activatedRoute.params.subscribe( this.handleRouteChange );

	}


	/**
	* I submit the new settings for processing.
	*/
	public submitForm() : void {

		if ( this.isProcessing ) {

			return;

		}

		this.isProcessing = true;
		this.errorMessage = null;

		this.featureFlagService
			.updateFeatureFlagSettings({
				key: this.key,
				name: this.form.name,
				description: this.form.description
			})
			.then(
				() => {

					this.isProcessing = false;
					this.router.navigate([ "/feature-flag", this.key, "targeting" ]);

				},
				( error ) => {

					this.isProcessing = false;
					this.errorMessage = this.errorService.getMessage( error );
					this.errorService.handleError( error );

				}
			)
		;

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

					this.form.name = this.featureFlag.name;
					this.form.description = this.featureFlag.description;

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
