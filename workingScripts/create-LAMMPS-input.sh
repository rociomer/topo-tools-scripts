#!/bin/bash

guest="CH4"
temp="313"
if [ $guest = "CH4" ]; then
  atomsPerGuest=1
  fixstyle="nvt"
elif [ $guest = "CO2" ]; then
  atomsPerGuest=3
  fixstyle="rigid/nvt molecule"
elif [ $guest = "H2O" ]; then
  atomsPerGuest=4
  fixstyle="rigid/nvt molecule"
fi
for metal in Mg
#for metal in Mg Ni Zn
do
  framework=$(echo "${metal}-MOF-74")
  echo "Framework: $framework"
  for pressure in 50000
  #for pressure in $(seq 50000 50000 500000)
  do
    echo "Pressure: $pressure"
    uptake=($(awk '$1 == "'"$pressure"'"' isotherms/${metal}_${guest}_313_absolute.txt))
    echo "Uptake in molec/UC: ${uptake[1]}"
    replicasGuest=$(echo "(${uptake[1]} * 4)/1" | bc )
    echo "Replicas of guest per supercell at this pressure: $replicasGuest"
    cp lammps-toposcript-${metal}MOF74.tcl lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    sed -i "s/GUESTFILE/${guest}.xyz/g" lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    sed -i "s/ATOMSPERGUEST/${atomsPerGuest}/g" lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    sed -i "s/REPLICASGUEST/${replicasGuest}/g" lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    vmd -dispdev text -e lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    # rename data file
    mv system.data ${metal}MOF74-Pressure${pressure}.data
    # prepare in file
    cp template.in ${metal}MOF74-Pressure${pressure}.in
    # prepare force fields parameters
    cp forceFieldParams-MgMOF74-template ${metal}MOF74-Pressure${pressure}.in.settings
    # set guest atoms
    if [ $guest = "CH4" ]; then
      guestAtomCH4=($(grep "\s\sCH4" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtoms=$(echo "${guestAtomCH4[1]}") 
      sed -i "s/guestAtomCH4/${guestAtomCH4[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    elif [ $guest = "CO2" ]; then
      guestAtomCg=($(grep "\s\sCg" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtomOg=($(grep "\s\sOg" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtoms=$(echo "${guestAtomCg[1]} ${guestAtomOg[1]}") 
      sed -i "s/guestAtomCg/${guestAtomCg[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
      sed -i "s/guestAtomOg/${guestAtomOg[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    elif [ $guest = "H2O" ]; then
      guestAtomHw=($(grep "\s\sHw" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtomM=($(grep "\s\sMw" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtomOw=($(grep "\s\sOw" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtoms=$(echo "${guestAtomHw[1]} ${guestAtomM[1]} ${guestAtomOw[1]}") 
      sed -i "s/guestAtomHw/${guestAtomHw[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
      sed -i "s/guestAtomMw/${guestAtomMw[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
      sed -i "s/guestAtomOw/${guestAtomOw[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    fi
    sed -i "s/guestAtoms/${guestAtoms}/g" ${metal}MOF74-Pressure${pressure}.in
    # set framework atoms  
    mofAtomM=($(grep "\s\s${metal}" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomCa=($(grep "\s\sCa" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomCb=($(grep "\s\sCb" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomCc=($(grep "\s\sCc" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomCd=($(grep "\s\sCd" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomH=($(grep "\s\sH" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomOa=($(grep "\s\sOa" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomOb=($(grep "\s\sOb" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomOc=($(grep "\s\sOc" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtoms=$(echo "${mofAtomM[1]} ${mofAtomCa[1]} ${mofAtomCb[1]} ${mofAtomCc[1]} ${mofAtomCd[1]} ${mofAtomH[1]} ${mofAtomOa[1]} ${mofAtomOb[1]} ${mofAtomOc[1]}" | tr " " "\n" | sort -g | tr "\n" " " )
    sed -i "s/mofAtom${metal}/${mofAtomM[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    sed -i "s/mofAtomCa/${mofAtomCa[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    sed -i "s/mofAtomCb/${mofAtomCb[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    sed -i "s/mofAtomCc/${mofAtomCc[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    sed -i "s/mofAtomCd/${mofAtomCd[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    sed -i "s/mofAtomH/${mofAtomH[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    sed -i "s/mofAtomOa/${mofAtomOa[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    sed -i "s/mofAtomOb/${mofAtomOb[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    sed -i "s/mofAtomOc/${mofAtomOc[1]}/g" ${metal}MOF74-Pressure${pressure}.in.settings
    sed -i "s/mofAtoms/${mofAtoms}/g" ${metal}MOF74-Pressure${pressure}.in
    # set temperature and, fixstyle, and name of data file
    sed -i "s/TEMP/${temp}/g" ${metal}MOF74-Pressure${pressure}.in
    sed -i "s/FIXSTYLE/${fixstyle}/g" ${metal}MOF74-Pressure${pressure}.in
    sed -i "s/system.data/${metal}MOF74-Pressure${pressure}.data/g" ${metal}MOF74-Pressure${pressure}.in
    sed -i "s/system.in.settings/${metal}MOF74-Pressure${pressure}.in.settings/g" ${metal}MOF74-Pressure${pressure}.in
    # delete unnecessary force field parameters and insert force field parameters into *.in file in place of FORCEFIELDPARAMS
    sed -i '/guestAtom/d' ${metal}MOF74-Pressure${pressure}.in.settings
    cat ${metal}MOF74-Pressure${pressure}.in.settings | while read line;
    do
      lineArr=($line)
      if [ ${lineArr[0]} = "pair_coeff" ]; then
        echo "${lineArr[0]}         $(echo "${lineArr[1]} ${lineArr[2]}" | tr " " "\n" | sort -g | tr "\n" " " )${lineArr[3]} ${lineArr[4]} ${lineArr[5]} ${lineArr[6]}" >> ${metal}MOF74-Pressure${pressure}.in.settings.tmp
      else echo "$line" >> ${metal}MOF74-Pressure${pressure}.in.settings.tmp
      fi 
    done
    mv ${metal}MOF74-Pressure${pressure}.in.settings.tmp ${metal}MOF74-Pressure${pressure}.in.settings
  done
done
