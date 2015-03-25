#!/bin/bash
######################
# Symlinks the dotfiles into the home directory
######################


dir=~/dotfiles
olddir=~/dotfiles_old
files="bashrc vimrc vim"



echo "Any existing dotfiles will be moved to $olddir"
mkdir -p $olddir



for file in $files; do
  if [ -e "~/.$file" ]; then
    echo "Backing up ~/.$file"
    mv ~/.$file $olddir/
  fi

  echo "Creating symlink for $file"
  ln -s $dir/$file ~/.$file
done
