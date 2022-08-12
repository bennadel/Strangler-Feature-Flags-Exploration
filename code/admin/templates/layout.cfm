
<cfparam name="attibutes.title" type="string" default="" />

<cfswitch expression="#thistag.executionMode#">
	<cfcase value="start">
		<cfoutput>

			<cfcontent type="text/html; charset=utf-8" />

			<!doctype html>
			<html lang="en">
			<head>
				<meta charset="utf-8" />
				<meta name="viewport" content="width=device-width, initial-scale=1" />
				<title>
					#encodeForHtml( attributes.title )#
				</title>
				<link rel="preconnect" href="https://fonts.googleapis.com" />
				<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
				<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" />
				<link rel="stylesheet" type="text/css" href="/admin/static/main.css" />
				<script type="text/javascript" src="/admin/static/main.js"></script>
			</head>
			<body>

				<main class="site-wrapper">

					<h1>
						#encodeForHtml( attributes.title )#
					</h1>

		</cfoutput>
	</cfcase>
	<cfcase value="end">
		<cfoutput>

				</main>

			</body>
			</html>

		</cfoutput>
	</cfcase>
</cfswitch>
