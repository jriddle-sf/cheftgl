#!/usr/bin/env bash

CHEF_CONF="${HOME}/.chef/config.rb"
CHEF_CONF_LATEST="${HOME}/.chef/config.latest.rb"
CHEF_CONF_PREVIOUS="${HOME}/.chef/config.previous.rb"
OPTION="$1"

__usage(){
  echo ''
  echo "Usage: $(basename "$0") [option]"
  echo ''
  echo '  -d | --dump      Dumps the config to the output'
  echo '  -h | --help      Shows usage'
  echo '  -i | --install   Installs Chef Config'
  echo '  -l | --latest    Enables the latest config.'
  echo '  -p | --previous  Enables the previous config.'
  echo '  -s | --status    Displays the filename for the active Chef config'
  echo '  -v | --validate  Validates Chef Config Files'
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

__status(){
  active_config="$(readlink "$CHEF_CONF")"
  echo "Active config is ${active_config}"
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
    -d|--dump)
      __dump
    ;;
    -h|--help)
      __usage
    ;;
    -i|--install)
      __install  
    ;;
    -l|--latest)
      __latest
    ;;
    -p|--previous)
      __previous
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

