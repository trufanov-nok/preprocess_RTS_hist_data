#! /bin/bash

#http://stackoverflow.com/a/16869816/841424

wget raw.github.com/transcode-open/apt-cyg/master/apt-cyg
chmod +x apt-cyg
mv apt-cyg /usr/local/bin


  if [ -f "get_data.sh" ]; then
   chmod +x ./get_data.sh
  else 
   echo "cant set execution flag on get_data.sh - not found in current folder"
  fi

  if [ -f "process.sh" ]; then
   chmod +x ./process.sh
  else 
   echo "cant set execution flag on process.sh - not found in current folder"
  fi
  
  if [ -f "unoconv" ]; then
   chmod +x ./unoconv
  else 
   echo "cant set execution flag on unoconv - not found in current folder"
  fi
  
  
apt-cyg install unzip
apt-cyg install python3


echo "Note: you will need LibreOffice installed to work with xls files."