#!/bin/bash

# colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# flags (set to false by default, for the menu)
ENABLE_FLATPAK=false
ENABLE_SECURE_BOOT=false
INSTALL_OMZ=false
INSTALL_LATEX=false
INSTALL_VIRT_MANAGER=false

vscode_fedora(){
    echo -e "${GREEN}Installing Visual Studio Code...${NC}"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo dnf check-update
    sudo dnf install -y code
    echo -e "${GREEN}Visual Studio Code installation complete.${NC}"
}

librewolf_fedora(){
    echo -e "${GREEN}Installing LibreWolf...${NC}"
    curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
    sudo dnf install -y librewolf
    echo -e "${GREEN}LibreWolf installation complete.${NC}"
}

secure_boot_nvidia(){
    echo -e "${GREEN}Installing Secure Boot packages for NVIDIA...${NC}"
    sudo dnf install -y kmodtool akmods mokutil openssl
    sudo kmodgenca -a
    sudo mokutil --import /etc/pki/akmods/certs/public_key.der
    echo -e "${GREEN}Secure Boot setup complete.${NC}"
}

install_omzsh() {
    echo -e "${GREEN}Installing Oh My Zsh...${NC}"
    curl -L git.io/antigen > ~/.antigen.zsh # download antigen and hide the file
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo -e "${GREEN}Oh My Zsh installation complete.${NC}"
}

enable_flatpak() {
    echo -e "${GREEN}Enabling Flatpak support...${NC}"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "${GREEN}Flatpak support enabled.${NC}"
}

install_latex() {
    echo -e "${GREEN}Installing LaTeX TexLive (large download)...${NC}"
    sudo dnf install -y texlive-scheme-full pandoc
    echo -e "${GREEN}LaTeX installation complete.${NC}"
}

install_virt_manager() {
    echo -e "${GREEN}Installing Virtualization Manager...${NC}"
    sudo dnf install -y @virtualization
    sudo systemctl start libvirtd
    sudo systemctl enable libvirtd
    sudo usermod -aG libvirt $USER
    sudo usermod -aG kvm $USER
    echo -e "${GREEN}Virtualization setup complete. You may need to reboot.${NC}"
}

ubuntu_setup() {
    echo -e "${BLUE}Updating package lists...${NC}"
    sudo apt update && sudo apt full-upgrade -y
    
    echo -e "${BLUE}Installing base packages...${NC}"
    sudo apt install curl\
        git\
        wget\
        clang\
        cmake\
        automake\
        llvm\
        yasm\
        nasm\
        valgrind\
        gdb\
        neovim\
        build-essential\
        apt-transport-https\
        zip\
        unzip\
        p7zip-full\
        zsh\
        zsh-antigen\
        zsh-syntax-highlighting\
        zsh-autosuggestions\
        pandoc\
        libreoffice\
        flatpak\
        gnome-tweaks\
        gnome-software-plugin-flatpak\
        speedcrunch\
        net-tools\
        tmux\
        nmap

    echo -e "${GREEN}Ubuntu setup complete.${NC}"
}

fedora_setup() {
    echo -e "${BLUE}Upgrading System...${NC}"
    sudo dnf upgrade -y
    echo -e "${BLUE}Enabling RPM Fusion repositories...${NC}"
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    echo -e "${BLUE}Installing base packages...${NC}"
    sudo dnf install -y curl\
        git\
        wget\
        clang\
        cmake\
        automake\
        llvm\
        yasm\
        nasm\
        valgrind\
        gdb\
        neovim\
        nmap\
        htop\
        zip\
        unzip\
        p7zip-plugins\
        wireguard-tools\
        zsh\
        zsh-autosuggestions\
        zsh-syntax-highlighting\
        ranger\
        pandoc\
        flatpak\
        tmux\
        piper\
        solaar\
        speedcrunch\
        gnome-tweaks

    echo -e "${GREEN}Fedora base setup complete.${NC}"
}

# check package manager to detect system 
detect_system() {
    if command -v apt >/dev/null 2>&1; then
        echo "ubuntu"
    elif command -v dnf >/dev/null 2>&1; then
        echo "fedora"
    elif command -v yum >/dev/null 2>&1; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

#display menu and get user choices 
show_menu() {
    local system_type=$1
    
    echo -e "${BLUE}*************************************${NC}"
    echo -e "${BLUE}   Linux Setup Configuration Menu    ${NC}"
    echo -e "${BLUE}*************************************${NC}"
    echo ""
    echo -e "${YELLOW}Detected System: ${system_type}${NC}"
    echo ""
    echo "Select features to install (y/n):"
    echo ""
    
    read -p "  [1] Enable Flatpak support? (y/n): " choice
    [[ $choice =~ ^[Yy]$ ]] && ENABLE_FLATPAK=true
    read -p "  [2] Install Oh My Zsh? (y/n): " choice
    [[ $choice =~ ^[Yy]$ ]] && INSTALL_OMZ=true
    
    if [[ $system_type == "fedora" ]]; then
        echo ""
        echo -e "${YELLOW}Fedora-specific options:${NC}"
        
        read -p "  [3] Install Secure Boot packages for NVIDIA? (y/n): " choice
        [[ $choice =~ ^[Yy]$ ]] && ENABLE_SECURE_BOOT=true
        read -p "  [4] Install LaTeX (texlive-scheme-full)? (y/n): " choice
        [[ $choice =~ ^[Yy]$ ]] && INSTALL_LATEX=true
        read -p "  [5] Install Virtualization Manager (virt-manager)? (y/n): " choice
        [[ $choice =~ ^[Yy]$ ]] && INSTALL_VIRT_MANAGER=true
    fi
    
    echo ""
    echo -e "${GREEN}Configuration complete. Starting installation...${NC}"
    echo ""
}

# main exec
main() {
    SYSTEM_TYPE=$(detect_system)
    
    if [[ $SYSTEM_TYPE == "unknown" ]]; then
        echo -e "${RED}Error: No supported package manager found (apt, yum, dnf).${NC}"
        exit 1
    fi
    
    show_menu $SYSTEM_TYPE
    
    # for base setup
    echo -e "${BLUE}************************${NC}"
    echo -e "${BLUE}  1: Base System Setup  ${NC}"
    echo -e "${BLUE}************************${NC}"
    
    if [[ $SYSTEM_TYPE == "ubuntu" ]]; then
        ubuntu_setup
    elif [[ $SYSTEM_TYPE == "fedora" ]]; then
        fedora_setup
    fi
    
    # execute based on user choice 
    echo -e "${BLUE}************************${NC}"
    echo -e "${BLUE}  2: Optional Features  ${NC}"
    echo -e "${BLUE}************************${NC}"

    if [[ $SYSTEM_TYPE == "fedora" ]]; then
        if [[ $ENABLE_SECURE_BOOT == true ]]; then
            secure_boot_nvidia
        fi
        
        if [[ $INSTALL_LATEX == true ]]; then
            install_latex
        fi
        
        if [[ $INSTALL_VIRT_MANAGER == true ]]; then
            install_virt_manager
        fi
    fi

    if [[ $ENABLE_FLATPAK == true ]]; then
        enable_flatpak
    fi
    
    if [[ $INSTALL_OMZ == true ]]; then
        install_omzsh
    fi
        
    echo ""
    echo -e "${GREEN}*******************${NC}"
    echo -e "${GREEN}  Setup Complete!  ${NC}"
    echo -e "${GREEN}*******************${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  - Restart your terminal"

    if [[ $INSTALL_OMZ == true ]]; then
        echo "  - Set ZSH as default shell: chsh -s \$(which zsh)"
    fi
    if [[ $INSTALL_VIRT_MANAGER == true ]]; then
        echo "  - Reboot to activate virtualization groups"
    fi
    echo ""
}

# call main function
main