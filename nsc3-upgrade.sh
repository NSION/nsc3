#!/bin/bash
echo "++++++++++++++++++++++++++++++++++++++++"
echo "                                        "
echo "  NSC3 upgrade:        "
echo "  This script is upgrading NSC3 system  "
echo "                                        "
echo "++++++++++++++++++++++++++++++++++++++++"
echo "NSC3 installation folder, e.g /home/nscuser/nsc3: "
read  NSC3HOMEFOLDER
export NSCHOME=$NSC3HOMEFOLDER
echo "NSC3 public hostname, e.g videoservice.nsiontec.com: "
read  NSC3URL
export PUBLICIP=$NSC3URL
echo "NSC3 Release tag, e.g release-3.4: " 
read REL
export NSC3REL=$REL
export NSC3REG="registrynsion.azurecr.io"
# Move old files
mv docker-compose.yml docker-compose-$NSC3REL.old 2> /dev/null
# Create dictories
mkdir $NSCHOME/logs 2> /dev/null
mkdir $NSCHOME/mapdata 2> /dev/null
mkdir $NSCHOME/nsc-gateway-cert 2> /dev/null
cp $HOME/privkey.pem $NSCHOME/nsc-gateway-cert/. 2> /dev/null
cp $HOME/fullchain.pem $NSCHOME/nsc-gateway-cert/. 2> /dev/null
# Create docker-compose.yml file
echo "Pulling from github updated NSC3 configuration ..."
cd $NSCHOME
sudo git pull -f
(echo "cat <<EOF >docker-compose-temp.yml";
cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$NSC3REL"'/,/'"$NSC3REL"'/p';
) >temp.yml
. temp.yml 2> /dev/null
cat docker-compose-temp.yml > docker-compose.yml;
rm -f temp.yml docker-compose-temp.yml 2> /dev/null
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
