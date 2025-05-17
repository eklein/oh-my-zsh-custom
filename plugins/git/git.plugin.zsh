# Aliases
alias g='git'
compdef g=git
alias gs='git status'
compdef _git gs=git-status
alias gl='git pull'
compdef _git gl=git-pull
alias gup='git pull --rebase'
compdef _git gup=git-fetch
alias gp='git push'
compdef _git gp=git-push
alias gd='git diff'
gdv() { git diff -w "$@" | view - }
compdef _git gdv=git-diff
alias gdc='git diff --cached'
compdef _git gdc=git-diff
alias gc='git commit -v'
compdef _git gc=git-commit
alias gca='git commit -v -a'
compdef _git gca=git-commit
alias gco='git checkout'
compdef _git gco=git-checkout
alias gcm='git checkout main'
alias gr='git remote'
compdef _git gr=git-remote
alias grv='git remote -v'
compdef _git grv=git-remote
alias grmv='git remote rename'
compdef _git grmv=git-remote
alias grrm='git remote remove'
compdef _git grrm=git-remote
alias grset='git remote set-url'
compdef _git grset=git-remote
alias grup='git remote update'
compdef _git grset=git-remote
alias gb='git branch'
compdef _git gb=git-branch
alias gba='git branch -a'
compdef _git gba=git-branch
alias gcount='git shortlog -sn'
compdef gcount=git
alias gcl='git config --list'
alias gcp='git cherry-pick'
compdef _git gcp=git-cherry-pick
alias glg='git log --stat --max-count=5'
compdef _git glg=git-log
alias glgg='git log --graph --max-count=5'
compdef _git glgg=git-log
alias glgga='git log --graph --decorate --all'
compdef _git glgga=git-log
alias gss='git status -s'
compdef _git gss=git-status
alias ga='git add'
compdef _git ga=git-add
alias gm='git merge'
compdef _git gm=git-merge
alias grh='git reset head'
alias grhh='git reset head --hard'
alias gwc='git whatchanged -p --abbrev-commit --pretty=medium'
alias gf='git ls-files | grep'
alias gpoat='git push origin --all && git push origin --tags'
alias gu='git fetch upstream && git rebase upstream/main'

function gkb() {
  git branch -d $1 && git push origin :${1}
}

# will cd into the top of the current repository
# or submodule.
alias grt='cd $(git rev-parse --show-toplevel || echo ".")'

# git and svn mix
alias git-svn-dcommit-push='git svn dcommit && git push github main:svntrunk'
compdef git-svn-dcommit-push=git

alias gsr='git svn rebase'
alias gsd='git svn dcommit'
#
# will return the current branch name
# usage example: git pull origin $(current_branch)
#
function current_branch() {
  ref=$(git symbolic-ref head 2> /dev/null) || \
  ref=$(git rev-parse --short head 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

function current_repository() {
  ref=$(git symbolic-ref head 2> /dev/null) || \
  ref=$(git rev-parse --short head 2> /dev/null) || return
  echo $(git remote -v | cut -d':' -f 2)
}

# show local git user.name
function vi-git-username() {
  local -a username

  username=$(git config --local --get user.name 2> /dev/null | sed -e 's/\(.\{40\}\).*/\1.../')
  if [ -z $username ]; then
    return
  else
    echo "(pair:$username)"
  fi
}

# these aliases take advantage of the previous function
alias ggpull='git pull origin $(current_branch)'
compdef ggpull=git
alias ggpush='git push origin $(current_branch)'
compdef ggpush=git
alias ggpnp='git pull origin $(current_branch) && git push origin $(current_branch)'
compdef ggpnp=git

#git config --global alias.br "branch"
#git config --global alias.co "checkout"
#git config --global alias.ci "commit"
#git config --global alias.d "diff"
#git config --global alias.dc "diff --cached"
#git config --global alias.st "status"
#git config --global alias.la "config --get-regexp alias"

__log_cmd__="log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"

#git config --global alias.lg "$__log_cmd__"
#git config --global alias.lga "${__log_cmd__} --all"

alias lg="git ${__log_cmd__}"
alias lga="git ${__log_cmd__} --all"

#git config --global push.default "simple"
