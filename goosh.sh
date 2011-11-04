#!/bin/bash
#
# File name: goosh.sh
# Creation date: 04-11-2011
# Last modified: Tue 01 Nov 2011 12:58:15 PM CET
#
# Script to install and configure Goosh, the Google terminal like web 
# application. Clones the current version of Goosh into ~/goosh, where
# it also configures and builds the files needed for running Goosh on
# your web server.
#
# Please keep in mind that this script is meant to be run under Debian
# based distributions, such as Debian itself or Ubuntu or similar.
# 
# Author: Jostein Elvaker Haande <tolecnal@tolecnal.net>
# Webpage: http://tolecnal.net
#
# Please report any bugs to <bugs@tolecnal.net>
#

APTBIN="/usr/bin/apt-get"
APTPACKAGES="yui-compressor"

GITBIN="/usr/bin/git"
GITURL="https://github.com/isaacs/goosh"

YUIBIN="/usr/bin/yui-compressor"

#
# Pre flight checks
#

if [ -z "$EDITOR" ]; then
    echo -e "ERROR: you don't seem to have \$EDITOR set."
    echo -e "---> Please set this before proceeding!"
    echo -e "     EDITOR=/path/to/editor"
    echo -e "     export EDITOR"
    exit 1
fi

echo -e "Checking for apt-get binary..."
if [ ! -f $APTBIN ]; then
    echo -e "ERROR: apt-get binary not found. Please check your paths!"
    exit 1
else
    echo -e "---> apt-get binary found!"
fi

echo -e "Checking for git binary..."
if [ ! -f $GITBIN ]; then
    echo -e "ERROR: git binary not found. Please check your paths!"
    exit 1
else
    echo -e "---> git binary found!"
fi

echo -e "Checking for yui-compressor..."
if [ ! -f $YUIBIN ]; then
    echo -e "ERROR: yui-compressor not found. Installing via apt-get..."
    # SET OPTIONS FOR APT-GET AND RUN IT
    OPTS=(install $APTPACKAGES)
    CMD=($APTBIN $OPTS)
    "${CMD[@]}"
    if (( $? )) ; then
        echo -e "ERROR: apt-get failed, please check your console output"
    else
        echo -e "--- package 'yui-compressor' installed!"
    fi
else
    echo -e "---> yui-compressor found!"
fi

#
# Let's get down and dirty. Download the source and build it.
#

if [ -d $HOME"/goosh" ]; then
    echo -e "ERROR: there seems to be a copy of goosh already cloned via git"
    exit 1
fi

# CLONE THE REPO
CMD=($GITBIN clone $GITURL)
"${CMD[@]}"

if (( $? )) ; then
    echo -e "ERROR: 'git clone' failed, please check your console output"
    exit 1
else
    echo -e "Sucessfully cloned the git repoistory from $GITURL"
fi

echo -e "Creating $HOME/goosh/out folder..."
if [ ! -d $HOME"/goosh/out" ]; then
    mkdir $HOME"/goosh/out"
    if (( $? )) ; then
        echo -e "ERROR: failed to create directory $HOME/goosh/out -> $!"
        exit 1
    else
        echo -e "---> directory created"
    fi
fi


exit 0
