
// Import core angular modules.
import { firstValueFrom } from "rxjs";
import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";

// Import application modules.
import { environment } from "~/environments/environment";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

export interface RequestConfig {
	method: "get" | "post" | "delete";
	url: string,
	urlParams?: UrlParams;
	body?: any;
}

export interface UrlParams {
	[ param: string ]: string | number | boolean;
}

export interface ResponseError {
	isApiClientError: boolean;
	data: {
		type: string;
		message: string;
		rootCause: any;
	};
	status: {
		code: number;
		text: string;
	};
}

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@Injectable({
	providedIn: "root"
})
export class ApiClient {

	private apiDomain: string;
	private httpClient: HttpClient;

	/**
	* I initialize the API client.
	*/
	constructor( httpClient: HttpClient ) {

		this.httpClient = httpClient;

		// TODO: Should this be provided as an injectable? It seems sloppy for a runtime
		// component to be pulling directly from the environment. This creates tight-
		// coupling to the application bootstrapping process.
		this.apiDomain = environment.apiDomain;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I make an API request with the given configuration.
	*/
	public makeRequest<T>( config: RequestConfig ) : Promise<T> {

		var observable = this.httpClient.request<T>(
			config.method,
			`${ this.apiDomain }${ config.url }`,
			{
				params: config.urlParams,
				body: config.body
			}
		);

		return( this.buildResponse( config, observable ) );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I take the given Observable response and convert it a Promise. An error handler is
	* attached that converts the HTTP error into a API client error.
	*/
	private buildResponse<T>(
		config: RequestConfig,
		observable: Observable<T>
		) : Promise<T> {

		var promise = firstValueFrom( observable ).catch(
			( errorResponse ) => {

				throw( this.normalizeError( errorResponse ) );

			}
		);

		return( promise );

	}


	/**
	* I normalize the given error to have a predictable shape.
	*/
	private normalizeError( errorResponse: any ) : ResponseError {

		var error = {
			isApiClientError: true,
			data: {
				type: "ServerError",
				message: "An unexpected error occurred while processing your request.",
				rootCause: null
			},
			status: {
				code: ( errorResponse.status || 0 ),
				text: ( errorResponse.statusText || "" )
			}
		};

		// If the error data is an Object (which it should be if the server responded
		// with a domain-based error), then it should have "type" and "message"
		// properties within it. That said, just because this isn't a transport error, it
		// doesn't mean that this error is actually being returned by our application.
		if (
			( typeof( errorResponse.error?.type ) === "string" ) &&
			( typeof( errorResponse.error?.message ) === "string" ) &&
			( typeof( errorResponse.error?.strangler ) === "boolean" )
			) {

			error.data.type = errorResponse.error.type;
			error.data.message = errorResponse.error.message;

		// If the error data has any other shape, it means that an unexpected error
		// occurred on the server (or somewhere in transit). Let's pass that raw error
		// through as the rootCause, using the default error structure.
		} else {

			error.data.rootCause = errorResponse.error;

		}

		return( error );

	}

}
