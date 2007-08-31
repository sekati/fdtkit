////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation.delegates.controls 
{
import flash.display.DisplayObject;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.automation.Automation;
import mx.core.mx_internal;
import mx.controls.ToggleButtonBar;

use namespace mx_internal;

[Mixin]
/**
 * 
 *  Defines methods and properties required to perform instrumentation for the 
 *  ToggleButtonBar control.
 * 
 *  @see mx.controls.ToggleButtonBar 
 *
 */
public class ToggleButtonBarAutomationImpl extends ButtonBarAutomationImpl 
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
        Automation.registerDelegateClass(ToggleButtonBar, ToggleButtonBarAutomationImpl);
    }   

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     * @param obj ToggleButtonBar object to be automated.     
     */
    public function ToggleButtonBarAutomationImpl(obj:ToggleButtonBar)
    {
        super(obj);
    }

    /**
     *  @private
     *  storage for the owner component
     */
    protected function get tbar():ToggleButtonBar
    {
        return uiComponent as ToggleButtonBar;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        switch (event.keyCode)
        {
            case Keyboard.PAGE_DOWN:
            case Keyboard.PAGE_UP:
            case Keyboard.HOME:
            case Keyboard.END:
            case Keyboard.SPACE:
            case Keyboard.ENTER:
                recordAutomatableEvent(event);
                break;
                
            default:
            {
                super.keyDownHandler(event);
            }
        }
    }
        
}

}