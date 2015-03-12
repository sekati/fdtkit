# FDTKit Documentation & Usage Guide #

## Introduction ##

Assuming you have already installed [Eclipse, FDT, Subclipse](http://code.google.com/p/fdtkit/wiki/Eclipse_FDT_Subclipse_Install_Guide) & [FDTKit](http://code.google.com/p/fdtkit/wiki/Installation) you are ready to start using your new environment. So, lets start by creating a test project and continue customizing our environment.


## Create a new Project ##
  1. First we must make sure we are in the _Flash Perspective_ by going to `"Window -> Open Perspective -> Flash"`.
  1. `"File -> New -> New Flash Project"`.
  1. Enter `"Test Project"` for `"Project Name"`, insuring that `"Use Default Location"` is checked and hit `"Next"`.
  1. Select your default `"Core Library"` (based on your target FlashPlayer version). If you would like to use a different Core Library simply press `"Change Core Library"` and select the version you would like (these will already be available via FDTKit installation).
  1. Press `"Finish"` and your project will be created. You may see this in the `"Flash Explorer"` panel (`"Window -> Show View -> Flash Explorer"`).


## Add a Project Buildfile ##
  1. A great number of things can be automated in Eclipse using [FDTKit's Buildfile](http://fdtkit.googlecode.com/svn/trunk/build.xml) & [Apache Ant](http://en.wikipedia.org/wiki/Apache_Ant).
  1. First we need to copy the FDTKit Buildfile into our project: Expand the `"fdtkit"` project in FlashExplorer.
  1. Right click on `"build.xml"` in `"fdtkit"` and choose `"Copy"`.
  1. Right click our `"Test Project"` and choose `"Paste"`.
  1. Double click the `"Build.xml"` now in your `"Test Project"` so that we may configure the buildfile for our project.
  1. Edit the `"project name"` attribute.
  1. Edit the `"fdtkit"` location to reflect the absolute path to the `"fdtkit"` project on your computer.
  1. Edit the `"Project Details"` paying special attention to `corelib, target_player, target_fla & target_swf"` (the remaining Project Details are unused unless you plan on compiling with MTASC).
  1. If you are planning on using any of the automated `"deployment"` tasks and are running OS X or Windows with [cygwin](http://www.cygwin.com/) installed (for `"rsync"` + `"ssh"` support); edit the `"Deployment Settings"`, `"Project Deployment Paths"` & `"Documentation Deployment Paths"`. **Please note**: you will need to generate and install a `"public SSH key"` on the server you wish to automate deployment on. If you have not generated an SSH key pair before you can do this simply by entering `"ssh-keygen -t dsa`" into the Terminal on your development machine (be sure to leave the `"Password"` blank so that Eclipse can do remote deployments). Next copy the contents of the resulting public key  from `"~/.ssh/id_dsa.pub"` in to the `"~/.ssh/authorized_keys"` file _on your production server_.
  1. Save you updated build.xml and close the file.
  1. Next open the Eclipse Ant panel: `"Window -> Show View -> Ant"`.
  1. In the Ant panel press the `"Add Buildfiles"` button (small ant icon with a plus symbol).
  1. Select `"Test Project -> build.xml"`, the buildfile will now appear in the Ant panel.
  1. Since you must run the Buildfile in the same JRE as the workspace, navigate to: `"Run -> External Tools -> Open External Tools Dialogue ... -> (select the tab) JRE -> (check the option) Run in the same JRE as the workspace"`.
  1. You Buildfile is now configured and you may run any of the available tasks you wish on your project. You may expand the Buildfile to see all available tasks by clickin on the arrow to the left of the Buildfile project title.
  1. You may [create your own custom tasks](http://ant.apache.org/manual/) or use some of those already provided by FDTKit. The tasks you will most likely be interested in are:

  * **TestMovie** `- _will run a "Test Movie" in the flash IDE for the currently opened fla.`
  * **build\_target** `- will open your main fla in the flash ide and compile it.`
  * **create\_project\_structure** `- creates a general project directory structure.`
  * **document\_as2api** `- will generate html documents for all javadoc'd classes in the project "docs" directory.`

> In the next section we will use the `create_project_structure` task to create our project layout.


## Create the Project Layout ##
  1. Now we want to create a good project structure to keep things organized. Fortunately the `create_project_structure` task from the Buildfile we added in the previous section will automate this for us. Start by expanding your Buildfile in the Ant Panel to view all tasks`.
  1. Locate the `"create_project_structure"` task and press small green play icon button.
  1. The Eclipse console will appear notifying you that the project structure has been created.
  1. Next right-click your `"Test Project"` in the Flash Explorer and select `"Refresh"`. Your new project directory structure will appear as follows:

  * **build**/ `- compressed & dated project archives (i.e. myProject-mm-dd-yy.zip) for hand-off &/or archival purposes.`
  * **deploy**/ `- project files ready for deployment to a productions server (sans source code)`
  * deploy/assets `- misc external project graphics, audio, videos, etc`
  * deploy/css `- css files`
  * deploy/js `- javascript files`
  * deploy/php `- php files`
  * deploy/xml `- xml files`
  * **docs**/ `- ActionScript Documentation generated with FDTKit`
  * **lib**/ `- assets needed for project development but not for production`
  * lib/assets `- generic assets`
  * lib/comps `- design comps`
  * lib/fonts `- reqiured fonts`
  * **tests**/ `- unit tests and fla's`
  * **src**/ `-  source classes, packages and project fla's`

> _Note:_ If you would like to add additional directories you may do so simple by right clicking your `"Test Project"` in the Flash Explorer and click `"New -> Folder"`. Give it a name of your choosing and press `"Finish"`.


## Linking the Source Folder ##
  1. Next we need to tell Eclipse and FDT that we want to use `"src"` as our source folder by adding it to our project classpath. Start by right-clicking on the `"src"` folder in Flash Explorer.
  1. Select `"Source Folder -> Add to Classpath"`.
  1. Notice the icon has changed from that of a generic folder (yellow) to a source folder (blue).


## Create a Class ##
  1. Right click on our project `"src"` folder and choose `"New -> Class"`.
  1. In the `"Create AS2 Class"` wizard fill in our package: `"com.sekati.core"`, classname:`"Test"`, superclass: `"MovieClip"`.
  1. Press `"Finish"`. Our class has been created, you may view it by expanding the `"src"` folder to see our package and its class contents.
  1. Assuming you have followed the [FDTKit Installation Wiki](http://code.google.com/p/fdtkit/wiki/Installation) and configured your FDT templates your resulting class will look similar to the one below. A method has been added with as2api compatible javadoc formatted comments for reference:

```
/**
 * com.sekati.core.Test
 * @version 1.0.0
 * @author jason m horwitz | sekati.com
 * Copyright (C) 2007  jason m horwitz, Sekat LLC. All Rights Reserved.
 * Released under the MIT License: http://www.opensource.org/licenses/mit-license.php
 */
 
/**
 * Test
 */
class com.sekati.core.Test extends MovieClip {
	
	function Test() {
		super();
		sayHello("Hello World!");
	}
	
	/**
	 * Trace a message.
	 * @param str (String) message to trace.
	 * @return Void
	 * {@code Usage:
	 * 	sayHello("Hello World!");
	 * }
	 */
	private function sayHello(str:String):Void {
		trace(str);	
	}
}
```


## Create an Fla ##
  1. Right click on our project `"src"` folder and choose `"New -> Fla"`.
  1. In the `"New Fla"` wizard fill in our fla name: `"Main.fla"`
  1. Press `"Finish"`. Our fla has been created.
  1. Double click the `"Main.fla"` in our `"src"` folder and the Flash IDE will launch and open the Fla.
  1. Next go to `"Publish Settings"` in the Flash IDE and set the FlashPlayer Version for the FLA to match your Core Library.
  1. Select the `"Formats"` tab in `"Publish Settings"`.
  1. Uncheck `"HTML"`.
  1. Change the `"Flash"` file from `"Main.swf"` to `"../deploy/Main.swf"` so our movie will be published into the `"deploy"` directory in our project structure.


## Creating Test Fla's ##
  1. Creating unit test fla's in the `"tests/"` directory is quite similar to the process described above except we do not want to publish our swf's  into the deploy directory and we will need to adjust the as2 path.
  1. To adjust the class path in the Flash IDE we go to  `"Publish Settings"` and click `"settings"` next to `"ActionScript version"` and add `"../src"` so our test fla's can locate our classes.


## Automate Compilation, Documentation & Other Common Tasks ##


> ### Adding Key Bindings ###
  1. You may wish to have some familiar hotkeys similar to those you used in flash. For instance if you would like to map `"Control+Enter"` to the `"TestMovie"` default task from the FDTKit buildfile so you can easily go straight from editting a class in Eclipse to viewing the compiled swf you can do this via: `"Eclipse -> Preferences -> Keys"`.
  1. Find the Command  `"Run Ant Build"`, When: `"In Windows"` under Category: `"Run/Debug"` and add a key binding of your choosing (usually `"Control+Enter"` or `"Command+Enter"`).
  1. If you use SVN you may also choose to add bindings for `"&Add to Version Control"` `(Control+A)` and `"&Commit..."` `(Control+S)`.


> ### Built-In Shortcuts ###
> If you would like to know more about the built-in shortcuts and key-bindings in Eclipse & FDT please see the [FDTKit Shortcuts Wiki page](http://code.google.com/p/fdtkit/wiki/Shortcuts).
