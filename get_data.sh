#! /bin/bash

wget -nH -np --cut-dirs=5 -R index.html -r http://ftp.micex.com/pub/info/stats/history/F/$1

#if [ -f "index.html" ]; then
#rm index.html
#fi

