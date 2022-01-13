#!/bin/bash
# Setup variables for installation
echo "++++++++++++++++++++++++++++++++++++++++"
echo "                                        "
echo "  NSC3 docker-compose installer:        "
echo "  This script prepares NSC3 config      "
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
echo "Map files options : "
echo "1. North America map"
echo "2. Europa map"
echo "3. Australia map"
echo "4. GCC states map"
echo "Select your option as number: "
declare -i MAP_OPTION
read MAP_OPTION
if [ $MAP_OPTION -eq 1 ]
then
    export MAPNAME="North America"
    echo "Selected maptiles is $MAPNAME. Size 15.19 GiB"
    echo "Do you want to download the file? "
    select yn in "yes" "no"; do
    case $yn in
        yes ) wget -k -O $NSCHOME/mapdata/north_america.mbtiles "https://nscdevstorage.blob.core.windows.net/maptiler/north-america.mbtiles?sp=ra&st=2021-04-24T14:05:55Z&se=2023-01-06T23:05:55Z&sv=2020-02-10&sr=b&sig=XGJQgOZWC6fH2zyjUEDfTQeU9e1BG67f3v4p8fVEimc%3D"; break;;
        no ) exit;;
    esac
done   
fi
if [ $MAP_OPTION -eq 2 ]
then
    export MAPNAME="Europa"
    echo "Selected maptiles is $MAPNAME. Size 19.39 GiB"
    echo "Do you want to download the file? "
    select yn in "yes" "no"; do
    case $yn in
        yes ) wget -k -O $NSCHOME/mapdata/europe.mbtiles "https://nscdevstorage.blob.core.windows.net/maptiler/europe.mbtiles?sp=ra&st=2021-04-24T12:40:49Z&se=2023-01-07T21:40:49Z&sv=2020-02-10&sr=b&sig=m3ANK5J8%2BqYh80OdON0BRVCIll4ptM0%2F2kSjzGMmGrc%3D"; break;;
        no ) exit;;
    esac
done  
fi
if [ $MAP_OPTION -eq 3 ]
then
    export MAPNAME="Australia"
    echo "Selected maptiles is $MAPNAME. Size 1.21 GiB"
    echo "Do you want to download the file? "
    select yn in "yes" "no"; do
    case $yn in
        yes ) wget -k -O $NSCHOME/mapdata/australia.mbtiles "https://nscdevstorage.blob.core.windows.net/maptiler/australia-oceania_australia.mbtiles?sp=ra&st=2021-04-24T14:25:30Z&se=2023-01-06T23:25:30Z&sv=2020-02-10&sr=b&sig=yWkB7loHb02SNgCIhWiNZMb8VpfppfISaJW4MnsFHMw%3D"; break;;
        no ) exit;;
    esac
done 
fi
if [ $MAP_OPTION -eq 4 ]
then
    export MAPNAME="GCC states"
    echo "Selected maptiles is $MAPNAME. Size 390.52 MiB"
    echo "Do you want to download the file? "
    select yn in "yes" "no"; do
    case $yn in
        yes ) wget -k -O $NSCHOME/mapdata/asia.mbtiles "https://nscdevstorage.blob.core.windows.net/maptiler/asia_gcc-states.mbtiles?sp=ra&st=2021-04-25T15:03:13Z&se=2023-01-07T00:03:13Z&sv=2020-02-10&sr=b&sig=nvfmJOdn4XG2BV2CEncNXQuEnscJ2lfmtJeQZellHwM%3D"; break;;
        no ) exit;;
    esac
done 
fi
if [ $MAP_OPTION -gt 4 ]
then
    echo "Selected value $MAP_OPTION is out of range 1-4!"
exit 0
fi
if [ $MAP_OPTION -lt 1 ]
then
    echo "Selected value $MAP_OPTION  is out of range 1-4!"
exit 0
fi
echo "$MAPNAME map files is downloaded"
# Move old files
mv docker-compose.yml docker-compose-$NSC3REL.old 2> /dev/null
# Create dictories
mkdir $NSCHOME/logs 2> /dev/null
mkdir $NSCHOME/mapdata 2> /dev/null
mkdir $NSCHOME/nsc-gateway-cert 2> /dev/null
cp $HOME/privkey.pem $NSCHOME/nsc-gateway-cert/. 2> /dev/null
cp $HOME/fullchain.pem $NSCHOME/nsc-gateway-cert/. 2> /dev/null
# Create docker-compose.yml file
cd $NSCHOME
(echo "cat <<EOF >docker-compose-temp.yml";
cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$NSC3REL"'/,/'"$NSC3REL"'/p';
) >temp.yml
. temp.yml 2> /dev/null
cat docker-compose-temp.yml > docker-compose.yml;
rm -f temp.yml docker-compose-temp.yml 2> /dev/null
echo "++++++++++++++++++++++++++++++++++++++++"
echo "                                        "
echo "docker-compose.yml file is created..."
echo "Start the nsc3 service: sudo docker-compose up -d"
echo ""                                        
echo "Login to your NSC3 web app by URL address https://$PUBLICIP"
echo ""
echo "++++++++++++++++++++++++++++++++++++++++"
