#!/bin/bash
echo "Requires attended setup"

secure_boot_nvidia(){
    sudo dnf install -y kmodtool akmods mokutil openssl
    sudo kmodgenca -a
    sudo mokutil --import /etc/pki/akmods/certs/public_key.der
}

fed_virt_manager(){
    sudo dnf install @virtualization
    sudo systemctl start libvirtd
    sudo systemctl enable libvirtd
    sudo usermod -aG libvirt $USER
    sudo usermod -aG kvm $USER
}

fed_texlive_install(){
    sudo dnf install -y texlive-scheme-full pandoc
}

fedora_extras() {
    read -p "Do you want to install LaTeX TexLive (y/n): "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        fed_texlive_install
    fi

    read -p "Do you want to install Virtualization Manager (y/n): "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        fed_virt_manager
    fi

    echo "Fedora extras setup complete."
}

docker_engine_setup(){
    sudo dnf remove docker \
                      docker-client \
                      docker-client-latest \
                      docker-common \
                      docker-latest \
                      docker-latest-logrotate \
                      docker-logrotate \
                      docker-selinux \
                      docker-engine-selinux \
                      docker-engine
}