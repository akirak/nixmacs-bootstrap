#!/bin/sh

# Run this script as an administrator

# Abort the script if a command has returned non-zero exit code
set -o errexit

# Function to check if $1 is a command
function has_executable () { command -v "$1" >/dev/null 2>&1; }

# Abort if Chocolatey is not installed
if ! has_executable choco; then
    echo <<EOF >&2
Chocolatey is not installed.
Install from https://chocolatey.org
EOF
    exit 1
fi

# Install executables
has_executable emacs || choco install --yes emacs
has_executable make || choco install --yes make

# The path to the home directory in Emacs (Emacs internal path)
HOME_DIR="$(echo $HOMEDRIVE$HOMEPATH | sed -e 's/\\/\//g')"
# Where the configuration repository is cloned into (bash path)
USER_EMACS_DIRECTORY="$HOME/.emacs.d"
# The path to APPDATA directory (bash path)
USER_APPDATA_DIRECTORY="$(echo $APPDATA | sed -e 's/\\/\//g')"
# The path to the home directory for command sessions inside Emacs (Wndows path)
EMACS_HOME_PATH="$(echo $HOMEDRIVE$HOMEPATH | sed -e 's/\\/\\\\/g')"

# Set up the configuration repository
if [ ! -d "${USER_EMACS_DIRECTORY}" ]; then
    git clone -b maint https://github.com/akirak/emacs.d.git "${USER_EMACS_DIRECTORY}"
    cd "${USER_EMACS_DIRECTORY}"
    git submodule update --init --recursive
    make install-hooks
    make windows-deps
fi

# Install chemacs
cp -fv "${USER_EMACS_DIRECTORY}/nix/contrib/chemacs/.emacs" \
   "${USER_APPDATA_DIRECTORY}/.emacs"
cp -fv "${USER_EMACS_DIRECTORY}/nix/contrib/chemacs/.emacs" \
   "$HOME/.emacs"

# Create a custom file if it does not exist
touch "$HOME/.custom.el"

# Create a chemacs profile for starting Emacs from the start menu
if [ ! -f "${USER_APPDATA_DIRECTORY}/.emacs-profiles.el" ]; then
    exec 1>"${USER_APPDATA_DIRECTORY}/.emacs-profiles.el"
    cat <<EOF
(("default" . ((user-emacs-directory . "${HOME_DIR}/.emacs.d")
               (custom-file . "${HOME_DIR}/.custom.el")
               (env . (("HOME" . "${EMACS_HOME_PATH}"))))))
EOF
fi

# Create a chemacs profile for starting Emacs from a bash session
if [ ! -f "$HOME/.emacs-profiles.el" ]; then
    exec 1>"$HOME/.emacs-profiles.el"
    cat <<EOF
(("default" . ((user-emacs-directory . "${HOME_DIR}/.emacs.d")
               (custom-file . "${HOME_DIR}/.custom.el"))))
EOF
fi
