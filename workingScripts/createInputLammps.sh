#!/bin/bash

guest="CH4"
atomsPerGuest=4

for metal in Mg Ni Zn
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
    mv system.data ${metal}MOF740-Pressure${pressure}.data
    cp template.in ${metal}MOF740-Pressure${pressure}.in
  done
done
