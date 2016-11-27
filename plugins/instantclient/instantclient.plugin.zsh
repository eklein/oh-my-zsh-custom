IC=$HOME/bin/`ls -1 $HOME/bin | grep '^instantclient' | sort -n | head -1`
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$IC
export PATH=$PATH:$IC
