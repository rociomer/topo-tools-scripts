#!/bin/bash

for i in Mg Ni Zn; do mkdir ${i}-MOF-274-CO2-298K; for j in 1000 2500 5000 7500 10000 25000 50000 75000 100000 250000 500000 750000 1000000 2500000 5000000 7500000 10000000; do mkdir ${i}-MOF-274-CO2-298K/Pressure${j}; mv ${i}*Pressure${j}.* ${i}-MOF-274-CO2-298K/Pressure${j}/.; done; done
