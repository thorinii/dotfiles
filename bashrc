# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi




# Android SDK PATH
export ANDROID_HOME=/home/lachlan/adt-linux/sdk

export BEES_HOME=/home/lachlan/cloudbees-sdk-1.5.2/

export SCALA_HOME=/home/lachlan/scala/scala-2.11.0

export PATH=${PATH}:${BEES_HOME}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$SCALA_HOME/bin

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export PATH="/app/halcyon:/app/cabal/bin:/app/ghc/bin:/app/bin:$PATH"

export PATH="/home/lachlan/bin:$PATH"

export PATH="$PATH:/home/lachlan/ide/activator-1.3.2-minimal/"



# Start gnome-keyring-daemon if not already

SSH_AUTH_SOCK=`ss -l | grep -o "/run[/a-zA-Z0-9]*keyring-[a-zA-Z0-9]*/ssh"`

if [ -z $SSH_AUTH_SOCK ]; then
  pidof gnome-keyring-daemon > /dev/null
  if [ $? -eq 0 ]; then
    pidof gnome-keyring-daemon | xargs kill
  fi

  echo "Starting gnome-keyring-daemon"

  DAEMON_OUTPUT=`nohup gnome-keyring-daemon -s -d`

  SSH_AUTH_SOCK=`echo $DAEMON_OUTPUT | grep 'SSH_AUTH_SOCK' | grep -o '/run.*/ssh'`
  GNOME_KEYRING_PID=`echo $DAEMON_OUTPUT | grep PID | grep -o '=[0-9]*' | grep -o '[0-9]*'`

  export GNOME_KEYRING_PID
  echo $GNOME_KEYRING_PID > /home/lachlan/.GNOME_KEYRING.pid
fi

if [ -e '/home/lachlan/.GNOME_KEYRING.pid' ]; then
  GNOME_KEYRING_PID=`cat /home/lachlan/.GNOME_KEYRING.pid`
  export GNOME_KEYRING_PID

  SSH_AUTH_SOCK=`ss -l | grep -o "/run[/a-zA-Z0-9]*keyring-[a-zA-Z0-9]*/ssh"`
fi

if [ -z $SSH_AUTH_SOCK ]; then
  SSH_AUTH_SOCK=`ss -l | grep -o "/run[/a-zA-Z0-9]*keyring-[a-zA-Z0-9]*/ssh"`
fi

if [ -z $SSH_AUTH_SOCK ]; then
  echo "Could not properly start or connect to gnome-keyring-daemon"
fi

export SSH_AUTH_SOCK
export PATH=$PATH:/usr/local/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/lib



gitpush() {
  COMMIT_MESSAGE=$1
  BRANCH=${2:-master}

  git commit -m "$COMMIT_MESSAGE" && git push origin $BRANCH
}


source ~/programming/others/liquidprompt/liquidprompt


#export HALCYON_NO_SELF_UPDATE=1
#export HALCYON_KEEP_DEPENDENCIES=1

export HALCYON_AWS_ACCESS_KEY_ID="AKIAI754F3P2GIBW2WWQ"
export HALCYON_AWS_SECRET_ACCESS_KEY="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"
export HALCYON_S3_BUCKET="halcyon-sandboxes"
export HALCYON_S3_ENDPOINT="s3-ap-southeast-2.amazonaws.com"
export HALCYON_S3_ACL="public-read"
#export HALCYON_NO_UPLOAD=1
