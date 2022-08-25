
// Import core angular modules.
import { AfterViewInit } from "@angular/core";
import { Directive } from "@angular/core";
import { EventEmitter } from "@angular/core";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

@Directive({
	selector: "[app-initial-render]",
	outputs: [ "onRenderEvents: onRender" ]
})
export class InitialRenderDirective implements AfterViewInit {

	public onRenderEvents: EventEmitter<void>;

	constructor() {

		this.onRenderEvents = new EventEmitter<void>();

	}

	// ---
	// PUBLIC METHODS.
	// ---

	public ngAfterViewInit() : void {

		this.onRenderEvents.next();

	}

}
