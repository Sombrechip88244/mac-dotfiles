# Mac Dotfiles

### Install

#### Initial Git Setup (if needed):
```
xcode-select --install # If you don't have Xcode Command Line Tools
```
#### Clone Dotfiles repo:
```
git clone https://github.com/Sombrechip88244/mac-dotfiles.git ~/.dotfiles
```
#### Run the script:
```
cd ~/.dotfiles
./install.sh
```
### Explanation of script
    #!/bin/bash: Shebang line, telling the system to execute the script with Bash.
  
    set -e: Ensures that the script will exit immediately if any command fails. This prevents unexpected behavior from partial installations.

    log_message: A simple helper function to print standardized messages, making the script's output easier to read.

    command_exists: A utility function to check if a given command is available in the system's PATH.

    1. Install Xcode Command Line Tools: Homebrew and many development tools require these. The script checks for their presence and prompts for installation if they're missing. It then waits for user input, as the installation is a GUI process.

    2. Install Homebrew: The script checks if Homebrew is installed. If not, it runs the official installation script. If Homebrew is already present, it updates and upgrades existing packages. It also ensures Homebrew is in the current session's PATH.

    3. Clone Dotfiles Repository: It checks if your dotfiles directory already exists. If not, it clones your repository from GitHub. If it exists (e.g., on a subsequent run), it pulls the latest changes to keep your local dotfiles up-to-date.

    4. Create Symbolic Links: This is the core of dotfiles management.

        It iterates through the DOTFILES_TO_SYMLINK array.

        For each file, it determines the source_path (in your cloned repo) and target_path (in your home directory).

        Idempotency: It checks if a symlink already exists or if a regular file/directory is in the way. If so, it removes the old symlink or backs up the existing file/directory before creating the new symlink. This makes the script safely re-runnable without manual cleanup.

        ln -sf: -s creates a symbolic link, -f forces the operation (overwriting existing symlinks or files after backup).

    5. Install Homebrew Packages: Installs command-line tools specified in the BREW_PACKAGES array using brew install.

    6. Install Homebrew Cask Applications: Installs GUI applications (like browsers, IDEs) specified in the CASK_PACKAGES array using brew install --cask.

    7. Install Oh My Zsh (Optional): If you use Oh My Zsh, uncomment this section. It checks if Oh My Zsh is already installed before attempting to install it.

    8. Set Zsh as default shell (Optional): If you want Zsh to be your default shell, uncomment this. chsh -s /bin/zsh changes your default shell. A terminal restart is often needed for this change to take effect.

    9. Clean up Homebrew: Runs brew cleanup to remove old versions and downloaded files, freeing up disk space.

    Final Message: Provides instructions on how to apply changes (e.g., sourcing shell config or restarting the terminal).

Important Considerations:

    Idempotency: The script is designed to be idempotent, meaning you can run it multiple times without causing issues. It checks for existing installations and files, backs up where necessary, and updates instead of blindly reinstalling.

    Permissions: Be mindful of file permissions, especially for files like ~/.ssh/config. After symlinking, you might need to manually set chmod 600 ~/.ssh/config. You could add chmod 600 ~/.ssh/config to your script if it's consistently needed.

    Sensitive Data: As mentioned before, never commit sensitive information (API keys, passwords, private SSH keys) directly to your public Git repository. Your install script should not handle these directly. Instead, manually add them to untracked files (e.g., ~/.localrc) or use tools like git-crypt.

    User Interaction: The script tries to minimize user interaction but will pause for Xcode Command Line Tools installation. For fully unattended scripts, you might pre-install these manually.

    Order of Operations: The order is important: Homebrew first, then cloning dotfiles, then symlinking (so shell configs are in place), then installing packages.

    Customization is Key: This script is a template. You must customize the variable arrays (DOTFILES_TO_SYMLINK, BREW_PACKAGES, CASK_PACKAGES) and uncomment sections like Oh My Zsh installation based on your personal setup.
