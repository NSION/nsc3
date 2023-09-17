#!/bin/bash
## NSC3 registry:
export NSC3REG="registrynsion.azurecr.io"
TIMESTAMP=$(date +%Y%m%d%H%M)
source ./nsc-host.env
PREVRELEASE=$(cat $NSCHOME/docker-compose.yml | grep registrynsion.azurecr.io/main-postgres: | cut -d\: -f3) 2> /dev/null
export EXTIP=$(host $PUBLICIP | awk '{print $4}') 2> /dev/null
export MINIOSECRET=$(sudo docker inspect nsc-minio | grep MINIO_ROOT_PASSWORD= | awk '{print $1}' | sed s/MINIO_ROOT_PASSWORD=// | sed -e 's/[""]//g') 2> /dev/null
silentmode=false
if [ ${1+"true"} ]; then
   if  [ $1 == "--silent" ]; then
       silentmode=true
       echo "silent mode"
   fi
   if  [ $1 == "--help" ]; then
       clear
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       echo "NSC3 Upgrade script usage:"
       echo ""
       echo "sudo ./nsc3-upgrade.sh --help 	  'help text'"
       echo "sudo ./nsc3-upgrade.sh --silent      'upgrade with command line parameters'"
       echo "sudo ./nsc3-upgrade.sh 		  'interactive upgrade mode'"
       echo ""
       echo "CLI parameters usage:"
       echo "sudo ./nsc3-upgrade.sh --silent <NSC3 release tag>"
       echo ""
       echo "CLI parameters example:"
       echo "sudo ./nsc3-upgrade.sh --silent release-3.15"
       echo ""
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       exit 0
   fi
   if [ ${2+"true"} ]; then
       export NSC3REL=$2
   fi
fi
if [ "$silentmode" = false ]; then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "                                        "
    echo "  NSC3 upgrade:        "
    echo "  This script is upgrading NSC3 system  "
    echo "  Current release tag: $PREVRELEASE  "    
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    read -p "NSC3 Release tag for upgrading, e.g release-3.15: " NSC3REL
fi
cd $NSCHOME
# Check values
if grep -q $NSC3REL $NSCHOME/nsc3-docker-compose-ext-reg.tmpl; then     
   echo "$NSC3REL tag found from docker-compose template" 
   RELEASETAG=$NSC3REL
   else    
   echo "Release tag: $NSC3REL is missing. Using release tag: rc as runtime parameters configuration" 
   RELEASETAG="rc"
fi
# Move old files and create new.
mv docker-compose.yml docker-compose-$NSC3REL.old 2> /dev/null
if [ -z "$TEAM_BRIDGE_ENABLED" ]; then
 # Backup
 if [ -f "nsc-team-bridge-service-server.env" ]; then cp nsc-team-bridge-service-server.env nsc-team-bridge-service-server-$TIMESTAMP.env 2> /dev/null; fi
 if [ -f "nsc-team-bridge-service-client.env" ]; then cp nsc-team-bridge-service-client.env nsc-team-bridge-service-client-$TIMESTAMP.env 2> /dev/null; fi
    if [[ $TBMODE = UDP ]]; then
      if [[ $TBROLE = client ]]; then
         (echo "cat <<EOF >docker-compose-temp.yml";
         cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
         sed '/add-on nsc-team-bridge-service-client-udp/,/add-off nsc-team-bridge-service-client-udp/ s/#//';
         ) >temp.yml
         . temp.yml 2> /dev/null
         cat docker-compose-temp.yml > docker-compose.yml;
         (echo "cat <<EOF >nsc-team-bridge-service-client-temp.yml";
         cat nsc-team-bridge-service-client.tmpl;
         ) >tb-client-temp.yml
         . tb-client-temp.yml 2> /dev/null
         cat nsc-team-bridge-service-client-temp.yml > nsc-team-bridge-service-client.env;
         rm -f tb-client-temp.yml nsc-team-bridge-service-client-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
      fi
      if [[ $TBROLE = server ]]; then
         (echo "cat <<EOF >docker-compose-temp.yml";
         cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
         sed '/add-on nsc-team-bridge-service-server-udp/,/add-off nsc-team-bridge-service-server-udp/ s/#//'; 
         ) >temp.yml
         . temp.yml 2> /dev/null
         cat docker-compose-temp.yml > docker-compose.yml;
         (echo "cat <<EOF >nsc-team-bridge-service-server-temp.yml";
         cat nsc-team-bridge-service-server.tmpl;
         ) >tb-server-temp.yml
         . tb-server-temp.yml 2> /dev/null
         cat nsc-team-bridge-service-server-temp.yml > nsc-team-bridge-service-server.env;
         rm -f tb-server-temp.yml nsc-team-bridge-service-server-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
      fi
      if [[ $TBROLE = both ]]; then
         (echo "cat <<EOF >docker-compose-temp.yml";
         cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' | 
         sed '/add-on nsc-team-bridge-service-server-udp/,/add-off nsc-team-bridge-service-server-udp/ s/#//' |
         sed '/add-on nsc-team-bridge-service-client-udp/,/add-off nsc-team-bridge-service-client-udp/ s/#//';
         ) >temp.yml
         . temp.yml 2> /dev/null
         cat docker-compose-temp.yml > docker-compose.yml;
         # Client
         (echo "cat <<EOF >nsc-team-bridge-service-client-temp.yml";
         cat nsc-team-bridge-service-client.tmpl;
         ) >tb-client-temp.yml
         . tb-client-temp.yml 2> /dev/null
         cat nsc-team-bridge-service-client-temp.yml > nsc-team-bridge-service-client.env;
         # Server
         # Additional variables
         CLIENTSOURCE=$SOURCEORG
         SERVERSOURCE=$SOURCEORG2
         SERVERDEST=$TARGETORG2
         SOURCEORG=$SERVERSOURCE
         TARGETORG=$SERVERDEST 
         (echo "cat <<EOF >nsc-team-bridge-service-server-temp.yml";
         cat nsc-team-bridge-service-server.tmpl;
         ) >tb-server-temp.yml
         . tb-server-temp.yml 2> /dev/null
         cat nsc-team-bridge-service-server-temp.yml > nsc-team-bridge-service-server.env;
         rm -f tb-server-temp.yml nsc-team-bridge-service-server-temp.yml tb-client-temp.yml nsc-team-bridge-service-client-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
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
         (echo "cat <<EOF >nsc-team-bridge-service-client-temp.yml";
         cat nsc-team-bridge-service-client.tmpl;
         ) >tb-client-temp.yml
         . tb-client-temp.yml 2> /dev/null
         cat nsc-team-bridge-service-client-temp.yml > nsc-team-bridge-service-client.env;
         rm -f tb-client-temp.yml nsc-team-bridge-service-client-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
      fi
      if [[ $TBROLE = server ]]; then
         (echo "cat <<EOF >docker-compose-temp.yml";
         cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
         sed '/add-on nsc-team-bridge-service-server-tcp/,/add-off nsc-team-bridge-service-server-tcp/ s/#//';
         ) >temp.yml
         . temp.yml 2> /dev/null
         cat docker-compose-temp.yml > docker-compose.yml;
         (echo "cat <<EOF >nsc-team-bridge-service-server-temp.yml";
         cat nsc-team-bridge-service-server.tmpl;
         ) >tb-server-temp.yml
         . tb-server-temp.yml 2> /dev/null
         cat nsc-team-bridge-service-server-temp.yml > nsc-team-bridge-service-server.env;
         rm -f tb-server-temp.yml nsc-team-bridge-service-server-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
      fi
      if [[ $TBROLE = both ]]; then
         (echo "cat <<EOF >docker-compose-temp.yml";
         cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' | 
         sed '/add-on nsc-team-bridge-service-server-tcp/,/add-off nsc-team-bridge-service-server-tcp/ s/#//' |
         sed '/add-on nsc-team-bridge-service-client-tcp/,/add-off nsc-team-bridge-service-client-tcp/ s/#//';
         ) >temp.yml
         . temp.yml 2> /dev/null
         cat docker-compose-temp.yml > docker-compose.yml;
         # Client
         (echo "cat <<EOF >nsc-team-bridge-service-client-temp.yml";
         cat nsc-team-bridge-service-client.tmpl;
         ) >tb-client-temp.yml
         . tb-client-temp.yml 2> /dev/null
         cat nsc-team-bridge-service-client-temp.yml > nsc-team-bridge-service-client.env;
         # Server
         CLIENTSOURCE=$SOURCEORG
         SERVERSOURCE=$SOURCEORG2
         SERVERDEST=$TARGETORG2
         SOURCEORG=$SERVERSOURCE
         TARGETORG=$SERVERDEST 
         (echo "cat <<EOF >nsc-team-bridge-service-server-temp.yml";
         cat nsc-team-bridge-service-server.tmpl;
         ) >tb-server-temp.yml
         . tb-server-temp.yml 2> /dev/null
         cat nsc-team-bridge-service-server-temp.yml > nsc-team-bridge-service-server.env;
         rm -f tb-server-temp.yml nsc-team-bridge-service-server-temp.yml tb-client-temp.yml nsc-team-bridge-service-client-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
      fi
    fi
else
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p';
   ) >temp.yml
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   if test -f docker-compose_$PUBLICIP.yml; then    mv docker-compose_$PUBLICIP.yml docker-compose_$PUBLICIP_$NSC3REL.old  2> /dev/null
   fi
   cp docker-compose.yml docker-compose_$PUBLICIP.yml
fi
if ! [ $(grep -c "TEAM_BRIDGE_ENABLED" $NSCHOME/nsc-host.env) -eq 1 ]; then 
   chmod 666 $NSCHOME/nsc-host.env
   echo "export TEAM_BRIDGE_ENABLED=false" >> $NSCHOME/nsc-host.env
   (echo "cat <<EOF >docker-compose-temp.yml";
   cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p';
   ) >temp.yml
   . temp.yml 2> /dev/null
   cat docker-compose-temp.yml > docker-compose.yml;
   rm -f temp.yml docker-compose-temp.yml 2> /dev/null
   if test -f docker-compose_$PUBLICIP.yml; then    mv docker-compose_$PUBLICIP.yml docker-compose_$PUBLICIP_$NSC3REL.old  2> /dev/null
   fi
   cp docker-compose.yml docker-compose_$PUBLICIP.yml
fi
# Maintenance log
if ! [ -f "$NSCHOME/logs/nsc-maintenance-log.txt" ]; then 
   touch $NSCHOME/logs/nsc-maintenance-log.txt 2> /dev/null;
   chmod 666 $NSCHOME/logs/nsc-maintenance-log.txt;
else 
   echo "$TIMESTAMP NSC3 upgraded from $PREVRELEASE to $RELEASETAG" >> $NSCHOME/logs/nsc-maintenance-log.txt 2> /dev/null; 
fi
echo "docker-compose.yml file is updated..."
echo "Upgrading docker images ..."
sudo docker-compose pull
sudo docker-compose up -d
# Post installation steps 
## Configure webrtc
sleep 5
export MINIOSECRET=$(sudo docker inspect nsc-minio | grep MINIO_ROOT_PASSWORD= | awk '{print $1}' | sed s/MINIO_ROOT_PASSWORD=// | sed -e 's/[""]//g') 2> /dev/null
sed -i 's/.*MINIO_SECRET_KEY=*.*/      - MINIO_SECRET_KEY='"$MINIOSECRET"'/' $NSCHOME/docker-compose.yml;
sudo docker-compose restart nsc-webrtc-proxy
#
echo "++++++++++++++++++++++++++++++++++++++++"
echo ""                                        
echo "NSC3 backend is upgraded to release $NSC3REL!"
echo ""
echo "Login to your NSC3 web app by URL address"
echo "https://$PUBLICIP"
echo ""
echo "++++++++++++++++++++++++++++++++++++++++"
