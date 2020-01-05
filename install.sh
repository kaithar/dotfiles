#! /bin/bash

FROM=$(pwd)

function linking { 
	if [ -f ~/$2 ]
	then
		echo "~/$2 already exists"
	else
		ln -vs $FROM/$1 ~/$2
	fi
}

mkdir -vp ~/.vim/{backup,tmp,undos}

linking gitconfig .gitconfig
linking gitignore_global .gitignore_global
linking htoprc .htoprc
linking inputrc .inputrc
linking lessfilter .lessfilter
linking screenrc .screenrc
linking tmux.conf .tmux.conf
linking toprc .toprc
linking vimrc .vimrc
linking zshrc .zshrc
#generatemaze.py  gitconfig  htoprc  inputrc  lessfilter  powerline-fonts  README.md  screenrc  ssh  tmux.conf  toprc  vimrc  zshrc

apt install git htop screen tmux vim zsh build-essential zsh-syntax-highlighting

curl -sfL git.io/antibody | sh -s - -b /usr/local/bin
