/**
 * com.sekati.core.Document
 * @version 1.0.0
 * @author jason m horwitz | sekati.com
 * Copyright (C) 2007  jason m horwitz, Sekat LLC. All Rights Reserved.
 * Released under the MIT License: http://www.opensource.org/licenses/mit-license.php
 */

/**
 * Document controller simulates an AS3 DocumentClass
 * {@code Usage on first _root frame:
 * Document.main(this);
 * }
 */
class com.sekati.core.Document extends MovieClip {
	/**
	 * Constructor
	 */
	private function Document () {
		init();
	}
	/**
	 * links class to _root timeline via constructor simulating document class
	 * @param target (MovieClip)
	 * @return Void
	 */
	public static function main(target:MovieClip):Void {
		target.__proto__ = Document.prototype;
		Function(Document).apply(target, null);
	}
	/**
	 * general movie setup and class compositions
	 * @return Void
	 */
	private function init():Void {
		setMovieProps();
		buildCompositions();
	}
	/**
	 * general movie setup
	 * @return Void
	 */
	private function setMovieProps():Void {
		System.security.allowInsecureDomain ("*");
		System.security.allowDomain ("*");
		fscommand ("swLiveConnect", "true");
		fscommand ("allowscale", "false");
		fscommand ("showmenu", "false");
		fscommand ("fullscreen", "false");
		Stage.align = "TL";
		Stage.scaleMode = "noScale";
		_quality = "HIGH";
		_focusrect = false;
	}
	/**
	 * centralize class compositions for core functionalities and start the application
	 * @return Void
	 */
	private function buildCompositions():Void {

	}
	//
}
// eof