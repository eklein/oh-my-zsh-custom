kb () {
  ln -sf ~/.chef/knife-$1.rb ~/.chef/knife.rb
}

function knife_prompt_info() {
  if [ -h ~/.chef/knife.rb ]; then
    echo "(knife:`readlink ~/.chef/knife.rb | awk -F- '{print $2}'| sed 's/.rb//'`)"
  else
    echo "(knife:default)"
  fi
}

function knife_kill_node() {
  if [ -n $1 ]; then
    knife node delete $1 -y
    knife client delete $1 -y
  else
    echo "Usage: knife_kill_node <node_name>"
  fi
}

alias kitchen="be kitchen"
alias k=kitchen
alias kt="kitchen test"
alias kp="kitchen create all && kitchen converge all && kitchen setup all"
alias kv="kitchen verify"
alias kc="kitchen converge"

alias berks="be berks"
