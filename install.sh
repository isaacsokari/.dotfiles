#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)
DOTFILES_DIR="$HOME/.dotfiles"

# ------------------------------------------------------------------------------------------
# Link and Back up Helper
# ------------------------------------------------------------------------------------------

link_dotfiles() {
	DEFAULT_FILE="$HOME/$1"
	LINK_FILE="$SCRIPT_DIR/$1"

	# creating backup files
	if [[ ! -L "$DEFAULT_FILE" ]]; then
		mv "$DEFAULT_FILE" "$DEFAULT_FILE.backup"
	else
		LINKING_TO=$(readlink "$DEFAULT_FILE")

		if [[ "$LINKING_TO" == "$LINK_FILE" ]]; then
			echo "> Symlink for $DEFAULT_FILE already exists. Skipping!"
			return
		else
			mv "$DEFAULT_FILE" "$DEFAULT_FILE.backup"
		fi
	fi

	ln -s "$LINK_FILE" "$DEFAULT_FILE"
	echo "> Created symlink for $DEFAULT_FILE."
}

# ------------------------------------------------------------------------------------------
# Begin Script
# ------------------------------------------------------------------------------------------

echo "======================================================================="
echo "Beginning installation"
echo "======================================================================="
echo ""

cd $HOME

# Move the dotfiles directory to the HOME path if necessary...
[[ ! -d $DOTFILES_DIR ]] && mv $SCRIPT_DIR $DOTFILES_DIR

link_dotfiles ".zshrc"
link_dotfiles ".hushlogin"
link_dotfiles ".gitconfig"
# link_dotfiles ".gitconfig.work"
# link_dotfiles ".bashrc"
link_dotfiles ".vimrc"

echo ""
echo "======================================================================="
echo "Installation complete"
echo "======================================================================="
