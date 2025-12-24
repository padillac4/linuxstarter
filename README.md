# Linux


## Ansible

Install Ansible on machine

```bash
    sudo apt update && sudo apt install -y ansible
```

### Running Playbook
```bash
    ansible-playbook -i ubuntu-update.yml # basic run

    #verbose 
    ansible-playbook -i ubuntu-update.yml -v

    # extra verbose for debugging
    ansible-playbook -i ubuntu-update.yml -vvv

    # avoid sudo prompt
    ansible-playbook -i ubuntu-update.yml -K  
```
## References/Links
- [Ubuntu Pro](https://ubuntu.com/pro)
- [RPM Fusion](https://rpmfusion.org/Configuration)
- [Fedora Nvidia](https://rpmfusion.org/Howto/NVIDIA)
- [Fedora Secure Boot](https://rpmfusion.org/Howto/Secure%20Boot)
- [OMZ Installer](https://ohmyz.sh/#install)
- [SDKMAN](https://sdkman.io/)
- [Docker Engine Install](https://docs.docker.com/engine/install/)
- [Docker Desktop Install](https://docs.docker.com/desktop/setup/install/linux/)

## Notes
- Ubuntu takes care of Secure Boot on its own. Ex. Nvidia Drivers