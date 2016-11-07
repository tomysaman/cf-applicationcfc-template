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

	// ************************ Application.cfc settings ************************
	this.name = "fw1-basic" & "_" & getEnvironment();
	this.description = "";
	this.applicationTimeout = createTimeSpan(1,0,0,0);
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.timeout = 60;
	this.requestTimeout = this.timeout;
	this.setClientCookies = true; // Whether to send CFID and CFTOKEN cookies to the client browser. If set to false CFID & CFTOKEN must be passed in via URL.
	this.setDomainCookies = false; // Whether to set CFID and CFTOKEN cookies for a domain (not just a host).
	this.locale = "English (Australian)"; // Lucee only
	this.timezone = "Australia/Sydney"; // Lucee only
	this.compression = true; // Lucee only - Enable GZip compression.
	this.scriptProtect = "all"; // all|none, or a combination of: form, url, cookie, cgi
	this.secureJSON = true; // Protection to JSON hijacking
	this.secureJSONPrefix = "//";
	this.webRoot = getDirectoryFromPath(getCurrentTemplatePath()); // This is our "htdocs" folder
	this.appRoot = getCanonicalPath( this.webRoot & "../" ); // This is our "src" folder, which contains our htdocs and other folders that we don't want to be accessible from web
	this.mappings = {
		"/app" = this.appRoot & 'app', // mapping to our fw1 files (which is outside of our web root)
		"/taffy" = this.appRoot & 'taffy' // mapping to Taffy (which is outside of our web root)
	};
	// Lucee's way of specify multiple datasources, change this if using ACF
	this.datasources["my_dsn_dev"] = {
		class: 'org.gjt.mm.mysql.Driver'
		, connectionString: 'jdbc:mysql://127.0.0.1:3309/my_database?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true'
		, username: 'root'
		, password: "encrypted:..."
		, blob: true // default: false
		, clob: true // default: false
		, connectionLimit: 10 // default:-1
	};
	this.datasources["my_dsn_staging"] = {
		class: 'org.gjt.mm.mysql.Driver'
		, connectionString: 'jdbc:mysql://127.0.0.1:3309/my_database?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true'
		, username: 'root'
		, password: "encrypted:..."
		, blob: true // default: false
		, clob: true // default: false
		, connectionLimit: 10 // default:-1
	};
	this.datasources["my_dsn_production"] = {
		class: 'org.gjt.mm.mysql.Driver'
		, connectionString: 'jdbc:mysql://127.0.0.1:3309/my_database?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true'
		, username: 'root'
		, password: "encrypted:..."
		, blob: true // default: false
		, clob: true // default: false
		, connectionLimit: 10 // default:-1
	};
	this.datasource = "my_dsn_#getEnvironment()#";
	this.defaultDatasource = this.datasource;
	/*
	// List of custom tag paths
	this.customTagPaths = [
		expandPath('/org/webqem/')
	];
	// Lucee only - list of component paths
	this.componentPaths = [
		expandPath('/org/webqem/')
	];
	this.sessionType = "j2ee"; // Lucee only - cfml|j2ee - cfml: session handled by Lucee; j2ee: session handled by the Servlet Engine; Use j2ee to make sessions over a clusterto or share session with a Java application.
	this.clientManagement = false;
	this.clientTimeout = createTimeSpan(90,0,0,0);
	this.sessionStorage = "memory"; // Lucee only - file|memory|cookie|<datasource-name>|<cache-name>
	this.clientStorage = "cookie"; // file|memory|cookie|<datasource-name>|<cache-name>
	this.loginStorage = "cookie"; // cookie||session
	this.sessionCluster = true; // Lucee only - If set to true, Lucee uses the storage backend for the session scope as master and checks for changes in the storage backend with every request. Set to false (default), the storage is only used as slave, Lucee only initially gets the data from the storage. Ignored for storage type "memory".
	this.clientCluster = true; // Lucee only - If set to true, Lucee uses the storage backend for the client scope as master and checks for changes in the storage backend with every request. Set to false (default), the storage is only used as slave, Lucee only initially gets the data from the storage. Ignored for storage type "memory".
	this.invokeImplicitAccessor = true; // Enable auto getter and setter (e.g. set<ValueName>()) when you call Component.<valueName>
	this.localMode = "modern"; // Lucee only - modern|classic - Defines how the local scope is invoked; modern: local scope is invoked always even variable does not exist in the local scope; classic: local scope is only invoked when variable already exists in the local scope.
	this.scopeCascading = "small"; // Lucee only - strict|small|standard - Define how Lucee scans certain scopes to find a variable when it is called without a scope; strict: scans only the variables scope; small: scans the scopes variables,url,form; standard: scans the scopes variables,cgi,url,form,cookie.
	this.wstype = "Axis1"; // Lucee only - Axis1|CXF
	this.onmissingtemplate = "path/to/cfm"; // Lucee only - Closure/udf executed when the requested template does not exist
	this.bufferOutput = true; // Lucee only - True: output written to the body of the tag is buffered and in case of a exception also outputted. False: the content to body is ignored and not disabled when a failure in the body of the tag occur.
	this.suppressRemoteComponentContent = false; // Lucee only - Suppress content written to response stream when a component is invoked remotely.
	*/

	// ************************ ORM settings ************************
	this.ormEnabled = true;
	this.ormsettings = {
		//dialect = "MySQL", // Usually don't need to specify this, CF will detect automatically
		cfcLocation = [expandPath('/app/common/model/')], // Array of directories to beans
		dbCreate = "update", // none|update|dropcreate - Auto update, or drop-then-create db tables base on beans
		autoGenMap = true, // If false, mapping should be provided in the form of .HBMXML files.
		logSql = true,
		//catalog = "", // DB catalog - usually only needed if you want ORM to access multiple databases
		//schema = "", // DB schema - usually only needed if you want ORM to access multiple databases
		//namingStrategy = "default", // default: Use the logical table or column name as it is; smart: Change the logical table or column name to uppercase. If the logical table or column name is in camel case, this strategy breaks the camelcased name and separates them with underscore; your_own_cfc : You can get complete control of the naming strategy by providing your own implementation.
		//saveMapping = false, // Turn this on to save the Hibernate config xml files to disk (for inspection/debug) - NOTE: If this is on, you may need to manually delete these xml files, or delete the compiled class (/WEB-INF/cfclasses) and restart CF in order for new (updated) xml files being generated and used for ORM
		//useDBForMapping = true, // Set to false to improve ORM reload time (so CF won't inspect database to figure out the mappings). If it is false then we need to make sure every properties will have a ORM type and other settings set properly
		//eventHandling = true, // Turn on even handling and we can use functions such as preUpdate(), postUpdate() in our bean cfc - See: http://therealdanvega.com/blog/2009/12/22/coldfusion-9-orm-event-handlers-use-case
		//evenHandler = "path.to.cfc", // Custom global ORM event handler cfc
		//sqlScript = "path.to.sql", // Path to SQL script file that gets executed after ORM is initialized. This applies if dbcreate is set to dropcreate
		//secondaryCacheEnabled = false, // Specifies whether secondary caching should be enabled.
		//cacheProvider = "ehcache", // Specifies the cache provider that should be used by ORM as secondary cache.
        //cacheconfig = "path.to.config", // Specifies the location of the configuration file that should be used by the secondary cache provider.
		// Set below two settings to false so we have complete control on Hibernate session. The only thing happens automatically is that session is flushed when a transaction commits
		flushAtRequestEnd = false, // Set this to false, we need to control ORM Flush - don't let CF do it automatically at the end of a request
		autoManageSession = false // Also set this to false, then 1). Stop Hibernate session being flushed at the beginning of a transaction; 2). Stop Hibernate session being cleared when a transaction is rolled back
	};

	/* ************************ FW1 settings ************************
		About the directory & file organisation:
			+ app (all the fw1 files are here, outside the web root)
				+ controllers
				+ layouts
				+ model
					+ beans
					+ services
				+ view
			+ other asset folders that we don't want users have direct access (e.g. ebooks, pdfs))
			+ htdocs (this is our web root)
				+ lib
					+ fw1 (framework files such as one.cfc, ioc.cfc are here)
				+ other web folders (assets, js, css, images etc)
				Application.cfc & index.cfm
	*/
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
		trace = false, // Display debug info at the end of display
		reloadApplicationOnEveryRequest = false, // Set to true when in dev so don't need to call /?reload=1
		/* routes: Array of structures define mappings of url to fw action
			- { "/product/:id" = "/product/view/id/:id" } will map url /product/1 to /production/view/id/1 (which is /?action=production.view&id=1)
			- It can be restricted to specific HTTP methods by prefixing them with $ and the method, e.g. { "$POST/search" = "/main/search" }
			- It can be a redirect by prefixing the action URL with an HTTP status code and a colon, e.g. { "/thankyou" = "302:/main/thankyou" }
			- Can use to setup REST API; { "$RESOURCES" = "dogs,cats,hamsters" }, for each of the resource item (take dogs as example) fw1 will create the following mappings
				{ "$GET/dogs/$" = "/dogs/default" },
				{ "$GET/dogs/new/$" = "/dogs/new" },
				{ "$POST/dogs/$" = "/dogs/create" },
				{ "$GET/dogs/:id/$" = "/dogs/show/id/:id" },
				{ "$PATCH/dogs/:id/$" = "/dogs/update/id/:id", "$PUT/dogs/:id/$" = "/dogs/update/id/:id" },
				{ "$DELETE/dogs/:id/$" = "/dogs/destroy/id/:id" }
			- To customise the $RESOURCES, instead of specify it as a list supply it as a structure likes below:
				$RESOURCES = {
					resources = "dogs,cats...",
					methods = "default,create,show", // Limits the generated routes as listed
					pathRoot = "/animals", // If specified, it is prepended to the generated route paths (i.e. $GET/animals/cats/$)
					nested = "..."/[...]/{...}
				}
			- { "*" = "/not/found" }, "*" is a wildcard that will match any request and therefore must be the last route in the array if used. If used, all your application's url/route must be defined here (because routes mapping has priority over actual /section/view files)
			- We can have multiple mappings and also a hint item in a struct, e.g.  { "/oldUrl"="301:/newUrl", "/item/:id"="/item/view/id/:id" hint="Description about this set of routes" }
		*/
		routes = [ ],
		/* resourceRouteTemplates: The rules of generate the $RESOURCES mappings mentioned above, default as below:
			resourceRouteTemplates = [
				{ method = 'default', httpMethods = [ '$GET' ] },
				{ method = 'new', httpMethods = [ '$GET' ], routeSuffix = '/new' },
				{ method = 'create', httpMethods = [ '$POST' ] },
				{ method = 'show', httpMethods = [ '$GET' ], includeId = true },
				{ method = 'update', httpMethods = [ '$PUT','$PATCH' ], includeId = true },
				{ method = 'destroy', httpMethods = [ '$DELETE' ], includeId = true }
			]
		*/
		// Environment specific settings
		environments = {
			prod = { },
			staging = { },
			dev = {
				// Turn on trace info and always reload fw when on dev
				trace = true,
				reloadApplicationOnEveryRequest = true
			}
		}
	};

	// ************************ FW1 Methods ************************

	public string function getEnvironment() hint="Determine the environment and return a string in format of tier or tier:server - e.g. dev, staging, production:win, production:linux" {
		if ( findNoCase("dev", CGI.SERVER_NAME) or findNoCase("local", CGI.SERVER_NAME) or findNoCase("127.0.0.1", CGI.SERVER_NAME) ) {
			return "dev";
		} else if ( findNoCase("staging", CGI.SERVER_NAME) or findNoCase("stage", CGI.SERVER_NAME) ) {
			return "staging";
		} else {
			return "prod";
		}
	}

	public void function setupEnvironment( string env ) hint="Can be used to provide additonal logic bases on the environemtn. This function is called during framework setup (after all framework settings are loaded into variables.framework scope)" {
		if ( arguments.env eq "dev" ) {

		} else if ( arguments.env eq "staging" ) {

		} else {
			// Add 301 redirects for production
			//arrayAppend( variables.framework.routes, { "/oldUrl" = "301:/main/newUrl" } );
		}
	}

	public void function setupApplication() hint="Application setup logic" {

	}

	public void function setupSession() hint="Session start/setup logic" {
		session.user = {
			id = '',
			isLoggedIn = 0,
			email = ''
		}
	}

	//public void function setupSubSystem (required string subSystem) hint="" {WriteDump("setupRequest");}

	public void function setupRequest() hint="Setup logic to be executed before every requests" {
		//controller('security.checkAuthorization');
	}

	public void function before( struct rc = {} ) hint="Similar to setupRequest(), but can access the rc scope. Setup rc scope here for every requests" {
		rc.isSU = isDefined("session.user.email") and findNoCase("@webqem.com", session.user.email);
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

	public string function onMissingView( struct rc = {} ) hint="Should be set to return some text/content to be used as a view (by default fw1 throws an exception if this is not defined)" {
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

	public boolean function isHttps() {
		if ( len(CGI.HTTPS) and listFindNoCase("Yes,On,True",CGI.HTTPS) ) {
			return true;
		} else if ( isBoolean(CGI.SERVER_PORT_SECURE) and CGI.SERVER_PORT_SECURE ) {
			return true;
		} else if ( len(CGI.SERVER_PORT) and CGI.SERVER_PORT eq "443" ) {
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