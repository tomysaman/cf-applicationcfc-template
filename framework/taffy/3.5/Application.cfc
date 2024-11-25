component extends="lib.taffy.core.api" output="false" {
	/* Application.cfc for Earthquake API project - using Taffy 3.6.0 with Lucee 5
		NOTE: If you want to override Taffy's Application.cfc methods (such as OnApplicationStart, OnRequestEnd etc), look at the comments in taffy/core/api.cfc
		- OnApplicationStart: MUST override it and call super.onApplicationStart()
		- OnSessionStart: Not used (no session used in taffy)
		- OnRequestStart: MUST override it and call super.onRequestStart()
		- OnRequest: DO NOT override
		- OnRequestEnd: Do it in onTaffyRequestEnd()
		- OnSessionEnd: Not used (no session used in taffy)
		- OnApplicationEnd: Can override (actually there is no OnApplicationEnd in taffy)
		- onCFCRequest: Can override (actually there is no onCFCRequest in taffy) - probably won't have any reason to use this in taffy app
		- onAbort: Can override (actually there is no onAbort in taffy)
		- onMissingTemplate: Not used (taffy throws 404 not found through <cfheader> if template file is not found); You can choose to implement it if you have any unhandled paths
		- onError: Can override, calling super.onError() is recommended; You should override it to provide custom logic if you have any unhandled paths, and just call super.onError() for normal taffy api requests
	*/

	/* Do we need session or not for this API app? Or do we have to share the main app (admin system)'s application scope and session scope?
		- By standard REST API is state-less (no session), and authentication is needed on every requests
		- But if session is required, we will need to implement something, see these posts:
			https://www.bennadel.com/blog/1990-building-a-twitter-inspired-restful-api-architecture-in-coldfusion.htm
			http://glynjackson.org/weblog/api-authentication-taffy/
			https://groups.google.com/forum/#!topic/taffy-users/XeK5cDWamzM
	*/

	// ************************ Application.cfc settings ************************
	this.appName = "Your API";
	this.name = replace(this.appName," ","-","all") & "_" & getEnvironment();
	this.description = "";
	this.applicationTimeout = createTimeSpan(1,0,0,0);
	this.sessionManagement = false;
	//this.sessionTimeout = createTimeSpan(0,1,0,0);
	this.timeout = 300;
	this.requestTimeout = this.timeout;
	//this.setClientCookies = true; // Whether to send CFID and CFTOKEN cookies to the client browser. If set to false CFID & CFTOKEN must be passed in via URL.
	//this.setDomainCookies = false; // Whether to set CFID and CFTOKEN cookies for a domain (not just a host).
	this.locale = "English (Australian)"; // Lucee only
	this.timezone = "Australia/Sydney"; // Lucee only
	//this.compression = true; // Lucee only - Enable GZip compression.
	this.scriptProtect = "all"; // all|none, or a combination of: form, url, cookie, cgi
	this.secureJSON = true; // Protection to JSON hijacking
	this.secureJSONPrefix = "//";
	this.apiRoot = getDirectoryFromPath(getCurrentTemplatePath()); // This is our "api" folder, which is under web root "htdocs" or "wwwroot" folder
	this.webRoot = getCanonicalPath( this.apiRoot & "../" ); // This is our web root "htdocs" or "wwwroot" folder
	this.appRoot = getCanonicalPath( this.webRoot & "../" ); // This is one level up from the web root, usually will be our project root, which contains our web root "htdocs"/"wwwroot" folder plus other folders that we don't want to be accessible from web
	this.uploadPath = this.webRoot & "assets/upload/"; // This is our "upload" folder for storing user uploaded files
	this.mappings = {
		"/app" = this.appRoot & 'app', // mapping to our app files (your app's beans/services etc), which is outside of our web root and won't be accessible directly from web
		"/api" = this.apiRoot, // mapping to our Taffy app
		"/taffy" = this.webRoot & 'lib/taffy', // mapping to Taffy core & dashboard files
		"/resources" = this.apiRoot & "resources" // mapping to Taffy api resources files
	};
	// Lucee's way of specify multiple datasources, change this if using ACF
	this.datasources["your_dsn_local"] = { // Connect to local machine MySQL
		class: 'org.gjt.mm.mysql.Driver'
		, connectionString: 'jdbc:mysql://localhost:3306/your_db_local?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull&useLegacyDatetimeCode=true'
		, username: 'root'
		, password: ""
		, blob: true
		, clob: true
	};
	this.datasources["your_dsn_dev"] = { // Connect to dev DB
		class: 'org.gjt.mm.mysql.Driver'
		, connectionString: 'jdbc:mysql://xx.xx.xx.xx:3306/your_db_dev?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull&useLegacyDatetimeCode=true'
		, username: 'root'
		, password: "encrypted:b4b8030ad...f1e42"
		, blob: true
		, clob: true
	};
	// See https://nb-ss.webqem.internal/SecretServer/SecretView.aspx?secretid=2549
	this.datasources["your_dsn_staging"] = {
		class: 'org.gjt.mm.mysql.Driver'
		, connectionString: 'jdbc:mysql://xx.xx.xx.xx:3306/your_db_staging?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull&useLegacyDatetimeCode=true'
		, username: 'root'
		, password: "encrypted:92fb884747...a7b1f"
		, blob:true
		, clob:true
	};
	// See https://nb-ss.webqem.internal/SecretServer/SecretView.aspx?secretid=2627
	this.datasources["your_dsn_prod"] = {
		class: 'org.gjt.mm.mysql.Driver'
		, connectionString: 'jdbc:mysql://xx.xx.xx.xx:3306/your_db_prod?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull&useLegacyDatetimeCode=true'
		, username: 'root'
		, password: "encrypted:88039c029a...8a637"
		, blob: true
		, clob: true
	};
	this.datasource = "your_dsn_#getEnvironment()#";
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
		cfcLocation = [ this.appRoot & "app/common/model/" ], // Array of directories to beans
		dbCreate = "update", // none|update|dropcreate - Auto update, or drop-then-create db tables base on beans
		autoGenMap = true, // If false, mapping should be provided in the form of .HBMXML files.
		logSql = true,
		//catalog = "", // DB catalog - usually only needed if you want ORM to access multiple databases
		//schema = "", // DB schema - usually only needed if you want ORM to access multiple databases
		//namingStrategy = "default", // default: Use the logical table or column name as it is; smart: Change the logical table or column name to uppercase. If the logical table or column name is in camel case, this strategy breaks the camelcased name and separates them with underscore; your_own_cfc : You can get complete control of the naming strategy by providing your own implementation.
		saveMapping = false, // Turn this on to save the Hibernate config xml files to disk (for inspection/debug) - NOTE: If this is on, you may need to manually delete these xml files, or delete the compiled class (/WEB-INF/cfclasses) and restart CF in order for new (updated) xml files being generated and used for ORM
		useDBForMapping = true, // Set to false to improve ORM reload time (so CF won't inspect database to figure out the mappings). If it is false then we need to make sure every properties will have a ORM type and other settings set properly
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

	// ************************ Taffy settings ************************
	variables.framework = {
		reloadKey = "reload",
		reloadPassword = "1",
		reloadOnEveryRequest = false,
		endpointURLParam = "endpoint", // The query-string parameter name that specifies the API URI. So it will be http://127.0.0.1/api/?endpoint=/artists
		//serializer = "taffy.core.nativeJsonSerializer",
		//deserializer = "taffy.core.nativeJsonDeserializer",
		disableDashboard = true,
		//disabledDashboardRedirect = "", // Redirect request to URL set here if dashboard is disabled
		//dashboardHeaders = { "x-my-header"="value" }, // A structure of custom headers to add to all requests made from the dashboard (auto populate these values in the request headers textarea)
		showDocsWhenDashboardDisabled = true,
		docs.APIName = "Your API",
		docs.APIVersion = "1.0",
		//docsPath = "../dashboard/docs.cfm", // The template (relative path from the taffy/core/api.cfc that this file extends) to include to generate the api doc at /?docs - All api info is available in application._taffy
		//jsonp = false, // Set to false to disable jsonp, set it to a string (the json callback function) to turn it on; What's jsonp? See http://stackoverflow.com/questions/3839966/can-anyone-explain-what-jsonp-is-in-layman-terms
		unhandledPaths = "/api/temp,/api/tests", // List of paths (absolute path from web root) that you do not want Taffy to interfere with - If you use any of these paths you should define your own OnError method in this application.cfc (as Taffy won't intercept the request, it won't handle the error as well)
		allowCrossDomain = true, // True or false; Can also be a list of domains that are allowed e.g. "http://example.com,http://foo.bar"
		globalHeaders = { // A structure of headers/values you want to return. Global headers are static, you set them on application initialization and they do not change
			"X-Content-Type-Options"="nosniff",
			"X-Frame-Options"="deny",
			"Content-Security-Policy"="default-src 'none'"
		},
		//debugKey = "debug", // For <cfsetting showdebugoutput="true">, if this is present in url (and debug is on in CF/Lucee admin) then debug info will show up
		useEtags = false, // Enable the use of HTTP ETags for caching purposes or not (see: http://fideloper.com/api-etag-conditional-get). According to Taffy doc, this feature is buggy for Lucee 4.0 (not sure about 4.5/5.0)
		returnExceptionsAsJson = true, // If set to true then unhandled CF errors will be returned as as json in the response body
		exceptionLogAdapter = "taffy.bonus.LogToEmail", // Use taffy.bonus.LogToEmail so that errors are sent as error emails
		exceptionLogAdapterConfig = {
			from = "support@yourcompany.com",
			to = "errors@yourcompany.com",
			subj = "#this.appName# (#getEnvironment()#) error",
			type = "html"
		},
		//beanFactory = "", // Object of external bean factory, if you want to re-use your main applicaiton's bean factory instead of Taffy's builtin one
		// Environment specific settings
		environments = {
			prod = { },
			staging = {
				disableDashboard = false
			},
			dev = {
				reloadOnEveryRequest = true,
				disableDashboard = false,
				returnExceptionsAsJson = false
			}
		},
		// Custom framework settings
		// CustomVar = SomeValue
	};

	// ************************ Application.cfc and Taffy Methods ************************

	public string function getEnvironment() hint="Determine the environment" {
		if ( findNoCase("dev", CGI.SERVER_NAME) or findNoCase("local", CGI.SERVER_NAME) or findNoCase("127.0.0.1", CGI.SERVER_NAME) ) {
			return "dev";
		} else if ( findNoCase("staging", CGI.SERVER_NAME) or findNoCase("stage", CGI.SERVER_NAME) or findNoCase("test", CGI.SERVER_NAME) ) {
			return "staging";
		} else {
			return "prod";
		}
	}

	public boolean function onApplicationStart() {
		// Your app/API settings
		application.config = {
			mode = getEnvironment(),
			dsn = this.datasource,
			serverUrl = '', // To be set later base on environment
			appPath = this.appRoot,
			webPath = this.webRoot,
			apiPath = this.apiRoot,
			uploadPath = this.uploadPath,
			appName = this.appName,
			locale = this.locale,
			countryName = "Australia",
			countryCode = "AU",
			timezone = this.timezone,
			dateFormat = "yyyy-mm-dd",
			encodeOpt = "ISO-8859-1", // Encoding/Decoding charset for converting string between binary/Base64/Hex and plain text
			systemEmails = {
				"error" = { to="errors@yourcompany.com", subject="#this.appName# (#getEnvironment()#) error", from="support@yourcompany.com", fromName="#this.appName#" }
			},
			pw = "Password1234" // A secret for hidden admin functions/pages, not used in API application
		};
		// These settings depend on the environment
		if ( getEnvironment() eq "dev" ) {
			if ( CGI.SERVER_PORT neq "80" and CGI.SERVER_PORT neq "8080" ) {
				application.config.serverUrl = "http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/api/";
			} else {
				application.config.serverUrl = "http://#CGI.SERVER_NAME#/api/";
			}
			application.config.apiAdminUsername = "admin"; // For webqem only, used by BasicAuthentication to gain access to API
			application.config.apiAdminPassword = "Password1234"; // For webqem only, used by BasicAuthentication to gain access to API
			application.config.apiAuthExpiration = 60*24*365; // The time (in minutes) that an api access token and an auth string will remain valid
			application.config.apiSignatureKey = "Password1234";
			application.config.apiDocs = "#application.config.serverUrl#?docs";
		} else if ( getEnvironment() eq "staging" ) {
			application.config.serverUrl = "https://test.yourcompany.com/api/";
			application.config.apiAdminUsername = "admin"; // For webqem only, used by BasicAuthentication to gain access to API
			application.config.apiAdminPassword = "Password1234"; // For webqem only, used by BasicAuthentication to gain access to API
			application.config.apiAuthExpiration = 60*24; // The time (in minutes) that an api access token and an auth string will remain valid
			application.config.apiSignatureKey = "Password1234_staging";
			application.config.apiDocs = "#application.config.serverUrl#?docs";
		} else {
			application.config.serverUrl = "https://www.yourcompany.com/api/";
			application.config.apiAdminUsername = "admin"; // For webqem only, used by BasicAuthentication to gain access to API
			application.config.apiAdminPassword = "Password1234"; // For webqem only, used by BasicAuthentication to gain access to API
			application.config.apiAuthExpiration = 60; // The time (in minutes) that an api access token and an auth string will remain valid
			application.config.apiSignatureKey = "Password1234_production";
			application.config.apiDocs = "#application.config.serverUrl#?docs";
		}
		// Setup utilities
		application.utils = {
			// My UDF lib
			udf = new lib.utils.udf(),
			// Converter to convert string & binary data between various formats
			converter = new lib.utils.converter( application.config.encodeOpt ),
			// Logger to log info to DB
			logger = new lib.utils.logger(),
			// JWT tool
			jwt = new lib.JSONWebTokens.JsonWebTokens()
		};
		// Setup Java jar utilities
		application.javaUtils = {
			xxxxTool = createObject("component", "lib.javaloader.JavaLoader").init( [expandPath("/lib/java/xxxx.jar")] )
		}
		// Use DI1 to load our beans and services
		application.beanFactory = createObject("component", "lib.fw1.ioc").init( "/app/common/model" );
		variables.framework.beanFactory = application.beanFactory;

		// Reset cache & ORM
		//cacheRemove(arrayToList(cacheGetAllIds()));
		ormReload();

		// Call parent to run taffy framework
		super.onApplicationStart();
		// Note: After the above super.onApplicationStart() finishes, all Taffy's settings (i.e. variables.framework) will be available in application._taffy.settings so that you can still access them in another cfc where you normally cannot access variables scope set here
		
		application.config.initializedAt = now();
		writeLog(file="your_api", type="information", text="Your API reloaded from ?#cgi.query_string#");
		return true;
	}

	public boolean function onRequestStart(required string targetPage) {
		request.requestID = "api_#getTickCount()#_#application.utils.udf.getRemoteIP()#";
		request.httpRequestData = getHttpRequestData();

		// Call parent to run taffy framework
		super.onRequestStart(arguments.targetPage);
		return true;
	}

	public any function onTaffyRequest(verb, cfc, requestArguments, mimeExt, headers, methodMetadata, matchedURI) {
		/* onTaffyRequest() is called after the request has been parsed and all request details are known (before passing the request to api resources)
			* This would be a good place for you to check API key validity and other non-resource-specific validation
			* Return true if the request is valid and is allowed to continue to the api resources
			* You can abort the request by returning an object - i.e. return a custom result by using noData() or representationOf()
		*/
		//content reset="true" type="text/html; charset=utf-8"; writedump(arguments);writedump(GetHttpRequestData());writedump(url); abort;

		// Currently authentication is done within each resource cfc (as it is easy and it makes sense to access all the functions we want through API Service cfc from there), if requried we can move authentication logic here instead.

		// Add log entry
		var loggingData = structNew("linked");
		loggingData["request_arguments"] = arguments.requestArguments;
		loggingData["headers"] = arguments.headers;
		application.utils.logger.addLog( "API", "Begin processing [#arguments.verb#] #arguments.matchedURI#", SerializeJSON(loggingData), "" );

		if( structKeyExists(arguments.requestArguments, "debugRequest") AND arguments.requestArguments.debugRequest ) {
			content reset="true" type="text/html; charset=utf-8";
			writedump(var=arguments, label="Arguments");
			writedump(var=GetHttpRequestData(), label="GetHttpRequestData()");
			abort;
		}

		return true;
	}

	public void function onTaffyRequestEnd(verb, cfc, requestArguments, mimeExt, headers, methodMetadata, matchedURI, parsedResponse, originalResponse, statusCode) {
		/* onTaffyRequestEnd() is called after the request has been processed by the api resources
			* This would be a good place to log/check/verify the API request & process
			* Don't need to return anything
		*/
		//content reset="true" type="text/html; charset=utf-8"; writedump(arguments);writedump(GetHttpRequestData());writedump(url); abort;

		// Add log entry
		var loggingData = structNew("linked");
		loggingData["request_arguments"] = arguments.requestArguments;
		loggingData["headers"] = arguments.headers;
		responseData = arguments.originalResponse;
		application.utils.logger.addLog( "API", "Finish processing [#arguments.verb#] #arguments.matchedURI#", SerializeJSON(loggingData), SerializeJSON(responseData) );
	
		if( structKeyExists(arguments.requestArguments, "debugResponse") AND arguments.requestArguments.debugResponse ) {
			content reset="true" type="text/html; charset=utf-8";
			writedump(var=arguments, label="Arguments");
			writedump(var=GetHttpRequestData(), label="GetHttpRequestData()");
			abort;
		}
	}

	/* We override Taffy's onError method because:
		* We want to return the error in proper case and order
			- All fields should be lower case (CF/Lucee default them to upper case)
			- Fields should be sorted in logical way (CF/Lucee sort them alphabetically)
		* We want to return the error in our format
			- Taffy's default onError method return either empty content or the error json with ERROR, DETAIL, TAGCONTEXT, and DEBUG
			- We want error to be returned as json in our format, with fields: status, message, [data], and [error] (which contains: resource, field, code, detail, [debug])
	*/
	public void function onError(required any exception, required string eventName) {
		// IMPORTANT: Do NOT call any onError or thorwError method here (unless there is propery try/catch in them) because if any error occurs in them will send the request back here again and could result in infinate looping
		// writedump(exception); abort;
		writeLog(file="your_api", type="fatal", text="onError() : #exception.message# - #exception.detail# : #getErrorTracks(exception.tagContext)#");

		try {
			// Call our Taffy error logger/handler, which we set it to taffy.bonus.LogToEmail - it will send out error email
			var logger = createObject("component", application._taffy.settings.exceptionLogAdapter).init( application._taffy.settings.exceptionLogAdapterConfig );
			logger.saveLog(exception);

			if ( structKeyExists(request, 'unhandled') and request.unhandled eq true ) {
				// This is a request to an unhandled path/page, we can just dump out error message onto screen
				content reset="true" type="text/html; charset=utf-8";
				header statuscode="500" statustext="Internal Server Error";
				writeoutput("<h1>Error 500 <small>Internal Server Error</small></h1>");
				writeoutput("<p>Oops! An error has occured.</p>");
				writeoutput("<p><strong>Error Message:</strong> #exception.message# - #exception.detail#</p>");
				if ( getEnvironment() eq "dev" ) {
					writeoutput("<h3>Exception Detail</h3>");
					writedump(exception);
					writeoutput("<h3>HTTP REQUEST DATA</h3>");
					writedump(GetHttpRequestData());
					writeoutput("<h3>REQUEST</h3>");
					writedump(request);
					writeoutput("<h3>DEBUG</h3>");
					try {
						writedump(request.debug);
					} catch (any e) {
						writeoutput("<em>DEBUG is not available</em>");
					}
					writeoutput("<h3>SESSION</h3>");
					try {
						writedump(session);
					} catch (any e) {
						writeoutput("<em>SESSION is not available</em>");
					}
					writeoutput("<h3>FORM</h3>");
					writedump(form);
					writeoutput("<h3>URL</h3>");
					writedump(url);
					writeoutput("<h3>CGI</h3>");
					writedump(cgi);
					writeoutput("<h3>APPLICATION CONFIG</h3>");
					writedump(application.config);
				}
			} else {
				// This is an API request, so return the error in proper json format
				// Get skeleton api response result data struct
				var result = application.utils.udf.api_newResultData( fieldList="status,message,timestamp" );
				result["error"] = application.utils.udf.api_newErrorData( fieldList="resource,code,detail", includeDebug=(getEnvironment() eq "dev") );
				// Prepare result
				var nowUTC = dateConvert("local2Utc", now());
				result.status = 500;
				result.message = "Internal Server Error";
				result.timestamp = dateFormat(nowUTC,"yyyy-mm-dd") & "T" & timeFormat(nowUTC,"HH:mm:ss") & "-00:00";
				// The API resource endpoint (can be in URL or FORM scope)
				if ( isDefined("endpoint") ) {
					result.error.resource = endpoint;
				}
				result.error.code = "server_500";
				result.error.detail = "Internal server error - #exception.message# - #exception.detail#";
				// Add detailed debug info if in dev
				if ( getEnvironment() eq "dev" ) {
					result.error.debug.message = exception.message;
					result.error.debug.detail = exception.detail;
					result.error.debug.stacktrace = exception.tagContext;
				}
				// Convert result to json string
				var resultJsonString = serializeJson(result); // May need to switch to use the Taffy json serialiser to make the result consistent.
				// Log it
				if ( isDefined("application.utils.logger") ) {
					application.utils.logger.addLog( "API", "Error processing #result.error.resource#", serializeJson(GetHttpRequestData()), resultJsonString );
				}
				// Get the error json out
				content reset="true" type="application/json; charset=utf-8";
				header statuscode="500" statustext="Internal Server Error";
				writeoutput( resultJsonString );
			}
		} catch (any e) {
			// Error occurs within this onError method itself, just display the error
			content reset="true" type="text/html; charset=utf-8";
			header statuscode="500" statustext="Internal Server Error";
			var linebreak = "#chr(13)##chr(10)#<br>#chr(13)##chr(10)#";
			writeoutput("Error 500 - Internal Server Error #linebreak#");
			writeoutput("Error Message: #e.message# - #e.detail# #linebreak#");
			if ( getEnvironment() eq "dev" ) {
				writedump(e);
			}
		}
	}

	/* We override Taffy's internal/core throwError method because:
		* We want to return the error in our json format
			- Taffy's internal throwError method return blank content (it only set the header status and message)
			- So we override it to return the framework internal error in proper json format
	*/
	private void function throwError(
		required numeric statusCode,
		required string msg,
		struct headers={}
	) {
		// Get skeleton api response result data struct
		var result = application.utils.udf.api_newResultData( fieldList="status,message,timestamp" );
		result["error"] = application.utils.udf.api_newErrorData( fieldList="resource,code,detail", includeDebug=false );
		// Prepare result
		var nowUTC = dateConvert("local2Utc", now());
		result.status = arguments.statusCode;
		result.message = arguments.msg;
		result.timestamp = dateFormat(nowUTC,"yyyy-mm-dd") & "T" & timeFormat(nowUTC,"HH:mm:ss") & "-00:00";
		// This API resource endpoint (can be in URL or FORM scope)
		if ( isDefined("endpoint") ) {
			result.error.resource = endpoint;
		}
		result.error.code = "server_#arguments.statusCode#";
		result.error.detail = "#arguments.msg#";
		// Convert result to json string
		var resultJsonString = serializeJson(result); // May need to switch to use the Taffy json serialiser to make the result consistent.
		// Log it
		application.utils.logger.addLog( "API", "Error processing #result.error.resource#", serializeJson(GetHttpRequestData()), resultJsonString );
		// Get the error json out
		content reset="true" type="application/json; charset=utf-8";
		addHeaders(arguments.headers);
		header statuscode="#arguments.statusCode#" statustext="#arguments.msg#";
		writeoutput( resultJsonString );
		abort;
	}

	public boolean function onMissingTemplate(required string targetPage) {
		content reset="true";
		header statuscode="404" statustext="Not Found";
		writeoutput("<p>404 - Page not found</p>");
		return true;
	}

	// ************************ Custom Methods ************************

	public boolean function isHttps() {
		if ( structkeyexists(GetHttpRequestData().headers, "X-Forwarded-Proto") and GetHttpRequestData().headers["X-Forwarded-Proto"] eq "https" ) {
			return true;
		} else if ( len(CGI.HTTPS) and listFindNoCase("Yes,On,True",CGI.HTTPS) ) {
			return true;
		} else if ( isBoolean(CGI.SERVER_PORT_SECURE) and CGI.SERVER_PORT_SECURE ) {
			return true;
		} else if ( len(CGI.SERVER_PORT) and CGI.SERVER_PORT eq "443" ) {
			return true;
		} else {
			return false;
		}
	}

	// Note: getCanonicalPath is only available in Lucee; use this function if in CF
	public string function getCanonicalPathCF(required string rawPath) hint="CF implementation of getCanonicalPath() function" {
		var canonicalPath = createObject("java", "java.io.File").init(arguments.rawPath).getCanonicalPath();
		return canonicalPath;
	}

	// Helper function to turn error tagContext info from array to a string. Useful for cflog as it can be logged as text and easier to inspect
	public string function getErrorTracks(required array tagContext) hint="Go through CF error tagContext array and return their files & line numbers in one single string" {
		var result = "|";
		for( var item in arguments.tagContext ) {
			var thisError = "#item.template#:#item.line#";
			result = result & " #thisError# |";
		}
		return result;
	}

}