
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit
compdef git-achievements=git

autoload -U bashcompinit
bashcompinit

setopt COMPLETE_IN_WORD

autoload -U colors
colors

EDITOR=/usr/bin/vim
HISTFILE=~/.histfile
HISTSIZE=1000000000
SAVEHIST=1000000000
PATH=/usr/lib/colorgcc/bin:~/.local/bin:~/.cargo/bin:$PATH

export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'

setopt appendhistory autocd beep extendedglob notify prompt_subst prompt_percent
setopt extended_history INC_APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY transientrprompt

if [ -d ~/code/dotfiles/bin ]; then
    path=($(realpath -m ~/code/dotfiles/bin) $path)
    export PATH
fi

if [ -f /usr/share/virtualenvwrapper/virtualenvwrapper.sh ]; then
    path=('/usr/share/virtualenvwrapper' $path)
    export PATH
    source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
fi


export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/code

if [ -f $HOME/.local/bin/register-python-argcomplete ]; then
    eval "$(register-python-argcomplete pipx)"
fi

if [ -f /usr/local/bin/antibody ]; then
    source <(antibody init)
    antibody bundle robbyrussell/oh-my-zsh path:plugins/docker
    antibody bundle robbyrussell/oh-my-zsh path:plugins/docker-compose
    antibody bundle robbyrussell/oh-my-zsh path:plugins/git-extras
    antibody bundle robbyrussell/oh-my-zsh path:plugins/git-hubflow
    antibody bundle robbyrussell/oh-my-zsh path:plugins/python
    antibody bundle robbyrussell/oh-my-zsh path:plugins/salt
    # This imports the wrapper if it can find it, but really I'd rather not since it prefers lazy loading
    antibody bundle robbyrussell/oh-my-zsh path:plugins/virtualenvwrapper
    antibody bundle sharat87/pip-app
    antibody bundle supercrabtree/k
    antibody bundle zpm-zsh/figures
    #antigen bundle unixorn/autoupdate-antigen.zshplugin
    #antigen apply
fi

alias ls="ls --color=auto"
alias grep='grep --colour=auto'
alias vi=vim
alias esed="sed -r"

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

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
ESC=`echo "\e"`

if [[ -z $HAVE_POWERLINE ]]; then
  # This isn't a certain thing, but it's probably good enough.
  fc-list -q PowerlineSymbols &> /dev/null
  if [[ $? -eq 0 ]]; then
    HAVE_POWERLINE=true
  fi
fi

# Glyph selection...
if [[ $HAVE_POWERLINE == true ]]; then
  LT=''
  GT=''
  FILLGT=''
else
  LT='<'
  GT='>'
  FILLGT='>'
fi
unset HAVE_POWERLINE # Don't leak this, it gives headaches :p

function _ssh-reagent {
  ls /tmp | grep ssh- 2>&1 > /dev/null
  if [[ $? == 0 ]]; then
    for agent in /tmp/ssh-*/agent.*; do
      export SSH_AUTH_SOCK=$agent
      ssh-add -l 2>&1 > /dev/null
      return $?
      if [ $? != 2 ]; then
        return
      fi
    done
  fi
  return 2
}

function ssh-reagent {
  _ssh-reagent
  case $? in
    2)
      echo 'Cannot find ssh agent, starting one'
      eval `ssh-agent -s`
      echo '';&
    1)
      echo 'No keys found, adding some.'
      ssh-add
      echo '';&
    0)
      echo 'Found working SSH Agent:'
      ssh-add -l;;
  esac
}

if [[ $TERM == "" ]]; then
    # This is actualy a non-interactive terminal btw...
else
    if [[ -f ~/.dotfiles/generatemaze.py ]]; then
        echo "Have some a-maze-ing art..."
        env python ~/.dotfiles/generatemaze.py 70 15 2>/dev/null
    fi
fi

echo "Shell up...\n"
#ssh-reagent # > /dev/null

function gnome_reagent {
  echo "\ngnome-keyring-daemon says:"
  gnometest=`gnome-keyring-daemon --start | grep -v SSH_AUTH_SOCK`
  echo $gnometest
  eval $gnometest
  export GNOME_KEYRING_CONTROL
  export GPG_AGENT_INFO
}

if [[ ($EUID -eq 0) || ("$USER" == 'root')]]; then
  echo "\nSkipping gnome-keyring-daemon for root."
else
  #gnome_reagent
fi

if [[ "$SSH_AUTH_SOCK" == '' ]]; then
    export SSH_AUTH_SOCK="/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"
else
    echo "\nSkipping new SSH agent"
fi

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

# This is based on the (not entirely related) code provided for doing the same thing as `transientrprompt` here:
# http://stackoverflow.com/questions/14316463/zsh-clear-rps1-before-adding-line-to-linebuffer
function _-accept-line()
{
    TMOUT=0
    emulate -L zsh
    PROMPT=$COLLAPSED_PROMPT
    zle reset-prompt
    zle .accept-line
}
zle -N accept-line _-accept-line

trap ctrl_c INT
function ctrl_c() {
  emulate -L zsh
  FOO=$PROMPT
  RFOO=$RPS1
  PROMPT=$COLLAPSED_PROMPT
  RPS1=""
  zle reset-prompt
  zle -I
  zle end-of-history
  echo ""
  echo "** Trapped CTRL-C"
  zle -R
  PROMPT=$FOO
  RPS1=$RFOO
  zle kill-buffer
  zle reset-prompt
}

F_HG=false
F_GIT=false
result=''
result_bw=''

function collapse_path {
  dir=${1/$HOME/\~}
  tree=(${(s:/:)dir})
  result=''
  result_bw=''
  temp=''
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
      result+="%B%F{white}/%B%F{magenta}"
    } elif [[ -d ${~temp}${dir}/.git ]] {
      F_GIT=true
      result+="%B%F{white}/%B%F{magenta}"
    } elif [[ -d ${~temp}${dir}/.hg ]] {
      F_HG=true
      result+="%B%F{white}/%B%F{magenta}"
    } else {
      result+="%B%F{white}/%B%F{green}"
    }
    if (( $#tree <= 3 )) {
      result+=$dir
      result_bw+="/$dir"
      temp+="$dir/"
      if (( $#tree == 1 )) { break }
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
  result+="%b"
}

function precmd {
  local errno=$?
  RPS1="%B%F{green}%*%B%F{white}" #<-- current time
  PROMPT=""
  typeset -a PROMPT_PARTS
  typeset -a COLLAPSED_PROMPT_PARTS
  COLLAPSED_PROMPT=""
  if [[ ($errno -gt 0) && ($RAN -eq 1)]] {
    PROMPT_PARTS+=("%F{red}#   !!! %F{cyan}${LT} %F{red}Previous exit status: %? %F{cyan}${GT}")
    COLLAPSED_PROMPT_PARTS+=("%F{red}#   !!! %F{cyan}${LT} %F{red}Previous exit status: %? %F{cyan}${GT}")
  }
  RAN=0
  PROMPT_PARTS+=('%{${ESC}[48;5;17m%}%E')
  PROMPT_LINE="%b%{${ESC}[0m%}%F{red}#  %b%F{cyan}╭────────${LT} %y ${LT} $SHLVL deep ${LT} "
  COLLAPSED_PROMPT_LINE="%F{red}#  %B%F{cyan}.%b%F{cyan}---- "
  if [[ ($EUID -eq 0) || ("$USER" == 'root')]] {
    PROMPT_LINE+="%B%F{red}%m%b " #<-- Host
    COLLAPSED_PROMPT_LINE+="%B%F{red}root %F{white}@ %F{red}%m%b " #<-- root@Host
  } else {
    PROMPT_LINE+="%B%F{green}%n%F{cyan} @ %B%F{green}%m%b " #<-- User @ Host
    COLLAPSED_PROMPT_LINE+="%B%F{green}%n%F{cyan} @ %B%F{green}%m%b " #<-- root@Host
  }
  PROMPT_LINE+="%2(j.%F{cyan}${GT}────${LT} %F{green}%j Jobs ."
  PROMPT_LINE+="%1(j@%F{cyan}${GT}────${LT} %F{green}1 Job @)"
  PROMPT_LINE+=")%F{cyan}${GT}────${LT} "

  PWD=`pwd`
  F_HG=false
  F_GIT=false
  collapse_path $PWD

  PROMPT_LINE+=${result:-/}
  PROMPT_LINE+="%b%E"
  COLLAPSED_PROMPT_LINE+=": "${result:-/}
  COLLAPSED_PROMPT_LINE+="%b"
  PROMPT_PARTS+=($PROMPT_LINE)
  COLLAPSED_PROMPT_PARTS+=($COLLAPSED_PROMPT_LINE)
  if [[ -d .svn ]] {
    svn_repo=`head -n 6 .svn/entries | tail -n 1`
    PROMPT_PARTS+=("%b%F{red}#  %F{cyan}├───────${LT}%b %F{green}SVN repo %F{cyan}${GT} %F{yellow}${svn_repo}")
  }
  if ($F_GIT) {
    git_path=`git remote -v |grep fetch|sed -E 's/\t/ /g'|cut -f2 -d' '|sed ':s;N;s/\n/, /;t s;'`
    guessed_branch=`git branch | sed -n '/\* /s///p'`
    tracking_branch=`git rev-parse --symbolic-full-name --abbrev-ref @{u}`
    PROMPT_PARTS+=('%b%F{red}#  %F{cyan}├───────${LT}%b %F{green}Git repo %F{cyan}${GT} %F{yellow}${git_path} %F{cyan}${GT} %F{yellow}${guessed_branch}%F{green} (tracking %F{yellow}${tracking_branch}%F{green})')
  }
  if ($F_HG) {
    hg_path=`hg paths|cut -f3- -d' '`
    PROMPT_PARTS+=("%b%F{red}#  %F{cyan}├───────${LT}%b %F{green}HG repo %F{cyan}${GT} %F{yellow}${hg_path}")
  }
  if [[ -n "$VIRTUAL_ENV" ]] {
    collapse_path $VIRTUAL_ENV
    PROMPT_PARTS+=("%b%F{red}#  %F{cyan}├──────${LT}%b %F{green}Using Virtualenv %F{cyan}${GT} %F{yellow}${result}")
  }
  PROMPT_PARTS+=("%b%F{red}#  %b%F{cyan}╰────${FILLGT} %k%b%F{white}")
  COLLAPSED_PROMPT_PARTS+=("%F{red}#  %B%F{cyan}$BTICK%b%F{cyan}----> %B%F{white}")
  PROMPT=${(pj:\n:)PROMPT_PARTS}
  COLLAPSED_PROMPT=${(pj:\n:)COLLAPSED_PROMPT_PARTS}
  title "zsh in $result_bw"
}

# This must be at the end
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
