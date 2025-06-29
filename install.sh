#!/bin/bash

# --- Dotfiles Installation Script for macOS ---
#
# This script automates the setup of a new macOS machine or refreshes an existing one,
# by installing Homebrew, cloning dotfiles, creating symbolic links, and installing
# common applications and tools.
#
# Usage:
# 1. Save this file as 'install.sh' in your dotfiles repository.
# 2. Make it executable: chmod +x install.sh
# 3. Run it: ./install.sh
#
# Before running, ensure you have Git installed (comes with Xcode Command Line Tools).
# You may need to manually install Xcode Command Line Tools first if not present:
# xcode-select --install
#
# Customize the variables and sections below to match your specific dotfiles,
# desired applications, and preferred shell configurations.

# --- Configuration Variables ---
# Your GitHub username
GITHUB_USERNAME="your_github_username" # <-- SET YOUR GITHUB USERNAME HERE
# Your dotfiles repository name (e.g., 'dotfiles' or 'my-config')
DOTFILES_REPO_NAME="dotfiles" # <-- SET YOUR REPO NAME HERE (e.g., "mac-dotfiles")
# The directory where your dotfiles will be cloned locally (e.g., $HOME/dotfiles)
DOTFILES_DIR="$HOME/$DOTFILES_REPO_NAME"

# Array of dotfiles/directories to symlink from DOTFILES_DIR to $HOME.
# For directories, ensure the directory exists in your DOTFILES_DIR with the content.
# Example: If you have `~/dotfiles/zsh/.zshrc`, you'd list `.zshrc` here.
# If you have `~/dotfiles/config/nvim`, and you want it as `~/.config/nvim`,
# you might need to adjust the symlinking logic or use a tool like GNU Stow.
# This example assumes direct mapping from $DOTFILES_DIR/<file> to $HOME/<file>.
DOTFILES_TO_SYMLINK=(
  ".zshrc"
  ".bashrc"
  ".vimrc"
  ".gitconfig"
  ".tmux.conf"
  # Example for a directory like ~/.config/nvim:
  # ".config/nvim" # Make sure 'config/nvim' exists inside your DOTFILES_DIR
  # Example for SSH config (be careful with sensitive data):
  # ".ssh/config" # Ensure permissions are set correctly after symlinking (chmod 600)
  # Add more as needed
)

# Homebrew packages to install
BREW_PACKAGES=(
  aom ffmpeg jpeg-turbo libsodium luajit p11-kit tesseract
  aribb24 flac jpeg-xl libsoxr luv pango texinfo
  autoconf fontconfig lame libssh lynx pcre2 theora
  automake freetype leptonica libtasn1 lz4 pinentry tree-sitter
  bdw-gc frei0r libarchive libtiff lzo pixman unbound
  berkeley-db@5 fribidi libass libunibreak m4 pkgconf unibilium
  brotli gettext libassuan libunistring mbedtls powerlevel10k utf8proc
  c-ares giflib libb2 libusb mpdecimal pycparser w3m
  ca-certificates git libbluray libuv mpg123 pyenv webp
  cairo glib libdeflate libvidstab msmtp python@3.13 wget
  certifi gmime libevent libvmaf mu rav1e x264
  cffi gmp libgcrypt libvorbis ncurses readline x265
  cjson gnupg libgpg-error libvpx neovim ripgrep xapian
  cmatrix gnutls libidn2 libx11 nettle rubberband xorgproto
  coreutils gpgme libksba libxau node sdl2 xvid
  dav1d graphite2 libmicrohttpd libxcb notmuch sfsexp xz
  docker harfbuzz libnghttp2 libxdmcp npth snappy yt-dlp
  docker-completion highway libogg libxext opencore-amr speex zeromq
  docker-compose icu4c@77 libpng libxml2 openexr sqlite zimg
  emacs-mac@29 imath librist libxrender openjpeg srt zstd
  expat isync libsamplerate little-cms2 openssl@3 svt-av1
  fd jansson libsndfile lpeg opus talloc
  # Add more command-line tools you use
)

# Homebrew Cask applications to install (GUI applications)
CASK_PACKAGES=(
  visual-studio-code
  docker
  spotify
  discord
  ghostty # Popular terminal replacement
  # Add more applications you use
)

# --- Script Setup ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to print messages in a consistent format
log_message() {
  echo "--- $1 ---"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Main Installation Logic ---

log_message "Starting dotfiles installation script..."

# 1. Install Xcode Command Line Tools (if not already installed)
# This is a prerequisite for Homebrew and Git.
log_message "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  log_message "Xcode Command Line Tools not found. Installing..."
  xcode-select --install
  # Wait for the user to complete the installation dialog.
  echo "Please approve the Xcode Command Line Tools installation in the pop-up window."
  read -p "Press any key to continue after installation is complete..." -n 1 -r
  echo
else
  log_message "Xcode Command Line Tools already installed."
fi

# 2. Install Homebrew (if not already installed)
log_message "Checking for Homebrew..."
if ! command_exists brew; then
  log_message "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for current session
  if [ -f "/opt/homebrew/bin/brew" ]; then # For Apple Silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f "/usr/local/bin/brew" ]; then # For Intel Macs
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  log_message "Homebrew installed successfully."
else
  log_message "Homebrew already installed. Updating Homebrew..."
  brew update
  brew upgrade
fi

# 3. Clone Dotfiles Repository
log_message "Cloning dotfiles repository..."
if [ ! -d "$DOTFILES_DIR" ]; then
  log_message "Cloning $GITHUB_USERNAME/$DOTFILES_REPO_NAME into $DOTFILES_DIR..."
  # Changed this line to use the variables consistently
  git clone "https://github.com/Sombrechip88244/mac-dotfiles.git" "$DOTFILES_DIR"
  log_message "Dotfiles repository cloned."
else
  log_message "Dotfiles directory ($DOTFILES_DIR) already exists. Pulling latest changes..."
  # Ensure we are in the dotfiles directory to pull
  (cd "$DOTFILES_DIR" && git pull origin main || git pull origin master) # Try 'main' then 'master'
  log_message "Dotfiles repository updated."
fi

# 4. Create Symbolic Links (Symlinks)
log_message "Creating symbolic links..."
for file in "${DOTFILES_TO_SYMLINK[@]}"; do
  source_path="$DOTFILES_DIR/$file"
  target_path="$HOME/$file"

  if [ -e "$source_path" ]; then # Check if the source file/directory exists in your dotfiles repo
    if [ -L "$target_path" ]; then
      log_message "Existing symlink for $file found. Removing..."
      rm "$target_path"
    elif [ -e "$target_path" ]; then
      log_message "Existing file/directory at $target_path found. Backing up to ${target_path}_backup..."
      mv "$target_path" "${target_path}_backup"
    fi

    # Ensure parent directory for symlink target exists
    parent_dir=$(dirname "$target_path")
    if [ ! -d "$parent_dir" ]; then
      log_message "Creating parent directory: $parent_dir"
      mkdir -p "$parent_dir"
    fi

    log_message "Creating symlink: $source_path -> $target_path"
    ln -sf "$source_path" "$target_path"
  else
    log_message "Warning: Source file/directory $source_path does not exist in your dotfiles repository. Skipping $file."
  fi
done
log_message "Symbolic links created."

# 5. Install Homebrew Packages
log_message "Installing Homebrew packages..."
if [ ${#BREW_PACKAGES[@]} -gt 0 ]; then
  brew install "${BREW_PACKAGES[@]}"
  log_message "Homebrew packages installed."
else
  log_message "No Homebrew packages specified to install."
fi

# 6. Install Homebrew Cask Applications
log_message "Installing Homebrew Cask applications..."
if [ ${#CASK_PACKAGES[@]} -gt 0 ]; then
  brew install --cask "${CASK_PACKAGES[@]}"
  log_message "Homebrew Cask applications installed."
else
  log_message "No Homebrew Cask applications specified to install."
fi

# 7. Install Oh My Zsh (Optional)
# If you use Oh My Zsh, uncomment and configure this section.
log_message "Checking for Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log_message "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  log_message "Oh My Zsh already installed."
fi

# 8. Set Zsh as default shell (Optional)
log_message "Setting Zsh as default shell..."
if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s /bin/zsh
  log_message "Zsh set as default shell. Please restart your terminal."
else
  log_message "Zsh is already the default shell."
fi

# 9. Clean up Homebrew
log_message "Cleaning up Homebrew installations..."
brew cleanup
log_message "Homebrew cleanup complete."

log_message "Dotfiles installation script finished!"
echo "Please restart your terminal or source your shell config (e.g., 'source ~/.zshrc') to apply changes."
echo "If you installed Zsh as default shell, a full terminal restart is recommended."
