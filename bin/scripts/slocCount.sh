#!/bin/sh
####################################################################
#
# SLOCCount.sh - Source Lines Of Code Counter v1.1 - sekati.com
#
####################################################################

DIR="../../"
EXT="*.as"
SLOC=`find . -name $EXT -print0 | xargs -0 cat | wc -l`

cd $DIR

echo "/**"
echo " * Source Lines of Code for Project:"
echo " * @return Number$SLOC"
echo " */"

exit 0
