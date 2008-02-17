////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.containers.utilityClasses
{

import mx.core.Container;
import mx.core.EdgeMetrics;
import mx.core.IFlexDisplayObject;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  The ApplicationLayout class is for internal use only.
 */
public class ApplicationLayout extends BoxLayout
{
	include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function ApplicationLayout()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Lay out children as per Application layout rules.
	 */
	override public function updateDisplayList(unscaledWidth:Number,
											   unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		var target:Container = super.target;

		// If there are scrollbars, and any children are at negative
		// co-ordinates, make adjustments to bring them into the visible area.
		if ((target.horizontalScrollBar && getHorizontalAlignValue() > 0) ||
			(target.verticalScrollBar && getVerticalAlignValue() > 0))
		{
			var paddingLeft:Number = target.getStyle("paddingLeft");
			var paddingTop:Number = target.getStyle("paddingTop");
			var oX:Number = 0;
			var oY:Number = 0;

			var n:int = target.numChildren;
			var i:int;
			var child:IFlexDisplayObject;

			for (i = 0; i < n; i++)
			{
				child = IFlexDisplayObject(target.getChildAt(i));

				if (child.x < paddingLeft)
					oX = Math.max(oX, paddingLeft - child.x);

				if (child.y < paddingTop)
					oY = Math.max(oY, paddingTop - child.y);
			}

			if (oX != 0 || oY != 0)
			{
				for (i = 0; i < n; i++)
				{
					child = IFlexDisplayObject(target.getChildAt(i));
					child.move(child.x + oX, child.y + oY);
				}
			}
		}
	}
}

}
