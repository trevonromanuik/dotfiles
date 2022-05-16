#.bashrc

# ----- set default output for ls; add auto ls after cd -----------------------

if [[ "$(uname)" == "Darwin" ]]; then
    export LSCOLORS='dxfxcxexbxegedabagacad'
    alias ls='ls -G'
else
    alias ls='ls --color'
fi

cdls () {
    cd "$1"
    local cderr="$?"
    if [[ "$cderr" -eq '0' ]]; then
        [[ "$1" = '-' ]] || pwd
        shift
        ls "$@"
    fi
    return "$cderr"
}

alias cd='cdls'

# ----- git helpers -----------------------------------------------------------

alias ga='git add -A :/'
alias gd='git diff'
alias gs='git status'
alias gl='git log'
alias gco='git checkout'
alias gpull='git pull'
alias gpush='git push'

gc () {
    git commit -m "$1"
}

gr () {
    git fetch
    git rebase
}

gp() {
    current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [[ "$current_branch" != "master" ]]; then
        echo "WARNING: You are on branch $current_branch, NOT master."
    fi
    git remote update --prune
    remote_branches=$(git branch -r | grep -v "/master$" | grep -v "/$current_branch$")
    local_branches=$(git branch | grep -v "$origin/" | grep -v "master$" | grep -v "$current_branch$")
    del_branches=
    for local in $local_branches; do
        if [[ -z "$(echo "$remote_branches" | grep "$local")" ]]; then
            del_branches="$del_branches $local"
        fi
    done
    if [[ -z "$del_branches" ]]; then
        echo "No branches to remove."
    else
        del_branches="$(echo "$del_branches" | sed 's/^ //')"
        echo "This will remove the following branches:"
        echo "$del_branches" | tr ' ' '\n'
        read -p "Continue? (y/n): " -n 1 choice
        echo
        if [[ "$choice" == "y" ]] || [[ "$choice" == "Y" ]]; then
            git branch -D $del_branches
        else
            echo "No branches removed."
        fi
    fi
}

gu() {
    current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    git push -u origin $current_branch
}

# ----- Prompt config ---------------------------------------------------------

ps1_color_error () {
    if [[ "$1" -eq 0 ]]; then
        printf '32'
    else
        printf '31'
    fi
    exit $1
}

ps1_value_error () {
    if [[ "$1" -gt 0 ]]; then
        printf "$1\n\r"
    fi
}

ps1_git_branch () {
    local br="$(git branch 2> /dev/null)"
    if [[ ! -z "$br" ]]; then
        printf "$br" | sed '/^[^*]/d;s/* \(.*\)/ [\1]/'
    fi
}

export PS1='\[\033[0;$(ps1_color_error $?)m\]$(ps1_value_error $?)\[\033[0m\]\u\[\033[0;33m\] \W\[\033[0;36m\]$(ps1_git_branch)\[\033[0m\]) '

# ----- Default Exports -------------------------------------------------------

export EDITOR=nano
