////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation.tabularData
{

import mx.automation.AutomationManager;
import mx.automation.IAutomationTabularData;
import mx.collections.CursorBookmark;
import mx.collections.errors.ItemPendingError;
import mx.controls.listClasses.ListBase;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.List;
import mx.core.mx_internal;
use namespace mx_internal;

/**
 *  @private
 */
public class ListBaseTabularData
    implements IAutomationTabularData
{

    private var list:ListBase;

    /**
     *  Constructor
     */
    public function ListBaseTabularData(l:ListBase)
    {
		super();

        list = l;
    }

    /**
     *  @inheritDoc
     */
    public function get firstVisibleRow():int
    {
		var listItems:Array = list.rendererArray;

		if (listItems && listItems.length && listItems[0].length)
            return list.itemRendererToIndex(listItems[0][0])
    	return 0;
    }
    
    /**
     *  @inheritDoc
     */
    public function get lastVisibleRow():int
    {
		var listItems:Array = list.rendererArray;

		if (listItems && listItems.length && listItems[0].length)
        {
	        var row:int = listItems.length - 1;
	        var col:int = listItems[0].length - 1;
	        while (!listItems[row][col] && row >= 0 && col >= 0)
	        {
	            if (col != 0)
	                col --;
	            else if (row != 0)
	            {
	                row--;
	                col = listItems[0].length - 1;
	            }
	        }
        
	        return (row >= 0 && col >= 0 
    	            ? list.itemRendererToIndex(listItems[row][col]) 
        	        : numRows);
        }
        
        return 0;
    }

    /**
     *  @inheritDoc
     */
    public function get numRows():int
    {
        return (list.collectionIterator ? list.collectionIterator.view.length : 0);
    }

    /**
     *  @inheritDoc
     */
    public function get numColumns():int
    {
        return 1;
    }

    /**
     *  @inheritDoc
     */
    public function get columnNames():Array
    {
        return [ "" ];
    }

    /**
     *  @inheritDoc
     */
    public function getValues(start:uint = 0, end:uint = 0):Array
    {
        //empty list of column names for list, dg overrides
        var values:Array = [ ];
		if (list.collectionIterator)		
		{
            var bookmark:CursorBookmark = list.collectionIterator.bookmark;
            var i:int = start;
    		var more:Boolean = true;
            list.collectionIterator.seek(CursorBookmark.FIRST, start);
    		
		    while (more && !list.collectionIterator.afterLast && 
		           (i <= end))
		    {
                var data:Object = list.collectionIterator.current;
                var curRowValues:Array = getAutomationValueForData(data);
                
                values.push(curRowValues);

				try 
				{
					more = list.collectionIterator.moveNext();
				}
				catch (e:ItemPendingError)
				{
					more = false;
				}

			    ++i;
		    }

		    // reset to previous iterator position
		    list.collectionIterator.seek(bookmark, 0);
        }

        return values;
    }
    
    /**
     *  @inheritDoc
     */
    public function getAutomationValueForData(data:Object):Array
    {
    	return [];
    }
}
}
