#!/usr/bin/env zsh

0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if (( ! $+commands[bw] )); then
  echo 'Bitwarden-CLI not installed\r'
elif (( ! $+commands[jq] )); then
  echo 'jq not installed\r'
else
  fpath=("${0:h}/functions" "${fpath[@]}")
  autoload -Uz $fpath[1]/*(.:t)

  # ensure cache dir is created
  : ${BW_CACHE_DIR:="$XDG_CACHE_HOME/bitwarden"}
  [[ -d $BW_CACHE_DIR ]] || mkdir -p $BW_CACHE_DIR

  bw_get_status() {
    echo  $(bw status --session ${1:=$BW_SESSION} | jq --raw-output .status 2>/dev/null)
  }

  # read cached session
  : ${BW_SESSION:=$(cat $cache_dir/session 2>/dev/null)}
  : ${BW_VAULT_STATUS::=$(bw_get_status $BW_SESSION)}
  if [[ ! $BW_VAULT_STATUS == 'unlocked' ]]; then
    echo "Bitwarden vault $BW_VAULT_STATUS\r"
  else
    export BW_SESSION
  fi
  : ${BITWARDENCLI_APPDATA_DIR:=$XDG_DATA_HOME/bitwarden}
  export BITWARDENCLI_APPDATA_DIR

  # function () {
  #   [[ (bw status ${BW_SESSION:+"--session $BW_SESSION"} | jq --raw-output .status) == 'unlocked' ]] && echo '' || echo '' 
  # }

fi