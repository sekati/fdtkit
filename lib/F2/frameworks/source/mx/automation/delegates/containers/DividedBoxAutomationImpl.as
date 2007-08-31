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
import flash.events.Event;

import mx.automation.Automation;
import mx.automation.delegates.core.ContainerAutomationImpl;
import mx.containers.DividedBox;
import mx.core.mx_internal;
import mx.events.DividerEvent;

use namespace mx_internal;

[Mixin]
/**
 * 
 *  Defines the methods and properties required to perform instrumentation for the 
 *  DividedBox class. 
 * 
 *  @see mx.containers.DividedBox
 *  
 */
public class DividedBoxAutomationImpl extends ContainerAutomationImpl 
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
        Automation.registerDelegateClass(DividedBox, DividedBoxAutomationImpl);
    }   

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     * @param obj DividedBox object to be automated.     
     */
    public function DividedBoxAutomationImpl(obj:DividedBox)
    {
        super(obj);

        obj.addEventListener(DividerEvent.DIVIDER_RELEASE, recordAutomatableEvent, false, 0, true);
    }

    /**
     *  @private
     *  storage for the owner component
     */
    protected function get dBox():DividedBox
    {
        return uiComponent as DividedBox;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Replay methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Replays <code>DIVIDER_RELEASE</code> events by dispatching 
     *  a <code>DIVIDER_PRESS</code> event, moving the divider in question,
     *  and dispatching a <code>DIVIDER_RELEASE</code> event.
     */
    override public function replayAutomatableEvent(interaction:Event):Boolean
    {
        if (interaction is DividerEvent)
        {
            var dividerInteraction:DividerEvent = DividerEvent(interaction);
            
            // dispatch a pressed event (in case anyone was listening)
            var pressedEvent:DividerEvent = 
                new DividerEvent(DividerEvent.DIVIDER_PRESS);
            pressedEvent.dividerIndex = dividerInteraction.dividerIndex;
            dBox.dispatchEvent(pressedEvent);
            
            // dispatch a dragged event (in case anyone was listening)
            var draggedEvent:DividerEvent = 
                new DividerEvent(DividerEvent.DIVIDER_DRAG);
            draggedEvent.dividerIndex = dividerInteraction.dividerIndex;
            draggedEvent.delta = dividerInteraction.delta / 2;
            dBox.dispatchEvent(draggedEvent);
            
            // move the divider
            dBox.moveDivider(dividerInteraction.dividerIndex,
                        dividerInteraction.delta);
            
            dBox.validateNow();
            // dispatch a released event (the same one that was recorded)
            dBox.dispatchEvent(interaction);
            
            return true;
        }
        return super.replayAutomatableEvent(interaction);
    }

}

}
