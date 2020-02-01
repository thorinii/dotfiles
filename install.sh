#!/bin/bash

###############################
# Installs everything useful. #
###############################


basedir="$(cd "$(dirname "$0")" || exit 1; pwd)"
targetdir="$HOME"

vendor_dir="$basedir/vendor"
backup_dir="$basedir/backup"

liquidprompt_dir="$vendor_dir/liquidprompt"
vimplug_dir="$vendor_dir/vim-plug"


clone_repo () {
  local repo="${1}"
  local target="${2}"

  local name="$(basename "$target")"

  echo "$name:"
  if [[ -e "$target" ]]; then
    echo "- removing existing repo"
    rm -rf "$target"
  fi

  echo "- cloning $repo"
  git clone "$repo" "$target"
}


link_dotfile () {
  local source="${1}"
  local target="${2}"

  local file="$(basename "$source")"
  local target_parent="$(dirname "$target")"

  echo "$file:"
  if [[ -h "$target" ]]; then
    echo "- removing existing symlink"
    rm "$target"
  elif [[ -e "$target" ]]; then
    echo "- backing up existing"
    mkdir -p "$backup_dir"
    mv "$target" "$backup_dir/$file"
  fi

  if [[ ! -e "$target_parent" ]]; then
    echo "- creating parent dir"
    mkdir -p "$target_parent"
  fi

  echo "- linking"
  ln -s "$source" "$target"
}



mkdir -p "$vendor_dir"

clone_repo "https://github.com/nojhan/liquidprompt.git" "$liquidprompt_dir"
clone_repo "https://github.com/junegunn/vim-plug.git" "$vimplug_dir"

link_dotfile "$basedir/bashrc" "$targetdir/.bashrc"
link_dotfile "$basedir/vim" "$targetdir/.vim"
link_dotfile "$basedir/vimrc" "$targetdir/.vimrc"
link_dotfile "$basedir/neovim_init.vim" "$targetdir/.config/nvim/init.vim"
link_dotfile "$vimplug_dir/plug.vim" "$basedir/vim/autoload/plug.vim"
link_dotfile "$basedir/gitconfig" "$targetdir/.gitconfig"
