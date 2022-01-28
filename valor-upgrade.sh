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
       echo "Valor Upgrade script usage:"
       echo ""
       echo "sudo ./valor-upgrade.sh --help 	  'help text'"
       echo "sudo ./valor-upgrade.sh --silent      'upgrade with command line parameters'"
       echo "sudo ./valor-upgrade.sh 		  'interactive upgrade mode'"
       echo ""
       echo "CLI parameters usage:"
       echo "sudo ./valor-upgrade.sh --silent <NSC3 release tag>"
       echo ""
       echo "CLI parameters example:"
       echo "sudo ./valor-upgrade.sh --silent release-3.4"
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
    echo "  Valor upgrade:        "
    echo "  This script is upgrading NSC3 system  "
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "New NSC3 Release tag for upgrading, e.g release-3.4: " 
    read REL
    export NSC3REL=$REL
fi
cd $NSCHOME
# Move old files
if [ -f "docker-compose-valor.yml" ]; then
   mv docker-compose-valor.yml docker-compose-valor-$NSC3REL.old 2> /dev/null
fi
(echo "cat <<EOF >docker-compose-valor-temp.yml";
cat valor-docker-compose-ext-reg.tmpl | sed -n '/'"$NSC3REL"'/,/'"$NSC3REL"'/p';
) >temp.yml
. temp.yml 2> /dev/null
cat docker-compose-valor-temp.yml > docker-compose-valor.yml;
rm -f temp.yml docker-compose-valor-temp.yml 2> /dev/null
# Archive env specific file to system
if test -f docker-compose-valor_$PUBLICIP.yml; then
    mv docker-compose-valor_$PUBLICIP.yml docker-compose-valor_$PUBLICIP.old  2> /dev/null
fi
cp docker-compose-valor.yml docker-compose-valor_$PUBLICIP.yml
echo "Upgrading docker images ..."
sudo docker-compose -f docker-compose-valor.yml pull
sudo docker-compose -f docker-compose-valor.yml up -d
echo "++++++++++++++++++++++++++++++++++++++++"
echo ""                                        
echo "Valor is upgraded to release $NSC3REL!"
echo ""
echo "Login to your NSC3 web app by URL address"
echo "https://$PUBLICIP"
echo ""
echo "++++++++++++++++++++++++++++++++++++++++"
