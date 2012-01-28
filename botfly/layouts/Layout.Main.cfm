<cfoutput>
	<!DOCTYPE HTML>
	<html>
		<head>
			#renderHeadAssets()#
			#renderHeaderAssets()#
		</head>
		<body>
			<div class="container">
				#renderView('includes/header')#
				#renderView()#
				#renderView('includes/footer')#
				#renderFooterAssets()#
			</div>
		</body>
	</html>
</cfoutput>
