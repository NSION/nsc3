# NSC3 Installation Guides
## Project description:
NSC3 backend installation guides and scripts for single node server configuration

## Project structure:

- README.md -> Instructions
- nsc3-install.sh -> Script for installation

## NSC3 backend installation guide for single node via public NSION repository:
### Prerequisites:
- Minimux HW configuration: 8 CPU cores, 8GB RAM, 500GB Free Disk
- Linux operating system
- Docker and docker-compose installed
- Access to internet
- Following TCP/IP4 ports open: 443(HTTPS), 1935(RTMPS), 1936(RTMP), NSC3 specific client ports (25204, 25205, 25206)
- SSL certifications for the service domain. Human readable formated private key named as privkey.pem and full chained certification named as fullchain.pem
- The server IP and domain name is bound together by DNS operator. 
- NSION registry account and secrets are available
- Linux account with sudo privileges for the operating system
- git installed 

### Default installation locations:

- Following instructions are using folder $HOME/nsc3 as default location for installation, but the location can be something else. The folder nsc3 will be created automatically while installation process
- Default docker content folder is /var/lib/docker
- Default Relation Database (Postgresql) content folder is /var/lib/docker/volumes/main-postgres-volume
- Default Object Storage (min.io) content folder is /var/lib/docker/volumes/minio-volume
- Default NSC3 logs files folder is $HOME/nsc3/logs
- Default NSC3 maptiles files folder is $HOME/nsc3/mapdata
- Default SSL cert files folder is $HOME/nsc3/nsc-gateway-cert

### NSC3 installation:
#### Install Docker:
Please follow the latest installation instructions by Docker community https://docs.docker.com/engine/install/ 
As example Ubuntu:

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io

#### Install git:

- Please follow the latest installation instructions by Git community https://git-scm.com/download/linux


#### Setup installation folder:

- Copy the SSL cert files privkey.pem and fullchain.pem to your home folder. As this example $HOME 
- Clone git project from NSION repository

#### Gather installation scripts from NSION github:

    cd $HOME
    git clone https://github.com/NSION/nsc3.git
    
#### Grant execute rights for the installation script:

    cd $HOME/nsc3
    chmod u+x nsc3-install.sh
    
#### Login to NSION docker registry:

    cd $HOME/nsc3
    sudo docker login registrynsion.azurecr.io
    
    <Registry crentials will be delivered separately>
        
#### Install Docker-compose:

Please follow the latest installation instructions by Docker community https://docs.docker.com/compose/install/. Note that python3 is required. Ubuntu based linux apt will install it automatically if missing.
As example Ubuntu:

    sudo apt-get update
    sudo apt-get install docker-compose




