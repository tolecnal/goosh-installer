GOOSH INSTALLER
===============

*Remember that this is an unoffical installer of goosh. Use at your own risk! But if you find any bugs, please let me know!*

Script to install and configure Goosh, the Google terminal like web
application. Clones the current version of Goosh into ~/goosh, where
it also configures and builds the files needed for running Goosh on
your web server.

Please keep in mind that this script is meant to be run under Debian
based distributions, such as Debian itself, Ubuntu or similar.

DEPENDENCIES
------------

Apache or lighthttpd with a working installation of PHP. Also requires yui-compressor, that should be installed by the installer script if not found.

BUGS
----

No known bugs. But if you find one, please report them. Patches welcome! :)

INSTALLATION
------------

    wget "https://raw.github.com/tolecnal/goosh-installer/master/goosh.sh" (to your home directory)
    chmod u+x goosh.sh
    ./goosh.sh

Then follow the on screen instructions

CREDITS
-------

* Thanks to Stefan Grothkopp <grothkopp@gmail.com> for making goosh in the first place.
* Thanks to Steinar H. Gunderson (Sesse) for invaluable BASH help.

ABOUT THE AUTHOR
----------------

Author: Jostein Elvaker Haande <tolecnal@tolecnal.net>
Webpage: http://tolecnal.net
