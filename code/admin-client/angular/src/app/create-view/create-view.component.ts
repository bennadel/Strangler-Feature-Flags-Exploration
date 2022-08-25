
// Import core angular modules.
import { Component } from "@angular/core";
import { Router } from "@angular/router";

// Import application modules.
import { ErrorService } from "~/app/services/error.service";
import { FeatureFlags } from "~/app/services/feature-flag.service";
import { FeatureFlagService } from "~/app/services/feature-flag.service";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

interface TypeOption {
	label: string;
	value: FeatureFlags.Type;
}

// NOTE: I'm defining the variant value as a wrapper so that when I use the ngFor to
// stamp-out the inputs/ngModel bindings, the ngFor has an object reference not a raw
// value. This will keep the DOM elements in place while the inputs are being updated.
interface VariantWrapper {
	value: string;
}

@Component({
	selector: "app-create-view",
	templateUrl: "./create-view.component.html",
	styleUrls: [ "./create-view.component.less" ]
})
export class CreateViewComponent {

	private errorService: ErrorService;
	private featureFlagService: FeatureFlagService;
	private router: Router;

	public errorMessage: string | null;
	public form: {
		key: string;
		name: string;
		description: string;
		selectedTypeOption: TypeOption;
		variants: VariantWrapper[];
		fallthroughVariantRef: number;
	};
	public isProcessing: boolean;
	public typeOptions: TypeOption[];

	/**
	* I initialize the component with the given dependencies.
	*/
	constructor(
		errorService: ErrorService,
		featureFlagService: FeatureFlagService,
		router: Router
		) {

		this.errorService = errorService;
		this.featureFlagService = featureFlagService;
		this.router = router;

		this.isProcessing = false;
		this.errorMessage = null;
		this.typeOptions = [
			{
				label: "Boolean",
				value: "Boolean"
			},
			{
				label: "Numeric",
				value: "Numeric"
			},
			{
				label: "String",
				value: "String"
			},
			{
				label: "Any (serializable value)",
				value: "Any"
			}
		];
		this.form = {
			key: "",
			name: "",
			description: "",
			selectedTypeOption: this.typeOptions[ 0 ],
			variants: [
				{
					value: "false"
				},
				{
					value: "true"
				}
			],
			fallthroughVariantRef: 1
		};

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I add a new, empty variant option.
	*/
	public addVariant() : void {

		this.form.variants.push({
			value: ""
		});

	}


	/**
	* I submit the new feature flag for processing.
	*/
	public createFeatureFlag() : void {

		if ( this.isProcessing ) {

			return;

		}

		this.isProcessing = true;
		this.errorMessage = null;

		var unwrappedVariants = this.form.variants.map(
			( variantWrapper ) => {

				return( variantWrapper.value );

			}
		);

		this.featureFlagService
			.createFeatureFlag({
				key: this.form.key,
				name: this.form.name,
				description: this.form.description,
				type: this.form.selectedTypeOption.value,
				variants: unwrappedVariants,
				fallthroughVariantRef: this.form.fallthroughVariantRef
			})
			.then(
				( response ) => {

					this.router.navigate([ "/feature-flag", this.form.key ]);

				},
				( error ) => {

					this.isProcessing = false;
					this.errorMessage = this.errorService.getMessage( error );

				}
			)
		;

	}


	/**
	* I remove the variant option at the given index.
	*/
	public removeVariant( i: number ) : void {

		var variantRef = ( i + 1 );

		// If the variant being removed is the currently-selected fall-through variant,
		// then reset the fall-through selection to be the first variant.
		if ( this.form.fallthroughVariantRef === variantRef ) {

			this.form.fallthroughVariantRef = 1;

		// If the variant being removed is above the currently-selected fall-through
		// variant, then we just need to move the selection index up one so that it will
		// point to the new index of the existing selection.
		} else if ( this.form.fallthroughVariantRef > variantRef ) {

			this.form.fallthroughVariantRef--;

		}

		this.form.variants.splice( i, 1 );

	}

}
