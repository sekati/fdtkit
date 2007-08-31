////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation.delegates.containers
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;

import mx.automation.Automation;
import mx.automation.IAutomationObject;
import mx.automation.IAutomationObjectHelper;
import mx.automation.delegates.core.ContainerAutomationImpl;
import mx.core.Application;
import mx.core.mx_internal;
import mx.core.IUIComponent;
import mx.events.FlexEvent;

use namespace mx_internal;

[Mixin]
/**
 * 
 *  Defines the methods and properties required to perform instrumentation for the 
 *  Application class. 
 * 
 *  @see mx.core.Application
 *  
 */
public class ApplicationAutomationImpl extends ContainerAutomationImpl
{
    
    include "../../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Registers the delegate class for a component class with automation manager.
     */
    public static function init(root:DisplayObject):void
    {
        Automation.registerDelegateClass(Application, ApplicationAutomationImpl);
    }   

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     * @param obj Application object to be automated.     
     */
    public function ApplicationAutomationImpl(obj:Application)
    {
        super(obj);
        recordClick = true;
    }
    
    /**
     *  @private
     */
    protected function get application():Application
    {
        return uiComponent as Application;      
    }
    
    /**
     *  @private
     */
    override protected function componentInitialized():void
    {
        super.componentInitialized();
        // Override for situations where an app is loaded into another
        // application. Find the Flex loader that contains us.
        var owner:IAutomationObject = application.owner as IAutomationObject;

        if (owner == null && application.systemManager.isTopLevel() == false)
        {
            try
            {
                var findAP:DisplayObject = application.parent;
                
                owner = findAP as IAutomationObject;
                while (findAP != null &&
                       !(owner))
                {
                    findAP = findAP.parent;
                    owner = findAP as IAutomationObject;
                }
        
                application.owner = owner as DisplayObjectContainer;
            }
            catch (e:Error)
            {
            }
        }
    }
    
}

}