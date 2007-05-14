#!/bin/sh
####################################################################################
# SyncSite - v.0.0.3 - ssh/rsync dev to production - jason m horwitz | sekati.com
# Copyright (C) 2007  jason m horwitz, Sekat LLC. All Rights Reserved.
# Released under the MIT License: http://www.opensource.org/licenses/mit-license.php
#
# Usage: Copy script to your project/build directory and edit config sections below.
#
####################################################################################
# CONFIGURATION - edit these to suite your environment

SOURCE="/Users/jason/workspace/fdtkit/"
DEST_HOST="sekati.com"
DEST_PATH="/www/dev/fdtkit/"
DEST_USER="jason"
EXCLUDE="*bak*,*BAK*,*.tmp,*.TMP,.DS_Store,Thumbs.db,.exclude_buildsite"

####################################################################################

echo "SYNCSITE: building exclude list ..."
echo $EXCLUDE | sed -e 's/\,/\
/g' >> .exclude_buildsite

echo "SYNCSITE: syncing ($SOURCE)-->($DEST_HOST:$DEST_PATH)\n"
rsync -ave ssh --delete --force --exclude-from=".exclude_buildsite" $SOURCE $DEST_HOST:$DEST_PATH

echo "\nSYNCSITE: CLEANING UP ..."
rm .exclude_buildsite

echo "SYNCSITE: complete."
exit 0

####################################################################################
