#!/bin/bash
ff=(`find ./ -name 'OUTCAR' |sort `)
compfile=()
finalword=()
isif=()
your=()
nbands=()
highestband=()
jobstatus=()
cfile=()
nsw=()
nsteps=()

#---- exclude some files 
for index in "${!ff[@]}"
do
if [[  "${ff[index]}" != *"relax"*  ]]  && [[ "${ff[index]}" != *"old"*  ]] \
     && [[ "${ff[index]}" != *"bak"*  ]]; then
   cfile+=(`echo "${ff[index]}"`)
fi
done

#----- extract some important informations
for index  in "${!cfile[@]}"
do
fcontcar=`echo "${cfile[index]}" |sed  "s/OUTCAR/CONTCAR/g" `
fposcar=`echo  "${cfile[index]}" |sed  "s/OUTCAR/POSCAR/g" ` 
fmd1=`md5sum $fcontcar| awk '{printf "%s", $1}'`
fmd2=`md5sum $fposcar| awk '{printf "%s", $1}'`
if [ "$fmd1" == "$fmd2" ] ;then
    compfile+=("Same")
else
    compfile+=("Diff")
fi

final_line=`tail -1  "${cfile[index]}"`
finalword+=(`echo  $final_line | awk '{printf "%s\n", $1}'`)

isif+=(`grep   'ISIF' "${cfile[index]}"|tail -1 |awk '{printf "%s\n", $3}'`)
nsw+=(`grep   'number of steps for IOM' "${cfile[index]}"|tail -1 |awk '{printf "%s\n", $3}'`)
nsteps+=(`grep   'Iteration' "${cfile[index]}"|tail -1 |sed  "s/(/ /g"|awk '{printf "%s\n", $3}'`)
yourhigh=`grep 'Your highest band is occupied at some k-points!'  "${cfile[index]}"|tail -1|awk '{printf "%s\n", $2}'`
if [  ${#yourhigh} -gt  0 ]; then
    your+=("insufficent")
else
    your+=("sufficent")
fi
nbands+=(`grep 'NBANDS='   "${cfile[index]}"|tail -1|  awk '{printf "%s\n", $15}'`)
highestband+=(`grep 'NELECT ='  "${cfile[index]}"|tail -1|  awk '{printf "%6d\n", $3/2}'`)

if  [  "${finalword[index]}" == 'Voluntary' ]; then
    jobstatus+=("Success")
else
    jobstatus+=("Failure")
fi
done

# show some information on screen
# normally finished jobs
echo "#C_P---> Are CONTCAR and POSCAR same?"
echo "#HBANDS---> highest bands account from total number of electrons."
echo "#NBANDS_OK---> sufficient: setup of NBANDS is OK."
echo "#Normally finished jobs:"
echo "#Path"    "ISIF"  "NSW" "NSTEP" "Job_stat"  "C_P"  "NBANDS" "HBANDS" "NBANDS_OK"|\
    awk '{printf "%-30s %-4s %-4s %-5s %-9s %-5s %-6s %-7s %-10s\n", $1,$2,$3,$4,$5,$6,$7,$8,$9}'
for index in  "${!jobstatus[@]}"
do
    if [  "${jobstatus[index]}" == 'Success'  ];then
    echo "${cfile[index]}"  "${isif[index]}"  "${nsw[index]}" "${nsteps[index]}" \
          "${jobstatus[index]}"  "${compfile[index]}"  \
    "${nbands[index]}" "${highestband[index]}" "${your[index]}"|\
    awk '{printf "%-30s %-2d %5d %5d %9s %5s %6d %6d %10s\n", $1,$2,$3,$4,$5,$6,$7,$8, $9}'
    fi
done
echo "#Abnormally finished jobs:"
echo "#Path"    "ISIF"  "NSW" "NSTEP" "Job_stat"  "C_P"  "NBANDS" "HBANDS" "NBANDS_OK"|\
    awk '{printf "%-30s %-4s %-4s %-5s %-9s %-5s %-6s %-7s %-10s\n", $1,$2,$3,$4,$5,$6,$7,$8,$9}'
for index in  "${!jobstatus[@]}"
do
    if [  "${jobstatus[index]}" != 'Success'  ];then
    echo "${cfile[index]}"  "${isif[index]}"  "${nsw[index]}" "${nsteps[index]}"\
          "${jobstatus[index]}"  "${compfile[index]}"  \
    "${nbands[index]}" "${highestband[index]}" "${your[index]}"|\
    awk '{printf "%-30s %-2d %5d %5d %9s %5s %6d %6d %10s\n", $1,$2,$3,$4,$5,$6,$7,$8, $9}'
    fi
done




