////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers
{

import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.utils.Dictionary;
import flash.utils.Timer;
import mx.core.Application;
import mx.core.mx_internal;
import mx.core.Singleton;
import mx.managers.IHistoryManagerClient;
import mx.managers.HistoryManagerGlobals;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class HistoryManagerImpl implements IHistoryManager
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Implementation notes
	//
	//--------------------------------------------------------------------------

	/*
		HistoryManager works in conjunction with certain components
		and with an invisible "history SWF".

		The history SWF
		---------------

		The HTML wrapper for an MXML application contains an invisible iframe
		named _history which contains history.swf.

		This SWF's sole purpose is to encode state information for the 
		MXML application in the query parameters of its URL.
		
		HistoryManager-aware components
		-------------------------------
				
		In order to support history management, a component must implement
		the IHistoryManagerClient interface and must register with HistoryManager.

		When the application state is considered to have changed, someone
		must call <code>HistoryManager.save()</code>; in response, the HistoryManager calls
		the <code>saveState()</code> method of all the registered components.

		Each registered component returns an Object containing arbitrary
		state information such as { selectedIndex: 1 }.

		HistoryManager encodes the state information for all registered
		components into the query parameters of a URL for the history SWF.
		For example, the query parameters might be
		
		    ?ce41-selectedIndex=1&10f7-selectedIndex=2
		
		In order to keep the length of the URL within the browser's limits,
		the identity of the component is specified by a short hash string
		(such as "ce41" or "1047" above) computed from its toString() string.

		The <code>save()</code> method reloads the _history iframe with the new URL
		that contains the MXML apps' state info in its query parameters.

		The browser stores these various URLs, representing various states
		of the application, in its history cache.
		
		When the user clicks the browser's Back button, the browser loads
		a previous URL into the _history iframe. This causes the history.swf
		to be reloaded.
		
		When the history.swf is reloaded, it decodes its URL and calls
		HistoryManager.load(). HistoryManager then calls the loadState()
		methods of all registered components. It ensures that loadState()
		is called on shallowly nested components before being called
		on more deeply nested components, so that, for example, an Accordion
		inside a ViewStack works properly.

		Handshakes
		----------
		
		HistoryManager is initialized when the application starts.
		
		When HistoryManager is initialized by the init() method,
		it periodically attempts to contact the history.swf
		using a LocalConnection to determine whether it has been loaded
		and has completed its own initialization.

		The "handshake" consists of the following sequence:
			HistoryManager.initHandshake()
			register() in history.swf
			HistoryManager.registered()
		
		A corresponding handshake is initiated by the initApp() method
		of the history.swf.

		It consists of the following sequence:
			initHandshake() in history.swf
			HistoryManager.registerHandshake()
			registered() in history.swf
			HistoryManager.load()

	*/

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 *  The interval between handshake attempts.
	 */
	private static const HANDSHAKE_INTERVAL:int = 500; // milliseconds

	/**
	 *  @private
	 *  The maximum number of handshake attempts.
	 */
	private static const MAX_HANDSHAKE_TRIES:int = 100;
	
	/*
	 *  The following three constants are used to encode state information
	 *  about multiple objects into the query parameters of an URL.
	 *  The query parameters might look like this:
	 *  ?8ce2-selectedIndex=1&47f0-selectedIndex=2
	 */
	
	/**
	 *  @private
	 *  The separator between the object identifier (the crc of its path)
	 *  and the property name.
	 */
	private static const ID_NAME_SEPARATOR:String = "-";
	
	/**
	 *  @private
	 *  The separator between the property name and the property value.
	 */
	private static const NAME_VALUE_SEPARATOR:String = "=";
	
	/**
	 *  @private
	 *  The separator between consecutive object/property/value triples.
	 */
	private static const PROPERTY_SEPARATOR:String = "&";
	
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
    private static var systemManager:ISystemManager;

	/**
	 *  @private
	 */
	private static var instance:IHistoryManager;

	/**
	 *  @private
	 *  CRC for the app.
	 */
	private static var appID:String;

	/**
	 *  @private
	 *  Session-unique local connection id.
	 *  This is passed to the SWF via the FlashStatic Vars in the HTML wrapper,
	 *  and is currently a randomly-generated hex string such as "eb8b".
	 */
	private static var lconID:String;

	/**
	 *  @private
	 *  URL for history frame.
	 *  This is passed to the SWF via the FlashStatic Vars in the HTML wrapper,
	 *  and is currently "/dev/flex-internal?action=history_html".
	 */
	private static var historyURL:String;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():IHistoryManager
	{
		if (!instance)
		{
			systemManager = SystemManagerGlobals.topLevelSystemManagers[0];
		    instance = new HistoryManagerImpl();
		}

		return instance;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function HistoryManagerImpl()
	{
		super();

		if (instance)
		    throw new Error("Instance already exists.");

		if (appID)
			return;
		var loaderInfo:LoaderInfo;
		
		// Added to support Cross-versioning issue,
		// so one needs to set the Singleton.loaderInfo object
		// to the loaderInfo of the top-most object
		if (HistoryManagerGlobals.loaderInfo)
		{
		    loaderInfo = HistoryManagerGlobals.loaderInfo;
		}
		else
		{
		    // Get values that were passed in via the FlashVars
			// in the HTML wrapper.
		    loaderInfo = DisplayObject(systemManager).loaderInfo;
		}
			
		lconID = loaderInfo.parameters.lconid;
		historyURL = loaderInfo.parameters.historyUrl;

		if (!lconID || !historyURL)
			return;
		
		var appURL:String;

		// Use our URL as the unique CRC for this movie.
		if (HistoryManagerGlobals.loaderInfo) 
		    appURL = HistoryManagerGlobals.loaderInfo.url;
		else 
		    appURL = DisplayObject(systemManager).loaderInfo.url;


		appID = calcCRC(appURL);
		// Set up a LocalConnection for communicating with the history.swf.
		lc = new MainLocalConnection();
		lc.allowDomain("~", "localhost");
		lc.addEventListener(StatusEvent.STATUS, statusHandler);
		lc.connect(appID + lconID);

		lcinit = new InitLocalConnection();
		lcinit.addEventListener(StatusEvent.STATUS, statusHandler);
		lcinit.allowDomain("~", "localhost");
		try
		{
			lcinit.connect("init" + lconID);
		}
		catch (error:Error)
		{
			// Ignore error.
			// If you try to load multiple applications on the same HTML page,
			// the init connection will fail for the second
			// (and any subsequent) app.
		}
		
		// Start trying to contact the history.swf.
		handshakeTimer = new Timer(HANDSHAKE_INTERVAL, MAX_HANDSHAKE_TRIES);
		handshakeTimer.addEventListener(TimerEvent.TIMER, initHandshake);
		handshakeTimer.start();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  @private
	 *  A flag that keeps track of whether the history.swf
	 *  has returned the handshake that HistoryManager sent.
	 */
	private var isRegistered:Boolean = false;
														
	/**
	 *  @Private
	 *  An Array of objects that will save and load state information.
	 *  Each object must implement the IHistoryManagerClient interface.
	 */
	private var registeredObjects:Array = [];
	
	/**
	 *  @private
	 *  A map from a registed object's path to its RegistrationInfo
	 *  (path crc and path depth).
	 */
	private var registrationMap:Dictionary;

	/**
	 *  @private
	 *  Pending states for deferred restoration.
	 */
	private var pendingStates:Object = {};

	/**
	 *  @private
	 *  Timer for periodically contacting the history.swf.
	 */
	private var handshakeTimer:Timer;

	/**
	 *  @private
	 *  Main local connection for communicating with history.swf.
	 *  It has the methods loadState(), register(), and registered().
	 */
	private var lc:MainLocalConnection;

	/**
	 *  @private
	 *  Special local connection used for init only.
	 *  It has the methods loadInitialState().
	 */
	private var lcinit:InitLocalConnection;
	
	/**
	 *  @private
	 *  Pending query string to be sent to history.swf.
	 */
	private var pendingQueryString:String;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Registers an object with the HistoryManager.
	 *  The object must implement the IHistoryManagerClient interface.
	 *
	 *  @param obj Object to register.
	 *
	 *  @see mx.managers.IHistoryManagerClient
	 */	
	public function register(obj:IHistoryManagerClient):void
	{
		// Ensure that this object isn't already registered.
		unregister(obj);
		
		// Add the object to the Array of all registered objects.
		registeredObjects.push(obj);
				
		// Get a "path" string such as "Application_1.VBox0.hb:HBox.main:
		// Panel.bodyStack:ViewStack.checkoutView:VBox.accordion:Accordion"
		// that uniquely represents this object in the visual hierarchy
		// of the application.
		var path:String = getPath(obj);
		
		// Calculate a 4-character hex CRC of this path as a short
		// identifier for the object to be encoded into the
		// query parameters of the history URL.
		var crc:String = calcCRC(path);
		
		// Determine the depth of the object in the visual hierarchy.
		// This is important because state must be restored
		var depth:int = calcDepth(path);
		
		// Store the crc and depth of the registered object in a
		// RegistrationInfo instance kept in the HistoryManager's
		// registrationMap. Given a registed object, we can look up
		// its crc and depth using getRegistrationInfo().
		if (!registrationMap)
			registrationMap = new Dictionary();
		registrationMap[obj] = new RegistrationInfo(crc, depth);
		
		// Sort the Array of all registered objects according to their depth.
		registeredObjects.sort(depthCompare);
		
		// See if there is a pending state for this object.
		if (pendingStates[crc])
		{
			obj.loadState(pendingStates[crc]);
			delete pendingStates[crc];
		}
	}

	/**
	 *  @private
	 */
	private function getPath(obj:IHistoryManagerClient):String
	{
		return obj.toString();
	}
	
	/**
	 *  @private
	 *  Function to calculate a cyclic rendundancy checksum (CRC).
	 *  This returns a 4-character hex string representing a 16-bit uint
	 *  calculated from the specified string using the CRC-CCITT mask.
	 *  In http://www.joegeluso.com/software/articles/ccitt.htm,
	 *  the following sample input and output is given to check
	 *  this implementation:
	 *  "" -> "1D0F"
	 *  "A" -> "9479"
	 *  "123456789" -> "E5CC"
	 *  "AA...A" (256 A's) ->"E938"
	 */
	private function calcCRC(s:String):String
	{
		var crc:uint = 0xFFFF;

		// Process each character in the string.
		var n:int = s.length;
		for (var i:int = 0; i < n; i++)
		{
			var charCode:uint = s.charCodeAt(i);
			
			// Unicode characters can be greater than 255.
			// If so, we let both bytes contribute to the CRC.
			// If not, we let only the low byte contribute.
			var loByte:uint = charCode & 0x00FF;
			var hiByte:uint = charCode >> 8;
			if (hiByte != 0)
				crc = updateCRC(crc, hiByte);
			crc = updateCRC(crc, loByte);
		}

		// Process 2 additional zero bytes, as specified by the CCITT algorithm.
		crc = updateCRC(crc, 0);
		crc = updateCRC(crc, 0);

		return crc.toString(16);
	}

	/**
	 *  @private
	 */
	private function updateCRC(crc:uint, byte:uint):uint
	{
		const poly:uint = 0x1021; // CRC-CCITT mask

		var bitMask:uint = 0x80;

		// Process each bit in the byte.
		for (var i:int = 0; i < 8; i++)
		{
			var xorFlag:Boolean = (crc & 0x8000) != 0;
			
			crc <<= 1;
			crc &= 0xFFFF;

			if ((byte & bitMask) != 0)
				crc++;

			if (xorFlag)
				crc ^= poly;

			bitMask >>= 1;
		}

		return crc;
	}

	/**
	 *  @private
	 */
	private function calcDepth(path:String):int
	{
		return path.split(".").length;
	}
	
	/**
	 *  @private
	 */
	private function depthCompare(a:Object, b:Object):int
	{
		var regInfoA:RegistrationInfo = getRegistrationInfo(IHistoryManagerClient(a));
		var regInfoB:RegistrationInfo = getRegistrationInfo(IHistoryManagerClient(b));
		
		// Guard against the possibility of an object's 
		// registration info not being found.
		if (!regInfoA || !regInfoB)
			return 0;
		
		if (regInfoA.depth > regInfoB.depth)
			return 1;
		
		if (regInfoA.depth < regInfoB.depth)
			return -1;
			
		return 0;
	}
	
	/**
	 *  @private
	 */
	private function getRegistrationInfo(
								obj:IHistoryManagerClient):RegistrationInfo
	{
		return registrationMap ? registrationMap[obj] : null;
	}
	
	/**
	 *  Unregisters an object with the HistoryManager.
	 *
	 *  @param obj Object to unregister.
	 */
	public function unregister(obj:IHistoryManagerClient):void
	{
		// Find the index of the object in the Array of all
		// registered objects; -1 means not found.
		var index:int = -1;
		var n:int = registeredObjects.length;
		for (var i:int = 0; i < n; i++)
		{
			if (registeredObjects[i] == obj)
			{
				index = i;
				break;
			}
		}
			
		// If the object was found in the Array, remove it.
		if (index >= 0)
			registeredObjects.splice(index, 1);
		
		// Remove it from the map as well.
		if (obj && registrationMap)
			delete registrationMap[obj];
	}

	/**
	 *  Saves the application's current state so it can be restored later.
	 *  This method is automatically called by navigator containers
	 *  whenever their navigation state changes.
	 *  If you registered an interface with the HistoryManager,
	 *  you are responsible for calling the <code>save()</code> method
	 *  when the application state changes.
	 */	
	public function save():void
	{
		if (!isRegistered)
			return;
		var haveState:Boolean = false;

		// Query string always starts with the application identifier.
		var queryString:String = "app=" + appID;
		
		// Call saveState() on every registered object
		// to get an Object containing its state information.
		var n:int = registeredObjects.length;
		for (var i:int = 0; i < n; i++)
		{
			var registeredObject:IHistoryManagerClient = registeredObjects[i];
			var stateInfo:Object = registeredObject.saveState();
				
			// stateInfo might be something like { selectedIndex: 1 }
			
			// Encode the stateInfo into the query string, building up
			// a string like "ce41-selectedIndex=1&10f7-selectedIndex=2"
			// that specifies objects (via the crcs of their paths),
			// property names, and property values.
			var crc:String = getRegistrationInfo(registeredObject).crc;
			for (var name:String in stateInfo)
			{
				var value:Object = stateInfo[name];
				
				if (queryString.length > 0)
					queryString += PROPERTY_SEPARATOR;
				queryString += crc;
				queryString += ID_NAME_SEPARATOR;
				queryString += escape(name);
				queryString += NAME_VALUE_SEPARATOR;
				queryString += escape(value.toString());
				haveState = true;
			}
		}
		
		// If any registered objects specified any state information to save,
		// reload the history SWF with an URL that encodes all the state info.
		if (haveState)
		{
			pendingQueryString = queryString;
			Application.application.callLater(this.submitQuery);
		}
	}
	
	/**
	 *  @private
	 *  Reloads the _history iframe with the history SWF.
	 */
	private function submitQuery():void
	{
		if (pendingQueryString)
		{
			var url:String = historyURL + "&" + pendingQueryString;
			navigateToURL(new URLRequest(url), "_history");
			pendingQueryString = null;
			Application.application.resetHistory = true;
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  This method is called periodically by the handshakeTimer
	 *  to try to contact the history.swf by calling its register() method.
	 *  The register() method in the history.swf
	 *  responds by calling the registered() method below
	 */
	private function initHandshake(event:TimerEvent):void
	{
		lc.send("history" + lconID, "register", appID + lconID);
	}
	
	/**
	 *  @private
	 *  This method is called if there is an error during a local connection.
	 *  We ignore the errors, but need to install a handler for them in order
	 *  to prevent an "unhandled status event" RTE.
	 */
	private function statusHandler(event:StatusEvent):void
	{
	    //	    trace(event.level + " " + event.code);
	}

	//--------------------------------------------------------------------------
	//
	//  Class LocalConnection handlers called by history.swf
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Called by the register() method of the history.swf
	 *  to return the handshake we sent in initHandshake().
	 *  HistoryManager.save() doesn't nothing until this method is called,
	 *  since the history.swf must be ready to store the query parameters.
	 */
	public function registered():void
	{
		if (!isRegistered)
		{
			// We've successfully registered with the HistoryManager.
			isRegistered = true;
			// Kill the handshake timer since it is no longer needed.
			handshakeTimer.reset();
			handshakeTimer = null;
		}
	}
	
	/**
	 *  @private
	 *  Called by the initHandshake() method of history.swf.
	 *  This method responds to its handshake by calling the
	 *  registered() method of history.swf.
	 *  history.swf will then call loadState() below.
	 */
	public function registerHandshake():void
	{
		// Return the handshake.
		lc.send("history" + lconID, "registered");
	}
	
	/**
	 *  @private
	 *  Loads state information.
	 *  Called by the registered() method of history.swf
	 *  after we have returned its handshake.
	 *
	 *  @param stateVars State information.
	 */
	public function load(stateVars:Object):void
	{
		// Whenever we save state (by calling the save() method), load is called
		// to load the state we just saved. Most of the time this is harmless
		// (loadState methods are written to not do anything if they are at the
		// current state), but sometimes we get into timing issues where we are
		// loading a state that is older than the last state we saved.
		// To work around this, we ignore any load that immediately follows a 
		// call to save().
		if (Application.application.resetHistory)
		{
			Application.application.resetHistory = false;
			return;
		}
		var p:String;
		var crc:String;
			
		var params:Object = {};

		// Unpack the stateVars into parameter objects for each state interface.
		// stateVars looks like
		//   { ce41-selectedIndex: 1, 10f7-selectedIndex: 2 }
		// params will look like
		//   { ce41: { selectedIndex: 1 }, 10f7: { selectedIndex: 2 } }
		for (p in stateVars)
		{
			var crclen:int = p.indexOf(ID_NAME_SEPARATOR)
			if (crclen > -1)
			{
				crc = p.substr(0, crclen);
				var name:String = p.substr(crclen + 1, p.length);
				var value:Object = stateVars[p];
				
				if (!params[crc])
					params[crc] = {};
				
				params[crc][name] = value;
			}
		}		
		
		// Call loadState() on all registered objects.
		var n:int = registeredObjects.length;
		for (var i:int = 0; i < n; i++)
		{
			var registeredObject:IHistoryManagerClient = registeredObjects[i];
			crc = getRegistrationInfo(registeredObject).crc;

			registeredObject.loadState(params[crc]);
			delete params[crc];
		}
		
		// Save off any remaining state variables in the pendingStates object.
		// This way the state can be restored if the interface
		// is instantiated later.
		for (p in params)
		{
			pendingStates[p] = params[p];
		}

	}

	/**
	 *  @private
	 */
	public function loadInitialState():void
	{
		// Load up the initial application state.
		if (!Application.application.resetHistory)
			load({});
		
		Application.application.resetHistory = false;
	}
}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: RegistrationInfo
//
////////////////////////////////////////////////////////////////////////////////

/**
 *  @private
 */
class RegistrationInfo
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function RegistrationInfo(crc:String, depth:int)
	{
		super();

		this.crc = crc;
		this.depth = depth;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public var crc:String;

	/**
	 *  @private
	 */
	public var depth:int;
}
