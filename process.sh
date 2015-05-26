#! /bin/bash

# dataset could be obtained at http://ftp.micex.com/pub/info/stats/history/F/


verbose=0
output="./result"
ignore_xls=0
csv_header="code;contract;price;amount;dat_time;trade_id;Nosystem"
required_number_of_commas=6
python="" #used only in cygwin

if [ -d "/cygdrive" ]; then
  #running under cygwin
  echo "cygwin"
  python=($(/usr/bin/find /cygdrive/ -iname python.exe 2> /dev/null | grep -i -m 1 -e '.*LibreOffice.*\/program\/python.exe$ | sed -e "s# #\\\ #g" '))
fi

while getopts ":hvid:o:" OPTIONS; do
    case ${OPTIONS} in
        h) echo "OPTIONS:
    -h    Show this message
    -v    Verbose mode
    -i    Ignore xls files
    -d    Dataset folder (that contains subfolders 2003-2015). Default value:'.'
    -o    Output filename (suffixes -op.csv and -ft.csv will be added). Default value:'./result'"
    exit 0;;
        v) verbose=1;;
        i) ignore_xls=1;;
        d) echo "dataset dir is set to "${OPTARG}; cd ${OPTARG};;
        o) output=${OPTARG};;
    esac
done

# override echo fnction to incorparae verbose
function echo() { ((verbose)) && command echo "$@" || return 0; }

function copy_csv()
{
   commas=($(head -n 1 $1 | grep -o ';' | wc -l))   
       
    if [ $commas == "$required_number_of_commas" ]; then        
     tail -n +2 $1 >> $2 
     else
      commas=$((required_number_of_commas-commas))      
      new_commas=($(head -c $commas < /dev/zero | tr '\0' ';'))      
      tail -n +2 $1 | sed "s#.*#&$(echo $new_commas)#" >> $2
    fi
}

case $output in
  /*) ;;
  *) output=$PWD/$output; echo $output;;
esac


 # get list of folders made of 4 digits
 folders=($(ls -A | grep "^[0-9]\{4\}$" | sort))
 
 echo $csv_header > $output"-ot.csv"
 echo $csv_header > $output"-ft.csv"

 for i in "${folders[@]}"
 do
  cd $i
  
  # create temp folders
  if [ ! -d "tmp" ]; then
   echo "create temp folder "$i"/tmp"
   mkdir tmp
  else 
   if [ "$(ls ./tmp)" ]; then
   rm ./tmp/*
   fi   
  fi
  
 
  zips=($(ls | grep -i "^FT[0-9]\{6\}\.zip$" | sort))
  
  for j in "${zips[@]}"
  do
  
   echo "processing "$j
   
   echo "decompressing.."   
   unzip -o -q $j -d ./tmp
   
   cd ./tmp
   
   
   csv=($(ls | grep -i "^.*ot\.csv$"))
   for k in "${csv[@]}"
   do
   copy_csv $k $output"-ot.csv"   
   rm $k
   done
   
   csv=($(ls | grep -i "^.*ft\.csv$"))
   for k in "${csv[@]}"
   do    
   copy_csv $k $output"-ft.csv"   
   rm $k
   done

   
   if [ "$ignore_xls" == "0" ]; then
    xls=($(ls | grep -i "\.xls$"))
   
    for k in "${xls[@]}"
    do
     echo "converting "$k" to csvsheets.. "
     eval $python ../../unoconv -f csvsheets $k
    
     fn=${k%.*}

     if [ -f $fn".csv-options_trades.csv" ]; then
      echo "options data found"
      
      copy_csv $fn".csv-options_trades.csv" $output"-ot.csv" 
      #tail -n +2 $fn".csv-options_trades.csv" >> $output"-ot.csv" 
      #mv $fn.csv-options_trades.csv ../res/${fn:2}"ot.csv"
     fi
   
     if [ -f $fn".csv-futures_trades.csv" ]; then
      echo "futures data found"
      copy_csv $fn".csv-futures_trades.csv" $output"-ft.csv" 
      #tail -n +2 $fn".csv-futures_trades.csv" >> $output"-ft.csv" 
      #mv $fn.csv-futures_trades.csv ../res/${fn:2}"ft.csv"
     fi  
        
    
     if [ "$(ls .)" ]; then
     rm ./*
     fi   
    done
   
   fi 
   
    if [ "$(ls .)" ]; then
    rm ./*
    fi 

   cd ..   
  done
  
  
  
  cd ..
 done
 
 #ls | grep '^[0-9]\{4\}$' | sed 's#\(.*\)#mkdir \1\/tmp#' | sh
 
 #ls | grep -i 'FT' | sed 's#\(.*\)#zcat \1 > temp.xls \&\&  unoconv -f csvsheets temp.xls \&\& mv temp.csv-options_trades.csv .\/res/\1_ot.csv \&\& mv temp.csv-futures_trades.csv .\/res/\1_ft.csv#g' | sh