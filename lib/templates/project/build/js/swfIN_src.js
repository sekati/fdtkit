/*////////////////////////////////////////////////////////////////////////////////////////

  swfIN 1.0.3  -  2007-03-29
  javascript toolkit for flash developers
  © 2004-2007 Francis Turmel  |  swfIN.nectere.ca  |  www.nectere.ca  |  francis@nectere.ca
  released under the MIT license

/*////////////////////////////////////////////////////////////////////////////////////////

// Main project
var fd = {};
fd.showFlash = function(movie, id, params, flashVars, w, h, requiredVersion, action, expressInstall){
	
	//define vars & consts
	if (fd.movies == null) fd.movies = [];
	if (requiredVersion == null) requiredVersion = 0;
	var installed_version = fd.tools.getFlashVersion();
	var codebase = "http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version="+requiredVersion+",0,0,0";
	if (fd.player_download == null) fd.player_download = "http://www.macromedia.com/go/getflashplayer";
	
	//6.0.65  is the minimum version that supports express install...
	fd.tryExpressInstall = (installed_version < requiredVersion && expressInstall && installed_version >= 6);

	//parse action string
	(action != null) ? action = action.split(" : ") : action = "";
	
	// Parse action
	if (installed_version >= requiredVersion || fd.tools.getQsParam("bypassFlashCheck") == "true" || fd.tryExpressInstall){
		//Flash player OK or Bypass == true, printout the swf tag
		fd.actions.outputTag(movie, id, params, flashVars, w, h, codebase);
	}else if(action[0] == "r"){
		//redirect to page
		fd.actions.redirect(action[1], action[2], requiredVersion, installed_version);
	}else if(action[0] == "i"){
		//show image
		fd.actions.image(action[1], action[2]);
	}else if (action[0] == "d"){
		//show hidden div content
		fd.actions.showDiv(action[1]);
	}else if (action[0] == "h"){
		//output raw HTML
		fd.actions.html(action[1]);
	}
	
	//make sure no other swfs have the same ID - if one does, warn the dev with an alert() so that he can fix this
	for (var i=0; i<fd.movies.length; i++){
		if(fd.movies[i] == id) alert("swfIN alert:\nYou cannot name two swfs by the same id. Please revise your swfs IDs in your swfIN() instanciation.");
	}
	
	//push this new movie in here
	fd.movies.push(id);
};


// Actions if player requirements not met
fd.actions = {
	////////////////////////////////////////////////////////////
	// Output embed/object tag for swf
	outputTag: function(movie, id, params, flashVars, w, h, codebase){
		
		//express install stuff
		if(fd.tryExpressInstall){
			
			flashVars["MMplayerType"] = (fd.tools.nsPlugin()) ? "PlugIn": "ActiveX";
			document.title = document.title.slice(0, 47) + " - Flash Player Installation";
			flashVars["MMdoctitle"] = document.title;
			flashVars["MMredirectURL"] = escape(window.location);
			
		}
		
		//append flash vars to swf path
		var fv = "";
		for (var k in flashVars){
			fv += ( fv == "" ) ? k + "=" + escape(flashVars[k]) : "&" + k + "=" + escape(flashVars[k]);
		}
		
		//param/name array DEFAULTS
		var p = [];
		p["quality"] = "high";
		p["menu"] = "false";
		p["swLiveConnect"] = "true";
		p["pluginspage"] = fd.player_download;
		p["allowScriptAccess"] = "always";  //"always"  ? this might be needed for express install
		p["FlashVars"] = fv;
		
		//then use user's version to override the default
		for (var i in params) p[i] = params[i];
		
		
		//NS4 will need the exact w and h in the obj
		var obj_w, obj_h;
		if ( !fd.tools.ns4() ){
			obj_w = "100%";
			obj_h = "100%";
		}else{
			obj_w = fd.size.calculate(w, "w");
			obj_h = fd.size.calculate(h, "h");
		}
		
		
		//only use codebase for IE7 since we can't detect the version... All the other browsers should use express install or redirection
		var cb = (fd.tools.ie7())? "codebase='"+codebase+"'" : "" ;
		
		
		//compile the object & embed tag
		//var tag = "<object classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='"+codebase+"' id='"+id+"' width='"+obj_w+"' height='"+obj_h+"' align='top' hspace='0' vspace='0'><param name='movie' value='"+movie+"'>";
		var tag = "<object classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' "+cb+" id='"+id+"' width='"+obj_w+"' height='"+obj_h+"' align='top' hspace='0' vspace='0'><param name='movie' value='"+movie+"'>";
		for (var i in p) tag += "<param name='"+i+"' value='"+p[i]+"'>";
		tag += "<embed src='"+movie+"' width='"+obj_w+"' height='"+obj_h+"' align='top' hspace='0' vspace='0' type='application/x-shockwave-flash' name='"+id+"' ";
		for (var i in p) tag += i+"='"+p[i]+"' ";
		tag += "></embed></object>";
		
		//output
		if ( !fd.tools.ns4() ){
			//not NS4, append the div tag
			var a = "<div id='div_"+id+"' style='width:"+ fd.size.calculate(w, "w") +"; height:"+ fd.size.calculate(h, "h") +"'>" + tag + "</div>";
			document.write(a);
			//alert(a);
			
			//little hack to refresh content, fixes a bug in IE when used inside a table
			if( fd.tools.ie() ) $id("div_" + id).innerHTML = $id("div_" + id).innerHTML;
			
			//remember the initial w/h settings
			$id("div_" + id).fd_w = w;
			$id("div_" + id).fd_h = h;
			
		}else{
			//ns4, output directly the embed/object, no div since it can't change the width/height
			document.write(tag);
		}
		
	},
	
	////////////////////////////////////////////////////////////
	// Redirect to page
	redirect: function(url, getVars, required, installed){
		if ( getVars == "true" ){
			location.href = url + "?r=" + required + "&i=" + installed;	
		}else{
			location.href = url;		
		} 
	},
	
	////////////////////////////////////////////////////////////
	// Show image
	image: function(img_path, url){
		if (url == "none"){
			//print out image with no <a> tag
			document.write("<img src='"+img_path+"' border=0 />");
		}else{
			//if no URL specified, use the default macromedia download
			//else, use the one specified
			if (url == null) url = fd.player_download;
			document.write("<a href='"+url+"' target='_blank'><img src='"+img_path+"' border=0 /></a>");
		}
	},
	
	////////////////////////////////////////////////////////////
	// Show hidden div  -  Not compatible with ns4 and ie5_mac
	showDiv: function(id){
		if ( !fd.tools.ns4() && !fd.tools.ie5_mac() ){
			$id(id).style.display="block";
		}
	},
	
	////////////////////////////////////////////////////////////
	// Output raw HTML
	html: function(html){
		document.write(html);
	}
	
};


// Size and refresh related methods
fd.size = {
	////////////////////////////////////////////////////////////
	// Returns good value to use with height and width
	calculate: function(val, type){
		
		//only parse if there's a " : " in val
		if ( val.indexOf(" : ") != -1 ){
			//parse and check minimum display size
			val = val.split(" : ");
			
			//if the first value is a percent value, use it to modify comparison
			var t_val = val[0].split("%");
			
			//define multiplier
			var multiplier = (t_val[0] != "" && t_val[1] != null) ? (t_val[0] / 100) : 1;
			
			//compare window
			var pixelVal = fd.tools.browserSize()[type] * multiplier;
			var res = (val[1] > pixelVal || val[1] == "") ? val[1] : val[0];
			
			//force to have the correct type
			if(res.indexOf("%") > -1){
				return res;
			}else{
				return res + "px";
			}
			
			
		}else{
			
			if(val.indexOf("%") > -1){
				return val;
			}else{
				return val + "px";
			}
			
		}
		
	},
	
	////////////////////////////////////////////////////////////
	// Called by the window.resize
	refresh: function(){
		if ( !fd.tools.ns4() ){
			//batch-check all movies in the page
			for (var id in fd.movies){
				
				//change the DIV tag's property if this object exists
				if ( $id("div_" + fd.movies[id]) ){
					
					//get size to use
					var w = fd.size.calculate($id("div_" + fd.movies[id]).fd_w , "w");
					var h = fd.size.calculate($id("div_" + fd.movies[id]).fd_h , "h");
					
					$id("div_" + fd.movies[id]).style.width = w;
					$id("div_" + fd.movies[id]).style.height = h;
					
				}
			}
		}else{
			//ns4, force a redraw because of that old stupid window.resize refresh bug
			location.reload();
		}
	},
	
	////////////////////////////////////////////////////////////
	// force a manual resize of the div
	resizeDiv: function(id, w, h){
		//split values
		var old_w = $id("div_" + id).fd_w.split(" : ");
		var old_h = $id("div_" + id).fd_h.split(" : ");
		
		//write new values
		$id("div_" + id).fd_w = (old_w[1] == null) ? w : w + " : " + old_w[1];
		$id("div_" + id).fd_h = (old_h[1] == null) ? h : h + " : " + old_h[1];
		
		//alert($id("div_" + id).fd_w + " " + $id("div_" + id).fd_h);
		
		//force refresh
		fd.size.refresh();
	},
	
	////////////////////////////////////////////////////////////
	// to change the minSize on the fly after writing the div
	changeMinSize: function(id, w, h){
		//split values
		var old_w = $id("div_" + id).fd_w.split(" : ");
		var old_h = $id("div_" + id).fd_h.split(" : ");
		
		//write new values
		$id("div_" + id).fd_w = old_w[0] + " : " + w;
		$id("div_" + id).fd_h = old_h[0] + " : " + h;
		
		//alert($id("div_" + id).fd_w + " " + $id("div_" + id).fd_h);
		
		//force refresh
		fd.size.refresh();
	},
	
	percent2pixel: function(){
		return 0;
	}
	
};


// General tools
fd.tools = {
	////////////////////////////////////////////////////////////
	// Get querystring param
	getQsParam: function(key){
		var tmp = fd.tools.getQs()[key];
		return (tmp != null && tmp != undefined && tmp != "") ? tmp : null ;
	},
	
	////////////////////////////////////////////////////////////
	// Get full querystring, will return an array
	getQs: function(){
		var params = window.location.search.substring(1).split("&");
		var qs=[];
		
		for (var i=0; i<params.length; i++) { //var i in params not supported by IE on mac! ouch..
			var pos = params[i].indexOf("=");
			if (pos > 0) qs[params[i].substring(0,pos)] = params[i].substring(pos+1);
		}
		
		return qs;
	},
	
	////////////////////////////////////////////////////////////
	// Simple detections for problematic browsers  http://www.webreference.com/programming/javascript/detection/3.html
	ns4: function(){
		return (document.layers) ? true : false;		
	},
	
	ie5_mac: function(){
		var user_agent = navigator.userAgent.toLowerCase();
		return (user_agent.indexOf("msie 5") != -1 && user_agent.indexOf("mac") != -1);
	},
	
	ie7: function(){
		var user_agent = navigator.userAgent.toLowerCase();
		return (user_agent.indexOf("msie 7") != -1);
	},
	
	ie: function(){
		var user_agent = navigator.userAgent.toLowerCase();
		return (user_agent.indexOf("msie") != -1);
	},
	
	mac: function(){
		var user_agent = navigator.userAgent.toLowerCase();
		return (user_agent.indexOf("mac") != -1);
	},
	
	nsPlugin: function(){
		return (navigator.plugins && navigator.mimeTypes && navigator.mimeTypes.length);
	},
	
	////////////////////////////////////////////////////////////
	// Get width and height of browser (supports old browsers). Returns an object.
	browserSize: function(){
		if (self.innerWidth){
			return {w: self.innerWidth, h: self.innerHeight};
		}else if (document.documentElement && document.documentElement.clientWidth){
			return {w: document.documentElement.clientWidth, h: document.documentElement.clientHeight};
		}else if (document.body){
			return {w: document.body.clientWidth, h: document.body.clientHeight};
		}
		
		return false;
	},

	////////////////////////////////////////////////////////////
	// Returns installed Flash version
	getFlashVersion: function(){
		//IE activeX detection
		document.writeln('<script language="VBscript">');
		document.writeln('Function detectActiveXControl(activeXControlName)');
		document.writeln('  on error resume next');
		document.writeln('  detectActiveXControl = False');
		document.writeln('  detectActiveXControl = IsObject(CreateObject(activeXControlName))');
		document.writeln('End Function');
		document.writeln('</scr'+'ipt>');
		
		var installedVersion = 0;
		var b = navigator.userAgent.toLowerCase();
		
		if ( (b.indexOf('msie') != -1) && (b.indexOf('win') != -1) && (b.indexOf('opera') == -1) ) {
			
			//IE
			if ( fd.tools.ie7() ){
				//IE7 - for now IMPOSSIBLE TO DETECT, so return a high version and try to embed anyways with a codebase
				installedVersion = 15;
				
			}else{
				//IE6 and less
				for (var i=3; i<15; i++){
					if(detectActiveXControl("ShockwaveFlash.ShockwaveFlash."+i) == true) installedVersion = i;
				}
			}
			
		} else {
			//Other browsers
			if (navigator.plugins["Shockwave Flash"]) {
				var pluginDesc = navigator.plugins["Shockwave Flash"].description;
				installedVersion = parseInt( pluginDesc.charAt( pluginDesc.indexOf(".")-1 ) );
			}
			
			//webTV
			if(b.indexOf("webtv/2.6") != -1) installedVersion = 4;
			if(b.indexOf("webtv/2.5") != -1) installedVersion = 3;
			if(b.indexOf("webtv") != -1) installedVersion = 2;
			
		}
		
		return installedVersion;	
	},
	
	screenSize: function(type){
		//type can be "full", or "avail"
		if(type == "full") return {w: screen.width, h: screen.height}; 
		if(type == "avail") return {w: screen.availWidth, h: screen.availHeight};
		return false;
	},
	
	////////////////////////////////////////////////////////////
	// popUp window launcher
	popUp: function(url, name, w, h, x, y, params){
		
		//check fullscreen and center stuff
		var scr2 = fd.tools.screenSize("full");
		var scr = fd.tools.screenSize("avail");
		w = (w == "full") ? scr.w : w;
		h = (h == "full") ? scr.h : h;
		
		//always center from fullscreen size
		x = (x == "center") ? (scr2.w - w) / 2 : x;
		y = (y == "center") ? (scr2.h - h) / 2 : y;
		
		//define all extra params
		var p = [];
		p["width"] = w;
		p["innerWidth"] = w;
		p["height"] = h;
		p["innerHeight"] = h;
		//--use moveTo() instead, it remembers the monitor where the launcher was
		//p["left"] = x;
		//p["screenX"] = x
		//p["top"] = y;
		//p["screenY"] = y;
		p["toolbar"] = 0; //Specifies whether to display the toolbar in the new window.
		p["location"] = 0; //Specifies whether to display the address line in the new window.
		p["directories"] = 0; //Specifies whether to display the Netscape directory buttons.
		p["status"] = 0; //Specifies whether to display the browser status bar.
		p["menubar"] = 0; //Specifies whether to display the browser menu bar.
		p["scrollbars"] = 0; //Specifies whether the new window should have scrollbars.
		p["resizable"] = 0; //Specifies whether the new window is resizable.
		p["copyhistory"] = 0; //Whether or not to copy the old browser window's history list to the new window. does it work?
		p["fullscreen"] = 0;  //IE only fullscreen mode - it goes above the taskbar...
		
		//overwrite default params with custom ones
		for(var i in params) p[i] = params[i];
		
		//compile final extras string
		var finalExtras = "";
		for(var i in p) finalExtras += (finalExtras == "") ? i+"="+p[i]  : ","+i+"="+p[i];
		
		//open window	
		var win = window.open(url, name, finalExtras);
		
		//move, resize and focus
		win.resizeTo(w, h);
		win.moveTo(0, 0);
		win.moveBy(x, y);
		win.focus();
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

//Array.push() prototype for IE5 on Mac
if (Array.prototype.push == null){
	Array.prototype.push=function(val){
		this[this.length]=val;
		return this.length;
	};
}


//getElementByID shortcut - Returns path to an object
function $id(id){
	return document.getElementById(id);
};


// Resize listener
window.onresize = fd.size.refresh;


//////////////////////////////////////////////////////////////////////////////////////////
// New class wrapper to ease up use - this is only temporary, everything will be fused in a proto structure soon

var swfIN = function(movie, id, w, h, requiredVersion){
	//keep path the fd object
	this.fd = fd;
	
	//transfer refs
	this.params = [];
	this.flashVars = [];
	this.movie = movie;
	this.id = id;
	this.w = w;
	this.h = h;
};

swfIN.prototype = {
	//add param to stack
	addParam: function(paramName, val){
		this.params[paramName] = val;
	},
	
	//add flash vars to stack
	addVar: function(varName, val){
		this.flashVars[varName] = val;
	},
	
	//add multiple flash vars to stack - compatible with fd.tools.getQs()
	addVars: function(vars){
		for(var i in vars) this.addVar(i, vars[i]);
	},
	
	minSize: function(minW, minH){
		if(minW != null) this.w += " : " + minW;
		if(minH != null) this.h += " : " + minH;
	},
	
	detect: function(requiredVersion, param1, param2, param3){
		this.requiredVersion = requiredVersion;
		
		//action
		this.param1 = param1, this.param2 = param2, this.param3 = param3;
		var temp = "";
		for(var i=1; i<=3; i++ ){
			if ( this["param"+i] != null ){
				if (temp == ""){
					temp += this["param"+i];
				}else{
					temp +=" : "+ this["param"+i];
				}
			}
		}
		
		this.myAction = temp;
	},
	
	useExpressInstall: function(){
		this.express = true;
	},
	
	write: function(){
		//print
		this.fd.showFlash(this.movie, this.id, this.params, this.flashVars, this.w, this.h, this.requiredVersion, this.myAction, this.express);
		
		//refresh to fix IE table bug
		this.fd.size.refresh();
	},
	
	
	//swfIN
	name: "swfIN 1.0.3  -  2007-03-29",
	author: "© 2004-2007 Francis Turmel  |  swfIN.nectere.ca  |  www.nectere.ca  |  francis@nectere.ca",
	desc: "javascript toolkit for flash developers  |  released under the MIT license"
  
};

