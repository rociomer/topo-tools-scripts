#!/bin/bash

for i in Mg Ni; do for j in 1500000 2000000 2500000 3000000 3500000 4000000 4500000 5000000 10000000; do scp -r ${i}-MOF-74-CH4-313K/Pressure${j}/ rocio@pitzer.cchem.berkeley.edu:~/diffusion/${i}-MOF-74-CH4-313K/. ; done; done

#for i in Zn; do for j in 1500000 2000000 2500000 3000000 3500000 4000000 4500000 5000000 10000000; do scp -r ${i}-MOF-74-CH4-313K/Pressure${j}/ rocio@clean.cchem.berkeley.edu:~/diffusion/${i}-MOF-74-CH4-313K/. ; done; done
