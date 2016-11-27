alias br='brew'
alias brup='brew update && brew upgrade && brew cleanup'
alias bro='brew update && brew outdated'
alias brc='brew cask'
alias bri='brew install'
alias brs='brew search'
alias brh='brew home'
alias brdr='brew doctor'

brew-help () {
  echo
  echo 'Homebrew Alias Usage'
  echo
  alias | grep brew | sed 's/=/	= /'
  echo
}