////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.binding
{

import mx.rpc.IResponder;

[ExcludeClass]

/**
 *  @private
 *  This responder is a fallback in case the set or get methods
 *  we are invoking to implement this binding do not properly
 *  catch the ItemPendingError.  There may be some issues with
 *  leaving this in long term as we are not handling the
 *  case where this binding is executed multiple times in
 *  rapid succession (and thus piling up responders) and
 *  also not dealing with a potential stale item responder.
 */
public class EvalBindingResponder implements IResponder
{
    include "../core/Version.as";

 	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Constructor.
	 */
    public function EvalBindingResponder(binding:Binding, object:Object)
    {
		super();

        this.binding = binding;
        this.object = object;
    }

 	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
    private var binding:Binding;
    
	/**
	 *  @private
	 */
	private var object:Object;

 	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
    public function result(data:Object):void
    {
        binding.execute(object);
    }

	/**
	 *  @private
	 */
    public function fault(data:Object):void
    {
       // skip it
    }
}

}
