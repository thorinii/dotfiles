#!/usr/bin/bash -f

if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

PS1="\u@\h \W/ \t\$ "



#
# Low-level config
#

# setup infinite history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
shopt -s histappend

shopt -s checkwinsize

if ! tput setaf 0 >/dev/null 2>&1; then
  export TERM=xterm-256color
fi


#
# User config
#

shopt -s direxpand

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi


alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gg='git grep -nE'
alias grep='grep --color=auto'
alias tree='tree --dirsfirst -C'

if command -v nvim >/dev/null; then
  alias vim='nvim'
fi


# enable prompt
[[ $- = *i* ]] && source ~/dotfiles/vendor/liquidprompt/liquidprompt

# enable fuzzy-finder for history
[[ $- = *i* && -f ~/.fzf.bash ]] && source ~/.fzf.bash

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

if [[ -f /etc/bash_completion.d/git ]]; then
  . /etc/bash_completion.d/git
elif [[ -f /usr/share/bash-completion/completions/git ]]; then
  . /usr/share/bash-completion/completions/git
fi

export NVM_DIR="$HOME/.nvm"
alias enable_nvm='[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"'

export PATH="$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/globalnode/node_modules/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/bin/lib:$LD_LIBRARY_PATH"




#
# Functions
#

pipe_port () {
  local host="$1"
  local port="$2"
  echo "Redirecting localhost:$port -> $host:$port"
  ssh -N -L "$port:localhost:$port" "$host"
}
pipe_port_3 () {
  local host="$1"
  local port="$2"
  local local_port="$3"
  echo "Redirecting localhost:$local_port -> $host:$port"
  ssh -N -L "$local_port:localhost:$port" "$host"
}


# takes the first word of each line
firstword () { awk '{ print $1; }'; }
# `wordn <number>` takes the nth word of each line
wordn () { awk '{ print $'"$1"'; }'; }


# a more compact list of images
dls () {
  (
    echo $'NAME\tCREATED\tREPO'
    docker image ls \
      | tail -n+2 \
      | sed -r 's/  +/\t/g' \
      | sed -r 's/^([a-z0-9]+([.:-][a-z0-9]+)+)\/([^\t]+)\t(.*)/\3\t\4\t\1/g' \
      | awk -F$'\t' '{print $1":"$2 "\t" $4 "\t" $6;}' \
      | sort
  ) | column -t -s $'\t'
}

# a more compact list of containers
dps () {
  (
    echo $'NAME\tPORTS\tIMAGE'
    docker ps -a --format '{{.Names}}\t{{.Ports}}\t{{.Status}}\t{{.Image}}' | sort \
    | while read line; do
      local name ports uptime image
      name="$(echo "$line" | cut -d$'\t' -f1)"
      ports="$(echo "$line" | cut -d$'\t' -f2 | sed -r 's;/tcp|0\.0\.0\.0:;;g ; s/(^| )[0-9]+(, |$)//g')"
      uptime="$(echo "$line" | cut -d$'\t' -f3)"
      image="$(echo "$line" | cut -d$'\t' -f4)"

      if [[ "$ports" != *", "* ]]; then
        ports="$(echo "$ports" | sed -r 's/->[0-9]+//g')"
      fi

      uptime="${uptime/ (healthy)/}"
      uptime="${uptime/ hours/h}"
      if [[ "$uptime" == "Exited"* ]]; then
        local exit_code ago
        exit_code="$(echo "$uptime" | sed -r 's/Exited \(([0-9]+)\).*/\1/g')"
        ago="$(echo "$uptime" | sed -r 's/.*\) //')"
        ago="${ago/ ago/}"
        if [[ "$exit_code" == "0" ]]; then
          uptime="-"
        else
          uptime="e$exit_code $ago"
        fi

        ports="$uptime"
      fi

      if [[ "$image" == *":"*":"* ]]; then
        local repo relative_name
        repo="$(echo "$image" | cut -d/ -f1 | cut -d: -f1 | sed -r 's/([a-z0-9])[a-z0-9]+-?/\1/g ; s/\..+//g')"
        relative_name="$(echo "$image" | cut -d/ -f2-)"
        image="$repo:$relative_name"
      fi
      image="${image/el7\//}"

      printf '%s\t%s\t%s\n' "$name" "$ports" "$image"
    done
  ) | column -t -s $'\t'
}


# executes a bash command in the supplied docker container
debash () {
  local container_id="${1}"
  docker exec -it "$container_id" bash
}

# executes a bash command in the supplied docker container
depsql () {
  local container_id="${1}"
  local db_id="${2}"
  docker exec -it "$container_id" bash -c "psql '$db_id'"
}

# executes a command in the supplied docker container
de () {
  docker exec -it "$@"
}


# a function that curls a URL, and returns formatted JSON
curlj () {
  curl -s "$@" | jq -C '.'
}
# the same as above, but also through less
curljl () {
  curlj "$@" | less -R
}


# get duration in seconds of a audio/video file
ffduration () {
  local file="$1"
  ffprobe "${file}" 2>&1 \
    | grep Duration \
    | grep -oE '[0-9]+:[0-9]+:[0-9.]+' \
    | sed -r 's/([0-9]+):([0-9]+):([0-9.]+)/scale=2; (\1 * 60 + \2) * 60 + \3/' \
    | bc
}

# add numbers from stdin together
add_numbers () {
  paste -d+ -s | bc
}

# print a duration in seconds as hours, minutes, seconds
pretty_duration () {
  local time="$1"

  local seconds minutes hours days
  seconds="$(sed -r 's/\..+//' <<<"$time")"
  minutes=0
  hours=0
  days=0

  if [[ "$seconds" -gt 60 ]]; then
    minutes="$(( seconds / 60 ))"
    seconds="$(( seconds - (minutes * 60) ))"
  fi
  if [[ "$minutes" -gt 60 ]]; then
    hours="$(( minutes / 60 ))"
    minutes="$(( minutes - (hours * 60) ))"
  fi
  if [[ "$hours" -gt 24 ]]; then
    days="$(( hours / 24 ))"
    hours="$(( hours - (days * 24) ))"
  fi

  local format=
  format="${seconds}s"
  if [[ "$minutes" -gt 0 ]]; then
    format="${minutes}m ${format}"
  fi
  if [[ "$hours" -gt 0 ]]; then
    format="${hours}h ${format}"
  fi
  if [[ "$days" -gt 0 ]]; then
    format="${days}days ${format}"
  fi
  echo "$format"
}
