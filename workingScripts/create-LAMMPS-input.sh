#!/bin/bash

guest="CH4"
temp="313"
if [ $guest = "CH4" ]; then
  atomsPerGuest=1
elif [ $guest = "CO2" ]; then
  atomsPerGuest=3
elif [ $guest = "H2O" ]; then
  atomsPerGuest=4
fi
for metal in Mg
#for metal in Mg Ni Zn
do
  framework=$(echo "${metal}-MOF-74")
  echo "Framework: $framework"
  for pressure in $(seq 50000 50000 500000)
  do
    echo "Pressure: $pressure"
    uptake=($(awk '$1 == "'"$pressure"'"' isotherms/${metal}_${guest}_313_absolute.txt))
    echo "Updake in molec/UC: ${uptake[1]}"
    replicasGuest=$(echo "(${uptake[1]} * 4)/1" | bc )
    echo "Replicas of guest per supercell at this pressure: $replicasGuest"
    cp lammps-toposcript-${metal}MOF74.tcl lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    sed -i "s/GUESTFILE/${guest}/g" lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    sed -i "s/ATOMSPERGUEST/${atomsPerGuest}/g" lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    sed -i "s/REPLICASGUEST/${replicasGuest}/g" lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    vmd -dispdev text -e lammps-toposcript-${metal}MOF74-Pressure${pressure}.tcl
    # rename data file
    mv system.data ${metal}MOF74-Pressure${pressure}.data
    # prepare in file
    cp template.in ${metal}MOF74-Pressure${pressure}.in
    # prepare force fields parameters
    cp forceFieldParams-MgMOF74-template ${metal}MOF74-Pressure${pressure}-template
    # set guest atoms
    if [ $guest = "CH4" ]; then
      guestAtomCH4=($(grep " CH4" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtoms=$(echo "$guestAtomCH4[1]") 
      sed -i "s/guestAtomCH4/${guestAtomCH4[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    elif [ $guest = "CO2" ]; then
      guestAtomCg=($(grep " Cg" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtomOg=($(grep " Og" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtoms=$(echo "$guestAtomCg[1] $guestAtomOg[1]") 
      sed -i "s/guestAtomCg/${guestAtomCg[1]}/g" ${metal}MOF74-Pressure${pressure}-template
      sed -i "s/guestAtomOg/${guestAtomOg[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    elif [ $guest = "H2O" ]; then
      guestAtomHw=($(grep " Hw" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtomM=($(grep " Mw" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtomOw=($(grep " Ow" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestAtoms=$(echo "$guestAtomHw[1] $guestAtomM[1] $guestAtomOw[1]") 
      sed -i "s/guestAtomHw/${guestAtomHw[1]}/g" ${metal}MOF74-Pressure${pressure}-template
      sed -i "s/guestAtomMw/${guestAtomMw[1]}/g" ${metal}MOF74-Pressure${pressure}-template
      sed -i "s/guestAtomOw/${guestAtomOw[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    fi
    sed -i "s/guestAtoms/${guestAtoms}/g" ${metal}MOF74-Pressure${pressure}.in
    # set framework atoms  
    mofAtomM=($(grep " ${metal}" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomCa=($(grep " Ca" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomCb=($(grep " Cb" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomCc=($(grep " Cc" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomCd=($(grep " Cd" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomH=($(grep " H" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomOa=($(grep " Oa" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomOb=($(grep " Ob" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtomOc=($(grep " Oc" ${metal}MOF74-Pressure${pressure}.data | head -1))
    mofAtoms=$(echo "$mofAtomM[1] $mofAtomCa[1] $mofAtomCb[1] $mofAtomCc[1] $mofAtomH[1] $mofAtomOa[1] $mofAtomOb[1] $mofAtomOc[1]") 
    sed -i "s/mofAtomM/${mofAtomM[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    sed -i "s/mofAtomCa/${mofAtomCa[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    sed -i "s/mofAtomCb/${mofAtomCb[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    sed -i "s/mofAtomCc/${mofAtomCc[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    sed -i "s/mofAtomCd/${mofAtomCd[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    sed -i "s/mofAtomH/${mofAtomH[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    sed -i "s/mofAtomOa/${mofAtomOa[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    sed -i "s/mofAtomOb/${mofAtomOb[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    sed -i "s/mofAtomOc/${mofAtomOc[1]}/g" ${metal}MOF74-Pressure${pressure}-template
    sed -i "s/mofAtoms/${mofAtoms}/g" ${metal}MOF74-Pressure${pressure}.in
    # set temperature
    sed -i "s/TEMP/${temp}/g" ${metal}MOF74-Pressure${pressure}.in
    sed -i '/guestAtom/d' ${metal}MOF74-Pressure${pressure}-template
    sed -i "/FORCEFIELDPARAMS/r ${metal}MOF74-Pressure${pressure}-template" ${metal}MOF74-Pressure${pressure}.in
    sed -i '/FORCEFIELDPARAMS/d' ${metal}MOF74-Pressure${pressure}.in
  done
done
