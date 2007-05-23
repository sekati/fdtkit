/*////////////////////////////////////////////////////////////////////////////////////////

  swfIN 1.0.3  -  2007-03-29
  javascript toolkit for flash developers
  © 2004-2007 Francis Turmel  |  swfIN.nectere.ca  |  www.nectere.ca  |  francis@nectere.ca
  released under the MIT license

/*////////////////////////////////////////////////////////////////////////////////////////

  1.0 GENERAL USAGE
	This is an example on how to use the Flash player detection and embed/object features of swfIN


	//create the swfIN  |  [required]  |  path to SWF (string), movie's ID (string), width (int: pixel value OR string with trailing %: percent value)
	var f = new swfIN("movie.swf", "movieID", "100%", "100%");
	
	//force a minimum size when resizing browser or screen resolution too small |  [optional]  |  width (int: pixel value), height (int: pixel value)
	f.minSize(800, 600);
	
	//tell the script to use expressInstall (works with swfObject's expressInstall.as)  |  [optional]  | no arguments
	f.useExpressInstall();
	
	//player requirements & action if requirements are not met  |  [optional]  |  required flash version (int), type of action (string), extras[...]
	//*** see documentation section 2.0 in documentation for details on using actions
	f.detect(8, true, "r", "update.html", true);
	
	//flashvars  |  [optional]  |  flashVar name (string), flashVar value (string)
	f.addVar("hello", "test");  //direct value
	//f.addVar( "hello", fd.tools.getQsParam("hello") );  //read through querystring as  index.html?hello=test
	//f.addVars( fd.tools.getQs() );  //pass the whole querystring as params - notice the method's name: .addVars()
	
	//embed/object params  |  [optional]  |  param name (string), param value (string)
	f.addParam("bgcolor", "#400000");
	f.addParam("menu", "false");
	
	//write the tag  |  [required]
	f.write();


/*////////////////////////////////////////////////////////////////////////////////////////

  2.0 ACTIONS
	Description of all the possible actions if the Flash player requirements are not met
	note: These are always used in the .detect() method, and this method's first argument is always the Flash Player version required
  
  
  2.1 Redirection  |  "r"  |  Redirects to a given URL with optional GET variables

	- Simple redirection (relative and absolute paths are supported)
		.detect(8, "r", "upgrade.html");
	
	- Using GET variables  |  will append ?r=10&i=9 to the upgrade.html call, where "r" is the required Flash player version, and "i" is the installed Flash player version
		.detect(8, "r", "upgrade.html", true);
		
		Note: The GET vars can be read back in with if you include swfIN.js again in the redirect page to make personalized error messages.
			fd.tools.getParam("r");
			fd.tools.getParam("i");


  2.2 Image  |  "i"  |  Shows an image at the exact place the .write() method is called

	- Image with no <a> tag  (relative and absolute paths are supported)
		.detect(8, "i", "image.jpg", "none");
	
	- Image with default flash upgrade <a> tag to macromedia's site
		.detect(8, "i", "image.jpg");
	
	- Image with a custom <a> tag
		.detect(8, "i", "image.jpg", "http://www.google.com");


  2.3 Show div  |  "d"  |  Shows a hidden div tag on the page
	Notes: Will not work with NS4 or IE5 on mac
	
	- Shows a hidden div tag, by ID name
		.detect(8, "d", "flash_update");
	
	* Example of a correctly formated div tag (note: it also needs to be declared before the .write() method is called)
		<div id="flash_update" style="display:none">This is the upgrade div tag</div>


  2.4 HTML  |  "h"  |  Raw HTML output
	Note: Due to old code, you cannot use a ":" symbol surrounded by spaces like this:   " : "   or your string will be truncated
	This will be fixed very soon.

	- Output raw HTML
		.detect(8, "h", "<i>please update your flash player</i>");


/*////////////////////////////////////////////////////////////////////////////////////////
  3.0 ADDITIONAL IMPORTANT NOTES ON FUNCTIONALITIES AND RESTRICTIONS

	- Use the compressed version for production, the file size is about 50% lighter
	
	- express install will work on player 6.0.65.0 and up. If the user has a lower version than this, it will behave
	as if you didn't specify using express install (it will redirect or whatever you tell it to do in the .detect() method)
	
	- You can use several swfIN instances on the same page, and they will all be updated on window.resize. The only restriction is that they
	all need to have a unique ID
	
	- For the % and .minSize() to be very precise, the page needs to have 0 borders as follows:
	<style type="text/css">  body {margin:0; padding:0}   </style>
	
	- You can use the querystring param:  index.html?bypassFlashCheck=true   to bypass all flash checks in a page
	
	- Your SWF will automatically be wrapped isnide a div tag named in this fashion: div_idname  (where idname is the id you gave your SWF upon instanciation)
	
	- swLiveConnect communication (javascript -> flash) doesn't seem possible for ns4 and ie5_mac
	
	- The only doctype supported for now is:
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
	
	- The default params for the embed/object tag are:
		quality = "high";
		menu = "false";
		swLiveConnect = "true";
		pluginspage = "http://www.macromedia.com/go/getflashplayer";
		allowScriptAccess = "always";
		
		** they can all be overwritten using the .addParam() method
		
		
		Here's a bunch of params you can use. Google them or check out Adobe's reference for more infos.
		I left a couple out on purpose since internal code already manages params like id, movie, width, height for example.
		http://www.adobe.com/cfusion/knowledgebase/index.cfm?id=tn_12701
		
		play
		loop
		menu
		quality
		scale
		align
		salign
		wmode
		bgcolor
		base
		devicefont
		allowScriptAccess
		seamlesstabbing
		swLiveConnect


/*////////////////////////////////////////////////////////////////////////////////////////
  4.0 OTHER TOOLS
	Since swfIN has been created as a toolkit for Flash developers, here is a rundow of the available tools you can use in addition to
	the Flash player detection / embed solution.

	- Read a querystring variable (returns a string)
		fd.tools.getQsParam(key);
	
	- Read the full querystring ( returns an array in the format qs[key] = value )
		fd.tools.getQs();
	
	- Resize the swf on the fly  |  this will resize the automatically generated div tag that contains the swf
		fd.size.resizeDiv(swfID, width, height);
	
	- Change minSize  |  this will change the forced minimum size of a swf on the fly (after writing the tag) and force a refresh
		fd.size.changeMinSize(swfID, width, height);
	
	- Detection for problematic browsers (returns a boolean)
		Netscape 4
			fd.tools.ns4();
		
		Internet Explorer 5 on Mac
			fd.tools.ie5_mac();
		
		Internet Explorer 7
			fd.tools.ie7();

	- Browser size (returns an object as  {w:100, h:200} - where obj.w is the width and obj.h is the height of the browser)
		fd.tools.browserSize();
	
	- Screen size (returns an object as {w:100, h:200} - where obj.w is the width and obj.h is the height of the screen).
		- Available screen size
			fd.tools.screenSize("avail");
		
		- Full resolution screen size
			fd.tools.screenSize("full");
	
	- Prototype-style shortcut for getElementByID()
		$id(id);
	
	- standalone Flash player version checker (returns the installed version as int, 0 if not installed)	
		fd.tools.getFlashVersion();
	
	- popUp utility  |  Lets you popup up windows with several options
		fd.tools.popUp(html_page, window_name, width, height, x, y, extras);
		
		ex:
		fd.tools.popUp("update.html", "windowName", "full", "full", "center", "center", {resizable:1}); //fullscreen centered
		fd.tools.popUp("update.html", "windowName", "500", "full", "100", "center", {resizable:1});  //500px width, fullscreen height, x = 100 and y (verticaly) centered to screen.
		fd.tools.popUp("update.html", "windowName", "800", "600", "center", "center", {resizable:1, location:1});  //800x600 centered, resizable and with location bar
		
		notes:
		- here's a list of the extras you can use (they all default to 0 - false)
			
			toolbar  //Specifies whether to display the toolbar in the new window.
			location  //Specifies whether to display the address line in the new window.
			directories  //Specifies whether to display the Netscape directory buttons.
			status  //Specifies whether to display the browser status bar.
			menubar  //Specifies whether to display the browser menu bar.
			scrollbars  //Specifies whether the new window should have scrollbars.
			resizable  //Specifies whether the new window is resizable.
			copyhistory  //Whether or not to copy the old browser window's history list to the new window. does it work?
			fullscreen   //IE only fullscreen mode - it goes above the taskbar...
		
	
	
	
	
	
	- Coming soon:	
		- History manager
	

  
/*////////////////////////////////////////////////////////////////////////////////////////
  5.0 BROWSER COMPATIBILITY
	Latest browser compatibility tests, as of version 1.0.0 RC
	*** To all developers, please send your browser testings stats and report bugs: info@nectere.ca

	Windows XP
		Firefox 2.0 Beta 1  |  OK
		Internet Explorer 6  |  OK
		Internet Explorer 7  |  OK, but can't detect the Flash Player version yet, so it acts like the installed player is version 15 to force embed
		Opera 9  |  OK
		Netscape 4.78  |  OK, but no showDiv action, swLiveConnect impossible, window.resize will reload the whole page
		Mozilla 1.7.13  |  OK
		Netscape 7.2  |  OK
		Netscape 8.1  |  OK

	OS X
		Firefox 1.0.4  |  OK
		Safari 2.0.3  |  OK
		Internet Explorer 5.2.3  |  OK, but no showDiv action, swLiveConnect impossible
		Camino 1.0.2  |  OK
		Opera 9.0  |  OK, but weird refresh bug when resizing the window
		Netscape 7.1  |  OK

	//TODO
	Older Windows platforms
	OS 9 (mostly IE 5 - NS 4)
	Linux & others (Konqueror)


/*////////////////////////////////////////////////////////////////////////////////////////
  6.0 MIT LICENSE  |  http://www.opensource.org/licenses/mit-license.php
  
	Copyright (c) 2004-2007 Francis Turmel  |  swfIN.nectere.ca  |  www.nectere.ca  |  francis@nectere.ca
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
	documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
	rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
	INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
	PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
	FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  
