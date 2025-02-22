#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$HOME/.dotfiles"

# ------------------------------------------------------------------------------------------
# Link and Back up Helper
# ------------------------------------------------------------------------------------------

link_dotfiles() {
  TARGET_FILE="$HOME/$1" SOURCE_FILE="$SCRIPT_DIR/home/$1" link_file "$1"
}

link_config() {
  TARGET_FILE="$HOME/.config/$1" SOURCE_FILE="$SCRIPT_DIR/config/$1" link_file "$1"
}

link_file() {
  # creating backup files
  if [[ ! -L "$TARGET_FILE" ]]; then
    [[ -e "$TARGET_FILE" ]] && mv "$TARGET_FILE" "$TARGET_FILE.backup"
  else
    LINKING_TO=$(readlink "$TARGET_FILE")

    if [[ "$LINKING_TO" == "$SOURCE_FILE" ]]; then
      echo "> Symlink for $TARGET_FILE already exists. Skipping!"
      return
    else
      mv "$TARGET_FILE" "$TARGET_FILE.backup"
    fi
  fi

  ln -s "$SOURCE_FILE" "$TARGET_FILE"
  echo "> Created symlink for $TARGET_FILE."
}

# ------------------------------------------------------------------------------------------
# Begin Script
# ------------------------------------------------------------------------------------------

echo "======================================================================="
echo "Beginning installation"
echo "======================================================================="
echo ""

cd "$HOME" || (echo "unable to cd to \$HOME" && exit 1)

# Move the dotfiles directory to the HOME path if necessary...
[[ ! -d $DOTFILES_DIR ]] && mv "$SCRIPT_DIR" "$DOTFILES_DIR"

echo ""
echo "======================================================================="
echo "Installing Dotfiles"
echo "======================================================================="

# link_dotfiles ".zshrc"
link_dotfiles ".p10k.zsh"
link_dotfiles ".hushlogin"
link_dotfiles ".gitconfig"
link_dotfiles ".gitignore"
link_dotfiles ".vimrc"
link_dotfiles ".ignore"
link_dotfiles ".asdfrc"
link_dotfiles ".ideavimrc"

echo ""
echo "======================================================================="
echo "Installing Config"
echo "======================================================================="

link_config "nvim"
link_config "tmux"
link_config "ohmyposh"
link_config "starship.toml"
link_config "ghostty"

echo ""
echo ""
echo "======================================================================="
echo "Installation complete"
echo "======================================================================="
