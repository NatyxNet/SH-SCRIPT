#!/bin/bash
log() {
    local type=$1
    local message=$2
    case $type in
        "OK") echo "[OK] $message" ;;
        "FAIL") echo "[FAIL] $message" ;;
        "ERROR") echo "[ERROR] $message" ;;
    esac
}

# Update system packages
echo "[INFO] Updating system packages..."
if sudo apt update && sudo apt full-upgrade -y; then
    log "OK" "System packages updated successfully"
else
    log "ERROR" "Failed to update system packages"
    exit 1
fi

# Install dependencies
echo "[INFO] Installing dependencies..."
if apt install -y sudo git curl fonts-powerline zsh; then
    log "OK" "Dependencies installed successfully"
else
    log "ERROR" "Failed to install dependencies"
    exit 1
fi

# Install and configure locales
echo "[INFO] Installing locales..."
if sudo apt install -y locales; then
    log "OK" "Locales installed successfully"

    echo "Generating en_US.UTF-8 locale..."
    sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    if sudo locale-gen && sudo update-locale LANG=en_US.UTF-8; then
        log "OK" "Locales generated and set"
    else
        log "ERROR" "Failed to generate or set locales"
        exit 1
    fi
else
    log "ERROR" "Failed to install locales"
    exit 1
fi

# Install oh-my-zsh
echo "[INFO] Installing oh-my-zsh..."
if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    log "OK" "Oh-my-zsh installed successfully"
else
    log "ERROR" "Failed to install oh-my-zsh"
    exit 1
fi

# Set theme to agnoster
echo "Setting agnoster theme..."
if sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc; then
    log "OK" "Agnoster theme set successfully"
else
    log "FAIL" "Failed to set agnoster theme"
    exit 1
fi

# Add UTF-8 locale to .zshrc
echo "[INFO] Exporting LANG and LC_ALL in .zshrc..."
{
    echo ""
    echo "# Set locale to UTF-8"
    echo "export LANG=en_US.UTF-8"
    echo "export LC_ALL=en_US.UTF-8"
} >> ~/.zshrc

# Set zsh as default shell
echo "[INFO] Setting zsh as default shell..."
if chsh -s $(which zsh); then
    log "OK" "Zsh set as default shell"
else
    log "FAIL" "Failed to set zsh as default shell"
fi

log "OK" "Installation completed successfully"
echo "Please log out and log back in to apply changes"