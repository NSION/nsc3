# NSC3 Installation guidance
## Project description:
Valor installation guides and scripts for single node server configuration

29th of January 2022: Release tag latest support is available

    Release Tag: latest

## Project structure:

- valor-installation-guide.md -> Valor installation instructions
- valor-install.sh -> Script for Valor installation
- valor-upgrade.sh -> Script for Valor upgrade
- valor-docker-compose-ext-reg.tmpl -> Docker Compose template for Valor

## Prerequisites for NSC3 installation:
- Minimum HW configuration: 8 CPU cores with GPU, 32 GB RAM, 500GB Free Disk. As reference 1h video clip is consuming around 2GB disk space.
- Linux operating system, Ubuntu 20.04 LTS as reference.
- The computer or virtual machine is allocated for NSC3 use only.
- Internet access 
- NSC3 backend is installed and Docker is attached to NSION container registry
- Valor specific NSC3 license is required 

NSC3 technical description: https://www.nsiontec.com/technical-specifications/

## NSC3 backend installation guidance for single node via public NSION repository:
### Default file system locations:

- NSC3 Installation folder $HOME/nsc3, However this location is configurable. Instruction are referring for $HOME/nsc3 folder. 
- Docker content folder is /var/lib/docker
- Valor RDB content folder is /var/lib/docker/volumes/analytics-postgres-volume
- NSC3 logs files folder is $HOME/nsc3/logs


### NSC3 installation:
#### Install Docker:
Please follow the latest installation instructions by Docker community https://docs.docker.com/engine/install/ 
As example Ubuntu:

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io

    
#### Download latest version of Valor installation scripts:

    cd $HOME/nsc3
    chmod u-x *.sh
    git pull
    chmod u+x *.sh
    


#### Install NSC3
##### Silent installation mode: 

    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    NSC3 installer usage:

    sudo ./valor-install.sh --help 	  	'help text'
    sudo ./valor-install.sh --silent     'installation with command line parameters'
    sudo ./valor-install.sh 		  		'interactive installation mode'

    CLI parameters usage:
    sudo ./valor-install.sh --silent <NSC3 release tag>

    CLI parameters example:
    sudo ./valor-install.sh --silent release-3.4
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


##### Interactive installation mode: installation dialog with example values  

    cd $HOME/nsc3
    sudo ./nsc3-install.sh  
    

    ++++++++++++++++++++++++++++++++++++++++

      Valor docker-compose installer:       
      This script prepares Valor config     

    ++++++++++++++++++++++++++++++++++++++++
    Valor Release tag, e.g release-3.4: 
    latest  
    ++++++++++++++++++++++++++++++++++++++++
    Valor backend is installed!
    Login to your NSC3 web app by URL address
    https://foo.nsion.io
    ++++++++++++++++++++++++++++++++++++++++
    
#### Verify installation
Check docker containers. NSC3 + Valor conteiner both are up and running

    sudo docker ps
    sudo docker stats

Check Web services, Expected result if ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
Check SSL Certification status, Expected result when ok, "SSL certificate verify ok"

    curl --cert-status -v https://$PUBLICIP 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
    
#### Post installation steps

### Upgrade NSC3

Downlaod the latest scripts from github:

    cd $HOME/nsc3
    chmod u-x *.sh
    git pull -f
    
Grant execute rights for the upgrade script:

    chmod u+x valor-upgrade.sh
    
Start upgrade process:

    sudo ./valor-upgrade.sh
    
Note that release tag format is 
    
    release-<release number>, e.g: release-3.4    
    
### Valor maintenance

Stop Valor services:

    cd $HOME/nsc3
    sudo docker-compose -f docker-compose-valor.yml  down

Start NSC3 services:

    cd $HOME/nsc3
    sudo docker-compose -f docker-compose-valor.yml up -d  

Monitor container logs via docker logs:

    sudo docker logs <container name>
    
    
Check disk storage usage level:

    df -hT | grep /$ | awk '{ print $6}'
    
Check computer free RAM memory:

    echo $(free -g | grep Mem: | awk '{ print $7}') "GB"
    
Container status:

    sudo docker stats
    
### Valor troubleshooting

#### Valor services are not working properly:

Try to restart NSC3 services:

    cd $HOME/nsc3
    sudo docker-compose -f docker-compose-valor.yml up -d 
    
Check https status: 
Expected result if ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
If still no access please then check ...
- Network status
- Disk space usage level
- Docker status
