# topo-tools

### Description
Scripts for generating LAMMPS input (topology files and run script) for 
simulations of methane and carbon dioxide in MOF-74 and MOF-274 using the
DFT-derived FF. 

The main script creates, for each set
of conditions specified, a .tcl script for putting a specific number of guest 
molecules in a simnulation box by reading isotherm data in *IsothermData-74/*.
This .tcl script is then run using vmd to generate .data, .in, and 
.in.settings files. It works by reading a *template.in* file, PDB structures 
for frameworks, XYZ structures for guest molecules, and force field parameters 
defined in *forceFieldParamsTemplates/*. A different force field template file 
is read if the molecule is charged or uncharged. Furthermore, the .in file 
generated will be different if the guest molecule is just a single atom or 
contains many atoms.

### Instructions
To generate LAMMPS input files for carbon dioxide adsorbed in MOF-74, run 
the script *create-LAMMPS-input-74-CO2.sh*. 
Define the "list" of pressures and metal frameworks that you want to create 
input files for at the top of *create-LAMMPS-input-74-CO2.sh*. 
This script will read the respective files from the *IsothermData-74/* directory 
(to know how many gas molecules to put in the simulation box), the 
*topoScripts/* directory (for the .tcl template scripts that it uses to 
generate the LAMMPS topology files), and the
*forceFieldParamsTemplates/* directory (for the DFT-FF parameters/charges). 

*template.in* is the file that serves as the template for all the LAMMPS input 
scripts, so any changes made here will then affect all the input files generated 
(this is a good place to change any fixes or dump commands, but note that it
contains many substrings that the *create-LAMMPS-input* scripts search and
replace).

The analogous scripts can be used to generate input files for simulations of
carbon dioxide adsorbed in MOF-274 frameworks, or for methane adsorbed in 
MOF-74.

### Author
Rocío Mercado

### Link
https://github.com/rociomer/topo-tools
