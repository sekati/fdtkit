////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.skins.halo
{

import flash.display.GradientType;
import mx.skins.Border;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

/**
 *  The skin for the track in a Slider.
 */
public class SliderTrackSkin extends Border 
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
	public function SliderTrackSkin()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  measuredWidth
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredWidth():Number
	{
		return 200;
	}

	//----------------------------------
	//  measuredHeight
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredHeight():Number
	{
		return 4;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
    /**
	 *  @private
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{	
		super.updateDisplayList(w, h);

		// User-defined styles.
		var borderColor:Number = getStyle("borderColor");
		var fillAlphas:Array = getStyle("fillAlphas");
		var fillColors:Array = getStyle("trackColors") as Array;
		StyleManager.getColorNames(fillColors);
		
		// Derivative styles.
		var borderColorDrk:Number =
			ColorUtil.adjustBrightness2(borderColor, -50);
		
		graphics.clear();
		
		drawRoundRect(0,0,w,h,0,0,0); // Draw a transparent rect to fill the entire space
		
		drawRoundRect(
			1, 0, w, h - 1, 1.5,
			borderColorDrk, 1, null,
			GradientType.LINEAR, null,
			{ x: 2, y: 1, w: w - 2, h: 1, r: 0 });

		drawRoundRect(
			2, 1, w - 2, h - 2, 1,
			borderColor, 1, null,
			GradientType.LINEAR, null,
			{ x: 2, y: 1, w: w - 2, h: 1, r: 0 });
		
		drawRoundRect(
			2, 1, w - 2, 1, 0,
			fillColors, Math.max(fillAlphas[1] - 0.3, 0),
			horizontalGradientMatrix(2, 1, w - 2, 1));
	}
}

}
