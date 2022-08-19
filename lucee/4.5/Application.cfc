/*
    Application.cfc (For Lucee)
    http://docs.lucee.org/guides/cookbooks/application-context-basic.html
    https://helpx.adobe.com/coldfusion/cfml-reference/application-cfc-reference.html
*/
component {

    /*
        Application variables
        https://cfdocs.org/application-cfc
        http://docs.lucee.org/reference/tags/application.html
        https://helpx.adobe.com/coldfusion/cfml-reference/application-cfc-reference/application-variables.html
    */
    this.name = "MyAppName";
    this.applicationTimeout = createTimeSpan(1,0,0,0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0,0,30,0);
    this.timeout = 60;
    this.requestTimeout = this.timeout;
    this.setClientCookies = true; // Whether to send CFID and CFTOKEN cookies to the client browser. If set to false CFID & CFTOKEN must be passed in via URL.
    this.setDomainCookies = false; // Whether to set CFID and CFTOKEN cookies for a domain (not just a host).
    this.locale = "English (Australian)"; // Lucee only - https://cfdocs.org/setlocale
    this.timezone = "Australia/Sydney"; // Lucee only - http://www.javadb.com/list-possible-timezones-or-zoneids-in-java/
    this.scriptProtect = "all"; // all|none, or a combination of: form, url, cookie, cgi
    this.secureJSON = true; // Protection to JSON hijacking
    this.secureJSONPrefix = "//";
    // A structure of mappings. The logical path is the key and the absolute path is the value.
    this.mappings = {
        "/CFIDE" = expandPath('/path/to/cfide'),
        "/API" = expandPath('../api')
    };
    // Lucee's way of specify multiple datasources
    this.datasources["myDSN_local"] = {
        class: 'org.gjt.mm.mysql.Driver'
        , connectionString: 'jdbc:mysql://127.0.0.1:3306/my_database?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true'
        , username: 'root'
        , password: "encrypted:..."
        , blob: true // default: false
        , clob: true // default: false
        , connectionLimit: 10 // default:-1
    };
    this.datasource = "myDSN_local";
    this.defaultDatasource = this.datasource;

    /*
    // List of custom tag paths
    this.customTagPaths = [
        expandPath('/org/webqem/'),
        expandPath('/org/tomy/')
    ];
    // Lucee only - list of component paths
    this.componentPaths = [
        expandPath('/org/webqem/'),
        expandPath('/org/tomy/')
    ];
    this.sessionType = "j2ee"; // Lucee only - cfml|j2ee - cfml: session handled by Lucee; j2ee: session handled by the Servlet Engine; Use j2ee to make sessions over a clusterto or share session with a Java application.
    this.clientManagement = false;
    this.clientTimeout = createTimeSpan(90,0,0,0);
    this.sessionStorage = "memory"; // Lucee only - file|memory|cookie|<datasource-name>|<cache-name>
    this.clientStorage = "cookie"; // file|memory|cookie|<datasource-name>|<cache-name>
    this.loginStorage = "cookie"; // cookie||session
    this.sessionCluster = true; // Lucee only - If set to true, Lucee uses the storage backend for the session scope as master and checks for changes in the storage backend with every request. Set to false (default), the storage is only used as slave, Lucee only initially gets the data from the storage. Ignored for storage type "memory".
    this.clientCluster = true; // Lucee only - If set to true, Lucee uses the storage backend for the client scope as master and checks for changes in the storage backend with every request. Set to false (default), the storage is only used as slave, Lucee only initially gets the data from the storage. Ignored for storage type "memory".
    this.compression = true; // Lucee only - Enable GZip compression.
    this.invokeImplicitAccessor = true; // Enable auto getter and setter (e.g. set<ValueName>()) when you call Component.<valueName>
    this.localMode = "modern"; // Lucee only - modern|classic - Defines how the local scope is invoked; modern: local scope is invoked always even variable does not exist in the local scope; classic: local scope is only invoked when variable already exists in the local scope.
    this.scopeCascading = "small"; // Lucee only - strict|small|standard - Define how Lucee scans certain scopes to find a variable when it is called without a scope; strict: scans only the variables scope; small: scans the scopes variables,url,form; standard: scans the scopes variables,cgi,url,form,cookie.
    this.wstype = "Axis1"; // Lucee only - Axis1|CXF
    this.onmissingtemplate = "path/to/cfm"; // Lucee only - Closure/udf executed when the requested template does not exist
    this.bufferOutput = true; // Lucee only - True: output written to the body of the tag is buffered and in case of a exception also outputted. False: the content to body is ignored and not disabled when a failure in the body of the tag occur.
    this.suppressRemoteComponentContent = false; // Lucee only - Suppress content written to response stream when a component is invoked remotely.
    */

    // ORM settings see: https://helpx.adobe.com/coldfusion/developing-applications/coldfusion-orm/configure-orm/orm-settings.html;
    // also see: http://www.compoundtheory.com/how-i-configure-coldfusion-orm-and-why/
    this.ormEnabled = true;
    this.ormsettings = {
        //dialect = "MySQL", // Usually don't need to specify this, CF will detect automatically
        cfcLocation = [expandPath('/app/common/model/')], // Array of directories to beans
        dbCreate = "update", // none|update|dropcreate - Auto update, or drop-then-create db tables base on beans
        autoGenMap = true, // If false, mapping should be provided in the form of .HBMXML files.
        logSql = true,
        //catalog = "", // DB catalog - usually only needed if you want ORM to access multiple databases
        //schema = "", // DB schema - usually only needed if you want ORM to access multiple databases
        namingStrategy = "default", // default: Use the logical table or column name as it is; smart: Change the logical table or column name to uppercase. If the logical table or column name is in camel case, this strategy breaks the camelcased name and separates them with underscore; your_own_cfc : You can get complete control of the naming strategy by providing your own implementation.
        saveMapping = false, // Turn this on to save the Hibernate config xml files to disk (for inspection/debug) - NOTE: If this is on, you may need to manually delete these xml files, or delete the compiled class (/WEB-INF/cfclasses) and restart CF in order for new (updated) xml files being generated and used for ORM
        useDBForMapping = true, // Set to false to improve ORM reload time (so CF won't inspect database to figure out the mappings). If it is false then we need to make sure every properties will have a ORM type and other settings set properly
        eventHandling = false, // Turn on even handling and we can use functions such as preUpdate(), postUpdate() in our bean cfc - See: http://therealdanvega.com/blog/2009/12/22/coldfusion-9-orm-event-handlers-use-case
        //evenHandler = "path.to.cfc", // Custom global ORM event handler cfc
        //sqlScript = "path.to.sql", // Path to SQL script file that gets executed after ORM is initialized. This applies if dbcreate is set to dropcreate
        //secondaryCacheEnabled = false, // Specifies whether secondary caching should be enabled.
        //cacheProvider = "ehcache", // Specifies the cache provider that should be used by ORM as secondary cache.
        //cacheconfig = "path.to.config", // Specifies the location of the configuration file that should be used by the secondary cache provider.
        // Set below two settings to false so we have complete control on Hibernate session. The only thing happens automatically is that session is flushed when a transaction commits
        flushAtRequestEnd = false, // Set this to false, we need to control ORM Flush - don't let CF do it automatically at the end of a request
        autoManageSession = false // Also set this to false, then 1). Stop Hibernate session being flushed at the beginning of a transaction; 2). Stop Hibernate session being cleared when a transaction is rolled back
    };

    /*
        onApplicationStart
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onApplicationStart
        If return false or throw an exception, the application context will not be initialized and the next request will call "onApplicationStart" again.
    */
    public boolean function onApplicationStart() {
        return true;
    }

    /*
        onApplicationEnd
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onApplicationEnd
        Argument is the application scope that ends.
    */
    public void function onApplicationEnd(struct applicationScope={}) {
        return;
    }

    /*
        onSessionStart
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onSessionStart
    */
    public void function onSessionStart() {
        return;
    }

    /*
        onSessionEnd
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onSessionEnd
        Arguments are application scope and the session scope that ends.
    */
    public void function onSessionEnd(required struct sessionScope, struct applicationScope={}) {
        return;
    }

    /*
        onRequestStart
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onRequestStart
        Return false to prevent ColdFusion from processing the request and return the result to the client.
        Argument is the requested template page.
    */
    public boolean function onRequestStart(required string targetPage) {
        // Reload application by using URL.reload=1
        if (isDefined("URL.reload") and URL.reload) {
            onApplicationStart();
        }
        return true;
    }

    /*
        onRequest
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onRequest
        This method is optional. If you implement this method, it must explicitly call the requested page to process it.
        Argument is the requested template page.
    */
    public void function onRequest(required string targetPage) {
        include arguments.targetPage;
        return;
    }

    /*
        onCFCRequest
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onCFCRequest
        Intercepts any HTTP or AMF calls to an application based on CFC request (Ajax, Web Service, and Flash Remoting).
        Arguments are the dot path to cfc component, the component method, and the argument collection.
    */
    public void function onCFCRequest(string cfcname, string method, struct args) {
        invoke(cfcname, method, args);
        return;
    }

    /*
        onRequestEnd
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onRequestEnd
    */
    public void function onRequestEnd() {
        return;
    }

    /*
        onAbort
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onAbort
        Runs when you execute <cfabort> or "abort" in cfscript.
        If showError attribute is specified in cfabort, onError method is executed instead of onAbort.
        When using cfabort, cflocation, or cfcontent tags, the onAbort method is invoked instead on onRequestEnd.
        Argument is the requested template page.
    */
    public void function onAbort(required string targetPage) {
        dump("request aborted - " & targetPage);
        return;
    }

    /*
        onError
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onError
        Arguments are the exception (cfcatch block) and the eventName.
    */
    public void function onError(required any exception, required string eventName) {
        dump(var:exception, label:eventName);
        return;
    }

    /*
        onMissingTemplate
        https://wikidocs.adobe.com/wiki/display/coldfusionen/onMissingTemplate
        Return false to invoke the standard error handler.
        Argument is the requested template page.
    */
    public boolean function onMissingTemplate(required string targetPage) {
        dump("missing: " & targetPage);
        return true;
    }

}
