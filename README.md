# topo-tools

### Description
Scripts for generating LAMMPS input (topology files and run script) for 
simulations of methane and carbon dioxide in MOF-74 and MOF-274 using the
DFT-derived FF.

### Instructions
To generate LAMMPS input files for CO2/CH4 adsorbed in MOF-74, run 
the script *create-LAMMPS-input-74-CO2.sh*.

Set the "list" of pressures and metal frameworks you want to create input 
files for at the top of *create-LAMMPS-input-74-CO2.sh*. This script will read 
everything from the *IsothermData-74/* directory 
(to know how many gas molecules to put in the simulation box), *topoScripts/* 
for the .tcl scripts that it uses to generate the LAMMPS topology files, and
*forceFieldParamsTemplates/* for the force field DFT-FF parameters/charges. 

*template.in* is the file that serves as the template for all the LAMMPS input 
scripts, so any changes made here will then affect all the input files generated 
(this is a good place to change any fixes or dump commands).

The analogous scripts can be used to generate input files for simulations in 
MOF-274 frameworks.

### Author
Rocío Mercado
