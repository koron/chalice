#!/bin/sh

# Seach vim install directory
if [ -d "/usr/local/share/vim" ] ; then
  instdir="/usr/local/share/vim/vimfiles"
elif [ -d "/usr/share/vim" ] ; then
  instdir="/usr/share/vim/vimfiles"
else instdir="/usr/local/share/chalice"
fi

echo "Install directory: $instdir"

# Make install directory for chalice
mkdir -p $instdir

# Copy files of chalice to install directory
cp -R ftplugin plugin syntax $instdir

# Change permission
#chmod 755 $instdir $instdir/ftplugin $instdir/plugin $instdir/syntax
#chmod 644 $instdir/*/*.vim
