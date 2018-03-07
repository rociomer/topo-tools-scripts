#!/bin/bash

for i in */*/*.in
do 
  sed -i '69d' ${i}
  sed -i '69d' ${i}
  sed -i '70ifix_modify         3 temp allTemp' ${i}
  sed -i '70ifix                3 GUEST rigid/nvt molecule temp 298.0 298.0 100.0' ${i}
done
