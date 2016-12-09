#!/bin/bash

for i in *K/Pressure*/
do 
  cd ${i}

  echo "-------------------------Changing into ${i}----------------------------"

  cat corrmsd-output
  cat plot-MSD-output
 
  cd ../../
done

echo "Plotting..."

rm *-results.txt *-results.tmp*

for i in *K/Pressure*/
do 
  diffCoeffArr=($(grep "Diffusion coefficient:" ${i}plot-MSD-output))
  diffCoeff=${diffCoeffArr[2]}
  pressureTmp=${i#*313K/Pressure}
  pressure=${pressureTmp%/}
  echo "$pressure ${diffCoeff}" >> ${i%/Pressure*}-results.tmp1
done

for i in *K/
do 
  cat ${i%/}-results.tmp1 | while read line;
  do
    lineArr=(${line})
    if [ -z "${lineArr[1]}" ];then
      :
    else echo "${line}" >> ${i%/}-results.tmp2
    fi
  done
  sort -n ${i%/}-results.tmp2 >> ${i%/}-results.sorted
  echo "pressure_(Pa) diffusion_coefficient_(A2_per_ps)" >> ${i%/}-results.txt
  cat ${i%/}-results.sorted >> ${i%/}-results.txt
done

rm *-results.tmp* *-results.sorted

python plot-diffusionCoefficients.py

echo "Program complete."
