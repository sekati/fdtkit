#!/bin/sh
####################################################################################
# AS2 Documentation Builder - v.0.0.1 - jason m horwitz | sekati.com
# Copyright (C) 2007  jason m horwitz, Sekat LLC. All Rights Reserved.
# Released under the MIT License: http://www.opensource.org/licenses/mit-license.php
#
# Usage: Copy script to your project/build directory and edit config sections below.
#
####################################################################################
# CONFIGURATION - edit these to suite your environment

PROJECT_TITLE="FDTKit Project Template Documentation"
PROJECT_PATH="/Users/jason/workspace/fdtkit/lib/templates/project_template"
DOC_PATH="$PROJECT_PATH/docs"
CLASS_PATH="$PROJECT_PATH/src"
PACKAGES="com.sekati.*"

FDTK_PATH="/Users/jason/workspace/fdtkit"
AS2API_PATH="$FDTK_PATH/bin/as2api"
DOT="$FDTK_PATH/bin/graphviz/Graphviz.app/Contents/MacOS/dot"

####################################################################################

echo "DOCBUILDER: Generating $TITLE docs from [$CLASS_PATH] to [$DOC_PATH] ..."

# clear outdated docs
rm -rf $DOC_PATH/*

cd $AS2API_PATH
ruby as2api.rb package-spec $PACKAGES --classpath $CLASS_PATH --output-dir $DOC_PATH --title $PROJECT_TITLE --sources --progress --draw-diagram --dot-exe $DOT

cp "$DOC_PATH/frameset.html" "$DOC_PATH/index.html"
#cd ..

####################################################################################

echo "DOCBUILDER: complete."
exit 0

####################################################################################
