#!/bin/bash

install_node_nvm() {
    echo "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    echo "NVM installation complete."
}

install_sdkman() {
    echo "Installing SDKMAN (Java, Kotlin, Spark manager)..."
    curl -s "https://get.sdkman.io" | bash
    echo "SDKMAN installation complete."
}

# install nvm and sdkman
read -p "Do you want to install nvm (Node Version Manager) (y/n): "
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_node_nvm
fi

read -p "Do you want to install SDKMAN (Java, Kotlin, Spark manager) (y/n): "
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_sdkman
fi