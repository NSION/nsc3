#!/bin/bash
## NSC3 registry:
export NSC3REG="registrynsion.azurecr.io"
TIMESTAMP=$(date +%Y-%m-%d)
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
       echo "CLI parameters usage for client:"
       echo "./team-bridge-install.sh --silent <Installation path> <Role: client> <TCP or UDP mode> <Team Bridge Server IP> <Source Organisation ID>"
       echo ""
       echo "CLI parameters example for client:"
       echo "./team-bridge-install.sh --silent /home/ubuntu/nsc3 client UDP 172.17.12.12 123jdsfs345435"
       echo ""
       echo "CLI parameters usage for server:"
       echo "./team-bridge-install.sh --silent <Installation path> <Role: server/both> <TCP or UDP mode> <local Team-Bridge Server IP> <Source Organisation ID> <Targer Organisation ID>"
       echo ""
       echo "CLI parameters example for server:"
       echo "./team-bridge-install.sh --silent /home/ubuntu/nsc3 server UDP 172.17.12.12 123jdsfs345435 vWjdsfsfsdfsd12"
       echo ""
       echo "CLI parameters usage for both server and client:"
       echo "./team-bridge-install.sh --silent <Installation path> <Role: both> <TCP or UDP mode> <Client: Other end Team-Bridge Server IP> <Client: Source Organisation ID> <Server: Local Team-Bridge Server IP> <Server: Source Organisation ID> <Server: Targer Organisation ID>"
       echo ""
       echo "CLI parameters example for both server client:"
       echo "./team-bridge-install.sh --silent /home/ubuntu/nsc3 both UDP 172.17.12.12 123jdsfs345435 172.17.12.13 vWjdsfsfsdfsd12 Qdgsdfgfsff434"
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
   if ! [[ $TBROLE = client  ||  $TBMODE = server ||  $TBMODE = both ]]; then echo "*** "$TBROLE"  as input value is not range of role selection. please type client, server or both"; exit 0; fi
   if [ $TBROLE = client ]; then 
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
   if [ $TBROLE = server ]; then 
      if [ ${4+"true"} ]; then
          export TBMODE=$4
      fi
      if [ ${5+"true"} ]; then
          export TBSERVERIP2=$5
      fi
      if [ ${6+"true"} ]; then
          export SOURCEORG=$6
      fi
      if [ ${7+"true"} ]; then
          export TARGETORG=$7
      fi
   fi
   if [ $TBROLE = both ]; then 
      if [ ${4+"true"} ]; then
          export TBMODE=$4
      fi
      if [ ${5+"true"} ]; then
          export TBSERVERIP=$5
      fi
      if [ ${6+"true"} ]; then
          export SOURCEORG=$6
      fi
      if [ ${7+"true"} ]; then
          export TBSERVERIP2=$7
      fi
      if [ ${8+"true"} ]; then
          export SOURCEORG2=$8
      fi
      if [ ${9+"true"} ]; then
          export TARGETORG2=$9
      fi
   fi
fi
if [ "$silentmode" = false ]; then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "                                        "
    echo "  NSC3 Team-Bridge installer:           "
    echo "  This script prepares NSC3 config      "
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "NSC3 installation folder, e.g /home/ubuntu/nsc3: "
    read NSC3HOMEFOLDER
    export NSCHOME=$NSC3HOMEFOLDER
    echo "TCP or UDP Protocol ?: "
    read TBMODE
    echo "Role (client, server or both) ?: "
    read TBROLE
    if ! [[ $TBROLE = client  ||  $TBMODE = server ||  $TBMODE = both ]]; then echo "*** "$TBROLE"  as input value is not range of role selection. please type client, server or both"; exit 0; fi
    if [ $TBROLE = client ]; then 
       echo "other end Team-Bridge server IP address: "
       read TBSERVERIP
       echo "Local source organisation ID: "
       read SOURCEORG
    fi
    if [ $TBROLE = server ]; then 
       echo "other end source organisation ID: "
       read SOURCEORG
       echo "local Team-Bridge server IP address: "
       read TBSERVERIP2
       echo "local target organisation ID: "
       read TARGETORG
    fi
    if [ $TBROLE = both ]; then 
       echo "Client - other end Team-Bridge server IP address: "
       read TBSERVERIP
       echo "Client - Local source organisation ID: "
       read SOURCEORG
       echo "Server - Local Team-Bridge server IP address: "
       read TBSERVERIP2
       echo "Server - other end source organisation ID: "
       read SOURCEORG2
       echo "Server - Local target organisation ID: "
       read TARGETORG2
    fi
fi
# Check values
if ! [ -d $NSCHOME ]; then echo "*** $NSCHOME 'Installation folder is missing! "; exit 0; fi
if ! [[ $TBMODE = TCP  ||  $TBMODE = UDP ]]; then echo "*** "$TBMODE"  as input value is not range of mode selection. please type TCP or UDP"; exit 0; fi
if ! [[ $TBROLE = client  ||  $TBMODE = server ||  $TBMODE = both ]]; then echo "*** "$TBROLE"  as input value is not range of role selection. please type client, server or both"; exit 0; fi
if ! [[ $TBSERVERIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP"  as input is not valid Team-Bridge server IP"; exit 0; fi
if ! [[ $TBSERVERIP2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP2"  as input is not valid Team-Bridge server IP"; exit 0; fi
if [[ $SOURCEORG = *" "* ]]; then echo "*** "$SOURCEORG"  as input is not valid NSC3 source organisation ID"; exit 0; fi
if [[ $SOURCEORG2 = *" "* ]]; then echo "*** "$SOURCEORG2"  as input is not valid NSC3 source organisation ID"; exit 0; fi
if [[ $TARGETORG = *" "* ]]; then echo "*** "$TARGETORG"  as input is not valid NSC3 target organisation ID"; exit 0; fi
if [[ $TARGETORG2 = *" "* ]]; then echo "*** "$TARGETORG2"  as input is not valid NSC3 target organisation ID"; exit 0; fi
# Create TCP keys
if ! [[ $TBMODE = TCP ]]; then
   if [ ! -d $NSCHOME/bridgekeys ]; then 
      chmod u+x $NSCHOME/generateTeamBridgeRSAKeyPairs.sh 2> /dev/null
      bash $NSCHOME/generateTeamBridgeRSAKeyPairs.sh 2> /dev/null
      KEY_COPY_REMINDER=true
   fi
fi
# Grep release tag value
NSC3REL=$(cat $NSCHOME/docker-compose.yml | grep registrynsion.azurecr.io/main-postgres: | cut -d\: -f3) 2> /dev/null
echo "*** Current release tag: $NSC3REL  ***" 
RELEASETAG=$NSC3REL
# Update env variables
source $NSCHOME/nsc-host.env 2> /dev/null
chmod 666 $NSCHOME/nsc-host.env 2> /dev/null
if ! [ $(grep -c "TBMODE" $NSCHOME/nsc-host.env) -eq 1 ]; ]; then echo "export TBMODE=$TBMODE" >> $NSCHOME/nsc-host.env; fi
if ! [ $(grep -c "TBROLE" $NSCHOME/nsc-host.env) -eq 1 ]; then echo "export TBROLE=$TBROLE" >> $NSCHOME/nsc-host.env; fi
if ! [ $(grep -c "TBSERVERIP" $NSCHOME/nsc-host.env) -eq 1 ]; then echo "export TBSERVERIP=$TBSERVERIP" >> $NSCHOME/nsc-host.env; fi
if ! [ $(grep -c "SOURCEORG" $NSCHOME/nsc-host.env) -eq 1 ]; then echo "export SOURCEORG=$SOURCEORG" >> $NSCHOME/nsc-host.env; fi
if ! [ $(grep -c "TARGETORG" $NSCHOME/nsc-host.env) -eq 1 ]; then echo "export TARGETORG=$TARGETORG" >> $NSCHOME/nsc-host.env; fi
if ! [ $(grep -c "SOURCEORG2" $NSCHOME/nsc-host.env) -eq 1 ]; then echo "export SOURCEORG2=$SOURCEORG2" >> $NSCHOME/nsc-host.env; fi
if ! [ $(grep -c "TARGETORG2" $NSCHOME/nsc-host.env) -eq 1 ]; then echo "export TARGETORG2=$TARGETORG2" >> $NSCHOME/nsc-host.env; fi
chmod 333 $NSCHOME/nsc-host.env 2> /dev/null
# Additional variables
if [ $TBROLE = both ]; then CLIENTSOURCE=$SOURCEORG; fi
if [ $TBROLE = both ]; then SERVERSOURCE=$SOURCEORG2; fi
if [ $TBROLE = both ]; then SERVERDEST=$TARGETORG2; fi
# Update docker-compose.yml file
cd $NSCHOME
# make backup
if [ -f "docker-compose.yml" ]; then
   cp docker-compose.yml docker-compose-tb-addition-backup-$TIMESTAMP.yml 2> /dev/null
fi
if [[ $TBMODE = UDP ]]; then
   if [[ $TBROLE = client ]]; then
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
   sed '/add-on nsc-team-bridge-service-client-udp/,/add-off nsc-team-bridge-service-client-udp/ s/#//';
   ) >temp.yml
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   cat nsc-team-bridge-service-client.tmpl > nsc-team-bridge-service-client.env;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = server ]]; then
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
   sed '/add-on nsc-team-bridge-service-server-udp/,/add-off nsc-team-bridge-service-server-udp/ s/#//'; 
   ) >temp.yml
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   cat nsc-team-bridge-service-server.tmpl > nsc-team-bridge-service-server.env;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = both ]]; then
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' | 
   sed '/add-on nsc-team-bridge-service-server-udp/,/add-off nsc-team-bridge-service-server-udp/ s/#//' |
   sed '/add-on nsc-team-bridge-service-client-udp/,/add-off nsc-team-bridge-service-client-udp/ s/#//';
   ) >temp.yml
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   cat nsc-team-bridge-service-client.tmpl > nsc-team-bridge-service-client.env;
   export SOURCEORG=$SOURCEORG2;
   export TARGETORG=$TARGETORG2;
   cat nsc-team-bridge-service-server.tmpl > nsc-team-bridge-service-server.env:
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
fi
if [[ $TBMODE = TCP ]]; then
   if [[ $TBROLE = client ]]; then
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
   sed '/add-on nsc-team-bridge-service-client-tcp/,/add-off nsc-team-bridge-service-client-tcp/ s/#//';
   ) >temp.yml
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   cat nsc-team-bridge-service-client.tmpl > nsc-team-bridge-service-client.env;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = server ]]; then
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
   sed '/add-on nsc-team-bridge-service-server-tcp/,/add-off nsc-team-bridge-service-server-tcp/ s/#//';
   ) >temp.yml
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   cat nsc-team-bridge-service-server.tmpl > nsc-team-bridge-service-server.env;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = both ]]; then
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' | 
   sed '/add-on nsc-team-bridge-service-server-tcp/,/add-off nsc-team-bridge-service-server-tcp/ s/#//' |
   sed '/add-on nsc-team-bridge-service-client-tcp/,/add-off nsc-team-bridge-service-client-tcp/ s/#//';
   ) >temp.yml
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   cat nsc-team-bridge-service-client.tmpl > nsc-team-bridge-service-client.env;
   export SOURCEORG=$SOURCEORG2;
   export TARGETORG=$TARGETORG2;
   cat nsc-team-bridge-service-server.tmpl > nsc-team-bridge-service-server.env;
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
echo "                                                       "                                        
echo "   NSC3 backend release $RELEASETAG is installed with  "
echo "   Team-Bridge role: $TBROLE using $TBMODE protocol    "
if [ $TBROLE = client ]; then echo "   Source org ID: $SOURCEORG ServerIP: $TBSERVERIP "; fi
if [ $TBROLE = server ]; then echo "   Source org ID: $SOURCEORG Target org ID: $TARGETORG "; fi
if [ $TBROLE = both ]; then echo "   Client: Source org ID: $CLIENTSOURCE ServerIP: $TBSERVERIP  "; fi
if [ $TBROLE = both ]; then echo "   Server: Source org ID: $SERVERSOURCE Target org ID: $SERVERDEST "; fi
echo ""
if [ $KEY_COPY_REMINDER ]; then echo " New TCP keypairs generated at this server. 
Please copy all key pair files from folder $NSCHOME/bridgekeys 
to other end server folder $NSCHOME/bridgekeys"; fi
echo ""
echo "   Login to your NSC3 web app by URL address       "
echo "   https://$PUBLICIP                               "
echo ""
echo "*******************************************************"
