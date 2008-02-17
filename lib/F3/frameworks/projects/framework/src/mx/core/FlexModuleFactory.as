////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2007 Adobe Systems Incorporated.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.system.ApplicationDomain;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;
import flash.utils.getDefinitionByName;
import mx.core.RSLItem;
import mx.core.RSLListLoader;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

[ExcludeClass]

/**
 *  @private
 */
public class FlexModuleFactory extends MovieClip implements IFlexModuleFactory
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
    private static const INIT_STATE:int = 0;
    
    /**
	 *  @private
	 */
	private static const RSL_START_LOAD_STATE:int = 1;
    
    /**
	 *  @private
	 */
	private static const APP_LOAD_STATE:int = 2;
    
    /**
	 *  @private
	 */
	private static const APP_START_STATE:int = 3;
    
    /**
	 *  @private
	 */
	private static const APP_RUNNING_STATE:int = 4;
    
    /**
	 *  @private
	 */
	private static const ERROR_STATE:int = 5;

    /**
	 *  @private
	 */
	private static const RSL_LOADING_STATE:int = 6;
    

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
	public function FlexModuleFactory()
    {
		super();

		var rsls:Array = info()["rsls"];
		var cdRsls:Array = info()["cdRsls"];
		        
		// Put cross-domain RSL information in the RSL list.
        var rslList:Array = [];
        var n:int;
        var i:int;
		if (cdRsls && cdRsls.length > 0)
		{
			var crossDomainRSLItem:Class = Class(getDefinitionByName("mx.core::CrossDomainRSLItem"));
			n = cdRsls.length;
			for (i = 0; i < n; i++)
			{
				// If crossDomainRSLItem is null, then this is a compiler error. It should not be null.
				var cdNode:Object = new crossDomainRSLItem(
					cdRsls[i]["rsls"],
					cdRsls[i]["policyFiles"],
					cdRsls[i]["digests"],
					cdRsls[i]["types"],
					cdRsls[i]["isSigned"]);
				
				rslList.push(cdNode);				
			}
			
		}

		// Append RSL information in the RSL list.
		if (rsls != null && rsls.length > 0)
		{
			n = rsls.length;
			for (i = 0; i < n; i++)
			{
			    var node:RSLItem = new RSLItem(rsls[i].url);
				rslList.push(node);
			}
		}

        rslListLoader = new RSLListLoader(rslList);

		mixinList = info()["mixins"];

		stop(); // Make sure to stop the playhead on the currentframe
        
		loaderInfo.addEventListener(Event.COMPLETE, moduleCompleteHandler);

	    var docFrame:int = totalFrames == 1 ? 0 : 1;

		addFrameScript(docFrame, docFrameHandler);

		// Frame 1: module factory
		// Frame 2: document class
		// Frame 3+: extra classes
	    for (i = docFrame + 1; i < totalFrames; i++)
	    {
		    addFrameScript(i, extraFrameHandler);
		}

		timer = new Timer(100);
		timer.addEventListener(TimerEvent.TIMER, timerHandler);
		timer.start();

        update();
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

  	/**
	 *  @private
	 */
	private var rslListLoader:RSLListLoader;
	
    /**
	 *  @private
	 */
	private var mixinList:Array;

    /**
	 *  @private
	 */
    private var state:int = INIT_STATE;
  
    /**
	 *  @private
	 */
	private var appReady:Boolean = false;
    
    /**
	 *  @private
	 */
	private var appLoaded:Boolean = false;
    
    /**
	 *  @private
	 */
	private var timer:Timer = null;
    /**
	 *  @private
	 */
	private var nextFrameTimer:Timer = null;
    
    /**
	 *  @private
	 */
	private var errorMessage:String = null;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

  	/**
   	 *  @private
	 *  This method is overridden in the autogenerated subclass.
   	 */
    public function create(... params):Object
    {
	    var mainClassName:String = info()["mainClassName"];
	    
		if (mainClassName == null)
	    {
            var url:String = loaderInfo.loaderURL;
            var dot:Number = url.lastIndexOf(".");
            var slash:Number = url.lastIndexOf("/");
            mainClassName = url.substring(slash + 1, dot);
	    }
	   
        var mainClass:Class = Class(getDefinitionByName(mainClassName));

        return mainClass? new mainClass() : null;
    }

  	/**
   	 *  @private
   	 */
    public function info():Object
    {
        return {};
    }

   /**
    *  @inheritDoc
    */
    public function getDefinitionByName(name:String):Object
    {
       const domain:ApplicationDomain =
		info()["currentDomain"] as ApplicationDomain; 

       var definition:Object;
       if (domain.hasDefinition(name))
          definition = domain.getDefinition(name);

       return definition;
    }

    /**
	 *  @private
	 */
    private function update():void
    {
        switch (state)
        {
            case INIT_STATE:
			{
                if (rslListLoader.isDone())
                    state = APP_LOAD_STATE;
                else
                    state = RSL_START_LOAD_STATE;
				break;
			}

            case RSL_START_LOAD_STATE:
			{
			    // start loading all the rsls
                rslListLoader.load(null,
                				   rslCompleteHandler,
                				   rslErrorHandler,
                				   rslErrorHandler,
                				   rslErrorHandler);
                state = RSL_LOADING_STATE;
                break;
            }
            case RSL_LOADING_STATE:
            {
                if (rslListLoader.isDone())
                {
                    state = APP_LOAD_STATE;
                }
                break;
			}

            case APP_LOAD_STATE:
			{
                if (appLoaded)
                {
                    deferredNextFrame();
                    state = APP_START_STATE;
                }
                break;
			}

            case APP_START_STATE:
			{
                if (appReady)
                {
            		if (mixinList && mixinList.length > 0)
            		{
            		    var n:int = mixinList.length;
            			for (var i:int = 0; i < n; i++)
            		    {
            		        var c:Class;
            		        try
            		        {
            		           c =	Class(getDefinitionByName(mixinList[i]));
            		           c["init"](this);
            		        }
            		        catch(e:Error)
            		        {
							}
            		    }
                    }

                    state = APP_RUNNING_STATE;
        			timer.removeEventListener(TimerEvent.TIMER, timerHandler);
        			// Stop the timer.
        			timer.reset();

                    dispatchEvent(new Event("ready"));
                }
                break;
			}

            case ERROR_STATE:
			{
                if (timer != null)
                {
        			timer.removeEventListener(TimerEvent.TIMER, timerHandler);
        			// stop the timer
        			timer.reset();
                }

                var tf:TextField = new TextField();
                tf.text = errorMessage;
                tf.x = 0;
                tf.y = 0;
                tf.autoSize = TextFieldAutoSize.LEFT;
                addChild(tf);
                break;
			}
        }
    }

    /**
	 *  @private
	 */
    public function autorun():Boolean
    {
        return true;
    }

    /**
	 *  @private
	 */
    private function displayError(msg:String):void
    {
        errorMessage = msg;
        state = ERROR_STATE;
        update();
    }
	
    /**
	 *  @private
	 */
	private function docFrameHandler(event:Event = null):void
	{
		// Register singleton classes.
		// Note: getDefinitionByName() will return null
		// if the class can't be found.

		Singleton.registerClass("mx.managers::IBrowserManager",
			Class(getDefinitionByName("mx.managers::BrowserManagerImpl")));

        Singleton.registerClass("mx.managers::ICursorManager",
			Class(getDefinitionByName("mx.managers::CursorManagerImpl")));

        Singleton.registerClass("mx.managers::IDragManager",
			Class(getDefinitionByName("mx.managers::DragManagerImpl")));

        Singleton.registerClass("mx.managers::IHistoryManager",
			Class(getDefinitionByName("mx.managers::HistoryManagerImpl")));

        Singleton.registerClass("mx.managers::ILayoutManager",
			Class(getDefinitionByName("mx.managers::LayoutManager")));

        Singleton.registerClass("mx.managers::IPopUpManager",
			Class(getDefinitionByName("mx.managers::PopUpManagerImpl")));

		Singleton.registerClass("mx.resources::IResourceManager",
			Class(getDefinitionByName("mx.resources::ResourceManager")));

        Singleton.registerClass("mx.styles::IStyleManager",
			Class(getDefinitionByName("mx.styles::StyleManagerImpl")));

        Singleton.registerClass("mx.styles::IStyleManager2",
			Class(getDefinitionByName("mx.styles::StyleManagerImpl")));

        Singleton.registerClass("mx.managers::IToolTipManager2",
			Class(getDefinitionByName("mx.managers::ToolTipManagerImpl")));

		appReady = true;
        
        // The resources must be installed before update() creates components
		// (such as DateChooswer) that might need them immediately.
		installCompiledResourceBundles();
		
		update();
        
		if (currentFrame < totalFrames)
            deferredNextFrame();
    }

    /**
	 *  @private
	 */
	private function installCompiledResourceBundles():void
	{
		//trace("FlexModuleFactory.installCompiledResourceBundles");

		var info:Object = this.info();
		
		var applicationDomain:ApplicationDomain =
            info["currentDomain"];

		var compiledLocales:Array /* of String */ =
			info["compiledLocales"];

		var compiledResourceBundleNames:Array /* of String */ =
			info["compiledResourceBundleNames"];
		
		var resourceManager:IResourceManager =
			ResourceManager.getInstance();
		
		resourceManager.installCompiledResourceBundles(
			applicationDomain, compiledLocales, compiledResourceBundleNames);

		// If the localeChain wasn't specified in the FlashVars of the SWF's
		// HTML wrapper, or in the query parameters of the SWF URL,
		// then set it to the list of compiled locales.
		// For example, if the applications was compiled with, say,
		// -locale=en_US,ja_JP, then set the localeChain to
		// [ "en_US", "ja_JP" ].
		if (!resourceManager.localeChain)
			resourceManager.localeChain = compiledLocales;
	}

    /**
	 *  @private
	 */
    private function deferredNextFrame():void
    {
        if (currentFrame + 1 <= framesLoaded)
		{
            nextFrame();
		}
        else
        {
            // Next frame isn't baked yet, we'll check back...
    		nextFrameTimer = new Timer(100);
		    nextFrameTimer.addEventListener(TimerEvent.TIMER,
											nextFrameTimerHandler);
		    nextFrameTimer.start();
        }
    }
    /**
	 *  @private
	 */
	private function extraFrameHandler(event:Event = null):void
	{
	    var frameList:Object = info()["frames"];

	    if (frameList && frameList[currentLabel])
	    {
	        var c:Class;
	        try
	        {
	            c = Class(getDefinitionByName(frameList[currentLabel]));
	            c["frame"](this);
	        }
	        catch(e:Error)
	        {
			}
	    }

	    if (currentFrame < totalFrames)
            deferredNextFrame();
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
    private function rslCompleteHandler(event:Event):void
    {
        update();
    }

    /**
	 *  @private
	 */
    private function rslErrorHandler(event:Event):void
    {
        var rsl:RSLItem = rslListLoader.getItem(rslListLoader.getIndex());
        
        trace("RSL " + rsl.urlRequest.url + " failed to load.");
        displayError("RSL " + rsl.urlRequest.url + " failed to load.");
    }

    /**
	 *  @private
	 */
    private function moduleCompleteHandler(event:Event):void
    {
        appLoaded = true;
		update();
    }

    /**
	 *  @private
	 */
	private function timerHandler(event:TimerEvent):void
	{
	    if (totalFrames > 2 && framesLoaded >= 2 || 
			framesLoaded == totalFrames)
		{
            appLoaded = true;
		}
		
		update();
    }

    /**
	 *  @private
	 */
	private function nextFrameTimerHandler(event:TimerEvent):void
	{
	    if (currentFrame + 1 <= framesLoaded)
	    {
	        nextFrame();
            nextFrameTimer.removeEventListener(TimerEvent.TIMER,
											   nextFrameTimerHandler);
        	// stop the timer
        	nextFrameTimer.reset();
        }
    }
}

}