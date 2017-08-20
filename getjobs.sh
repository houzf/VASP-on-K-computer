#!/bin/bash
#kstat -A -s | grep 'STANDARD OUT FILE'
kstat -A -s   > alljobs.inf

kid=(`cat alljobs.inf |  grep 'K ID   '|  awk '{printf " %s\n" ,$4 }' `)
jobid=(`cat alljobs.inf |  grep 'JOB ID   '|  awk '{printf "%s\n" , $4 }'`)
jobstatus=(`cat alljobs.inf |  grep 'STATE                       :'|  awk '{printf "%s\n" , $3 }'`)
jobdir=(`cat alljobs.inf |  grep 'STANDARD OUT FILE           :'|awk '{printf "%s\n" , $5 }'`) 
elstime=(`cat alljobs.inf |  grep 'ELAPSE TIME (USE)           :'|awk '{printf "%s\n" , $5 }'`) 
user=(`cat alljobs.inf |  grep 'USER                        :'|awk '{printf "%s\n" , $3 }'`) 
jobname=(`cat alljobs.inf |  grep 'JOB NAME                    :'|awk '{printf "%s\n" , $4 }'`) 
currentuser=`echo $USER`
njobs=0
for index in "${!user[@]}"
do
    if [  "${user[index]}" == "$currentuser"  ]; then
        njobs=$(expr $njobs + 1)
    fi
done

ijob=0
#echo "#***** You have  ${#kid[@]} jobs on K.*****"
echo "#***** You have $njobs  jobs on K.*****"
echo "#Idx" "KID" "PJobID"  "Status"  "Used_time"  "Work_DIR" |\
    awk '{printf "%-5s %-10s %-10s %-7s %-10s %-50s \n" , $1 , $2, $3, $4, $5, $6}'
# see: https://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
for index in "${!kid[@]}"
do
    if [  "${user[index]}" == "$currentuser"  ]; then
        ijob=$(expr $ijob + 1)
    jdir=`echo "${jobdir[index]}" |sed  's/\/data\// \/data\//g'|\
    sed  "s/${jobname[index]}/  /g" | \
    awk '{printf "%s\n" , $2 }'`
    echo "$ijob  ${kid[index]}  ${jobid[index]}  ${jobstatus[index]} ${elstime[index]} $jdir"  |\
        awk '{printf "%-5s %-10s %-10s %-7s %-10s %-50s \n" , $1 , $2, $3, $4, $5, $6}'
    fi
done

rm -f alljobs.inf

