#!/bin/bash

guest="CO2"
temp="298.0"
metalFrameworksList="Mg Ni Zn"
pressureList="1000 2500 5000 7500 10000 25000 50000 75000 100000 250000 500000 750000 1000000 2500000 5000000 7500000 10000000"

tempInt=${temp%.*}

if [ $guest = "CH4" ]; then
  atomsPerGuest=1
  fixstyle="nvt"
elif [ $guest = "CO2" ]; then
  atomsPerGuest=3
  fixstyle="rigid\/nvt molecule"
elif [ $guest = "H2O" ]; then
  atomsPerGuest=4
  fixstyle="rigid\/nvt molecule"
fi
for metal in $metalFrameworksList
#for metal in Mg Ni Zn
do
  framework=$(echo "${metal}-MOF-274")
  echo "Framework: $framework"
  for pressure in $pressureList  #for pressure in $(seq 50000 50000 500000)
  do
    # create .tcl topos script
    if [ $guest = "CH4" ]; then
      cp topoScripts/toposcript-${metal}MOF274-uncharged.tcl toposcript-${metal}MOF274-Pressure${pressure}.tcl
      cp topoScripts/toposcript-assign-molecules.py .
    elif [ $guest = "CO2" ]; then
      cp topoScripts/toposcript-${metal}MOF274-charged.tcl toposcript-${metal}MOF274-Pressure${pressure}.tcl
      cp topoScripts/toposcript-assign-molecules.py .
    elif [ $guest = "H2O" ]; then
      cp topoScripts/toposcript-${metal}MOF274-charged.tcl toposcript-${metal}MOF274-Pressure${pressure}.tcl
      cp topoScripts/toposcript-assign-molecules.py .
    fi
    # find the molecules/uc at a particular pressure (read GCMC output)
    echo "Pressure: $pressure"
    uptake=($(awk '$1 == "'"$pressure"'"' IsothermData-274/${metal}_${guest}_${tempInt}_absolute.txt))
    echo "Uptake in molec/UC: ${uptake[1]}"
    replicasGuest=$(echo "(${uptake[1]} * 4)/1" | bc )
    echo "Replicas of guest per supercell at this pressure: $replicasGuest"
    # replace important parameters in the topos script
    sed -i "s/GUESTFILE/${guest}.xyz/g" toposcript-${metal}MOF274-Pressure${pressure}.tcl
    sed -i "s/ATOMSPERGUEST/${atomsPerGuest}/g" toposcript-${metal}MOF274-Pressure${pressure}.tcl
    sed -i "s/REPLICASGUEST/${replicasGuest}/g" toposcript-${metal}MOF274-Pressure${pressure}.tcl
    vmd -dispdev text -e toposcript-${metal}MOF274-Pressure${pressure}.tcl
    # rename data file
    mv system.data ${metal}MOF274-Pressure${pressure}.data
    # add bonds for CO2 and H2O
    if [ $guest = "CH4" ]; then
      :
    elif [ $guest = "CO2" ]; then
        echo " Bonds" >> ${metal}MOF274-Pressure${pressure}.data
        echo " " >> ${metal}MOF274-Pressure${pressure}.data
        count=1
        for bondNumber in $(seq 1 $replicasGuest)
        do
          if [ $bondNumber -eq 1 ]; then
            echo "$count 1 1 2" >> ${metal}MOF274-Pressure${pressure}.data
            count=$(echo "$count + 1" | bc -l)
            echo "$count 1 2 3" >> ${metal}MOF274-Pressure${pressure}.data
            count=$(echo "$count + 1" | bc -l)
          elif [ $bondNumber -gt 1 ]; then
            echo "$count 1 $(echo "1 + 3 * ($bondNumber - 1)" | bc -l) $(echo "2 + 3 * ($bondNumber - 1)" | bc -l)" >> ${metal}MOF274-Pressure${pressure}.data
            count=$(echo "$count + 1" | bc -l)
            echo "$count 1 $(echo "2 + 3 * ($bondNumber - 1)" | bc -l) $(echo "3 + 3 * ($bondNumber - 1)" | bc -l)" >> ${metal}MOF274-Pressure${pressure}.data
            count=$(echo "$count + 1" | bc -l)
          fi
        done
        twiceBondNumber=$(echo "$bondNumber * 2" | bc -l)
        sed -i "s/0 bonds/$twiceBondNumber bonds/" ${metal}MOF274-Pressure${pressure}.data
        sed -i "s/0 bond types/1 bond types/" ${metal}MOF274-Pressure${pressure}.data
        echo " " >> ${metal}MOF274-Pressure${pressure}.data
        echo " Bond Coeffs" >> ${metal}MOF274-Pressure${pressure}.data
        echo " " >> ${metal}MOF274-Pressure${pressure}.data
        echo "1 351.487 1.44" >> ${metal}MOF274-Pressure${pressure}.data
    elif [ $guest = "H2O" ]; then
      :
    fi
    # prepare in file
    cp template.in ${metal}MOF274-Pressure${pressure}.in
    # create force fields parameter files
    if [ $guest = "CH4" ]; then
      cp forceFieldParamsTemplates/forceFieldParams-${metal}MOF274-uncharged-template ${metal}MOF274-Pressure${pressure}.in.settings
      sed -i "s/kspace_style       ewald 1.0e-6/#kspace_style       ewald 1.0e-6/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/fix                5/#fix                5/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/bond_style/#bond_style/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/bond_coeff/#bond_coeff/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/comm_modify/#comm_modify/g" ${metal}MOF274-Pressure${pressure}.in
    elif [ $guest = "CO2" ]; then
      cp forceFieldParamsTemplates/forceFieldParams-${metal}MOF274-charged-template ${metal}MOF274-Pressure${pressure}.in.settings
      #sed -i "s/compute            ChunkGuest/#compute            ChunkGuest/g" ${metal}MOF274-Pressure${pressure}.in
      #sed -i "s/compute            comChunkGuest/#compute            comChunkGuest/g" ${metal}MOF274-Pressure${pressure}.in
      #sed -i "s/fix                3/#fix                3/g" ${metal}MOF274-Pressure${pressure}.in
      #sed -i "s/fix                4/#fix                4/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/#fix                3/fix                3/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/#fix_modify         3/fix_modify         3/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/dump               3/#dump               3/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/dump_modify        3/#dump_modify        3/g" ${metal}MOF274-Pressure${pressure}.in
    elif [ $guest = "H2O" ]; then
      cp forceFieldParamsTemplates/forceFieldParams-${metal}MOF274-charged-template ${metal}MOF274-Pressure${pressure}.in.settings
      #sed -i "s/compute            ChunkGuest/#compute            ChunkGuest/g" ${metal}MOF274-Pressure${pressure}.in
      #sed -i "s/compute            comChunkGuest/#compute            comChunkGuest/g" ${metal}MOF274-Pressure${pressure}.in
      #sed -i "s/fix                3/#fix                3/g" ${metal}MOF274-Pressure${pressure}.in
      #sed -i "s/fix                4/#fix                4/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/dump               3/#dump               3/g" ${metal}MOF274-Pressure${pressure}.in
      sed -i "s/dump_modify        3/#dump_modify        3/g" ${metal}MOF274-Pressure${pressure}.in
    fi
    # set guest atoms
    if [ $guest = "CH4" ]; then
      guestAtomCH4=($(grep "\s\sCH4" ${metal}MOF274-Pressure${pressure}.data | head -1))
      guestAtoms=$(echo "${guestAtomCH4[1]}") 
      sed -i "s/guestAtomCH4/${guestAtomCH4[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    elif [ $guest = "CO2" ]; then
      guestAtomCg=($(grep "\s\sCg" ${metal}MOF274-Pressure${pressure}.data | head -1))
      guestAtomOg=($(grep "\s\sOg" ${metal}MOF274-Pressure${pressure}.data | head -1))
      guestAtoms=$(echo "${guestAtomCg[1]} ${guestAtomOg[1]}") 
      sed -i "s/guestAtomCg/${guestAtomCg[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
      sed -i "s/guestAtomOg/${guestAtomOg[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    elif [ $guest = "H2O" ]; then
      guestAtomHw=($(grep "\s\sHw" ${metal}MOF274-Pressure${pressure}.data | head -1))
      guestAtomM=($(grep "\s\sMw" ${metal}MOF274-Pressure${pressure}.data | head -1))
      guestAtomOw=($(grep "\s\sOw" ${metal}MOF274-Pressure${pressure}.data | head -1))
      guestAtoms=$(echo "${guestAtomHw[1]} ${guestAtomM[1]} ${guestAtomOw[1]}") 
      sed -i "s/guestAtomHw/${guestAtomHw[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
      sed -i "s/guestAtomMw/${guestAtomMw[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
      sed -i "s/guestAtomOw/${guestAtomOw[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    fi
    sed -i "s/guestAtoms/${guestAtoms}/g" ${metal}MOF274-Pressure${pressure}.in
    # set framework atoms  
    mofAtomM=($(grep "\s\s${metal}" ${metal}MOF274-Pressure${pressure}.data | head -1))
    mofAtomCa=($(grep "\s\sCa" ${metal}MOF274-Pressure${pressure}.data | head -1))
    mofAtomCb=($(grep "\s\sCb" ${metal}MOF274-Pressure${pressure}.data | head -1))
    mofAtomCc=($(grep "\s\sCc" ${metal}MOF274-Pressure${pressure}.data | head -1))
    mofAtomCd=($(grep "\s\sCd" ${metal}MOF274-Pressure${pressure}.data | head -1))
    mofAtomH=($(grep "\s\sH" ${metal}MOF274-Pressure${pressure}.data | head -1))
    mofAtomOa=($(grep "\s\sOa" ${metal}MOF274-Pressure${pressure}.data | head -1))
    mofAtomOb=($(grep "\s\sOb" ${metal}MOF274-Pressure${pressure}.data | head -1))
    mofAtomOc=($(grep "\s\sOc" ${metal}MOF274-Pressure${pressure}.data | head -1))
    mofAtoms=$(echo "${mofAtomM[1]} ${mofAtomCa[1]} ${mofAtomCb[1]} ${mofAtomCc[1]} ${mofAtomCd[1]} ${mofAtomH[1]} ${mofAtomOa[1]} ${mofAtomOb[1]} ${mofAtomOc[1]}" | tr " " "\n" | sort -g | tr "\n" " " )
    guestAndMofAtoms=$(echo "$guestAtoms ${mofAtomM[1]} ${mofAtomCa[1]} ${mofAtomCb[1]} ${mofAtomCc[1]} ${mofAtomCd[1]} ${mofAtomH[1]} ${mofAtomOa[1]} ${mofAtomOb[1]} ${mofAtomOc[1]}" | tr " " "\n" | sort -g | tr "\n" " " )
    sed -i "s/mofAtom${metal}/${mofAtomM[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    sed -i "s/mofAtomCa/${mofAtomCa[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    sed -i "s/mofAtomCb/${mofAtomCb[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    sed -i "s/mofAtomCc/${mofAtomCc[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    sed -i "s/mofAtomCd/${mofAtomCd[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    sed -i "s/mofAtomH/${mofAtomH[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    sed -i "s/mofAtomOa/${mofAtomOa[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    sed -i "s/mofAtomOb/${mofAtomOb[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    sed -i "s/mofAtomOc/${mofAtomOc[1]}/g" ${metal}MOF274-Pressure${pressure}.in.settings
    sed -i "s/mofAtoms/${mofAtoms}/g" ${metal}MOF274-Pressure${pressure}.in
    sed -i "s/guestAndMofAtoms/${guestAndMofAtoms}/g" ${metal}MOF274-Pressure${pressure}.in
    # set temperature and, fixstyle, and name of data file
    sed -i "s/TEMP/${temp}/g" ${metal}MOF274-Pressure${pressure}.in
    sed -i "s/FIXSTYLE/${fixstyle}/g" ${metal}MOF274-Pressure${pressure}.in
    sed -i "s/system.data/${metal}MOF274-Pressure${pressure}.data/g" ${metal}MOF274-Pressure${pressure}.in
    sed -i "s/system.in.settings/${metal}MOF274-Pressure${pressure}.in.settings/g" ${metal}MOF274-Pressure${pressure}.in
    # delete unnecessary force field parameters and insert force field parameters into *.in file in place of FORCEFIELDPARAMS
    sed -i '/guestAtom/d' ${metal}MOF274-Pressure${pressure}.in.settings
    cat ${metal}MOF274-Pressure${pressure}.in.settings | while read line;
    do
      lineArr=($line)
      if [ ${lineArr[0]} = "pair_coeff" ]; then
        echo "${lineArr[0]}         $(echo "${lineArr[1]} ${lineArr[2]}" | tr " " "\n" | sort -g | tr "\n" " " )${lineArr[3]} ${lineArr[4]} ${lineArr[5]} ${lineArr[6]}" >> ${metal}MOF274-Pressure${pressure}.in.settings.tmp
      else echo "$line" >> ${metal}MOF274-Pressure${pressure}.in.settings.tmp
      fi 
    done
    mv ${metal}MOF274-Pressure${pressure}.in.settings.tmp ${metal}MOF274-Pressure${pressure}.in.settings
  done
done
