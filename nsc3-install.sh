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
       echo "./nsc3-install.sh --help 	  'help text'"
       echo "./nsc3-install.sh --silent      'installation with command line parameters'"
       echo "./nsc3-install.sh 		  'interactive installation mode'"
       echo ""
       echo "CLI parameters usage:"
       echo "./nsc3-install.sh --silent <Installation path> <SSL cert files location> <host name> <MAP region> <NSC3 release tag> <VALOR enabled "true/false">"
       echo ""
       echo "CLI parameters example:"
       echo "./nsc3-install.sh --silent /home/ubuntu/nsc3 /home/ubuntu foo.nsion.io NA release-3.11 false"
       echo ""
       echo "Regional identifiers of MAP selection:"
       echo "EU=Europe, NA=North America, AUS=Australia, GCC=GCC states, false=skip map downloading"
       echo ""
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       exit 0
   fi
   if [ ${2+"true"} ]; then
       export NSCHOME=$2
   fi
   if [ ${3+"true"} ]; then
       export SSLFOLDER=$3
   fi
   if [ ${4+"true"} ]; then
       export PUBLICIP=$4
   fi
   if [ ${5+"true"} ]; then
       export REGION=$5
   fi
   if [ ${6+"true"} ]; then
       export NSC3REL=$6
   fi   
   if [ ${7+"true"} ]; then
       export VALOR_ENABLED='"'${7}'"'
   fi  
fi
if [ "$silentmode" = false ]; then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "                                        "
    echo "  NSC3 docker-compose installer:        "
    echo "  This script prepares NSC3 config      "
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "NSC3 installation folder, e.g /home/nscuser/nsc3: "
    read  NSC3HOMEFOLDER
    export NSCHOME=$NSC3HOMEFOLDER
    echo "NSC3 public hostname, e.g videoservice.nsion.io: "
    read  NSC3URL
    export PUBLICIP=$NSC3URL
    echo "Location of SSL cert files, e.g /home/nscuser: "
    read  SSLF
    export SSLFOLDER=$SSLF
    echo "NSC3 Release tag, e.g release-3.11: "
    read REL
    export NSC3REL=$REL
    echo "Valor enabled, true/false: "
    read ENABLED
    export VALOR_ENABLED='"'${ENABLED}'"'
fi
# Check values
if [ -d $NSCHOME ]; then echo "*** $NSCHOME 'Installation folder found' ***"; else echo "*** $NSCHOME 'Installation folder is missing! Exit' ***"; exit 0; fi
# Create dictories
if [ ! -d $NSCHOME/logs ]; then 
   mkdir $NSCHOME/logs 2> /dev/null 
fi
if [ ! -d $NSCHOME/mapdata ]; then 
   mkdir $NSCHOME/mapdata 2> /dev/null 
fi
if [ ! -d $NSCHOME/nsc-gateway-cert ]; then 
   mkdir $NSCHOME/nsc-gateway-cert 2> /dev/null 
fi

if [ -f "$SSLFOLDER/privkey.pem" ]; then
   cp $SSLFOLDER/privkey.pem $NSCHOME/nsc-gateway-cert/. 2> /dev/null
   else echo "*** $SSLFOLDER/privkey.pem private key file is missing! ***"
fi

if [ -f "$SSLFOLDER/fullchain.pem" ]; then
   cp $SSLFOLDER/fullchain.pem $NSCHOME/nsc-gateway-cert/. 2> /dev/null
   else echo "*** $SSLFOLDER/fullchain.pem cert file is missing! ***"
fi
if [ "$silentmode" = false ]; then
   echo "Map files options : "
   echo "1. North America map"
   echo "2. Europa map"
   echo "3. Australia map"
   echo "4. GCC states map"
   echo "5. Skip maptile downloading ..."
   echo "Select your option as number: "
   declare -i MAP_OPTION
   read MAP_OPTION
   if [ $MAP_OPTION -eq 1 ]; then
       export MAPNAME="North America"
       echo "Selected map file is $MAPNAME. Size 15.19 GiB"
       echo -n "Do you want to downloading the map file? (y/n): "
       read answer
       if [ "$answer" != "${answer#[Yy]}" ] ;then
           REGION="NA"
       else
           echo "Continue installation without maptiles ..."
       fi
   fi
    if [ $MAP_OPTION -eq 2 ];then
        export MAPNAME="Europe"
        echo "Selected map file is $MAPNAME. Size 19.39 GiB"
        echo -n "Do you want to downloading the map file?? (y/n): "
        read answer
        if [ "$answer" != "${answer#[Yy]}" ] ;then
            REGION="EU"
        else
            echo "Continue installation without maptiles ..."
        fi
    fi
    if [ $MAP_OPTION -eq 3 ]; then
        export MAPNAME="Australia"
        echo "Selected map file is $MAPNAME. Size 1.21 GiB"
        echo -n "Do you want to downloading the map file? (y/n): "
        read answer
        if [ "$answer" != "${answer#[Yy]}" ] ;then
            REGION="AUS"
        else
            echo "Continue installation without maptiles ..."
        fi
    fi
    if [ $MAP_OPTION -eq 4 ]; then
        export MAPNAME="GCC states"
        echo "Selected map file is $MAPNAME. Size 390.52 MiB"
        echo -n "Do you want to downloading the map file? (y/n): "
        read answer
        if [ "$answer" != "${answer#[Yy]}" ] ;then
            REGION="GCC"
        else
            echo "Continue installation without maptiles ..."
        fi
    fi    
    if [ $MAP_OPTION -eq 5 ]; then
        
       REGION="false"
        
    fi
    if [ $MAP_OPTION -gt 5 ]
    then
        echo "Selected value $MAP_OPTION is out of range 1-5!"
    exit 0
    fi
    if [ $MAP_OPTION -lt 1 ]
    then
        echo "Selected value $MAP_OPTION  is out of range 1-5!"
    exit 0
    fi
fi
# Download Map file:
if [ $REGION == "EU" ]; then 
     wget -k -O $NSCHOME/mapdata/europe.mbtiles "https://nscdevstorage.blob.core.windows.net/maptiler/europe.mbtiles?sp=r&st=2023-02-27T12:04:08Z&se=2025-02-27T20:04:08Z&sv=2021-06-08&sr=b&sig=BaISloviRuplrGsECr%2Fo%2FcxjFrLmVcN7KS4qXdzJJv8%3D"
     echo "*** $MAPNAME map file is downloaded ***"
fi     
if [ $REGION == "NA" ]; then 
     wget -k -O $NSCHOME/mapdata/north_america.mbtiles "https://nscdevstorage.blob.core.windows.net/maptiler/north-america.mbtiles?sp=r&st=2023-02-27T12:05:58Z&se=2025-02-27T20:05:58Z&sv=2021-06-08&sr=b&sig=VwKJLyy29YlQZ%2BtpFREz7Bh35ZxenfAszIiQNGVnhT0%3D"
     echo "*** $MAPNAME map file is downloaded ***"
fi     
if [ $REGION == "AUS" ]; then 
     wget -k -O $NSCHOME/mapdata/australia.mbtiles "https://nscdevstorage.blob.core.windows.net/maptiler/australia-oceania_australia.mbtiles?sp=r&st=2023-02-27T12:10:51Z&se=2025-02-27T20:10:51Z&sv=2021-06-08&sr=b&sig=eToyiT7yDb1s4CHDl1ZMXxh0%2BJ4EAqa3rzzDt98kezM%3D"
     echo "*** $MAPNAME map file is downloaded ***"
fi     
if [ $REGION == "GCC" ]; then 
     wget -k -O $NSCHOME/mapdata/asia.mbtiles "https://nscdevstorage.blob.core.windows.net/maptiler/asia_gcc-states.mbtiles?sp=r&st=2023-02-27T12:07:33Z&se=2025-02-27T20:07:33Z&sv=2021-06-08&sr=b&sig=7upeiUU7Y%2B7qrviKIi8Ceoiq5vZWSLO%2FdmELOcfq7l4%3D"
     echo "*** $MAPNAME map file is downloaded ***"
fi     
if [ $REGION == "false" ]; then 
     echo "*** Installation without maptiles downloading ***"
fi 
# Check values
if grep -q $NSC3REL $NSCHOME/nsc3-docker-compose-ext-reg.tmpl; then     
   echo "*** Release tag: $NSC3REL tag found ***" 
   RELEASETAG=$NSC3REL
   else    
   echo "*** Release tag: $NSC3REL is missing. Using release tag: 'latest' ***" 
   RELEASETAG="latest"
fi
# Move old files
mv docker-compose.yml docker-compose-$NSC3REL.old 2> /dev/null
# Remove old and create new env file
if [ -f "$NSCHOME/nsc-host.env" ]; then
   rm $NSCHOME/nsc-host.env 2> /dev/null
fi
# set defaults for empty variables
[ -z "$VALOR_ENABLED" ] && export VALOR_ENABLED=false
# Store variables
echo "export PUBLICIP=$PUBLICIP" > $NSCHOME/nsc-host.env
echo "export NSCHOME=$NSCHOME" >> $NSCHOME/nsc-host.env
echo "export VALOR_ENABLED=$VALOR_ENABLED" >> $NSCHOME/nsc-host.env
export EXTIP='"'$(hostname -i)'"' 2> /dev/null
#  Modify maptiles rights level
chmod 644 $NSCHOME/mapdata/*.* 2> /dev/null
# Create docker-compose.yml file
cd $NSCHOME
if [ -f "docker-compose.yml" ]; then
   mv docker-compose.yml docker-compose.old 2> /dev/null
fi
(echo "cat <<EOF >docker-compose-temp.yml";
cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p';
) >temp.yml
. temp.yml 2> /dev/null
cat docker-compose-temp.yml > docker-compose.yml;
rm -f temp.yml docker-compose-temp.yml 2> /dev/null
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
