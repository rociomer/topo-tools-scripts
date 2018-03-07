#!/bin/bash

for i in 10000 50000 100000 200000 300000 400000 500000 1000000 2000000 3000000 4000000 5000000 10000000
do
  cd Pressure${i}/
  cp ../Pressure10000/NiMOF74-Pressure10000.in.settings NiMOF74-Pressure${i}.in.settings
  cd ../
done
