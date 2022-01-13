# NSC3 Installation guidance
## Project description:
NSC3 backend installation guides and scripts for single node server configuration

13rd of January 2022: Release 3.3 is supported

    Release Tag: release-3.3

## Project structure:

- README.md -> Instructions
- nsc3-install.sh -> Script for installation
- nsc3-upgrade.sh -> Script for upgrade
- nsc3-docker-compose-ext-reg.tmpl -> Docker Compose template 

## Prerequisites for NSC3 installation:
- Minimux HW configuration: 8 CPU cores, 8GB RAM, 500GB Free Disk
- Linux operating system
- The computer or virtual machine is dedicated only for the NSC3 usage
- Docker and docker-compose installed
- Access to internet
- Following TCP/IP4 ports open: 443(HTTPS), 1935(RTMPS), 1936(RTMP), NSC3 specific client ports (25204, 25205, 25206)
- SSL certifications for the service domain. Human readable formated private key named as privkey.pem and full chained certification named as fullchain.pem
- The server IP and domain name is bound together by DNS operator. 
- NSION registry account and secrets are available
- Linux account with sudo privileges for the operating system
- Following 3rd party apps are needed: git, wget, curl. Most of them are by default included as part of a linux basic setup. However please check beforehand availability of your local linux setup. 

NSC3 technical description: https://www.nsiontec.com/technical-specifications/

## NSC3 backend installation guide for single node via public NSION repository:
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
    sudo git clone https://github.com/NSION/nsc3.git
    
#### Grant execute rights for the installation script:

    cd $HOME/nsc3
    sudo chmod u+x nsc3-install.sh
    
#### Login to NSION docker registry:

    cd $HOME/nsc3
    sudo docker login registrynsion.azurecr.io
    
    <Registry crentials will be delivered separately>
        
#### Install Docker-compose:

Please follow the latest installation instructions by Docker community https://docs.docker.com/compose/install/. Note that python3 is required. Ubuntu based linux apt will install it automatically if missing.
As example Ubuntu:

    sudo apt-get update
    sudo apt-get install docker-compose

#### Install NSC3

    cd $HOME/nsc3
    sudo ./nsc3-install.sh  
    
##### queries dialog while installation process    
    
    NSC3 installation folder, e.g /home/nscuser/nsc3: 
    /home/ubuntu/nsc3  <<< "your NSC3 installation folder"     
    NSC3 public hostname, e.g videoservice.nsiontec.com: 
    foo.nsion.io <<< "your hostname"  
    NSC3 Release tag, e.g release-3.3: 
    release-3.3 <<< "NSC3 release tag"  
    Map files options : 
    1. North America map
    2. Europa map
    3. Australia map
    4. GCC states map
    Select your option as number: 
    1 <<< "NA map is selected"  
    ++++++++++++++++++++++++++++++++++++++++
    NSC3 backend is installed!
    Login to your NSC3 web app by URL address
    https://foo.nsion.io
    ++++++++++++++++++++++++++++++++++++++++
    
#### Verify installation
Check docker containers, Totally 15 containers are running. Right after installation phase extra container "db-updater" is running for a while.

    sudo docker ps

Check Web services, Expected result when ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
Check SSL Certification status, Expected result when ok, "SSL certificate verify ok"

    curl --cert-status -v https://$PUBLICIP 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
    
#### Post installation steps

Login to the NSC3 web app as admin
- Change the default password rightaway. Right-Top corner on UI / Change password
- Download a instance key via NSC3 admin/license UI. Licenses Tab / Server license / Set new NSC3 license / Download Instance key
- Send the challenge file to your nsion counterpart
- NSION will return the license key file back. No need to left UI open while waiting
- Insert license key via NSC3 admin/license UI. Licenses Tab / Server license / Set new NSC3 license / Insert license key (download from local computer via Web app)

#### Upgrade NSC3

Downlaod the latest scripts from github:

    cd $HOME/nsc3
    sudo rm nsc3-install.sh
    sudo rm nsc3-upgrade.sh
    sudo git pull -f
    
Grant execute rights for the upgrade script:

    sudo chmod u+x nsc3-upgrade.sh
    
Start upgrade process:

    sudo ./nsc3-upgrade.sh
    
Note that release tag format is 
    
    release-<release number>, e.g: release-3.4    
    
#### NSC3 Maintenance

Stop NSC3 services:

    cd $HOME/nsc3
    sudo docker-compose down

Start NSC3 services:

    cd $HOME/nsc3
    sudo docker-compose up -d  

Monitor container logs via docker logs:

    sudo docker logs <container name>
    
Storage location of NSC3 log files in the file system:

    cd $HOME/nsc3/logs
    
Check disk storage usage level:

    df -hT | grep /$ | awk '{ print $6}'
    
Check computer free RAM memory:

    echo $(free -g | grep Mem: | awk '{ print $7}') "GB"
    
Container status:

    sudo docker stats
    
#### NSC3 system troubleshooting

##### No access to NSC3 services:

Try to restart NSC3 services:

    cd $HOME/nsc3
    sudo docker-compose up -d 
    
Check https status: 
Expected result when ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
If still no access please then check ...
- Network status
- Disk space usage level
- Docker status

##### NSC3 Web service is not working properly:

Check that SSL cert is valid:
Expected result when ok, "SSL certificate verify ok"

    cd $HOME/nsc3
    source nsc-host.env
    curl --cert-status -v https://$PUBLICIP 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'

Check that the HTTPS port is listening:

    ss -lntu | grep ':443'
    
Check TCP IP route from external network to NSC3 https port:
This requires extra tool called nmap:
As example Ubuntu installation

    sudo apt install nmap
    
Test that route to 443 port is open:

    nmap <hostname> | grep 443

    

