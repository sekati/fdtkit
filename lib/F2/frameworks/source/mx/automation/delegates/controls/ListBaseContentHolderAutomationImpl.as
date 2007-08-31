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
import flash.events.Event;
import flash.events.KeyboardEvent;

import mx.automation.Automation;
import mx.automation.IAutomationObject;
import mx.automation.delegates.core.UIComponentAutomationImpl;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.core.mx_internal;

use namespace mx_internal;

[Mixin]
/**
 * 
 *  Defines methods and properties required to perform instrumentation for the 
 *  ListBaseContentHolder class.
 * 
 *  @see mx.controls.listClasses.ListBaseContentHolder 
 *
 */
public class ListBaseContentHolderAutomationImpl extends UIComponentAutomationImpl 
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
        Automation.registerDelegateClass(ListBaseContentHolder, ListBaseContentHolderAutomationImpl);
    }   

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     * @param obj ListBaseContentHolder object to be automated.     
     */
    public function ListBaseContentHolderAutomationImpl(obj:ListBaseContentHolder)
    {
        super(obj);
        
        obj.addEventListener(Event.ADDED, addedHandler, false, 0, true);
    }
    
    /**
     *  @private
     *  storage for the owner component
     */
    protected function get listContent():ListBaseContentHolder
    {
        return uiComponent as ListBaseContentHolder;
    }
    
    /**
     *  @private
     *  The super handler makes the child a composite if the parent is already a composite.
     *  We have overriden here to revert that.
     */
    protected function addedHandler(event:Event):void 
    {
        if (event.target is IListItemRenderer)
        {
            var item:IListItemRenderer = event.target as IListItemRenderer;
            if(item.parent == listContent)
            {
                item.owner = listContent.getParentList();
                if(item is IAutomationObject)
                    IAutomationObject(item).showInAutomationHierarchy = true;
            }
        }
    }
    
    /**
     *  @private
     */
	override protected function keyDownHandler(event:KeyboardEvent):void
	{
		//no recording required
	}
    
}

}