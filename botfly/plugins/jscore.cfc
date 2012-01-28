<cfcomponent name="JQueryUI" hint="Plugin for building jqueryUI based views" extends="coldbox.system.plugin" cache="false" output="false">
<!---
License: Apache 2
Created by: Ernst van der Linden (evdlinden@gmail.com)
Created on: 23 april 2010
Last edited on: 11 may 2010
Release 1.0: implemented dependencies
Release 1.1: implemented localization for datepicker. Automatically sets proper language/locale by using i18n plugin fwLocale.
--->
	<cffunction name="init" access="public" returntype="jqueryUI">
		<cfargument name="controller" type="any" required="true">

		<cfscript>
			super.Init(arguments.controller);
			setPluginName("JQueryUI Plugin");
			setPluginVersion("1.0");
			setPluginDescription("Plugin for building JQueryUI 1.8 based views");
			instance.jqueryui = StructNew();

			// Cores
			setCoreNames('ui.core,ui.widget,effects.core,ui.mouse,ui.position');
			// Widgets
			setWidgetNames('accordion,autocomplete,button,dialog,slider,tabs,datepicker,progressbar');
			// Effects
			setEffectNames('blind,bounce,clip,drop,explode,foid,highlight,pulsate,scale,shake,slide,transfer');
			//Interactions
			setInteractionNames('draggable,droppable,resizeable,selectable,sortable');

			// i18n
			setSupportedLanguages(widgetName='datepicker',languages='af,ar,az,bg,bs,ca,cs,da,de,el,eo,es,et,eu,fa,fi,fo,fr,hr,hu,hy,id,is,it,ja,ko,lt,lv,ms,nl,no,pl,ro,ru,sk,sl,sq,sr,sv,ta,th,tr,uk,vi');
			setSupportedLocales(widgetName='datepicker',locales='en_GB,fr_CH,pt_BR,sr_SR,zh_CN,zh_HK,zh_TW');

			// relative path to jQuery js and css e.g. includes/jquery
			setBaseRelativePath( getSetting("jQueryUIPlugin.baseRelativePath") );
			setCssRelativePath( getBaseRelativePath() & '/themes/base' );
			setJsRelativePath( getBaseRelativePath() & '/ui' );
			setJsFileNameSuffix('');

			// Overwrite default css location?
			if ( settingExists('jQueryUIPlugin.cssRelativePath' )) {
				setCssRelativePath( getSetting('jQueryUIPlugin.cssRelativePath') );
			}
			// Overwrite default js location?
			if ( settingExists('jQueryUIPlugin.jsRelativePath' )) {
				setJsRelativePath( getSetting('jQueryUIPlugin.jsRelativePath') );
			}
			// Set minified suffix?
			if ( settingExists('jQueryUIPlugin.jsFileNameSuffix' )) {
				setJsFileNameSuffix( getSetting('jQueryUIPlugin.jsFileNameSuffix') );
			}
			return this;
		</cfscript>
	</cffunction>

	<!--- DATA --->
	<cffunction name="getData" access="private" returntype="struct">
		<cfscript>
		var data = StructNew();

		// No JQueryUI data available?
		if (not isData()) {

			// html head links
			data.jsLinks.main = ArrayNew(1);
			data.cssLinks.main = ArrayNew(1);
			// Custom
			data.jsLinks.custom = ArrayNew(1);
			data.cssLinks.custom = ArrayNew(1);

			// Init enabled
			data.enabled.coreNames = '';
			data.enabled.widgetNames = '';
			data.enabled.effectNames = '';
			data.enabled.interactionNames = '';

			// set data in request scope
			request.jQueryUIPluginData = data;
		}

		return request.jQueryUIPluginData;
		</cfscript>
	</cffunction>

	<cffunction name="isData" access="private" returntype="boolean">
        <cfreturn structKeyExists(request,'jQueryUIPluginData')>
	</cffunction>
	<!--- END: DATA --->

	<!--- CORE --->
	<cffunction name="setEnableCore" access="public" returntype="void">
		<cfargument name="coreName" type="string" required="true">

		<!--- Core exists? --->
		<cfif not ListFindNoCase(getCoreNames(),arguments.coreName)>
			<cfthrow message="Core name '#arguments.coreName#' does not exist. Available core names: '#getCoreNames()#' ">
		</cfif>

		<!--- Enable Core? --->
		<cfif not ListFindNoCase(getEnabledCoreNames(),arguments.coreName)>
			<cfset setJsLink(src='#getJsRelativePath()#/jquery.#arguments.coreName##getJsFileNameSuffix()#.js')>
			<cfset setEnabledCoreNames( ListAppend( getEnabledCoreNames(),arguments.coreName ) )>
		</cfif>
	</cffunction>

	<cffunction name="setEnableCores" access="private" returntype="void" hint="Enables multiple cores at once">
		<cfargument name="coreNames" type="string" required="true">
		<cfset var coreName = ''>
		<cfloop index="coreName" list="#arguments.coreNames#">
			<cfset setEnableCore(coreName=coreName)>
		</cfloop>
	</cffunction>
	<cffunction name="getCoreNames" access="public" returntype="string" hint="Returns a list of available cores">
		<cfreturn instance.jqueryui.coreNames>
	</cffunction>
	<cffunction name="setCoreNames" access="private" returntype="string">
		<cfargument name="coreNames" type="string" required="true">
		<cfset instance.jqueryui.coreNames = arguments.coreNames>
	</cffunction>
	<cffunction name="getEnabledCoreNames" access="private" returntype="string" hint="Returns a list of enabled cores">
		<cfreturn getData().enabled.coreNames>
	</cffunction>
	<cffunction name="setEnabledCoreNames" access="private" returntype="string">
		<cfargument name="coreNames" type="string" required="true">
		<cfset getData().enabled.coreNames = arguments.coreNames>
	</cffunction>

	<!--- END: CORE --->

	<!--- WIDGET --->
	<cffunction name="setEnableWidget" access="public" returntype="void">
		<cfargument name="widgetName" type="string" required="true">

		<cfset var fwLocale = getPlugin('i18n').getFwLocale()>
		<cfset var locale = structNew()>
		<cfset locale.language = ListFirst(fwLocale,'_')>
		<cfset locale.country = ListLast(fwLocale,'_')>

		<!--- Widget exists? --->
		<cfif not ListFindNoCase(getWidgetNames(),arguments.widgetName)>
			<cfthrow message="Widget name '#arguments.widgetName#' does not exist. Available widget names: '#getWidgetNames()#' ">
		</cfif>

		<!--- Enable cores for default widgets --->
		<cfset setEnableCores(coreNames='ui.core,ui.widget')>

		<!--- Additional dependencies? --->
		<cfswitch expression="#LCase(arguments.widgetName)#">
			<cfcase value="autocomplete,dialog">
				<cfset setEnableCore(coreName='ui.position')>
			</cfcase>
		</cfswitch>

		<!--- Core/Theme css? --->
		<cfif not ListLen(getEnabledWidgetNames())>
			<cfset setCssLink(href='#getCssRelativePath()#/jquery.ui.core.css')>
			<cfset setCssLink(href='#getCssRelativePath()#/jquery.ui.theme.css')>
		</cfif>

		<!--- Enable Widget? --->
		<cfif not ListFindNoCase(getEnabledWidgetNames(),arguments.widgetName)>
			<cfset setJsLink(src='#getJsRelativePath()#/jquery.ui.#LCase(arguments.widgetName)##getJsFileNameSuffix()#.js')>
			<cfset setCssLink(href='#getCssRelativePath()#/jquery.ui.#LCase(arguments.widgetName)#.css')>
			<cfset setEnabledWidgetNames( ListAppend( getEnabledWidgetNames(),arguments.widgetName ) )>

			<!--- ui i18n? --->
			<cfif LCase(arguments.widgetName) eq 'datepicker' and ListFind(getSupportedLocales(widgetName='datepicker'),'#locale.language#_#locale.country#')>
				<cfset setJsLink(src='#getJsRelativePath()#/i18n/jquery.ui.datepicker-#locale.language#-#locale.country#.js')>
			<cfelseif LCase(arguments.widgetName) eq 'datepicker' and ListFind(getSupportedLanguages(widgetName='datepicker'),locale.language)>
				<cfset setJsLink(src='#getJsRelativePath()#/i18n/jquery.ui.datepicker-#locale.language#.js')>
			</cfif>

		</cfif>
	</cffunction>

	<cffunction name="setEnableWidgets" access="public" returntype="void" hint="Enables multiple widgets at once">
		<cfargument name="widgetNames" type="string" required="true" hint="List of widget names">
		<cfset var widgetName = ''>
		<cfloop index="widgetName" list="#arguments.widgetNames#">
			<cfset setEnableWidget(widgetName=widgetName)>
		</cfloop>
	</cffunction>

	<cffunction name="getWidgetNames" access="public" returntype="string" hint="Returns a list of available widgets">
		<cfreturn instance.jqueryui.widgetNames>
	</cffunction>
	<cffunction name="setWidgetNames" access="private" returntype="string">
		<cfargument name="widgetNames" type="string" required="true">
		<cfset instance.jqueryui.widgetNames = arguments.widgetNames>
	</cffunction>

	<cffunction name="getEnabledWidgetNames" access="private" returntype="string" hint="Returns a list of enabled widgets">
		<cfreturn getData().enabled.widgetNames>
	</cffunction>
	<cffunction name="setEnabledWidgetNames" access="private" returntype="string">
		<cfargument name="widgetNames" type="string" required="true">
		<cfset getData().enabled.widgetNames = arguments.widgetNames>
	</cffunction>
	<!--- END: WIDGET --->

	<!--- EFFECT --->
	<cffunction name="setEnableEffect" access="public" returntype="void">
		<cfargument name="effectName" type="string" required="true">

		<!--- Effect exists? --->
		<cfif not ListFindNoCase(getEffectNames(),arguments.effectName)>
			<cfthrow message="Effect name '#arguments.effectName#' does not exist. Available effect names: '#getEffectNames()#' ">
		</cfif>

		<!--- Enable cores for default interactions --->
		<cfset setEnableCores(coreNames='effects.core')>

		<!--- Enable Effect? --->
		<cfif not ListFindNoCase(getEnabledEffectNames(),arguments.effectName)>
			<cfset setJsLink(src='#getJsRelativePath()#/jquery.effects.#LCase(arguments.effectName)##getJsFileNameSuffix()#.js')>
			<cfset setEnabledEffectNames( ListAppend( getEnabledEffectNames(),arguments.effectName ) )>
		</cfif>
	</cffunction>

	<cffunction name="setEnableEffects" access="public" returntype="void" hint="Enables multiple effects at once">
		<cfargument name="effectNames" type="string" required="true" hint="List of effect names">
		<cfset var effectName = ''>
		<cfloop index="effectName" list="#arguments.effectNames#">
			<cfset setEnableEffect(effectName=effectName)>
		</cfloop>
	</cffunction>

	<cffunction name="getEffectNames" access="public" returntype="string" hint="Returns a list of available effects">
		<cfreturn instance.jqueryui.effectNames>
	</cffunction>
	<cffunction name="setEffectNames" access="private" returntype="string">
		<cfargument name="effectNames" type="string" required="true">
		<cfset instance.jqueryui.effectNames = arguments.effectNames>
	</cffunction>

	<cffunction name="getEnabledEffectNames" access="private" returntype="string" hint="Returns a list of enabled widgets">
		<cfreturn getData().enabled.effectNames>
	</cffunction>
	<cffunction name="setEnabledEffectNames" access="private" returntype="string">
		<cfargument name="effectNames" type="string" required="true">
		<cfset getData().enabled.effectNames = arguments.effectNames>
	</cffunction>
	<!--- END: EFFECT --->

	<!--- INTERACTION --->
	<cffunction name="setEnableInteraction" access="public" returntype="void">
		<cfargument name="interactionName" type="string" required="true">

		<!--- Interaction exists? --->
		<cfif not ListFindNoCase(getInteractionNames(),arguments.interactionName)>
			<cfthrow message="Interaction name '#arguments.interactionName#' does not exist. Available interaction names: '#getInteractionNames()#' ">
		</cfif>

		<!--- Enable cores for default interactions --->
		<cfset setEnableCores(coreNames='ui.core,ui.widget,ui.mouse')>

		<!--- Additional dependencies? --->
		<cfswitch expression="#LCase(arguments.interactionName)#">
			<cfcase value="droppable">
				<cfset setEnableInteraction(interactionName='draggable')>
			</cfcase>
		</cfswitch>

		<!--- Enable Interaction? --->
		<cfif not ListFindNoCase(getEnabledInteractionNames(),arguments.interactionName)>
			<cfset setJsLink(src='#getJsRelativePath()#/jquery.ui.#LCase(arguments.interactionName)##getJsFileNameSuffix()#.js')>
			<cfset setEnabledInteractionNames( ListAppend( getEnabledInteractionNames(),arguments.interactionName ) )>
		</cfif>
	</cffunction>

	<cffunction name="setEnableInteractions" access="public" returntype="void" hint="Enables multiple interactions at once">
		<cfargument name="interactionNames" type="string" required="true" hint="List of interaction names">
		<cfset var interactionName = ''>
		<cfloop index="interactionName" list="#arguments.interactionNames#">
			<cfset setEnableInteraction(interactionName=interactionName)>
		</cfloop>
	</cffunction>

	<cffunction name="getInteractionNames" access="public" returntype="string" hint="Returns a list of available interactions">
		<cfreturn instance.jqueryui.interactionNames>
	</cffunction>
	<cffunction name="setInteractionNames" access="private" returntype="string">
		<cfargument name="interactionNames" type="string" required="true">
		<cfset instance.jqueryui.interactionNames = arguments.interactionNames>
	</cffunction>

	<cffunction name="getEnabledInteractionNames" access="private" returntype="string" hint="Returns a list of enabled widgets">
		<cfreturn getData().enabled.interactionNames>
	</cffunction>
	<cffunction name="setEnabledInteractionNames" access="private" returntype="string">
		<cfargument name="interactionNames" type="string" required="true">
		<cfset getData().enabled.interactionNames = arguments.interactionNames>
	</cffunction>
	<!--- END: INTERACTION --->

	<!--- RELATIVE PATHS --->
	<cffunction name="getBaseRelativePath" access="public" returntype="string">
        <cfreturn instance.jqueryui.baseRelativePath>
	</cffunction>
	<cffunction name="setBaseRelativePath" access="public" returntype="void">
		<cfargument name="relativePath" type="string" required="true">
        <cfset instance.jqueryui.baseRelativePath = arguments.relativePath>
	</cffunction>

	<cffunction name="getJsRelativePath" access="public" returntype="string">
        <cfreturn instance.jqueryui.jsRelativePath>
	</cffunction>
	<cffunction name="setJsRelativePath" access="public" returntype="void">
		<cfargument name="relativePath" type="string" required="true">
        <cfset instance.jqueryui.jsRelativePath = arguments.relativePath>
	</cffunction>

	<cffunction name="getCssRelativePath" access="public" returntype="string">
        <cfreturn instance.jqueryui.cssRelativePath>
	</cffunction>
	<cffunction name="setCssRelativePath" access="public" returntype="void">
		<cfargument name="relativePath" type="string" required="true">
        <cfset instance.jqueryui.cssRelativePath = arguments.relativePath>
	</cffunction>
	<!--- END: RELATIVE PATHS --->

	<!--- i18N --->
	<cffunction name="getSupportedLanguages" access="private" returntype="string">
		<cfargument name="widgetName" type="string" required="true">
        <cfreturn instance.jqueryui.supportedLanguages[arguments.widgetName]>
	</cffunction>
	<cffunction name="setSupportedLanguages" access="private" returntype="void">
		<cfargument name="widgetName" type="string" required="true">
		<cfargument name="languages" type="string" required="true">
        <cfset instance.jqueryui.supportedLanguages[arguments.widgetName] = arguments.languages>
	</cffunction>
	<cffunction name="getSupportedLocales" access="private" returntype="string">
		<cfargument name="widgetName" type="string" required="true">
        <cfreturn instance.jqueryui.supportedLocales[arguments.widgetName]>
	</cffunction>
	<cffunction name="setSupportedLocales" access="private" returntype="void">
		<cfargument name="widgetName" type="string" required="true">
		<cfargument name="locales" type="string" required="true">
        <cfset instance.jqueryui.supportedLocales[arguments.widgetName] = arguments.locales>
	</cffunction>
	<!--- END: i18N --->

	<cffunction name="getJsFileNameSuffix" access="public" returntype="string">
        <cfreturn instance.jqueryui.jsFileNameSuffix>
	</cffunction>
	<cffunction name="setJsFileNameSuffix" access="public" returntype="void">
		<cfargument name="suffix" type="string" required="true">
        <cfset instance.jqueryui.jsFileNameSuffix = arguments.suffix>
	</cffunction>

	<!--- HTML HEAD LINKS --->
	<cffunction name="setCssLink" access="private" returntype="void" hint="Sets a css link">
		<cfargument name="href" type="string" required="true">
		<cfargument name="media" type="string" required="false" default="screen">
		<cfargument name="renderPosition" type="numeric" required="false" hint="Provides control for the links render order">
		<cfargument name="typeName" type="string" required="false" default="main">

		<cfset var cssLink = StructNew()>
		<cfset cssLink.href = arguments.href>
		<cfset cssLink.media = arguments.media>
		<!--- <cfset cssLink.renderPosition = arguments.renderPosition> --->

		<!--- Render position zero or less? --->
		<cfif structKeyExists(arguments,'renderPosition')  and arguments.renderPosition lte 0>
			<cfthrow message="Arguments 'renderPosition' must be greater than zero">

		<!--- First render position? --->
		<cfelseif structKeyExists(arguments,'renderPosition') and arguments.renderPosition eq 1>
			<cfset ArrayPrepend(getData().cssLinks[arguments.typeName], cssLink)>

		<!--- Somewhere in array? --->
		<cfelseif structKeyExists(arguments,'renderPosition') and arguments.renderPosition lte ArrayLen(getData().cssLinks[arguments.typeName])>
			<cfset ArrayInsertAt(getData().cssLinks[arguments.typeName], arguments.renderPosition, cssLink)>

		<!--- Last position or default position handling --->
		<cfelse>
			<cfset arrayAppend(getData().cssLinks[arguments.typeName],cssLink)>
		</cfif>

	</cffunction>
	<cffunction name="getCssLinks" access="private" returntype="array" hint="Get css links">
		<cfargument name="typeName" type="string" required="false" default="main">
        <cfreturn getData().cssLinks[arguments.typeName]>
	</cffunction>

	<cffunction name="setJsLink" access="private" returntype="void" hint="Sets a js link">
		<cfargument name="src" type="string" required="true">
		<cfargument name="renderPosition" type="numeric" required="false" hint="Provides control for the links render order">
		<cfargument name="typeName" type="string" required="false" default="main">

		<cfset var jsLink = StructNew()>
		<cfset jsLink.src = arguments.src>
		<!--- <cfset jsLink.renderPosition = arguments.renderPosition>		 --->

		<!--- Render position zero or less? --->
		<cfif structKeyExists(arguments,'renderPosition')  and arguments.renderPosition lte 0>
			<cfthrow message="Arguments 'renderPosition' must be greater than zero">

		<!--- First render position? --->
		<cfelseif structKeyExists(arguments,'renderPosition') and arguments.renderPosition eq 1>
			<cfset ArrayPrepend(getData().jsLinks[arguments.typeName],jsLink)>

		<!--- Somewhere in array? --->
		<cfelseif structKeyExists(arguments,'renderPosition') and arguments.renderPosition lte ArrayLen(getData().jsLinks[arguments.typeName])>
			<cfset ArrayInsertAt(getData().jsLinks[arguments.typeName], arguments.renderPosition, jsLink)>

		<!--- Last position or default position handling --->
		<cfelse>
			<cfset arrayAppend(getData().jsLinks[arguments.typeName],jsLink)>
		</cfif>

	</cffunction>
	<cffunction name="getJsLinks" access="public" returntype="array" hint="Get custom js links">
		<cfargument name="typeName" type="string" required="false" default="main">
        <cfreturn getData().jsLinks[arguments.typeName]>
	</cffunction>
	<!--- END: HTML HEAD LINKS --->

	<!--- CUSTOM HTML HEAD LINKS --->
	<cffunction name="setCustomCssLink" access="public" returntype="void" hint="Sets a custom css link">
		<cfset arguments.typeName='custom'>
		<cfset setCssLink(argumentCollection=arguments)>
	</cffunction>
	<cffunction name="getCustomCssLinks" access="public" returntype="array" hint="Get custom css links">
		<cfset arguments.typeName='custom'>
		<cfreturn getCssLinks(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="setCustomJsLink" access="public" returntype="void" hint="Sets a custom js link">
		<cfset arguments.typeName='custom'>
		<cfset setJsLink(argumentCollection=arguments)>
	</cffunction>
	<cffunction name="getCustomJsLinks" access="public" returntype="array" hint="Get custom js links">
		<cfset arguments.typeName='custom'>
		<cfreturn getJsLinks(argumentCollection=arguments)>
	</cffunction>
	<!--- END: CUSTOM HTML HEAD LINKS --->

	<cffunction name="render" access="public" returntype="void" output="false">
        <cfset var i = 0>
        <cfset var carriageReturn = chr(13) & chr(10)>
        <cfset var mainJsLinks = getJsLinks()>
        <cfset var mainCssLinks = getCssLinks()>
        <cfset var customJsLinks = getJsLinks(typeName='custom')>
        <cfset var customCssLinks = getCssLinks(typeName='custom')>

		<!--- Data to render? --->
		<cfif isData()>
			<!--- JS--->

			<!--- Add main jsLinks to HTML Head --->
			<cfloop index="i" from="1" to="#ArrayLen(mainJsLinks)#">
				<cfhtmlhead text='<script language="javascript" src="#mainJsLinks[i].src#" type="text/javascript"></script>#carriageReturn#'>
			</cfloop>
			<!--- Add custom jsLinks to HTML Head --->
			<cfloop index="i" from="1" to="#ArrayLen(customJsLinks)#">
				<cfhtmlhead text='<script language="javascript" src="#customJsLinks[i].src#" type="text/javascript"></script>#carriageReturn#'>
			</cfloop>

			<!--- CSS --->

			<!--- Add main cssLinks to HTML Head --->
			<cfloop index="i" from="1" to="#ArrayLen(mainCssLinks)#">
				<cfhtmlhead text='<link rel="stylesheet" href="#mainCssLinks[i].href#" type="text/css" media="#mainCssLinks[i].media#">#carriageReturn#'>
			</cfloop>
			<!--- Add custom cssLinks to HTML Head --->
			<cfloop index="i" from="1" to="#ArrayLen(customCssLinks)#">
				<cfhtmlhead text='<link rel="stylesheet" href="#customCssLinks[i].href#" type="text/css" media="#customCssLinks[i].media#">#carriageReturn#'>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="getMemento" access="public" returntype="struct">
		<cfset var memento = Duplicate(instance.jqueryui)>
		<cfset memento.data = ''>
		<cfif isData()>
			<cfset memento.data = getData()>
		</cfif>
		<cfreturn memento>
	</cffunction>
</cfcomponent>