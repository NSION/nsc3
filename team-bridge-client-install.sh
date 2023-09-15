#!/bin/bash
## NSC3 registry:
export NSC3REG="registrynsion.azurecr.io"
silentmode=false
if [ ${1+"true"} ]; then
   if  [ $1 == "--silent" ]; then
       silentmode=true
       echo "*** silent installation mode ***"
   fi
   if  [ $1 == "--help" ]; then
       clear
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       echo "NSC3 installer usage:"
       echo ""
       echo "./team-bridge-install.sh --help 	  'help text'"
       echo "./team-bridge-install.sh --silent      'installation with command line parameters'"
       echo "./team-bridge-install.sh 		  'interactive installation mode'"
       echo ""
       echo "CLI parameters usage:"
       echo "./team-bridge-install.sh --silent <Installation path> <TCP or UDP mode> <Team Bridge Server IP> <Source Organisation ID>"
       echo ""
       echo "CLI parameters example:"
       echo "./team-bridge-install.sh --silent /home/ubuntu/nsc3 UDP 172.17.12.12 "
       echo ""
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       exit 0
   fi
   if [ ${2+"true"} ]; then
       export NSCHOME=$2
   fi
   if [ ${3+"true"} ]; then
       export TBROLE=$3
   fi
   if [ ${4+"true"} ]; then
       export TBMODE=$4
   fi
   if [ ${5+"true"} ]; then
       export TBSERVERIP=$5
   fi
   if [ ${6+"true"} ]; then
       export SOURCEORG=$6
   fi
fi
if [ "$silentmode" = false ]; then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "                                        "
    echo "  NSC3 Team-Bridge Client installer:    "
    echo "  This script prepares NSC3 config      "
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "NSC3 installation folder, e.g /home/nscuser/nsc3: "
    read NSC3HOMEFOLDER
    export NSCHOME=$NSC3HOMEFOLDER
    echo "TCP or UDP Mode?: (Value: TCP/UDP) "
    read TBMODE
    echo "Team-Bridge server IP address: "
    read TBSERVERIP
    echo "Source Organisation ID: "
    read SOURCEORG
fi
# Check values
if ! [ -d $NSCHOME ]; then echo "*** $NSCHOME 'Installation folder is missing! "; exit 0; fi
if ! [[ $TBMODE = TCP  ||  $TBMODE = UDP ]]; then echo "*** "$TBMODE"  as input value is not range of mode selection. please type TCP or UDP"; exit 0; fi
if ! [[ $TBSERVERIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP"  as input is not valid Team-Bridge server IP"; exit 0; fi
if [[ $SOURCEORG = *" "* ]]; then echo "*** "$SOURCEORG"  as input is not valid NSC3 source organisation ID"; exit 0; fi
# Create TCP keys
if ! [[ $TBMODE = TCP ]]; then
   if [ ! -d $NSCHOME/bridgekeys ]; then 
      chmod u+x $NSCHOME/generateTeamBridgeRSAKeyPairs.sh 2> /dev/null
      bash $NSCHOME/generateTeamBridgeRSAKeyPairs.sh 2> /dev/null
   fi
fi
# Grep release tag value
NSC3REL=$(cat $NSCHOME/docker-compose.yml | grep registrynsion.azurecr.io/main-postgres: | cut -d\: -f3) 2> /dev/null
echo "*** Current release tag: $NSC3REL  ***" 
RELEASETAG=$NSC3REL
# Update env variables
source $NSCHOME/nsc-host.env
if [ -z "$TBMODE" ]; then echo "export TBMODE=$TBMODE" >> $NSCHOME/nsc-host.env; fi
if [ -z "$TBROLE" ]; then echo "export TBMODE=$TBROLE" >> $NSCHOME/nsc-host.env; fi
if [ -z "$TBSERVERIP" ]; then echo "export TBSERVERIP=$TBSERVERIP" >> $NSCHOME/nsc-host.env; fi
if [ -z "$SOURCEORG" ]; then echo "export SOURCEORG=$SOURCEORG" >> $NSCHOME/nsc-host.env; fi
# Update docker-compose.yml file
cd $NSCHOME
# make backup
if [ -f "docker-compose.yml" ]; then
   cp docker-compose.yml docker-compose.tb-addition-backup 2> /dev/null
fi
if [[ $TBMODE = UDP ]]; then
   if [[ $TBROLE = client ]]
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
   sed '/add-on nsc-team-bridge-service-client-udp/,/add-off nsc-team-bridge-service-client-udp/ s/#//'
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = server ]]
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
   sed '/add-on nsc-team-bridge-service-server-udp/,/add-off nsc-team-bridge-service-server-udp/ s/#//' 
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = both ]]
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' | 
   sed '/add-on nsc-team-bridge-service-server-udp/,/add-off nsc-team-bridge-service-server-udp/ s/#//' |
   sed '/add-on nsc-team-bridge-service-client-udp/,/add-off nsc-team-bridge-service-client-udp/ s/#//'
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
fi
if [[ $TBMODE = TCP ]]; then
   if [[ $TBROLE = client ]]
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
   sed '/add-on nsc-team-bridge-service-client-tcp/,/add-off nsc-team-bridge-service-client-tcp/ s/#//'
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = server ]]
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
   sed '/add-on nsc-team-bridge-service-server-tcp/,/add-off nsc-team-bridge-service-server-tcp/ s/#//' 
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = both ]]
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' | 
   sed '/add-on nsc-team-bridge-service-server-tcp/,/add-off nsc-team-bridge-service-server-tcp/ s/#//' |
   sed '/add-on nsc-team-bridge-service-client-tcp/,/add-off nsc-team-bridge-service-client-tcp/ s/#//'
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
fi
# Archive env specific file to system
if test -f docker-compose_$PUBLICIP.yml; then
    mv docker-compose_$PUBLICIP.yml docker-compose_$PUBLICIP.old  2> /dev/null
fi
cp docker-compose.yml docker-compose_$PUBLICIP.yml
echo "*** docker-compose.yml file is created ***"
echo "*** Downloading docker images ... ***"
sudo docker-compose up -d
echo ""
echo "*******************************************************"
echo ""                                        
echo "   NSC3 backend release $RELEASETAG is installed!  "
echo ""
echo "   Login to your NSC3 web app by URL address       "
echo "   https://$PUBLICIP                               "
echo ""
echo "*******************************************************"
