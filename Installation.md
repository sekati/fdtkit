# FDTKit Installation Guide #


## Introduction ##

_This Install Guide assumes you already have the Required Environment (listed below) installed. If you are starting from scratch please read the [Eclipse, FDT, Subclipse Install Guide](http://code.google.com/p/fdtkit/wiki/Eclipse_FDT_Subclipse_Install_Guide) to setup your environment and then return to this document._

> ### Requirements ###
  * [Eclipse](http://www.eclipse.org/) - Any flavor of Eclipse should do but the [Web Tools Platform Project all-in-one](http://www.eclipse.org/webtools/) is what I recommend for most flash developers.
  * [FDT](http://fdt.powerflasher.com/update/)
  * [Subclipse](http://subclipse.tigris.org/install.html) - for FDTKit installation and updates as well as project Version Control.
  * [Flash CS3 or Flash 8](http://www.adobe.com/products/flash/) - for asset layout, management and optional Ant compilation.


> ### Install Route ###
  * [From the Project SVN Repository](http://code.google.com/p/fdtkit/source) via the Subclipse eclipse Plugin.

> To understand why [SVN](http://en.wikipedia.org/wiki/Subversion_(software)) is the more desirable route it is helpful to quickly review a few core concepts on how Eclipse, Subclipse and FDTKit fit together:

> Eclipse is a plugin-based IDE _(supporting multiple languages, usages and functionalities)_. We build our Flash IDE with the FDT plugin _(which adds advanced [ActionScript](http://en.wikipedia.org/wiki/ActionScript) support)_ and Subclipse plugin _(which allows Subversion version control support)_.

> Simply put; FDTKit is a treated as a _Generic 'Resource Perspective' Project_ in Eclipse; which means you can check out, or update the latest version from the project repository and have it available on your system - all directly from Eclipse. This is handy since all FDTKit is, in essence, is a collection of tool meant to help _complete_ the IDE in a centralized way by adding the necessary libraries, compilers, documentation tools, scripts, etc.


## Install via SVN ##

  1. From the Eclipse toolbar: `"Window -> Open Perspective -> Other -> SVN Repository Exporing"`.
  1. Right-click in the `"SVN Repository"` panel and select: `"New -> Repository Location..."`.
  1. Enter: _"[http://fdtkit.googlecode.com/svn/trunk/](http://fdtkit.googlecode.com/svn/trunk/)"_ in the URL field and click: `"Finish"`.
  1. The SVNKit repository will now be added to your `"SVN Repository"` panel.
  1. Right click on the repository and choose: `"Checkout..."`.
  1. Insure that the default: `"Check out as a project in the workspace"` is ticked, the Project Name is: `"fdtkit"`, and `"Head Revision"` is ticked. Then press: `"Finish"`.
  1. Wait while the current build of FDTKit is downloaded and installed; once complete you should see `"Checked out revision [number]."` in the `Console` panel.
  1. Thats it; you're now ready to configure FDT to use FDTKit. To switch back to the `"Flash Perspective"` from the Eclipse toolbar: `"Window -> Open Perspective -> Other -> Flash (default)"`.


## Configuring FDT to use FDTKit ##

One of the primary uses of FDTKit is the included organized Flash libraries & both platform builds of common compiler, documentation tool binaries as well as several handy FDT templates. In order to take advantage of this centralized packaging we need to change some basic configuration settings in FDT:

  1. From the Eclipse toolbar: `"Eclipse -> Preferences -> FDT -> Core Libraries"` (`"Window -> Preferences -> FDT -> Core Libraries"` on Windows).
  1. Press `"Add"`, then browse to `"..workspace/fdtkit/lib/FP7"`. Enter `"FP7"` as the Name for the library. Press `"Apply"`.
  1. Repeat the previous step until each `"FP"` directory has been added (_i.e. FP7, FP8, FP9_). Each of these represents a target Flash Player version you might target in a projects development.
  1. Finally tick the `"FP"` directory which you would like to use as your default core library.
  1. Navigate to `"Tools -> MTASC"` and browse to `"..workspace/fdtkit/bin/mtasc` and select the MTASC build for your platform.
  1. Because FDT 1.5.x does not support the Flash CS3 HelpPanel due to a bug, FDTKit includes the necessary plugin to add Flash 8 help support to Eclipse. To use this unarchive the `"fdtkit/docs/flashhelp.zip"` and place the resulting directory `"com.pf.fdt.flashhelp_1.5.1"` into your `"eclipse/plugins/"` directory and restart Eclipse. Note: you only need to do this if you only have Flash CS3 IDE installed, if you have the Flash 8 IDE you maybe simply set the proper paths in the FDT Preference panel.
  1. Navigate to `"Templates"`, tick `"Override System User Name - ${user}"` and customize this to your liking (_i.e. jason m horwitz | sekati.com_). This will be used to insert author credits in created class files.
  1. Navigate to `"Code Style -> Code Templates"` and press `"Import..."`. Browse to `"...workspace/fdtkit/lib/templates/fdt/codetemplate.xml"`. It is recommended you personalize the Copyright string in typeheader after template import to suite your tastes.
  1. Navigate to `"Editor -> Templates"` and `"Import..."`. Browse to `...workspace/fdtkit/lib/templates/fdt/templates.xml"`. You should then also edit and personalize the `"header"` template. These templates are formatted to work properly with the AS2API documentation tool (also part of FDTKit). _Note: For best results with AS2API you should insert the "header" template at the top of your classes, then do your import statements, and finally either "desc" or "usage" template to enter in the class description to be documented (header is ignored by as2api which does not support @author and many other javadoc tags)._


## Updating FDTKit ##

  * To update via SVN: Right-click on the `fdtkit` project in `Flash Explorer` panel and choose `Team -> Update`


## Usage ##

Please see the FDTKit [Documentation](http://code.google.com/p/fdtkit/wiki/Documentation) for specific usages.










