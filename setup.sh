#!/bin/bash
if [[ $EUID == 0 ]]; then
    read -p "It looks like you're currently root, are you sure? [y/n] " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo
        echo "Setup cancelled"
        echo
        exit
    fi
fi

PATH_GITCONFIG=~/.gitconfig
PATH_GITIGNORE=~/.gitignore
RM=`which rm`
TEE=`which tee`
CAT=`which cat`
TOUCH=`which touch`

if [ -f $PATH_GITCONFIG ]; then
    echo
    echo "Continuing will delete the file located at: $PATH_GITCONFIG?"
    echo
    echo "Are you sure you want to continue?"
    read -p "[y/n] " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo
        echo "Setup cancelled"
        echo
        exit
    fi

    echo
    echo "------------------------------------------"
    echo "Deleting file: $PATH_GITCONFIG"
    echo "------------------------------------------"
    echo
    $RM $PATH_GITCONFIG > /dev/null
fi

if [ ! -f $PATH_GITIGNORE ]; then
$CAT << EOF | $TEE $PATH_GITIGNORE >> /dev/null
.project
.settings
.buildpath
*~
EOF
fi

echo
echo "What's your email address?"
read -p " > " EMAIL
# TODO: Validate email one day?
echo "What's your Git name?"
read -p " > " USERNAME
$CAT << EOF | $TEE $PATH_GITCONFIG >> /dev/null
[user]
    name = $USERNAME
    email = $EMAIL
[core]
    excludesfile = $PATH_GITIGNORE
[alias]
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset %C(blue)(%an <%ae>)%Creset' --abbrev-commit --date=relative
    tlg = log --tags --simplify-by-decoration --pretty=format:'%ai %d'
    latest = for-each-ref --sort=-committerdate --format='%(committerdate:short) %(refname:short)'
[color]
    ui = auto
[color "diff"]
    meta = yellow bold
    frag = magenta bold
    old = red bold
    new = green bold
[color "status"]
    added = yellow
    changed = green
    untracked = cyan
EOF
