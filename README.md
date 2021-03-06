# NSC3 Installation guidance
## Project description:
NSC3 backend installation guides and scripts for single node server configuration

2nd of June 2022: Release 3.6 support is available

    Release Tag: release-3.6

## Project structure:
- README.md: General guidance for this repository. NSC3 installation, upgrade and maintenance instructions.
- nsc3-install.sh: Script for NSC3 installation
- nsc3-upgrade.sh: Script for NSC3 upgrade
- nsc3-docker-compose-ext-reg.tmpl: Docker Compose template for NSC3
- valor-installation-guide.md: Valor installation guidance 
- valor-install.sh: Script for Valor installation
- valor-upgrade.sh: Script for upgradeValor 
- valor-docker-compose-ext-reg.tmpl: Docker Compose template for Valor
- nsc3-conf-tool.sh: Shell Script for NSC3 and Valor runtime configuration. Designed for Development pipe usage where configuration is pre-set outside of targeted server.

## Prerequisites for NSC3 installation:
- [x] Minimum HW configuration: 8 CPU cores, 16GB RAM, 500GB Free Disk. As reference 1h video clip is consuming around 2GB disk space.
- [x] Linux operating system, Ubuntu 20.04 LTS as reference.
- [x] The computer or virtual machine is allocated for NSC3 use only.
- [x] Internet access is available
- [x] Following TCP/IP4 ports are open from network to server: 443(HTTPS), 1935(RTMPS), 1936(RTMP), NSC3 specific ports (25204, 25205, 25206)
- [x] SSL certifications for the service domain. Human readable (PEM) format. A private key file named as privkey.pem. A full chained certification file named as fullchain.pem
- [x] Server domain name is registered to DNS services. 
- [x] Access account to NSION container registry is available.
- [x] Linux account with sudo privileges for operating system.
- [x] Following 3rd party apps are needed: git, wget and curl. Most of them are by default included as part of a linux basic setup. However please ensure beforehand availability on your local linux setup. 

NSC3 technical description: https://www.nsiontec.com/technical-specifications/

## NSC3 backend installation guidance for single node via public NSION repository:
### Default file system locations:

- NSC3 Installation folder $HOME/nsc3, However this location is configurable. Instruction are referring for $HOME/nsc3 folder. The folder "nsc3" will be created automatically while installation process
- Docker content folder is /var/lib/docker
- Relational Database (Postgresql) content folder is /var/lib/docker/volumes/main-postgres-volume
- Object Storage (min.io) content folder is /var/lib/docker/volumes/minio-volume
- NSC3 logs files folder is $HOME/nsc3/logs
- NSC3 maptiles files folder is $HOME/nsc3/mapdata
- SSL cert files folder is $HOME/nsc3/nsc-gateway-cert

### NSC3 installation:
#### Install Docker:
Please follow the latest installation instructions by Docker community https://docs.docker.com/engine/install/ 
As example Ubuntu:

##### Update the apt package index and install packages to allow apt to use a repository over HTTPS:
```
sudo apt-get update
```
```bash
sudo apt-get install \
ca-certificates \
curl \
gnupg \
lsb-release
```

##### Add Docker???s official GPG key:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```    
##### Use the following command to set up the stable repository
```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
##### Install Docker Engine
```
sudo apt-get update
```
```
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

#### Install git:

- Please follow the latest installation instructions by Git community https://git-scm.com/download/linux

As example Ubuntu:
```
sudo apt install git
```
#### Setup installation folder:

- Copy the SSL cert files privkey.pem and fullchain.pem to your home folder. As this example $HOME 
- Clone git project from NSION SW repository

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

Please follow the latest installation instructions by Docker community https://docs.docker.com/compose/install/.
As example Ubuntu:

Remove old docker-compose:

    sudo apt-get remove docker-compose
    
Install docker-compose:

	VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')

    DESTINATION=/usr/local/bin/docker-compose
    sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
    sudo chmod 755 $DESTINATION


#### Install NSC3
##### Silent installation mode: 

    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    NSC3 installer usage:

    ./nsc3-install.sh --help 	  	'help text'
    ./nsc3-install.sh --silent     'installation with command line parameters'
    ./nsc3-install.sh 		  		'interactive installation mode'

    CLI parameters usage:
    ./nsc3-install.sh --silent <Installation path> <SSL cert files location> <host name> <MAP region> <NSC3 release tag>

    CLI parameters example:
    ./nsc3-install.sh --silent /home/ubuntu/nsc3 /home/ubuntu foo.nsion.io NA release-3.3

    Regional identifiers of MAP selection:
    EU=Europe, NA=North America, AUS=Australia, GCC=GCC states
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


##### Interactive installation mode: installation dialog with example values  
```
cd $HOME/nsc3
./nsc3-install.sh  
```    

    NSC3 installation folder, e.g /home/nscuser/nsc3: 
    /home/ubuntu/nsc3      
    NSC3 public hostname, e.g videoservice.nsiontec.com: 
    foo.nsion.io   
    Location of SSL cert files, e.g /home/nscuser: 
	/home/ubuntu
    NSC3 Release tag, e.g release-3.3: 
    release-3.3  
    Map files options : 
    1. North America map
    2. Europa map
    3. Australia map
    4. GCC states map
    Select your option as number: 
    1   
    ++++++++++++++++++++++++++++++++++++++++
    NSC3 backend is installed!
    Login to your NSC3 web app by URL address
    https://foo.nsion.io
    ++++++++++++++++++++++++++++++++++++++++
    
### Post installation steps

- [x] Verify installation
- [x] Insert NSC3 license
- [x] Configure NSC3 organisation

#### Verify installation
Check docker containers, Totally 15 containers

    sudo docker ps
    sudo docker stats

Check Web services, Expected result if ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
Check SSL Certification status, Expected result when ok, "SSL certificate verify ok"
```
curl --cert-status -v https://$PUBLICIP 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
```    
#### Insert NSC3 license

Login to the NSC3 web app as admin
- Change the default password rightaway. Right-Top corner on UI / Change password
- Download a instance key via NSC3 admin/license UI. Licenses Tab / Server license / Set new NSC3 license / Download Instance key
- Send the instance key file via NSION Jira Service desk support portal.
- NSION will prepare and return a corresponding license key file back. No need to left UI open while waiting
- Insert license key via NSC3 admin/license UI. Licenses Tab / Server license / Set new NSC3 license / Insert license key (download from local computer via Web app)

#### Configure NSC organisation

NSC3 Admin documentation: https://www.nsiontec.com/user-guide-webapp-admin/ 

### Upgrade NSC3

Downlaod the latest scripts from github:

    cd $HOME/nsc3
    chmod u-x *.sh
    git pull -f
    
Grant execute rights for the upgrade script:

    chmod u+x nsc3-upgrade.sh
    
Start upgrade process:

    ./nsc3-upgrade.sh
    
Note that release tag format is 
    
    release-<release number>, e.g: release-3.4    
    
### NSC3 Maintenance

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
    
### NSC3 system troubleshooting

#### No access to NSC3 services:

Try to restart NSC3 services:

    cd $HOME/nsc3
    sudo docker-compose up -d 
    
Check https status: 
Expected result if ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
If still no access please then check ...
- Network status
- Disk space usage level
- Docker status

#### NSC3 Web service is not working properly:

Check that SSL cert is valid:
Expected result if ok, "SSL certificate verify ok"

    cd $HOME/nsc3
    source nsc-host.env

```
curl --cert-status -v https://$PUBLICIP 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
```
Check that the HTTPS port is listening:

    ss -lntu | grep ':443'
    
Check TCP IP route from external network to NSC3 https port:
This requires extra tool called nmap:
As example Ubuntu installation

    sudo apt install nmap
    
Test that route to 443 port is open:

    nmap <hostname> | grep 443
