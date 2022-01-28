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
       echo "Valor installer usage:"
       echo ""
       echo "sudo ./valor-install.sh --help 	  'help text'"
       echo "sudo ./valor-install.sh --silent      'installation with command line parameters'"
       echo "sudo ./valor-install.sh 		  'interactive installation mode'"
       echo ""
       echo "CLI parameters usage:"
       echo "sudo ./valor-install.sh --silent <Valor release tag> <HW layout>"
       echo ""
       echo "CLI parameters example:"
       echo "sudo ./valor-install.sh --silent release-3.3 CPU"
       echo ""
       echo "sudo ./valor-install.sh --silent release-3.3"
       echo ""
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       exit 0
   fi
   if [ ${2+"true"} ]; then
       export NSC3REL=$2
   fi
   if [ ${2+"true"} ]; then
       export HWMODE=$3
   fi
fi
if [ "$silentmode" = false ]; then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "                                        "
    echo "  Valor docker-compose installer:       "
    echo "  This script prepares Valor config     "
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "Valor Release tag, e.g release-3.3: "
    read REL
    export NSC3REL=$REL
    echo "Select HW layout, Options CPU or GPU: "
    read HW    
    read HWMODE=$HW
fi
echo "export HWMODE=$HWMODE" >> $NSCHOME/nsc-host.env
# Move old files
if [ -f "docker-compose-valor.yml" ]; then
   mv docker-compose-valor.yml docker-compose-valor-$NSC3REL.old 2> /dev/null
fi
(echo "cat <<EOF >docker-compose-valor-temp.yml";
cat valor-docker-compose-ext-reg.tmpl | sed -n '/'"$NSC3REL" "$HWMODE"'/,/'"$NSC3REL" "$HWMODE"'/p';
) >temp.yml
. temp.yml 2> /dev/null
cat docker-compose-valor-temp.yml > docker-compose-valor.yml;
rm -f temp.yml docker-compose-valor-temp.yml 2> /dev/null
# Archive env specific file to system
if test -f docker-compose-valor_$PUBLICIP.yml; then
    mv docker-compose-valor_$PUBLICIP.yml docker-compose-valor_$PUBLICIP.old  2> /dev/null
fi
cp docker-compose-valor.yml docker-compose-valor_$PUBLICIP.yml
echo "docker-compose-valor.yml file is created..."
echo "Downloading docker images ..."
sudo docker-compose -f docker-compose-valor.yml up -d
echo "++++++++++++++++++++++++++++++++++++++++"
echo ""                                        
echo "NSC3 backend is installed!"
echo ""
echo "Login to your NSC3 web app by URL address"
echo "https://$PUBLICIP"
echo ""
echo "++++++++++++++++++++++++++++++++++++++++"
