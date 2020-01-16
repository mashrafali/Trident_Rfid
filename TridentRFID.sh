#! /bin/bash
clear
echo "##################"
echo "#  Trident RFID  #"
echo "#  Linux Driver  #"
echo "#       by       #"
echo "# Mohamed Ashraf #"
echo "##################"
sleep 2

## Defining Sudo Password
hashed="U2FsdGVkX1+QyuHB11BORoDZFxBo/rfnF4JqR3DY2yE="

## Declaring Requirments
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
diver=$((2#10010))
echo "NULL" > /tmp/tridentRFID.$LOGNAME
let n1=$diver/3;let n2=$diver/6;let n3=$diver/6;let n4=$diver/$diver
chmod 777 /tmp/tridentRFID.$LOGNAME
s1=$(echo TRIDENT|cut -c$n1);s2=$(echo LION|cut -c$n2);s3=$(echo SHOCKWAVE|cut -c$n3);s4=$(echo RAVEN|cut -c$n4)
clear
encore1=$(echo "obase=16; 10" | bc | awk '{print tolower($0)}')
echo
encore2=$(echo "obase=16; 14" | bc | awk '{print tolower($0)}')
echo
encore3=$(awk 'BEGIN{printf "%c", 115}')
GTX=$(echo "obase=16; 12" | bc | awk '{print tolower($0)}');GTY=$(echo "obase=16; 11" | bc | awk '{print tolower($0)}')

## Checking & Installing Packages
echo "### Starting Up Trident Driver:"
echo
echo "- Checking for Required System Libraries..."
supass=$(echo "$hashed" | openssl enc -$encore1$encore2$encore3-$((0x100))-$GTX$GTY$GTX -a -d -salt -pass pass:$s1$s2$s3$s4)
echo $supass | sudo -S apt-get update                                                                     #> /dev/null 2>&1
echo $supass | sudo -S apt-get install rfdump -y                                                          #> /dev/null 2>&1
echo $supass | sudo -S apt-get install xdotool -y                                                         #> /dev/null 2>&1
echo $supass | sudo -S apt install aptitude -y                                                            #> /dev/null 2>&1
echo $supass | sudo -S aptitude install build-essential libpcsclite-dev build-essential pcscd libccid -y  #> /dev/null 2>&1
echo $supass | sudo -S pkill cat
echo
echo " ============== [OK] =============="

#
echo -e '#! /bin/bash\n echo "   ==> Trident RFID Driver Has Started <=="\n sleep 3' > /tmp/letsbegin.sh
chmod a+x /tmp/letsbegin.sh
gnome-terminal -x /tmp/letsbegin.sh
#

## Extracting Device tty & Starting Listener
echo
while true
do
  sleep 1
  clear
  echo "### Starting Device Listener:"
  echo
  echo "- Device Logger is @ /tmp/tridentRFID.$LOGNAME"
  echo
  echo $supass | sudo -S pkill cat
  usbport=$(echo $supass | sudo -S cat /var/log/syslog | grep "Manufacturer: STMicroelectronics" | tail -1 | cut -d "]" -f2 | awk '{print $2}')
  printusb=$(echo $usbport | cut -d ":" -f1)
  ttydevice=$(echo $supass | sudo -S cat /var/log/kern.log | grep "$usbport" | grep "tty" | cut -d "_" -f2 | awk '{print $3}' | cut -d ":" -f1 | tail -1)
  preconnected=$(ls -lh /dev/ | grep -o "$ttydevice")
  if [ "$preconnected" != "$ttydevice" ]
  then
     echo ; echo "                     --- Required Device Not Found ---"
     printusb=NULL
     ttydevice=NULL
     echo "    NULL" > /tmp/tridentRFID.$LOGNAME
  else
     echo $supass | sudo -S cat /dev/$ttydevice >> /tmp/tridentRFID.$LOGNAME &
  fi
  echo
  echo " USB PORT : $printusb"
  echo " TTY Device : $ttydevice"
  echo
  let oldflag=0
  oldRFID=null
  seq=0
  while true
  do
    newflag=$(cat /tmp/tridentRFID.$LOGNAME | wc -l)
    if [ "$newflag" -gt "$oldflag" ]
    then
        newRFID=$(tail -2 /tmp/tridentRFID.$LOGNAME | head -1 | cut -c5-17)
        if [ "$newRFID" != "$oldRFID" ]
        then
           echo -en "     >>>>>  LATEST TAG ID : $newRFID  <<<<<" \\r
           if [ "$newRFID" != "NULL" ]
           then
              echo $supass | sudo -S xdotool type  --clearmodifiers -delay 0 "$newRFID"
           fi
           oldRFID=$newRFID
        fi
        oldflag=$newflag
    fi
    sleep 0.5
    let seq=$seq+1
    if [ "$seq" -eq "6" ]
    then
        oldRFID=null
        seq=0
    fi
    postconnected=$(ls -lh /dev/ | grep -o "$ttydevice")
    if [ "$postconnected" != "$ttydevice" ]
    then
        break
    fi
  done
done