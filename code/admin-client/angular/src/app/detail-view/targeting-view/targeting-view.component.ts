
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

interface EnabledOption {
	label: string;
	value: boolean;
}

interface VariantRefOption {
	label: string;
	value: number;
}

interface OperatorOption {
	label: string;
	value: string;
}

interface PercentOption {
	label: string;
	value: number;
}

@Component({
	selector: "app-targeting-view",
	templateUrl: "./targeting-view.component.html",
	styleUrls: [ "./targeting-view.component.less" ]
})
export class TargetingViewComponent {

	private activatedRoute: ActivatedRoute;
	private errorService: ErrorService;
	private featureFlagService: FeatureFlagService;
	private router: Router;

	public enabledOptions: EnabledOption[];
	public errorMessage: string | null;
	public featureFlag: FeatureFlags.FeatureFlag | null;
	public form: {
		isEnabled: boolean;
		fallthroughVariantRef: number;
		rules: FeatureFlags.Rule[];
	};
	public isLoading: boolean;
	public isProcessing: boolean;
	public key: string;
	public operatorOptions: OperatorOption[];
	public percentOptions: PercentOption[];
	public stringifiedVariants: {
		[key: number]: string;
	};
	public variantRefOptions: VariantRefOption[] | null;

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
		this.enabledOptions = [
			{ label: "Enabled", value: true },
			{ label: "Disabled", value: false }
		];
		this.operatorOptions = [
			{ label: "One Of", value: "OneOf" },
			{ label: "Not One Of", value: "NotOneOf" },
			{ label: "Contains", value: "Contains" },
			{ label: "Not Contains", value: "NotContains" },
			{ label: "Ends With", value: "EndsWith" },
			{ label: "Not Ends With", value: "NotEndsWith" },
			{ label: "Starts With", value: "StartsWith" },
			{ label: "Not Starts With", value: "NotStartsWith" },
			{ label: "Greater Than", value: "GreaterThan" },
			{ label: "Less Than", value: "LessThan" },
			{ label: "Matches Regex", value: "MatchesRegex" },
			{ label: "Not Matches Regex", value: "NotMatchesRegex" }
		];
		this.percentOptions = this.buildPercentOptions();
		this.stringifiedVariants = {};
		this.variantRefOptions = null;
		this.form = {
			isEnabled: false,
			fallthroughVariantRef: 1,
			rules: []
		};

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I add a new empty rule configuration.
	*/
	public addRule() : void {

		this.form.rules.push({
			tests: [],
			rollout: {
				type: "Single",
				variantRef: 1
			}
		});

	}


	/**
	* I add a new empty user-key test to the given rule.
	*/
	public addUserKeyTest( rule: FeatureFlags.Rule ) : void {

		rule.tests.push({
			type: "UserKey",
			operation: {
				operator: "OneOf",
				values: []
			}
		});

	}


	/**
	* I add a new empty user-property test to the given rule.
	*/
	public addUserPropertyTest( rule: FeatureFlags.Rule ) : void {

		rule.tests.push({
			type: "UserProperty",
			userProperty: "",
			operation: {
				operator: "OneOf",
				values: []
			}
		});

	}


	/**
	* I add the given value to the given test-operation.
	*/
	public addValue( operation: FeatureFlags.Operation, input: HTMLInputElement ) : void {

		var value = input.value.trim();

		if ( value ) {

			operation.values.push( value );
			input.value = "";

		}

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


	/**
	* I remove the rule at the given index.
	*/
	public removeRule( index: number ) : void {

		this.form.rules.splice( index, 1 );

	}


	/**
	* I remove the test at the given index.
	*/
	public removeTest( rule: FeatureFlags.Rule, testIndex: number ) : void {

		rule.tests.splice( testIndex, 1 );

	}


	/**
	* I remove the test-value at the given index.
	*/
	public removeValue( test: FeatureFlags.Test, valueIndex: number ) : void {

		test.operation.values.splice( valueIndex, 1 );

	}


	/**
	* I submit the current feature flag targeting state for processing.
	*/
	public submitForm() : void {

		if ( this.isProcessing || ! this.featureFlag ) {

			return;

		}

		this.isProcessing = true;
		this.errorMessage = null;

		this.featureFlagService
			.updateFeatureFlagTargeting({
				key: this.key,
				rules: this.featureFlag.rules,
				fallthroughVariantRef: this.form.fallthroughVariantRef,
				isEnabled: this.form.isEnabled
			})
			.then(
				() => {

					this.isProcessing = false;
					this.loadRemoteData();
					// TODO: Toast (or something to indicate success).

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
	* I switch the given rule to using a multi-variant rollout.
	*/
	public switchRuleToMultiRollout( rule: FeatureFlags.Rule ) : void {

		rule.rollout = {
			type: "Multi",
			distribution: this.featureFlag!.variants.map(
				( variant, i ) => {

					// As we switch the options, let's default the first option to having
					// 100% of the allocation. The user will almost certainly change this;
					// but, it helps to illustrate how it works.
					var percent = ( i === 0 )
						? 100
						: 0
					;

					return({
						percent: percent,
						variantRef: ( i + 1 )
					});

				}
			)
		};

	}


	/**
	* I switch the given rule to using a single-variant rollout.
	*/
	public switchRuleToSingleRollout( rule: FeatureFlags.Rule ) : void {

		rule.rollout = {
			type: "Single",
			variantRef: 1
		};

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build the 0-100% options for the multi-rollout distribution.
	*/
	private buildPercentOptions() : PercentOption[] {

		var options = [];

		for ( var i = 0 ; i <= 100 ; i++ ) {

			options.push({
				label: ( i + "%" ),
				value: i
			});

		}

		return( options );

	}


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

					this.featureFlag.variants.forEach(
						( variant, i ) => {

							this.stringifiedVariants[ i + 1 ] = JSON.stringify( variant );

						}
					);

					this.variantRefOptions = this.featureFlag.variants.map(
						( variant, i ) => {

							return({
								label: this.stringifiedVariants[ i + 1 ],
								value: ( i + 1 )
							});

						}
					);


					this.form.isEnabled = this.featureFlag.isEnabled;
					this.form.fallthroughVariantRef = this.featureFlag.fallthroughVariantRef;
					this.form.rules = this.featureFlag.rules;

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
