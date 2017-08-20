#!/bin/bash
ff=`find ./ -name 'OUTCAR'`
for i in $ff
do
final_line=`tail -1  $i`
final_word=`echo  $final_line | awk '{printf "%s\n", $1}'`

isif=`grep   'ISIF' $i|tail -1`

if [[  $i != *"relax"*  ]]  && [[ $i != *"old"*  ]]  && [[ $i != *"bak"*  ]]; then
    if  [  "$final_word" == 'Voluntary' ]; then
        echo $i   "job is finished normally."   $isif
    fi
fi
#if  [  "$final_word" != 'Voluntary' ]; then
#echo $i    $final_line
#else 
#echo $i   "job is finished normally."   $isif
#fi
done

echo 

for i in $ff
do
your=`grep 'Your highest band is occupied at some k-points! Unless you are'   $i|tail -1|\
      awk '{printf "%s\n", $2}'`
nbands=`grep 'NBANDS='   $i|tail -1|  awk '{printf "%s\n", $15}'`
highestband=`grep 'NELECT ='   $i|tail -1|  awk '{printf "%6d\n", $3/2}'`
final_line=`tail -1  $i`
final_word=`echo  $final_line | awk '{printf "%s\n", $1}'`

if [[  $i != *"relax"*  ]]  && [[ $i != *"old"*  ]]  && [[ $i != *"bak"*  ]]; then
    if  [  "$final_word" != 'Voluntary' ]; then
        echo $i    $final_line
    fi
    if  [  "$your" == 'Your' ]; then
        echo $i    "NBANDS should be increased. now it is ${nbands}. Highest band: ${highestband}."
    fi
fi
done


