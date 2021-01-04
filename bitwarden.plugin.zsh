#! zsh

0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if (( $+commands[bw] )); then
  fpath=("${0:h}/functions" "${fpath[@]}")
  autoload -Uz $fpath[1]/*(.:t)

  : ${BITWARDENCLI_APPDATA_DIR:=$XDG_DATA_HOME/bitwarden}
  export BITWARDENCLI_APPDATA_DIR

  __bitwarden_init() {
    local session=$(__bitwarden_cache_read_session)
    __bitwarden_set_session $session
  }

  __bitwarden_set_session() {
    local session=$1
    if [[ -n $session ]]; then
      local bw_status=$(bw status --session $session | jq --raw-output .status 2>/dev/null)
      if [[ $bw_status == unlocked ]]; then
        export BW_SESSION=$session
        __bitwarden_cache_write_session $session
      else
        echo 'Bitwarden session expired\r'
      fi
    else
      echo 'Bitwarden vault locked\r'
    fi
  }

  __bitwarden_cache_write_session() {
    local session=$1
    echo $session > $(__bitwarden_cache_dir)/session
  }

  __bitwarden_cache_read_session() {
    local cache_dir=$(__bitwarden_cache_dir)
    [[ -f $cache_dir/session ]] && cat $cache_dir/session
  }

  __bitwarden_cache_dir() {
    local cache_dir=$XDG_CACHE_HOME/bitwarden
    [[ -d $cache_dir ]] || mkdir -p $cache_dir
    echo $cache_dir
  }

  __bitwarden_init
else
  echo 'Bitwarden-CLI not installed\r'
fi