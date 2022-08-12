<cfscript>

	// Setup the default request parameters.
	param name="url.dataChanged" type="boolean" default=false;

	featureFlags = application.featureFlagService.getFeatureFlags();

</cfscript>
<cfmodule template="/templates/layout.cfm" title="All Feature Flags">
<cfoutput>

	<p>
		<a href="/admin/create-flag/index.cfm">Create a new Feature Flag</a>
	</p>

	<table width="100%">
	<thead>
		<tr>
			<th>
				Name
			</th>
			<th>
				Type
			</th>
			<th>
				Targeting Enabled
			</th>
			<th>
				Actions
			</th>
		</tr>
	</thead>
	<tbody>
		<cfloop item="featureFlag" array="#featureFlags#">
			<tr>
				<td>
					<a href="/admin/edit-targeting/index.cfm?key=#encodeForUrl( featureFlag.key )#">#encodeForHtml( featureFlag.name )#</a><br />
					Key: <code>#encodeForHtml( featureFlag.key )#</code>
				</td>
				<td align="center">
					#encodeForHtml( featureFlag.type )#
				</td>
				<td align="center">
					#yesNoFormat( featureFlag.isEnabled )#
				</td>
				<td>
					<a href="/admin/edit-targeting/index.cfm?key=#encodeForUrl( featureFlag.key )#">Targeting</a>,
					<a href="/admin/edit-settings/index.cfm?key=#encodeForUrl( featureFlag.key )#">Settings</a>,
					<a href="/admin/delete-flag/index.cfm?key=#encodeForUrl( featureFlag.key )#">Delete</a>
				</td>
			</tr>
		</cfloop>

	</tbody>
	</table>

	<!---
		When the admin has changed the feature flag data, we want to post a message over
		to the DEMO page letting it know so that it can automatically refresh and show the
		most up-to-date feature flag targeting results.
	--->
	<cfif url.dataChanged>
		<script type="text/javascript">

			window.top.postMessage( "adminReloaded", window.top.location.origin );

		</script>
	</cfif>

</cfoutput>
</cfmodule>
