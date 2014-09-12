
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit

setopt COMPLETE_IN_WORD

autoload -U colors
colors

EDITOR=/usr/bin/vim
HISTFILE=~/.histfile
HISTSIZE=1000000000
SAVEHIST=1000000000
PATH=/usr/lib/colorgcc/bin:$PATH

setopt appendhistory autocd beep extendedglob notify prompt_subst prompt_percent
setopt extended_history INC_APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY transientrprompt

alias ls="ls --color=always"
alias grep='grep --colour=auto'

bindkey "\e[1~" vi-beginning-of-line # Home
bindkey "\e[2~" list-choices # Insert
bindkey "\e[3~" vi-delete-char # Delete
bindkey "\e[4~" vi-end-of-line # End
bindkey "\e[5~" history-beginning-search-backward # Page up
bindkey "\e[6~" history-beginning-search-forward # Page down

bindkey "\e[H" vi-beginning-of-line # Home
bindkey "\e[F" vi-end-of-line # End

RAN=0
BTICK='\`'

function ssh-reagent {
  for agent in /tmp/ssh-*/agent.*; do
    export SSH_AUTH_SOCK=$agent
    if ssh-add -l 2>&1 > /dev/null; then
      echo 'Found working SSH Agent:'
      ssh-add -l
      return
    fi
  done
  echo 'Cannot find ssh agent - maybe you should reconnect and forward it?'
}


function title {
  if [[ $TERM == "screen" ]]; then
    # Use these two for GNU Screen:
    print -nR $'\033k'$1$'\033'\\

    print -nR $'\033]0;'$2$'\a'
  elif [[ $TERM == "xterm" || $TERM == "rxvt" ]]; then
    # Use this one instead for XTerms:
    print -nR $'\033]0;'$*$'\a'
  fi
}

function preexec {
  RAN=1
  print -n "\e[0m"
  emulate -L zsh
  local -a cmd; cmd=(${(z)1})
  title $cmd[1]:t "$cmd[2,-1]"

}

function _-accept-line()
{
    emulate -L zsh
    # PROMPT="test"
    zle reset-prompt
    zle .accept-line
}
zle -N accept-line _-accept-line

function precmd {
  local errno=$?
  PROMPT=""
  if [[ ($errno -gt 0) && ($RAN -eq 1)]] {
    PROMPT+="%F{red}#   !!! %F{cyan}< %F{red}Previous exit status: %? %F{cyan}>
"
    RAN=0
  }
  PROMPT+="%F{red}#  %B%F{cyan}.%b%F{cyan}---- "
  PROMPT+="%B%F{green}%T%b%F{cyan} ---- " #<-- Date
  if [[ ($EUID -eq 0) || ("$USER" == 'root')]] {
    PROMPT+="%B%F{red}%m%b " #<-- Host
  } else {
    PROMPT+="%B%F{green}%n%F{cyan} @ %B%F{green}%m%b " #<-- User @ Host
  }
  PROMPT+="%2(j.%F{cyan}---- %F{green}%j Jobs ."
  PROMPT+="%1(j@%F{cyan}---- %F{green}1 Job @)"
  PROMPT+=")%F{cyan}---- "

  PWD=`pwd`
  dir=${PWD/$HOME/\~}
  tree=(${(s:/:)dir})
  result=''
  result_bw=''
  temp=''
  F_HG=false
  F_GIT=false
  if [[ $tree[1] == \~* ]] {
    temp="${~tree[1]}/"
    result_bw=$tree[1]
    result=$tree[1]
    shift tree
  } else {
    temp="/"
  }
  for dir in $tree; {
    if [[ -d ${~temp}${dir}/.svn ]] {
      result+="%b%F{green}/%B%F{magenta}"
    } elif [[ -d ${~temp}${dir}/.git ]] {
      F_GIT=true
      result+="%b%F{green}/%B%F{magenta}"
    } elif [[ -d ${~temp}${dir}/.hg ]] {
      F_HG=true
      result+="%b%F{green}/%B%F{magenta}"
    } else {
      result+="%b%F{green}/%B%F{green}"
    }
	if (( $#tree <= 3 )) {
	  result+=$dir
      result_bw+="/$dir"
      temp+="$dir/"
      if (( $#tree == 1 )) {
        break
      }
      continue
    }
    expn=(a b)
    part=''
    i=0
    until [[ (( ${#expn} == 1 )) || $dir = $expn || $i -gt 99 ]]  do
      (( i++ ))
      part+=$dir[$i]
      expn=($(echo "${~temp}${part}*(-/)"))
    done
	result+=$part
    temp+="$dir/"
    result_bw+="/$part"
    shift tree
  }
  PROMPT+=${result:-/}
  PROMPT+="%b"
  if [[ -d .svn ]] {
    svn_repo=`head -n 6 .svn/entries | tail -n 1`
    PROMPT+="
%F{red}# %F{cyan}{----%b %F{green}SVN repo: %F{yellow}${svn_repo}"
  }
  if ($F_GIT) {
    git_path=`git remote -v |grep fetch|sed -E 's/\t/ /g'|cut -f2 -d' '|sed ':s;N;s/\n/, /;t s;'`
    PROMPT+="
%F{red}# %F{cyan}{----%b %F{green}Git repo: %F{yellow}${git_path}"
  }
  if ($F_HG) {
    hg_path=`hg paths|cut -f3- -d' '`
    PROMPT+="
%F{red}# %F{cyan}{----%b %F{green}HG repo: %F{yellow}${hg_path}"
  }
  PROMPT+="
%F{red}#  %B%F{cyan}$BTICK%b%F{cyan}---> %B%F{white}"
  title "zsh in $result_bw"
}

