#!/bin/bash
# Setup variables for installation
echo "++++++++++++++++++++++++++++++++++++++++"
echo "                                        "
echo "  NSC3 docker-compose installer:        "
echo "  This script prepares a configuration  "
echo "  docker-compose.yml                    "
echo "  Usage:                                "
echo "  -Start service: docker-compose up -d  "
echo "  -Stop service: docker-compose down    "
echo "  Upgrade process:                      "
echo "  -Modify release tag on compose file   "
echo "  -Stop service: docker-compose down    "
echo "  -Update images: docker-compose pull   "
echo "  -Start service: docker-compose up -d  "
echo "                                        "
echo "++++++++++++++++++++++++++++++++++++++++"
echo "NSC3 installation folder, e.g /home/nscuser/nsc3: "
read  NSC3HOMEFOLDER
export NSCHOME=$NSC3HOMEFOLDER
echo "NSC3 public hostname, e.g videoservice.nsiontec.com: "
read  NSC3URL
export PUBLICIP=$NSC3URL
echo "NSC3 Release tag, e.g release-3.3: " 
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
(echo "cat <<EOF >docker-compose-temp.yml";
cat nsc3-docker-compose-ext-reg.tmpl;
) >temp.yml
. temp.yml 2> /dev/null
cat docker-compose-temp.yml > docker-compose.yml;
rm -f temp.yml docker-compose-temp.yml
echo "++++++++++++++++++++++++++++++++++++++++"
echo "                                        "
echo "docker-compose.yml file created..."
echo "Start the nsc3 service: sudo docker-compose up -d"
echo ""
echo "Login to your NSC3 web app by url https://$PUBLICIP"
echo ""
echo "++++++++++++++++++++++++++++++++++++++++"
