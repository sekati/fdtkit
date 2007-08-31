////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation.events
{

import flash.events.Event;

/**
 * The TextSelectionEvent class lets you track selection within a text field.
 */
public class TextSelectionEvent extends Event
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  The <code>TextSelectionEvent.TEXT_SELECTION_CHANGE</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a <code>textSelectionChange</code> event.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>beginIndex</code></td><td>Index at which selection starts.</td></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>endIndex</code></td><td>Index at which selection ends.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType textSelectionChange
     */
    public static const TEXT_SELECTION_CHANGE:String = "textSelectionChange";
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function TextSelectionEvent(type:String = "textSelectionChange",
                                       bubbles:Boolean = false,
                                       cancelable:Boolean = false,
                                       beginIndex:int = -1,
                                       endIndex:int = -1)
    {
        super(type, bubbles, cancelable);

        this.beginIndex = beginIndex;
        this.endIndex = endIndex;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  beginIndex
    //----------------------------------

    /**
     *  Index at which selection starts.
     */
    public var beginIndex:int;
    
    //----------------------------------
    //  endIndex
    //----------------------------------

    /**
     *  Index at which selection ends.
     */
    public var endIndex:int;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function clone():Event
    {
        return new TextSelectionEvent(type, bubbles, cancelable, 
                                      beginIndex, endIndex);
    }    
}

}
