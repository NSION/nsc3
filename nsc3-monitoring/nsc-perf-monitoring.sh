#!/bin/bash
DATE=`date +%Y%m%d`  
TIME=$(date +"%T")
OUTPUTLOCATION="/tmp/"
HOSTNAME="ns3-server.com"
TEMPFILE="temp.txt"
OUTPUTFILE="nsc3-perftest-${HOSTNAME}-${DATE}.txt"
if [ ! -f $OUTPUTLOCATION/$OUTPUTFILE ]; then
    touch $OUTPUTLOCATION/$OUTPUTFILE 2> /dev/null
    echo "'DATE','TIME','NAME','CPU %','MEM usage','MEM limit','NET Inbound','NET Outbound','BLOCK Inbound','BLOCK Outbound','PIDS'" >> $OUTPUTLOCATION/$OUTPUTFILE 2> /dev/null
fi
DOCKERHEAD=$(sudo docker stats --no-stream --format "table '{{.Name}}','{{.CPUPerc}}','{{.MemUsage}}'" | head -n1 | sed 's/[/]/\x27,\x27/g')
DOCKERCOUNT=$(sudo docker stats --no-stream --format "table '{{.Name}}','{{.CPUPerc}}','{{.MemUsage}}','{{.NetIO}}','{{.BlockIO}}','{{.PIDs}}'" | tail -n+2 | wc -l)
DATE=`date +%Y%m%d` 
TIME=$(date +"%T")
#echo "Reported: ${DATE}: ${TIME}" >> $OUTPUTLOCATION/$OUTPUTFILE 
#docker stats --no-stream >> $OUTPUTLOCATION/$OUTPUTFILE 
#DOCKERCOUNT=$(sudo docker stats --no-stream --format "table {{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.BlockIO}},{{.PIDs}}" | tail -n+2 | wc -l)
#GPUMEM=$(gpustat --json | grep memory.used | awk '{ print $2}')
#GPUUSAGE=$(gpustat --json | grep utilization.gpu | awk '{ print $2}')
CPUUSAGE=$(echo "100 - $(mpstat | tail -1 | awk '{ print $12}')" | bc -l)" %" 2> /dev/null 
MEMUSAGE=$(free -g | grep Mem: | awk '{ print $3}')" GB" 2> /dev/null
MEMTOTAL=$(free -g | grep Mem: | awk '{ print $2}')" GB" 2> /dev/null
#echo "GPU memory used (MBytes): '"${GPUMEM}"', Utilization GPU (%): '"${GPUUSAGE}"', Free CPU: '"${CPUUSAGEFREE}"', Free MEM: '"${MEMUSAGEFREE}"'"  >> $OUTPUTLOCATION/$OUTPUTFILE
a=1
if [ -f $OUTPUTLOCATION/$TEMPFILE ]; then
  sudo rm $OUTPUTLOCATION/$TEMPFILE 2> /dev/null
fi
sudo docker stats --no-stream --format "table '{{.Name}}','{{.CPUPerc}}','{{.MemUsage}}','{{.NetIO}}','{{.BlockIO}}','{{.PIDs}}'" > $OUTPUTLOCATION/$TEMPFILE
while [ $a -le $DOCKERCOUNT ]
do
  l=$a"p"
  DOCKERLINE=$(cat $OUTPUTLOCATION/$TEMPFILE | tail -n+2 | sed 's/[/]/\x27,\x27/g' | sed -n $l)
  echo "'"$DATE"'","'"$TIME"'"","$DOCKERLINE >> $OUTPUTLOCATION/$OUTPUTFILE
  a=`expr $a + 1`
done
echo "'"$DATE"','"$TIME"','system','"$CPUUSAGE"','"$MEMUSAGE"','"$MEMTOTAL"'"  >> $OUTPUTLOCATION/$OUTPUTFILE
# add to crontab, sudo crontab -e,  like hourly 0 * * * /path-to-your-file/nsc-perf-monitoring.sh
