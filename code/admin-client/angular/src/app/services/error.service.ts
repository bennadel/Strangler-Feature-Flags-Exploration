
// Import core angular modules.
import { ErrorHandler } from "@angular/core";
import { Injectable } from "@angular/core";

// Import application modules.
import { ApiClient } from "~/app/services/api-client.service";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@Injectable({
	providedIn: "root"
})
export class ErrorService implements ErrorHandler {

	private apiClient;

	/**
	* I initialize the API client with the given dependencies.
	*/
	constructor( apiClient: ApiClient ) {

		this.apiClient = apiClient;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I attempt to extract the human-friendly error message from the given error. However,
	* since there are no guarantees as to where in the application this error was thrown,
	* we will have to do some introspection / type narrowing in order to find the most
	* appropriate error message property to display.
	*/
	public getMessage( error: any ) : string {

		// If this is an API Client error, the embedded message is trusted and can be
		// rendered for the user.
		if ( this.apiClient.isApiClientError( error ) ) {

			return( error.data.message );

		}

		return( "Sorry, we could not process your request." );

	}


	/**
	* I provide a centralized location for logging errors in Angular.
	*/
	public handleError( error: any ) : void {

		// NOTE: In the future, this could ALSO be used to push the errors to a remote log
		// aggregation API end-point or service.
		console.error( error );

	}
	
}
