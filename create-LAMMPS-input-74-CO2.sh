#!/bin/bash

##### SET VARIABLES HERE #####
# adsorbate molecule to insert
guest="CO2"
# temperature, in Kelvin
temp="298.0"
# "list" of frameworks to create input files for
frameworksList="Mg Ni Zn"
# "list" of pressures to create input files for
pressureList="1000 2500 5000 7500 10000 25000 \
50000 75000 100000 250000 500000 750000 1000000 \
2500000 5000000 7500000 10000000"
##############################

tempInt=${temp%.*} # integer value of temperature

# define fix style for type of molecule and number of atoms in adsorbate
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

# loop over all frameworks/pressures for which to create LAMMPS input
for metal in $frameworksList
do
  framework=$(echo "${metal}-MOF-74")

  echo "Framework: $framework"

  for pressure in $pressureList 
  do
    # define toposcript file
    toposcript="toposcript-${metal}MOF74-Pressure${pressure}.tcl"

    # create .tcl topos script
    if [ $guest = "CH4" ]; then
      cp topoScripts/toposcript-${metal}MOF74-uncharged.tcl ${toposcript}
      cp topoScripts/toposcript-assign-molecules.py .
    elif [ $guest = "CO2" ]; then
      cp topoScripts/toposcript-${metal}MOF74-charged.tcl ${toposcript}
      cp topoScripts/toposcript-assign-molecules.py .
    elif [ $guest = "H2O" ]; then
      cp topoScripts/toposcript-${metal}MOF74-charged.tcl ${toposcript}
      cp topoScripts/toposcript-assign-molecules.py .
    fi

    # find the number of molecules per unit cell at a particular pressure 
    #   (that is, read GCMC output)
    echo "Pressure: $pressure"

    uptake=($(awk '$1 == "'"$pressure"'"' \
isothermData-74/${metal}_${guest}_${tempInt}_absolute.txt))

    echo "Uptake in molec/UC: ${uptake[1]}"

    # replicate the number of guests based on the number of unit cells 
    #   in supercell
    replicasGuest=$(echo "(${uptake[1]} * 4)/1" | bc )

    echo "Replicas of guest per supercell at this pressure: $replicasGuest"

    # replace key substrings in template .tcl script with
    #    important parameters
    sed -i "s/GUESTFILE/${guest}.xyz/g" ${toposcript}
    sed -i "s/ATOMSPERGUEST/${atomsPerGuest}/g" ${toposcript}
    sed -i "s/REPLICASGUEST/${replicasGuest}/g" ${toposcript}

    # run .tcl script using vmd to generate .data file
    vmd -dispdev text -e ${toposcript}

    # define filenames
    dataFile="${metal}MOF74-Pressure${pressure}.data"
    inFile="${metal}MOF74-Pressure${pressure}.in"
    settingsFile="${metal}MOF74-Pressure${pressure}.in.settings"

    # rename .data file
    mv system.data ${dataFile}

    # add bonds for CO2 and H2O in .data file
    if [ $guest = "CH4" ]; then
      :
    elif [ $guest = "CO2" ]; then
      echo " Bonds" >> ${dataFile}
      echo " " >> ${dataFile}

      count=1 # dummy count

      for bondNumber in $(seq 1 $replicasGuest)
      do
        if [ $bondNumber -eq 1 ]; then
          echo "$count 1 1 2" >> ${dataFile}
          count=$(echo "$count + 1" | bc -l) # increase dummy count

          echo "$count 1 2 3" >> ${dataFile}
          count=$(echo "$count + 1" | bc -l) # increase dummy count

        elif [ $bondNumber -gt 1 ]; then
          echo "$count 1 $(echo "1 + 3 * ($bondNumber - 1)" | bc -l) \
$(echo "2 + 3 * ($bondNumber - 1)" | bc -l)" \
>> ${dataFile}

          count=$(echo "$count + 1" | bc -l) # increase dummy count

          echo "$count 1 $(echo "2 + 3 * ($bondNumber - 1)" | bc -l) \
$(echo "3 + 3 * ($bondNumber - 1)" | bc -l)" \
>> ${dataFile}

          count=$(echo "$count + 1" | bc -l) # increase dummy count
        fi
      done

      twiceBondNumber=$(echo "$bondNumber * 2" | bc -l)

      # replace substrings in .data file with correct number of bonds
      # corresponding to each guest
      sed -i "s/0 bonds/$twiceBondNumber bonds/" ${dataFile}
      sed -i "s/0 bond types/1 bond types/" ${dataFile}

      # add the correct bond coefficients
      echo " " >> ${dataFile}
      echo " Bond Coeffs" >> ${dataFile}
      echo " " >> ${dataFile}
      echo "1 351.487 1.44" >> ${dataFile}

    elif [ $guest = "H2O" ]; then
      :
    fi

    # prepare .in file
    cp template.in ${inFile}

    # create force fields parameter file (.in.settings file) and modify
    if [ $guest = "CH4" ]; then
      cp \
forceFieldParamsTemplates/forceFieldParams-${metal}MOF74-uncharged-template \
${settingsFile}
      sed -i "s/kspace_style       ewald 1.0e-6/#kspace_style       ewald 1.0e-6/g" ${inFile}
      sed -i "s/fix                5/#fix                5/g" ${inFile}
      sed -i "s/bond_style/#bond_style/g" ${inFile}
      sed -i "s/bond_coeff/#bond_coeff/g" ${inFile}
      sed -i "s/comm_modify/#comm_modify/g" ${inFile}
    elif [ $guest = "CO2" ]; then
      cp \
forceFieldParamsTemplates/forceFieldParams-${metal}MOF74-charged-template \
${settingsFile}
      #sed -i "s/compute            ChunkGuest/#compute            ChunkGuest/g" ${inFile}
      #sed -i "s/compute            comChunkGuest/#compute            comChunkGuest/g" ${inFile}
      #sed -i "s/fix                3/#fix                3/g" ${inFile}
      #sed -i "s/fix                4/#fix                4/g" ${inFile}
      sed -i "s/dump               3/#dump               3/g" ${inFile}
      sed -i "s/dump_modify        3/#dump_modify        3/g" ${inFile}
    elif [ $guest = "H2O" ]; then
      cp forceFieldParamsTemplates/forceFieldParams-${metal}MOF74-charged-template ${settingsFile}
      #sed -i "s/compute            ChunkGuest/#compute            ChunkGuest/g" ${inFile}
      #sed -i "s/compute            comChunkGuest/#compute            comChunkGuest/g" ${inFile}
      #sed -i "s/fix                3/#fix                3/g" ${inFile}
      #sed -i "s/fix                4/#fix                4/g" ${inFile}
      sed -i "s/dump               3/#dump               3/g" ${inFile}
      sed -i "s/dump_modify        3/#dump_modify        3/g" ${inFile}
    fi

    # set guest atoms
    if [ $guest = "CH4" ]; then
      guestAtomCH4=($(grep "\s\sCH4" ${dataFile} | head -1))
      guestAtoms=$(echo "${guestAtomCH4[1]}") 
      sed -i "s/guestAtomCH4/${guestAtomCH4[1]}/g" ${settingsFile}
    elif [ $guest = "CO2" ]; then
      guestAtomCg=($(grep "\s\sCg" ${dataFile} | head -1))
      guestAtomOg=($(grep "\s\sOg" ${dataFile} | head -1))
      guestAtoms=$(echo "${guestAtomCg[1]} ${guestAtomOg[1]}") 
      sed -i "s/guestAtomCg/${guestAtomCg[1]}/g" ${settingsFile}
      sed -i "s/guestAtomOg/${guestAtomOg[1]}/g" ${settingsFile}
    elif [ $guest = "H2O" ]; then
      guestAtomHw=($(grep "\s\sHw" ${dataFile} | head -1))
      guestAtomM=($(grep "\s\sMw" ${dataFile} | head -1))
      guestAtomOw=($(grep "\s\sOw" ${dataFile} | head -1))
      guestAtoms=$(echo "${guestAtomHw[1]} ${guestAtomM[1]} ${guestAtomOw[1]}") 
      sed -i "s/guestAtomHw/${guestAtomHw[1]}/g" ${settingsFile}
      sed -i "s/guestAtomMw/${guestAtomMw[1]}/g" ${settingsFile}
      sed -i "s/guestAtomOw/${guestAtomOw[1]}/g" ${settingsFile}
    fi
    sed -i "s/guestAtoms/${guestAtoms}/g" ${inFile}

    # set framework atoms  
    mofAtomM=($(grep "\s\s${metal}" ${dataFile} | head -1))
    mofAtomCa=($(grep "\s\sCa" ${dataFile} | head -1))
    mofAtomCb=($(grep "\s\sCb" ${dataFile} | head -1))
    mofAtomCc=($(grep "\s\sCc" ${dataFile} | head -1))
    mofAtomCd=($(grep "\s\sCd" ${dataFile} | head -1))
    mofAtomH=($(grep "\s\sH" ${dataFile} | head -1))
    mofAtomOa=($(grep "\s\sOa" ${dataFile} | head -1))
    mofAtomOb=($(grep "\s\sOb" ${dataFile} | head -1))
    mofAtomOc=($(grep "\s\sOc" ${dataFile} | head -1))

    mofAtoms=$(echo "${mofAtomM[1]} ${mofAtomCa[1]} ${mofAtomCb[1]} ${mofAtomCc[1]} ${mofAtomCd[1]} ${mofAtomH[1]} ${mofAtomOa[1]} ${mofAtomOb[1]} ${mofAtomOc[1]}" | \
tr " " "\n" | sort -g | tr "\n" " " )

    guestAndMofAtoms=$(echo "$guestAtoms ${mofAtomM[1]} ${mofAtomCa[1]} ${mofAtomCb[1]} ${mofAtomCc[1]} ${mofAtomCd[1]} ${mofAtomH[1]} ${mofAtomOa[1]} ${mofAtomOb[1]} ${mofAtomOc[1]}" | \
tr " " "\n" | sort -g | tr "\n" " " )

    sed -i "s/mofAtom${metal}/${mofAtomM[1]}/g" ${settingsFile}
    sed -i "s/mofAtomCa/${mofAtomCa[1]}/g" ${settingsFile}
    sed -i "s/mofAtomCb/${mofAtomCb[1]}/g" ${settingsFile}
    sed -i "s/mofAtomCc/${mofAtomCc[1]}/g" ${settingsFile}
    sed -i "s/mofAtomCd/${mofAtomCd[1]}/g" ${settingsFile}
    sed -i "s/mofAtomH/${mofAtomH[1]}/g" ${settingsFile}
    sed -i "s/mofAtomOa/${mofAtomOa[1]}/g" ${settingsFile}
    sed -i "s/mofAtomOb/${mofAtomOb[1]}/g" ${settingsFile}
    sed -i "s/mofAtomOc/${mofAtomOc[1]}/g" ${settingsFile}
    sed -i "s/mofAtoms/${mofAtoms}/g" ${inFile}
    sed -i "s/guestAndMofAtoms/${guestAndMofAtoms}/g" ${inFile}

    # set temperature and, fixstyle, and name of data file
    sed -i "s/TEMP/${temp}/g" ${inFile}
    sed -i "s/FIXSTYLE/${fixstyle}/g" ${inFile}
    sed -i "s/system.data/${dataFile}/g" ${inFile}
    sed -i "s/system.in.settings/${settingsFile}/g" ${inFile}

    # delete unnecessary force field parameters and insert force field 
    #   parameters into *.in file in place of FORCEFIELDPARAMS
    sed -i '/guestAtom/d' ${settingsFile}
    cat ${settingsFile} | while read line;
    do
      lineArr=($line)
      if [ ${lineArr[0]} = "pair_coeff" ]; then
        echo "${lineArr[0]}         $(echo "${lineArr[1]} ${lineArr[2]}" | \
tr " " "\n" | sort -g | \
tr "\n" " " )${lineArr[3]} ${lineArr[4]} ${lineArr[5]} ${lineArr[6]}" \
>> ${settingsFile}.tmp

      else echo "$line" >> ${settingsFile}.tmp

      fi 
    done

    mv ${settingsFile}.tmp ${settingsFile}

  done
done

# clean up the working directory by moving all the created input                
#   to its own directory                                                        
mkdir MOF-74-CO2-input-files/                                                   
mv *Pressure* MOF-74-CO2-input-files/                                           
echo "Done! Input files can be found in MOF-74-CO2-input-files/"
