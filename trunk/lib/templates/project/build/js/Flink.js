/*====================================================================================================
= Title: Sekati Flink 
= Desc: Flash<->JavaScript Communication Link, Anchor Deeplinking & ExternalInterface passthru
= Version: 2.0.1
= Date: 01.2007
= Author: jason m horwitz
= Site: www [d o t] sekati [d o t] com 
= License: GNU General Public License - http://www.gnu.org/licenses/gpl.txt
= Usage: Call setFlink/getFlink via getURL, ExternalInterface, or swfIN
=        <a href="javascript:setFlink('Hello World!','hello_world')">hello world</a>
=        <a href="javascript:alert(getFlink())">get Flink</a>
====================================================================================================*/
//
var dl = document.location.href.split("#")[0];
var dt = document.title;
//
// set document title & location anchor
function setFlink(t, a) {
	if (t) document.title = dt+" : "+t;
	if (a) document.location.href = dl+"#"+a;
}
//
// get document location anchor
function getFlink() {
	var a = document.location.href.split("#")[1];
	if (a) return a;
}
// get entire url
function getRef(){
	return document.location.href;
}
//
// call actionscript function: document.movieID.myFlashFunction( [argumentArray] );
function asCall(id, fn, argArr) {
	document[id][fn](argArr);
}
//
// helper functions tied to swfIN (http://swfin.nectere.ca)
function browserW() {
	return fd.tools.browserSize().w
}
function browserH() {
	return fd.tools.browserSize().h
}
// EOF