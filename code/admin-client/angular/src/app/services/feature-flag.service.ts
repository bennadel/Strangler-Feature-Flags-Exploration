
// Import core angular modules.
import { Injectable } from "@angular/core";
import { Subject } from "rxjs";

// Import application modules.
import { ApiClient } from "./api-client.service";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

export namespace FeatureFlags {

	interface BaseFeatureFlag {
		key: string;
		name: string;
		description: string;
		rules: Rule[];
		fallthroughVariantRef: number;
		isEnabled: boolean;
	}

	export type FeatureFlag =
		| AnyFeatureFlag
		| BooleanFeatureFlag
		| NumericFeatureFlag
		| StringFeatureFlag
	;

	export interface AnyFeatureFlag extends BaseFeatureFlag {
		type: "Any";
		variants: any[];
	}

	export interface BooleanFeatureFlag extends BaseFeatureFlag {
		type: "Boolean";
		variants: boolean[];
	}

	export interface NumericFeatureFlag extends BaseFeatureFlag {
		type: "Numeric";
		variants: number[];
	}

	export interface StringFeatureFlag extends BaseFeatureFlag {
		type: "String";
		variants: string[];
	}

	export type Type = 
		| "Any"
		| "Boolean"
		| "Numeric"
		| "String"
	;

	export interface Rule {
		tests: Test[];
		rollout: Rollout;
	}

	export type Test =
		| UserKeyTest
		| UserPropertyTest
	;

	export interface UserKeyTest {
		type: "UserKey";
		operation: Operation;
	}

	export interface UserPropertyTest {
		type: "UserProperty";
		userProperty: string;
		operation: Operation;
	}

	export type Operator =
		| "Contains"
		| "EndsWith"
		| "GreaterThan"
		| "LessThan"
		| "MatchesRegex"
		| "NotContains"
		| "NotEndsWith"
		| "NotMatchesRegex"
		| "NotOneOf"
		| "NotStartsWith"
		| "OneOf"
		| "StartsWith"
	;

	export interface Operation {
		operator: Operator;
		values: string[];
	}

	export type Rollout =
		| SingleRollout
		| MultiRollout
	;

	export interface SingleRollout {
		type: "Single";
		variantRef: number;
	}

	export interface MultiRollout {
		type: "Multi";
		distribution: Distribution[];
	}

	export interface Distribution {
		percent: number;
		variantRef: number;
	}

}

export namespace Events {

	interface BaseEvent {
		data: {
			key: string;
		}
	}

	export interface FeatureFlagCreated extends BaseEvent {
		type: "FeatureFlagCreated";
	}

	export interface FeatureFlagDeleted extends BaseEvent {
		type: "FeatureFlagDeleted";
	}

	export interface FeatureFlagSettingsUpdated extends BaseEvent {
		type: "FeatureFlagSettingsUpdated";
	}

	export interface FeatureFlagTargetingUpdated extends BaseEvent {
		type: "FeatureFlagTargetingUpdated";
	}

	export type All = 
		| FeatureFlagCreated
		| FeatureFlagDeleted
		| FeatureFlagSettingsUpdated
		| FeatureFlagTargetingUpdated
	;

}

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

export interface CreateFeatureFlagConfig {
	key: string;
	name: string;
	description: string;
	type: FeatureFlags.Type;
	variants: string[];
	fallthroughVariantRef: number;
}

export type CreateFeatureFlagResponse = void;

export type DeleteFeatureFlagResponse = void;

export interface FeatureFlagResponse {
	featureFlag: FeatureFlags.FeatureFlag;
}

export interface GetAllFeatureFlagsResponse {
	featureFlags: {
		[key: string]: FeatureFlags.FeatureFlag;
	};
}

export interface UpdateFeatureFlagSettingsConfig {
	key: string;
	name: string;
	description: string;
}

export type UpdateFeatureFlagSettingsResponse = void;

export interface UpdateFeatureFlagTargetingConfig {
	key: string;
	rules: FeatureFlags.Rule[];
	fallthroughVariantRef: number;
	isEnabled: boolean;
}

export type UpdateFeatureFlagTargetingResponse = void;

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@Injectable({
	providedIn: "root"
})
export class FeatureFlagService {

	private apiClient: ApiClient;

	public events: Subject<Events.All>;

	/**
	* I initialize the feature flag service with the given dependencies.
	*/
	constructor( apiClient: ApiClient ) {

		this.apiClient = apiClient;

		this.events = new Subject();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I make an API request to create a new feature flag.
	*/
	public async createFeatureFlag( config: CreateFeatureFlagConfig ) : Promise<CreateFeatureFlagResponse> {

		var response = await this.apiClient.makeRequest<CreateFeatureFlagResponse>({
			method: "post",
			url: "/admin/api/index.cfm",
			urlParams: {
				action: "createFeatureFlag"
			},
			body: config
		});

		this.events.next({
			type: "FeatureFlagCreated",
			data: {
				key: config.key
			}
		});

		return( response );

	}


	/**
	* I make an API request to delete the given feature flag.
	*/
	public async deleteFeatureFlag( key: string ) : Promise<DeleteFeatureFlagResponse> {

		var response = await this.apiClient.makeRequest<DeleteFeatureFlagResponse>({
			method: "delete",
			url: "/admin/api/index.cfm",
			urlParams: {
				action: "deleteFeatureFlag",
				key: key
			}
		});

		this.events.next({
			type: "FeatureFlagDeleted",
			data: {
				key: key
			}
		});

		return( response );

	}


	/**
	* I make an API request to get all feature flags.
	*/
	public async getAllFeatureFlags() : Promise<GetAllFeatureFlagsResponse> {

		var response = await this.apiClient.makeRequest<GetAllFeatureFlagsResponse>({
			method: "get",
			url: "/admin/api/index.cfm",
			urlParams: {
				action: "getFeatureFlags"
			}
		});

		return( response );

	}


	/**
	* I make an API request to get the given feature flag.
	*/
	public async getFeatureFlag( key: string ) : Promise<FeatureFlagResponse> {

		var response = await this.apiClient.makeRequest<FeatureFlagResponse>({
			method: "get",
			url: "/admin/api/index.cfm",
			urlParams: {
				action: "getFeatureFlag",
				key: key
			}
		});

		return( response );

	}


	/**
	* I make an API request to update the given feature flag's base settings.
	*/
	public async updateFeatureFlagSettings( config: UpdateFeatureFlagSettingsConfig ) : Promise<UpdateFeatureFlagSettingsResponse> {

		var response = await this.apiClient.makeRequest<UpdateFeatureFlagSettingsResponse>({
			method: "post",
			url: "/admin/api/index.cfm",
			urlParams: {
				action: "updateFeatureFlagSettings",
				key: config.key
			},
			body: {
				name: config.name,
				description: config.description
			}
		});

		this.events.next({
			type: "FeatureFlagSettingsUpdated",
			data: {
				key: config.key
			}
		});

		return( response );

	}


	/**
	* I make an API request to update the given feature flag's targeting settings.
	*/
	public async updateFeatureFlagTargeting( config: UpdateFeatureFlagTargetingConfig ) : Promise<UpdateFeatureFlagTargetingResponse> {

		var response = await this.apiClient.makeRequest<UpdateFeatureFlagTargetingResponse>({
			method: "post",
			url: "/admin/api/index.cfm",
			urlParams: {
				action: "updateFeatureFlagTargeting",
				key: config.key
			},
			body: {
				rules: config.rules,
				fallthroughVariantRef: config.fallthroughVariantRef,
				isEnabled: config.isEnabled
			}
		});

		this.events.next({
			type: "FeatureFlagTargetingUpdated",
			data: {
				key: config.key
			}
		});

		return( response );

	}

}
