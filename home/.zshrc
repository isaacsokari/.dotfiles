# zmodload zsh/zprof

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# set ls colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::command-not-found
zinit snippet OMZP::qrcode

# set up asdf
export ASDF_DATA_DIR=${ASDF_DATA_DIR:-$HOME/.asdf}
if [[ -d $ASDF_DATA_DIR ]]; then
  export PATH="$ASDF_DATA_DIR/shims:$PATH"

  # append completions to fpath
  fpath=($ASDF_DATA_DIR/completions $fpath)

  if asdf list java > /dev/null 2>&1; then
    . $ASDF_DATA_DIR/plugins/java/set-java-home.zsh
  fi
fi

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


if [[ -d "$HOME/.local/share/nvim/mason/bin" ]]; then
  # add show installs globally
  export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
fi

# Shell integrations
if which fzf > /dev/null; then
  eval "$(fzf --zsh)";
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi
if which zoxide > /dev/null; then eval "$(zoxide init --cmd cd zsh)"; fi

# For Loading the SSH key
if [ -f /usr/bin/keychain ]; then
/usr/bin/keychain --nogui $HOME/.ssh/id_rsa
# source $HOME/.keychain/$HOSTNAME-sh
source $HOME/.keychain/$HOST-sh
fi

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

if which rbenv > /dev/null; then
  eval "$(rbenv init -)"; 
  alias ruby='$(rbenv prefix)/bin/ruby'
fi

if which keychain > /dev/null; then
  /usr/bin/keychain --quiet --nogui $HOME/.ssh/id_ed25519
  source $HOME/.keychain/$HOST-sh
fi

if which go > /dev/null; then
  export PATH=$PATH:$(go env GOPATH)/bin
fi

# openssl
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@3/include"

# libpq
export PATH="/usr/local/opt/libpq/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/libpq/lib"
export CPPFLAGS="-I/usr/local/opt/libpq/include"


PATH="/Users/isaac/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/isaac/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/isaac/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/isaac/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/isaac/perl5"; export PERL_MM_OPT;

# enable zsh options
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

source "$HOME/.aliases"

if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

# take functions

# mkcd is equivalent to takedir
function mkcd takedir() {
  mkdir -p $@ && cd ${@:$#}
}

function takeurl() {
  local data thedir
  data="$(mktemp)"
  curl -L "$1" > "$data"
  tar xf "$data"
  thedir="$(tar tf "$data" | head -n 1)"
  rm "$data"
  cd "$thedir"
}

function takegit() {
  git clone "$1"
  cd "$(basename ${1%%.git})"
}

function take() {
  if [[ $1 =~ ^(https?|ftp).*\.(tar\.(gz|bz2|xz)|tgz)$ ]]; then
    takeurl "$1"
  elif [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]; then
    takegit "$1"
  else
    takedir "$@"
  fi
}

if which starship > /dev/null; then
  eval "$(starship init zsh)"
fi

# zprof
