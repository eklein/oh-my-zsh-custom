function rbenv_prompt_info() {
  which rbenv > /dev/null
  if [ $? -eq '0' ]; then
    RBENV_VERSION=`rbenv version | awk '{print $1}'`
    echo "(rbenv:$RBENV_VERSION)"
  fi
}
