/*====================================================================================================
= Title: JS Actions
= Version: 1.0.1
= Date: 12.2006
= Author: jason m horwitz
= Site: www [d o t] sekati [d o t] com 
====================================================================================================*/
//
// pop usage: <a href="info.html" target="info" onclick="popcart(this.href, this.target, 500, 400);return false;">info</a>
function pop (url, win, w, h, x, y, toolbar, location, status, menubar, scrollbars, resizeable) {
	var sx = (x == "center") ? (screen.availWidth - width) / 2 : x;
	var sy = (y == "center") ? (screen.availHeight - height) / 2 : y;
	var ww = (w == "fullscreen") ? screen.availWidth : w;
	var wh = (h == "fullscreen") ? screen.availHeight : h;
	var tb = (toolbar == true) ? "yes" : "no";
	var lc = (location == true) ? "yes" : "no";
	var st = (status == true) ? "yes" : "no";
	var mb = (menubar == true) ? "yes" : "no";
	var sc = (scrollbars == true) ? "auto" : "no";
	var re = (resizeable == true) ? "yes" : "no";
	var properties = "toolbar=" + tb + ",location=" + lc + ",directories=no,status=" + st + ",menubar=" + mb + ",scrollbars=" + sc + ",resizable=" + re + ",width=" + ww + ",height=" + wh + ",screenX=" + sx + ",screenY=" + sy;
	var pop = window.open(url, win, properties);
	pop.focus();
}
//
// Toggle usage: onclick="toggle(this, 'targetID', 'show', 'hide')"
function toggle (link, id) {
	var box = document.getElementById (id);
	if (box) {
		(box.style.display) ? box.style.display="" : box.style.display="none"; 
	}
}
//
// confirmbox usage: <a href="#" onclick="confirmbox('Are you sure?','yes.html')">delete</a>
function confirmbox (q, a) { if (confirm(q)) window.location = a; }
//
// ifocus usage: <input type="text" name="hw" value="hello world" onfocus="ifocus(this)" onblur="iblur(this)" />
function ifocus(inp) {  
	var defval;  
	if (inp) { 
		if ((defval=inp.getAttribute("defval")) && inp.value==defval) inp.value="";  
			else if (!defval) { inp.setAttribute("defval",inp.value); inp.value=""; } 
		} 
}
//
function iblur (inp) { 
	var defval; 
	if (inp && inp.value=="" && (defval=inp.getAttribute("defval"))) inp.value=defval; 
}
// EOF