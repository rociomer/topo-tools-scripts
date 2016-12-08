#!/bin/bash

for i in Mg Zn Ni
do
  scp -r rocio@clean.cchem.berkeley.edu:~/diffusion/${i}-MOF-74-CH4-313K/ .
done

for i in *K/Pressure*/
do 
  cd ${i}

  echo "Changing into ${i}"

  cp ../../msdScripts/create-InputMSD.sh .
  cp ../../msdScripts/input_template.msd .
  cp ../../msdScripts/plot-MSD.py .

  bash create-InputMSD.sh
  /home/rocio/Dropbox\ \(LSMO\)/Research/corrmsd/bin/corrfunc input.msd >> corrmsd-output
  python plot-MSD.py >> plot-MSD-output
 
  echo "Diffusion coefficients calculated for ${i}"   
 
  cd ../../
done

for i in *K/Pressure*/
do 
  diffCoeff=$(grep "Diffusion coefficient:" ${i}plot-MSD-output)
  echo "For structure ${i%/Pressure*}:"
  echo "For pressure ${i#*313K/}, the ${diffCoeff}"
done

echo "Program complete."
