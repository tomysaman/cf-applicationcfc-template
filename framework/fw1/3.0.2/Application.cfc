component extends="lib.fw1.one" output="false" {
	/* NOTE: If you want to override fw1's Application.cfc methods (such as OnApplicationStart, OnRequestEnd etc), look at the comments in /framework/one.cfc
		- OnApplicationStart: Do it in setupApplication()
		- OnSessionStart: Do it in setupSession()
		- OnRequestStart: Do it in setupRequest()
		- OnRequest: DO NOT override
		- OnRequestEnd: Can override, but must call super.onRequestEnd() first
		- OnSessionEnd: Can override (actually no onSessionEnd in fw1)
		- OnApplicationEnd: Can override (actually no OnApplicationEnd in fw1)
		- onCFCRequest: Can override (actually no onCFCRequest in fw1) - probably won't have any reason to use this in fw1 app
		- onAbort: Can override (actually no onAbort in fw1)
		- onMissingTemplate: Can override (actually no onAbort in fw1) - probably won't have any reason to use this in fw1 app
		- onError: Can override, calling supper.onError() is optional
	*/

	// Application.cfc settings
	this.name = "fw1-basic";
	this.description = "";
	this.webRoot = getDirectoryFromPath(getCurrentTemplatePath());
	this.appRoot = getCanonicalPath( this.webRoot & "../" );
	// A structure of mappings. The logical path is the key and the absolute path is the value.
	this.mappings = {
		"/app" = this.appRoot & 'app', // mapping to our fw1 files (which is outside of our web root)
		"/taffy" = this.appRoot & 'taffy' // mapping to Taffy (which is outside of our web root)
	};

	// FW1 settings
	variables.framework = {
		applicationKey = this.name & '_fw1', // Used if you have multiple fw1 applications that share the same CF application name
		base = '/app', // Must be set if the application itself (controllers,model,views,layouts etc) is not in the same directory as Application.cfc and index.cfm - this is a relative path to Application.cfc (and must start with "/")
		//cfcBase = '', // Only set this if the controllers and model folders are not in the same folder
		//action = 'action',
		//defaultSection = 'main',
		//defaultItem = 'default',
		usingSubsystems = false, // Note: this will become true if any of the subsystem settings below is present
		//subsystemDelimiter = ':',
		//siteWideLayoutSubsystem = 'common',
		//defaultSubsystem = 'home',
		//subsystems = { }, // ???????
		home = 'main.default', // Default home action => home:main.default
		error = 'main.error', // Default error action => home:main.error
		baseURL = 'useCgiScriptName', // Used for redirect() and buildURL(); default to using CGI.SCRIPT_NAME; set it to "useRequestURI" to use getPageContext().getRequest().getRequestURI() - which is usually used when fw1 is inside another system (for example, Mura) which utilise some kind of url rewrite
		generateSES = false, // /?action=main.about becomes /index.cfm/main/about
		SESOmitIndex = false, // /?action=main.about becomes /main/about
		diEngine = 'di1',
		diComponent = 'lib.fw1.ioc', // Path to DI/1 ioc.cfc
		diLocations = '/app/model,/app/controllers', // Paths to fw1 model and controllers folders
		//diConfig = { },
		cacheFileExists = false, // Cache the result of FileExists() calls to improve fw performance speeed (with this set to true, we will need to reload fw if we add any new cfc/view/layout files)
		//noLowerCase = false, // ALWAYS set this to false to enforce lower case on action url variable so it won't cause issue when we are on filename case sensitive OS
		unhandledPaths = '/api,/app,/assets,/css,/images,/js,/lib,/taffy,/tests,/temp,/tools', // paths to excluded from being handled by fw1
		unhandledExtensions = 'cfc', // List of file extensions that FW/1 should not handle
		unhandledErrorCaught = false, // Set to true will have fw1's error handler to catch errors raised by unhandled requests (e.g. those generic CF errors that are outside of fw1's scope)
		//preserveKeyUrlKey = 'fw1pk', // fw variables preservation urk key (mainly designed for flash, but can used for web app as well)
		//maxNumContextsPreserved = 10, // Set this to 1 will basically turn of "preserveKeyUrlKey" because with only one context FW/1 will not use a URL variable to track flash scope across redirects
		//reload = 'reload', // fw reload url key
		//password = 'true', // fw reload url key's value/password => /?reload=#password#
		trace = ( getEnvironment() eq 'dev' ) ? true : false, // Set to true to show fw debug info when in dev
		reloadApplicationOnEveryRequest = ( getEnvironment() eq 'dev' ) ? true : false, // Set to true when in dev so don't need to call /?reload=1
		//resourceRouteTemplates = , // ??????????
		routes = [ ] // ???????
	};

	// ************************ FW1 Methods ************************

	public void function setupApplication() hint="Application setup logic" {

	}

	public void function setupSession() hint="Session start/setup logic" {

	}

	//public void function setupSubSystem (required string subSystem) hint="" {WriteDump("setupRequest");}

	public void function setupRequest() hint="Setup logic to be executed before every requests" {
		//controller('security.checkAuthorization');
	}

	public void function before( struct rc = {} ) hint="Similar to setupRequest(), but can access the rc scope. Setup rc scope here for every requests" {

	}

	public void function after( struct rc = {} ) hint="Called after the controller item/method is executed" {

	}

	public void function setupView() hint="Called after controllers and services have completed but before any views are rendered" {

	}

	public void function setupResponse() hint="Called at the end of every requests, and right before redirection (if redirect() is used)" {

	}

	/* public void function onMissingMethod( string method, struct missingMethodArguments ) hint="Can omit this, not really required for us" {
		WriteDump(method);
		WriteDump(missingMethodArguments);
	} */

	public string function onMissingView( struct rc = {} ) hint="Should be set to return some text/content (by default fw1 throws an exception if this is not defined)" {
		// Set 404 header
		var pcResponse = getPageContext().getResponse();
		pcResponse.setStatus(404);
		return "Error 404 - Page not found.";
	}

	public void function onError( any exception, string eventName ) hint="On error method" {
		// Set 500 header
		var pcResponse = getPageContext().getResponse();
		pcResponse.setStatus(500);
		super.onError( arguments.exception, arguments.eventName );
		WriteDump(exception);
	}

	// ************************ Custom Methods ************************

	public string function getEnvironment() {
		var cgiServerName = CGI.SERVER_NAME;
		if ( findNoCase("dev", cgiServerName) or findNoCase("local", cgiServerName) or findNoCase("127.0.0.1", cgiServerName) ) {
			return "dev";
		} else if ( findNoCase("staging", cgiServerName) or findNoCase("stage", cgiServerName) ) {
			return "staging";
		} else {
			return "prod";
		}
	}

	public boolean function isHttps() {
		if ( len(cgi.HTTPS) and listFindNoCase("Yes,On,True",cgi.HTTPS) ) {
			return true;
		} else if ( isBoolean(cgi.SERVER_PORT_SECURE) and cgi.SERVER_PORT_SECURE ) {
			return true;
		} else if ( len(cgi.SERVER_PORT) and cgi.SERVER_PORT eq "443" ) {
			return true;
		} else if ( structkeyexists(GetHttpRequestData().headers, "X-Forwarded-Proto") and GetHttpRequestData().headers["X-Forwarded-Proto"] eq "https" ) {
			return true;
		} else {
			return false;
		}
	}

	// Note: getCanonicalPath only available in Lucee; use ths function if in CF
	private string function getCanonicalPathCF(required string rawPath) hint="CF implementation of getCanonicalPath() function" {
		var canonicalPath = createObject("java", "java.io.File").init(arguments.rawPath).getCanonicalPath();
		return canonicalPath;
	}

}