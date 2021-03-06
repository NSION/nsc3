#!/bin/bash
## NSC3 registry:
export NSC3REG="registrynsion.azurecr.io"
source ./nsc-host.env
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
       echo "./nsc3-upgrade.sh --help 	  'help text'"
       echo "./nsc3-upgrade.sh --silent      'upgrade with command line parameters'"
       echo "./nsc3-upgrade.sh 		  'interactive upgrade mode'"
       echo ""
       echo "CLI parameters usage:"
       echo "./nsc3-upgrade.sh --silent <NSC3 release tag>"
       echo ""
       echo "CLI parameters example:"
       echo "./nsc3-upgrade.sh --silent release-3.4"
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
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "New NSC3 Release tag for upgrading, e.g release-3.4: " 
    read REL
    export NSC3REL=$REL
fi
cd $NSCHOME
# Check values
if grep -q $NSC3REL $NSCHOME/nsc3-docker-compose-ext-reg.tmpl; then     
   echo "$NSC3REL tag found from docker-compose template" 
   RELEASETAG=$NSC3REL
   else    
   echo "Release tag: $NSC3REL is missing. Using release tag: latest as runtime parameters configuration" 
   RELEASETAG="latest"
fi
# Move old files
mv docker-compose.yml docker-compose-$NSC3REL.old 2> /dev/null
(echo "cat <<EOF >docker-compose-temp.yml";
cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p';
) >temp.yml
. temp.yml 2> /dev/null
cat docker-compose-temp.yml > docker-compose.yml;
rm -f temp.yml docker-compose-temp.yml 2> /dev/null
if test -f docker-compose_$PUBLICIP.yml; then    mv docker-compose_$PUBLICIP.yml docker-compose_$PUBLICIP_$NSC3REL.old  2> /dev/null
fi
cp docker-compose.yml docker-compose_$PUBLICIP.yml
echo "docker-compose.yml file is updated..."
echo "Upgrading docker images ..."
sudo docker-compose pull
sudo docker-compose up -d
echo "++++++++++++++++++++++++++++++++++++++++"
echo ""                                        
echo "NSC3 backend is upgraded to release $NSC3REL!"
echo ""
echo "Login to your NSC3 web app by URL address"
echo "https://$PUBLICIP"
echo ""
echo "++++++++++++++++++++++++++++++++++++++++"
