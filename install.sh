#!/bin/bash
######################
# Symlinks the dotfiles into the home directory
######################

basedir="$(cd "$(dirname "$0")" || exit 1; pwd)"
targetdir="$HOME"

vendor_dir="$basedir/vendor"
backup_dir="$basedir/backup"

liquidprompt_dir="$vendor_dir/liquidprompt"
vimplug_dir="$vendor_dir/vim-plug"


link_dotfile () {
  local file="$1"
  local source="$basedir/$file"
  local target="$targetdir/.$file"

  if [ -e "$target" ]; then
    echo "- backing up $file"
    mkdir -p "$backup_dir"
    mv "$target" "$backup_dir/$file"
  fi

  echo "- linking $file"
  ln -s "$source" "$target"
}



mkdir -p "$vendor_dir"


echo "Installing liquidprompt..."
git clone https://github.com/nojhan/liquidprompt.git "$liquidprompt_dir"


echo "Installing vim-plug"
git clone https://github.com/junegunn/vim-plug.git "$vimplug_dir"
ln -s "$vimplug_dir/plug.vim" "$basedir/vim/autoload/plug.vim"


link_dotfile "bashrc"
link_dotfile "vimrc"
link_dotfile "vim"
link_dotfile "gitconfig"
