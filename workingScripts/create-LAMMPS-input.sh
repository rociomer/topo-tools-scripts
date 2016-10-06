#!/bin/bash

guest="CH4"
if [ $guest = "CH4" ]; then
  atomsPerGuest=1
elif [ $guest = "CO2" ]; then
  atomsPerGuest=3
elif [ $guest = "H2O" ]; then
  atomsPerGuest=4
fi
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
    mv system.data ${metal}MOF74-Pressure${pressure}.data
    cp template.in ${metal}MOF74-Pressure${pressure}.in
    if [ $guest = "CH4" ]; then
      guestMoleculeAtom1=($(grep " CH4" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestMoleculeAtoms=$(echo "$guestMoleculeAtom1[1]") 
    elif [ $guest = "CO2" ]; then
      guestMoleculeAtom1=($(grep " Cg" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestMoleculeAtom2=($(grep " Og" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestMoleculeAtoms=$(echo "$guestMoleculeAtom1[1] $guestMoleculeAtom2[1]") 
    elif [ $guest = "H2O" ]; then
      guestMoleculeAtom1=($(grep " Hw" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestMoleculeAtom2=($(grep " M" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestMoleculeAtom3=($(grep " Ow" ${metal}MOF74-Pressure${pressure}.data | head -1))
      guestMoleculeAtoms=$(echo "$guestMoleculeAtom1[1] $guestMoleculeAtom2[1] $guestMoleculeAtom3[1]") 
    fi
    sed -i "s/GUESTMOLECULEATOMS/${guestMoleculeAtoms}/g" ${metal}MOF740-Pressure${pressure}.in
      mofAtom1=($(grep " ${metal}" ${metal}MOF74-Pressure${pressure}.data | head -1))
      mofAtom2=($(grep " Ca" ${metal}MOF74-Pressure${pressure}.data | head -1))
      mofAtom3=($(grep " Cb" ${metal}MOF74-Pressure${pressure}.data | head -1))
      mofAtom3=($(grep " Cc" ${metal}MOF74-Pressure${pressure}.data | head -1))
      mofAtom4=($(grep " Cd" ${metal}MOF74-Pressure${pressure}.data | head -1))
      mofAtom5=($(grep " H" ${metal}MOF74-Pressure${pressure}.data | head -1))
      mofAtom6=($(grep " Oa" ${metal}MOF74-Pressure${pressure}.data | head -1))
      mofAtom7=($(grep " Ob" ${metal}MOF74-Pressure${pressure}.data | head -1))
      mofAtom8=($(grep " Oc" ${metal}MOF74-Pressure${pressure}.data | head -1))
      mofAtoms=$(echo "$mofAtom1[1] $mofAtom2[1] $mofAtom3[1] $mofAtom4[1] $mofAtom5[1] $mofAtom6[1] $mofAtom7[1] $mofAtom8[1]") 
    sed -i "s/MOFATOMS/${mofAtoms}/g" ${metal}MOF740-Pressure${pressure}.in
  done
done
