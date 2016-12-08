#!/bin/bash

for i in */Pressure*/
do 
  cd ${i}

  cp ../../msdScripts/create-InputMSD.sh .
  cp ../../msdScripts/input_template.msd .
  cp ../../msdScripts/plot-MSD.py .

  bash create-InputMSD.sh
  /home/rocio/Dropbox\ \(LSMO\)/Research/corrmsd/bin/corrfunc input.msd >> corrmsd-output
  python plot-MSD.py >> plot-MSD-output
 
  echo "Diffusion coefficients calculated for ${i}"   
 
  cd ../../
done

echo "Program complete."
