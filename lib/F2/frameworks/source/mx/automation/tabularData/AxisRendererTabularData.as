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

import mx.charts.AxisRenderer;
import mx.charts.chartClasses.AxisLabelSet;
import mx.automation.AutomationManager;
import mx.automation.IAutomationObject;
import mx.automation.IAutomationTabularData;
import mx.core.mx_internal;
import mx.charts.chartClasses.AxisLabelSet;
use namespace mx_internal;

/**
 *  @private
 */
public class AxisRendererTabularData
    implements IAutomationTabularData
{

    private var axis:AxisRenderer;
    private var axisDelegate:IAutomationObject;

    /**
     *  @private
     */
    public function AxisRendererTabularData(l:IAutomationObject)
    {
		super();

        this.axisDelegate = l;
        this.axis = l as AxisRenderer;
    }

    /**
     *  @private
     */
    public function get firstVisibleRow():int
    {
    	return 0;
    }
    
    /**
     *  @private
     */
    public function get lastVisibleRow():int
    {
    	var labelSet:AxisLabelSet = axis.getAxisLabelSet();
        return labelSet.labels.length;
    }

    /**
     *  @private
     */
    public function get numRows():int
    {
    	var labelSet:AxisLabelSet = axis.getAxisLabelSet();
        return labelSet.labels.length;
    }

    /**
     *  @private
     */
    public function get numColumns():int
    {
        return 1;
    }

    /**
     *  @private
     */
    public function get columnNames():Array
    {
        return ["labels"];
    }

    /**
     *  @private
     */
    public function getValues(start:uint = 0, end:uint = 0):Array
    {
    	var labelSet:AxisLabelSet = axis.getAxisLabelSet();
    	var labels:Array = labelSet.labels;
        var length:int = labels.length;
        var _values:Array = [];
        for(var i:int = start; i <= end; ++i)
        	_values.push( [ labels[i].text ] );
        return _values;
    }
    
    /**
     *  @private
     */
    public function getAutomationValueForData(data:Object):Array
    {
    	return [];
    }
}
}
