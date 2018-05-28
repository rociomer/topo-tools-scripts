#!/bin/bash

############################################################################### 
                         ### SET VARIABLES HERE ###                             
############################################################################### 
# adsorbate molecule to insert
guest="CH4"
# temperature, in Kelvin
temp="313.0"
# "list" of frameworks to create input files for
frameworksList="Mg Ni Zn"
# "list" of pressures to create input files for
pressureList="10000" # artificial
frameworkReplicasList="4 8 12 16 20 24 28 32" # min is 4 because of PBCs
############################################################################### 

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

# loop over all replicas of framework
for frameworkReplicas in $frameworkReplicasList; do
  # loop over all frameworks/pressures for which to create LAMMPS input
  frameworkReplicas=$((frameworkReplicas * 6)) # density of 1 molec per unit cell

  for metal in $frameworksList; do
    framework=$(echo "${metal}-MOF-74")
  
    for pressure in $pressureList; do
      # define toposcript file
      toposcript="toposcript-${metal}MOF74-Pressure${pressure}-x${frameworkReplicas}.tcl"
  
      # create .tcl topos script
      if [ $guest = "CH4" ]; then
        cp topoScripts/toposcript-${metal}MOF74-uncharged-long.tcl ${toposcript}
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
      #   in supercell to keep the density the same as 1 molec per 4 uc
      if [ $metal = "Mg" ]; then
        replicasGuest=$(echo "($frameworkReplicas)/4" | bc )
      elif [ $metal = "Ni" ]; then
        replicasGuest=$(echo "($frameworkReplicas)/4" | bc )
      elif [ $metal = "Zn" ]; then
        replicasGuest=$(echo "($frameworkReplicas)/2" | bc )
      fi
     
  
      echo "Replicas of guest per supercell at this pressure: $replicasGuest"
  
      # replace key substrings in template tcl script with
      #    important parameters
      sed -i "s/GUESTFILE/${guest}.xyz/g" ${toposcript}
      sed -i "s/ATOMSPERGUEST/${atomsPerGuest}/g" ${toposcript}
      sed -i "s/REPLICASZDIRECTION/${frameworkReplicas}/g" ${toposcript}
      sed -i "s/REPLICASGUEST/${replicasGuest}/g" ${toposcript}
  
      # run .tcl script using vmd to generate .data file
      vmd -dispdev text -e ${toposcript}
  
      # define filenames
      dataFile="${metal}MOF74-Pressure${pressure}-x${frameworkReplicas}.data"
      inFile="${metal}MOF74-Pressure${pressure}-x${frameworkReplicas}.in"
      settingsFile="${metal}MOF74-Pressure${pressure}-x${frameworkReplicas}.in.settings"
  
      # rename .data file
      mv system.data ${dataFile}
  
      # add bonds for CO2 and H2O in .data file
      if [ $guest = "CH4" ]; then
        :
      elif [ $guest = "CO2" ]; then
        echo " Bonds" >> ${dataFile}
        echo " " >> ${dataFile}
  
        count=1 # dummy count
  
        for bondNumber in $(seq 1 $replicasGuest); do
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
        sed -i "s/0 bonds/$twiceBondNumber bonds/" \${dataFile}
        sed -i "s/0 bond types/1 bond types/" ${dataFile}
  
        # add the correct bond coefficients
        echo " " >> ${dataFile}
        echo " Bond Coeffs" >> ${dataFile}
        echo " " >> ${dataFile}
        echo "1 351.487 1.44" >> ${dataFile}
  
      elif [ $guest = "H2O" ]; then
        :
      fi

      # replace the coordinates for the guest atoms to be spread out throughout the pores
      #  (at least one in each pore)
      if [ $metal = "Mg" ]; then
        cycles=$(echo "($frameworkReplicas)/ (4 * 6)" | bc )
        for number in $(seq 1 $cycles); do 
          sed -i "s/$((1 + (number - 1)*6)) $((1 + (number - 1)*6)) 1 0.000000.*/$((1 + (number - 1)*6)) $((1 + (number - 1)*6)) 1 0.000000 2.0 44.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((2 + (number - 1)*6)) $((2 + (number - 1)*6)) 1 0.000000.*/$((2 + (number - 1)*6)) $((2 + (number - 1)*6)) 1 0.000000 2.0 30.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((3 + (number - 1)*6)) $((3 + (number - 1)*6)) 1 0.000000.*/$((3 + (number - 1)*6)) $((3 + (number - 1)*6)) 1 0.000000 2.0 15.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((4 + (number - 1)*6)) $((4 + (number - 1)*6)) 1 0.000000.*/$((4 + (number - 1)*6)) $((4 + (number - 1)*6)) 1 0.000000 13.0 37.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((5 + (number - 1)*6)) $((5 + (number - 1)*6)) 1 0.000000.*/$((5 + (number - 1)*6)) $((5 + (number - 1)*6)) 1 0.000000 13.0 22.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((6 + (number - 1)*6)) $((6 + (number - 1)*6)) 1 0.000000.*/$((6 + (number - 1)*6)) $((6 + (number - 1)*6)) 1 0.000000 13.0 7.0 ${number}.0 # CH4/" ${dataFile}
        done
      elif [ $metal = "Ni" ]; then
        cycles=$(echo "($frameworkReplicas)/ (4 * 6)" | bc )
        for number in $(seq 1 $cycles); do 
          sed -i "s/$((1 + (number - 1)*6)) $((1 + (number - 1)*6)) 1 0.000000.*/$((1 + (number - 1)*6)) $((1 + (number - 1)*6)) 1 0.000000 2.0 44.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((2 + (number - 1)*6)) $((2 + (number - 1)*6)) 1 0.000000.*/$((2 + (number - 1)*6)) $((2 + (number - 1)*6)) 1 0.000000 2.0 30.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((3 + (number - 1)*6)) $((3 + (number - 1)*6)) 1 0.000000.*/$((3 + (number - 1)*6)) $((3 + (number - 1)*6)) 1 0.000000 2.0 15.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((4 + (number - 1)*6)) $((4 + (number - 1)*6)) 1 0.000000.*/$((4 + (number - 1)*6)) $((4 + (number - 1)*6)) 1 0.000000 13.0 37.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((5 + (number - 1)*6)) $((5 + (number - 1)*6)) 1 0.000000.*/$((5 + (number - 1)*6)) $((5 + (number - 1)*6)) 1 0.000000 13.0 22.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((6 + (number - 1)*6)) $((6 + (number - 1)*6)) 1 0.000000.*/$((6 + (number - 1)*6)) $((6 + (number - 1)*6)) 1 0.000000 13.0 7.0 ${number}.0 # CH4/" ${dataFile}
        done
      elif [ $metal = "Zn" ]; then
        cycles=$(echo "($frameworkReplicas)/ (2 * 12)" | bc )
        for number in $(seq 1 $cycles); do 
          sed -i "s/$((1 + (number - 1)*12)) $((1 + (number - 1)*12)) 1 0.000000.*/$((1 + (number - 1)*12)) $((1 + (number - 1)*12)) 1 0.000000 2.0 44.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((2 + (number - 1)*12)) $((2 + (number - 1)*12)) 1 0.000000.*/$((2 + (number - 1)*12)) $((2 + (number - 1)*12)) 1 0.000000 2.0 30.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((3 + (number - 1)*12)) $((3 + (number - 1)*12)) 1 0.000000.*/$((3 + (number - 1)*12)) $((3 + (number - 1)*12)) 1 0.000000 2.0 15.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((4 + (number - 1)*12)) $((4 + (number - 1)*12)) 1 0.000000.*/$((4 + (number - 1)*12)) $((4 + (number - 1)*12)) 1 0.000000 12.0 37.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((5 + (number - 1)*12)) $((5 + (number - 1)*12)) 1 0.000000.*/$((5 + (number - 1)*12)) $((5 + (number - 1)*12)) 1 0.000000 12.0 22.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((6 + (number - 1)*12)) $((6 + (number - 1)*12)) 1 0.000000.*/$((6 + (number - 1)*12)) $((6 + (number - 1)*12)) 1 0.000000 12.0 7.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((7 + (number - 1)*12)) $((7 + (number - 1)*12)) 1 0.000000.*/$((7 + (number - 1)*12)) $((7 + (number - 1)*12)) 1 0.000000 25.0 44.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((8 + (number - 1)*12)) $((8 + (number - 1)*12)) 1 0.000000.*/$((8 + (number - 1)*12)) $((8 + (number - 1)*12)) 1 0.000000 25.0 30.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((9 + (number - 1)*12)) $((9 + (number - 1)*12)) 1 0.000000.*/$((9 + (number - 1)*12)) $((9 + (number - 1)*12)) 1 0.000000 25.0 15.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((10 + (number - 1)*12)) $((10 + (number - 1)*12)) 1 0.000000.*/$((10 + (number - 1)*12)) $((10 + (number - 1)*12)) 1 0.000000 38.0 37.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((11 + (number - 1)*12)) $((11 + (number - 1)*12)) 1 0.000000.*/$((11 + (number - 1)*12)) $((11 + (number - 1)*12)) 1 0.000000 38.0 22.0 ${number}.0 # CH4/" ${dataFile}
          sed -i "s/$((12 + (number - 1)*12)) $((12 + (number - 1)*12)) 1 0.000000.*/$((12 + (number - 1)*12)) $((12 + (number - 1)*12)) 1 0.000000 38.0 7.0 ${number}.0 # CH4/" ${dataFile}
        done
      fi
      # prepare .in file
      cp template-long.in ${inFile}
  
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

      # if single gas atom in framework, comment out "velocity" command
      if [ $frameworkReplicas = "4" ]; then
        sed -i "s/velocity/#velocity/g" ${inFile}
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
      cat ${settingsFile} | while read line; do
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
done

# clean up the working directory by moving all the created input 
#   to its own directory
mkdir MOF-74-CH4-input-files/
mv *Pressure* MOF-74-CH4-input-files/
echo "Done! Input files can be found in MOF-74-CH4-input-files/"
