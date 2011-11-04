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
# Set up functions used in script
#

function pause() {
    read -p "$*"
}

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

echo -e ""
echo -e "We now need to edit the config file to your goosh installation"
echo -e "Please edit the config file (will open in your \$EDITOR)"
echo -e ""
echo -e "Config options to edit:"
echo -e "\tgoosh.config.user (sets the username displayed)"
echo -e "\tgoosh.config.host (sets the hostname displayed)"
echo -e ""
pause "Press any key to start editing your config file"

# Start the $EDITOR to edit the config file

CMD=($EDITOR $HOME/goosh/src/config/config.js)
"${CMD[@]}"
if (( $? )) ; then
    echo -e "ERROR: failed to edit the config file: $!"
    exit 1
else
    echo -e "Sucessfully edited the config file"
fi

# Let's build the installation

[ -f "`which php 2>/dev/null`" ] && php $HOME/goosh/src/goosh.js > $HOME/goosh/out/goosh.raw.js
if (( $? )) ; then
    echo -e "ERROR: php failed to build the javascript file"
    exit 1
fi

[ -f "`which yui-compressor 2>/dev/null`" ] && yui-compressor $HOME/goosh/out/goosh.raw.js > $HOME/goosh/out/goosh.js
if (( $? )) ; then
    echo -e "ERROR: yui-compressed failed to compress the javascript file"
    exit 1
fi

if [ -f "$HOME/goosh/index.php"]; then
    echo -e "ERROR: there's already a index.php file, have we built this before?"
    exit 1
fi

print <<EOF > "$HOME/goosh/index.php"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>goosh.org - the unofficial google shell.</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
<link rel="shortcut icon" type="image/x-icon" href="favicon.ico" />  
<style type="text/css">
html { height: 100%; }
body { background: #fff; font-size: 12px; font-family: monospace; height: 99%; margin:0px; padding: 0px; }
form { padding: 0px; margin: 0px; }
pre { font-size: 12px; }
br { clear: both; }
:focus { outline: 0; }
input.cmdline { border: none; border: 0px; font-size: 12px; font-family: monospace; padding: 0px; margin:0px; width:100%; }
table.inputtable { width:100%; vertical-align:top; }
td.inputtd { width:100%; }
#input { margin-left: 8px; color: #666; overflow: hidden; }
#output{ margin-left: 8px; margin-top: 8px; }
.less { color: #666; }
.info { color: #090; }
table { padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px; }
td { padding: 0px; margin: 0px; vertical-align: top; font-size: 12px; font-family: monospace; }
.help td { padding-right: 25px; font-size: 12px; }
div#prompt { display: inline; white-space:nowrap; padding:0px; margin:0px; }
img { border: none; }
</style>
<script type="text/javascript">
//<!--
/*
 Goosh.org (c) 2008 - Stefan Grothkopp

 This script is a google-interface that behaves similar to a unix-shell.

 goosh is written by Stefan Grothkopp (grothkopp (at) gmail (dot) com)
 it is NOT an official google product!

 If you want to extend goosh.org, please take a look at the load command.
 You can see an example module at http://goosh.org/ext/spon.js

 Uncompressed source can be found at:
 http://code.google.com/p/goosh/
 Instructions for svn access are at:
 http://code.google.com/p/goosh/source/checkout

 If you have problems/bug reports/etc please write me an email.

*/
EOF

cat "$HOME/goosh/out/goosh.js" >> "$HOME/goosh/index.php"

print <<EOF >> "$HOME/goosh/index.php"
</script>
<meta name="description" content="goosh is a google-interface that behaves similar to a unix-shell."/>
<meta name="keywords" content="google, shell, google shell, commandline, cli, bash, interface, ajax, api, unix, search"/>
<meta name="author" content="Stefan Grothkopp"/>
</head>
<body id="body">
<div id="output">

 
<span class='less'>Goosh goosh.org 0.5.0-beta #1 Mon, 23 Jun 08 12:32:53 UTC Google/Ajax</span><br/> 
 <br/>
<span class='info'>Welcome to goosh.org - the unofficial google shell.</span><br/>
 <br/>
This google-interface behaves similar to a unix-shell.<br/>
You type commands and the results are shown on this page.<br/>
<br/>
goosh is powered by <a href='http://code.google.com/apis/ajax/' target='_blank'>google</a>.


<br/>
<br/>
goosh is written by <a href='http://stefan.grothkopp.com/tag/goosh'>Stefan Grothkopp</a> 
<script type="text/javascript">
// <!--
var gmail = "gmail.com";
document.write("&lt;<a href='mailto:grothkopp"+"@"+gmail+"?subject=goosh.org' style='text-decoration:none; color: #000;'>grothkopp"+"@"+gmail+"</a>&gt;");
//-->
</script>
<br/>
it is NOT an official google product!<br/>
goosh is <a href='http://code.google.com/p/goosh/' target='_blank'>open source</a> under the Artistic License/GPL.<br/>
<br/>
 Enter <span class='info'>help</span> or <span class='info'>h</span> for a list of commands.


<br/>
 <br/>
</div>
<div id="input">
<form name='f' onsubmit='return false;' class='cmdline' action=''>
<table class="inputtable"><tr><td><div id='prompt' class='less'></div></td><td class="inputtd"><input id='inputfield' name='q' type='text' class='cmdline' autocomplete='off' value="" /></td></tr></table>
</form>
</div>
<script type="text/javascript">
//<!--
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
//-->
</script>
</body>
</html>
EOF

echo -e "Done writing the file $HOME/goosh/index.php"
echo -e "---> To install do the following:"
echo -e "     mkdir /var/www/goosh"
echo -e "     cp $HOME/goosh/index.php /var/www/goosh"
echo -e ""
echo -e "Then point your browser at http://yourdomain.tld/goosh/"
echo -e ""
echo -e "If it doesn't work, make sure that .php is set to be a index type in Apache"
echo -e ""
echo -e "Congratulations, we are done! Enjoy your goosh installation"

exit 0
