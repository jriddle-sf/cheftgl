#!/usr/bin/env bash

CHEF_CONF="$HOME/.chef/config.rb"
CHEF_CONF_LATEST="$HOME/.chef/config.latest.rb"
CHEF_CONF_PREVIOUS="$HOME/.chef/config.previous.rb"
OPTION="$1"

__usage(){
  echo ''
  echo -e "$(basename "$0") - Usage"
  echo ''
  echo -e '\t-l | --latest\tEnable the global Chef Config file'
  echo -e '\t-p | --previous\tDisable the global Chef Config file'
  echo -e '\t-h | --help\tShows usage'
  echo -e '\t-i | --install\tInstalls Chef Config'
  echo -e '\t-d | --dump\tPrints active global Chef Config file'
  echo -e '\t-s | --status\tDisplays current status of Chef Config'
  echo -e '\t-v | --validate\tValidates Chef Config Files'
  echo ''
} 

__latest(){
  if ln -sf "$CHEF_CONF_LATEST" "$CHEF_CONF"; then
    echo "Latest Chef config enabled."
    exit 0
  else
    exit 1
  fi
}

__previous(){
  if ln -sf "$CHEF_CONF_PREVIOUS" "$CHEF_CONF"; then
    echo "Previous Chef config enabled."
    exit 0
  else
    exit 1
  fi
}

__create_previous(){
  if [ -e "$CHEF_CONF" ]; then
    cp "$CHEF_CONF" "$CHEF_CONF_PREVIOUS"
  fi
}

__create_latest(){
  if [ -e "$CHEF_CONF" ]; then
    cp "$CHEF_CONF" "$CHEF_CONF_LATEST"
  fi

}

__install(){
  if [ ! -e "$CHEF_CONF_LATEST" ]; then
    if [ -e "$CHEF_CONF" ]; then
      __create_previous && __create_latest && __latest
    else
      echo "Could not find Chef config at ${CHEF_CONF}"
    fi
  else
    __latest
  fi
}

__is_latest(){
  local active_file
  active_file="$(readlink "$CHEF_CONF")"
  if [ "$active_file" = "$CHEF_CONF_LATEST" ]; then
    return 0
  else
    return 1
  fi
}

__status(){
  if __is_latest; then
    echo "Latest Chef config enabled"
  else
    echo "Previous Chef config enabled"
  fi
}

__dump(){
  while read -r line; do
    echo "$line"
  done < "$CHEF_CONF"
}

__validate(){
  chef_conf="X"
  chef_conf_previous="X"
  chef_conf_latest="X"
  
  if [ -e "$CHEF_CONF" ] && [ -L "$CHEF_CONF" ]; then
    chef_conf="✓"
  fi

  if [ -e "$CHEF_CONF_PREVIOUS" ]; then
    chef_conf_previous="✓"
  fi

  if [ -e "$CHEF_CONF_PREVIOUS" ]; then
    chef_conf_latest="✓"
  fi

  echo "Chef Conf (link)   [ ${chef_conf} ]"
  echo "Chef Conf Previous [ ${chef_conf_previous} ]"
  echo "Chef Conf Latest   [ ${chef_conf_latest} ]"
}

main(){
  option="$1"
  case "$option" in
    -p|--previous)
      __previous
    ;;
    -t|--latest)
      __latest
    ;;
    -h|--help)
      __usage
    ;;
    -i|--install)
      __install  
    ;;
    -d|--dump)
    __dump
    ;;
    -s|--status)
      __status
    ;;
    -v|--validate)
      __validate
    ;;
    *)
      __usage
    ;;
  esac
}

main "$OPTION"

