
// Import core angular modules.
import { Component } from "@angular/core";
import { ElementRef } from "@angular/core";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@Component({
	selector: "app-error-message",
	inputs: [ "scrollOnRender" ],
	templateUrl: "./error-message.component.html",
	styleUrls: [ "./error-message.component.less" ]
})
export class ErrorMessageComponent {

	public scrollOnRender: boolean;

	private elementRef: ElementRef;

	/**
	* I initialize the error message component.
	*/
	constructor( elementRef: ElementRef ) {

		this.elementRef = elementRef;

		this.scrollOnRender = false;

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get called once after the view has been initialized / reconciled.
	*/
	public ngAfterViewInit() : void {

		if ( ! this.scrollOnRender ) {

			return;

		}

		this.elementRef.nativeElement.scrollIntoView({
			behavior: "smooth",
			block: "center",
			inline: "center"
		});

	}

}
