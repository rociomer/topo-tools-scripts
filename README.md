# topo-tools-scripts

### Description
This repo contains a collection of scripts for generating LAMMPS input (topology files and run scripts) for simulations of methane and carbon dioxide in MOF-74 and MOF-274 frameworks using the DFT-derived FF [Mercado et al. (2016)](https://doi.org/10.1021/acs.jpcc.6b03393). These scripts are related to MD simulations carried out for the following works: [Witherspoon et al. (2019)](https://doi.org/10.1021/acs.jpcc.9b01733) and [Forse et al. (2018)](https://doi.org/10.1021/jacs.7b09453). For details on the force field parameters used, see [this repo](https://github.com/rociomer/DFT-derived-force-field).

### Overview
The way the main scripts in this repo (which are titled *create-LAMMPS-input-\*.sh*) are intended to be used is to create, for each set of simulation conditions specified, a *.tcl* script for putting a specific number of guest molecules in a simulation box by reading isotherm data in [isothermData-74/](./isothermData-74/). This *.tcl* script is then run using vmd to generate:
* *.data*
* *.in*
* and *.in.settings* files. 
 
The script works by reading:
* a *template.in* file
* PDB structures for frameworks (located in [frameworkStructures/](./frameworkStructures/))
* XYZ structures for guest molecules (located in [adsorbateStructures/](./adsorbateStructures/))
* and force field parameters (defined in [forceFieldParamsTemplates/](./forceFieldParamsTemplates). 
 
A different set of force field template files are read depending on if the adsorbate molecule is charged or uncharged. 

### Instructions
The instructions below are for generating input files for MD simulations of **carbon dioxide** in **MOF-74**, but analogous instructions can be followed for **methane** as the adsorbate and **MOF-274** as the adsorbant.

To generate LAMMPS input files for **carbon dioxide** adsorbed in **MOF-74**, you can run the following script:

```
./create-LAMMPS-input-74-CO2.sh
```

Before running, define the "list" of pressures and metal frameworks that you  want to create input files for at the top of [create-LAMMPS-input-74-CO2.sh](./create-LAMMPS-input-74-CO2.sh). This script will read the respective files from:
* the [isothermData-74/](./isothermData-74/) directory (to know how many gas molecules to put in the simulation box)
* the [topoScripts/](./topoScripts/) directory (for the *.tcl* template scripts that it uses to generate the LAMMPS topology files)
* and the [forceFieldParamsTemplates/](./forceFieldParamsTemplates/) directory (for the DFT-FF parameters/charges). 

[template.in](./template.in) is the file that serves as the template for all the LAMMPS input scripts, so any changes made here will then affect all the input files generated (this is a good place to change any fixes or dump commands, but note that it contains many substrings that the *create-LAMMPS-input* scripts search and replace, so be careful).

As mentioned above, the analogous scripts can be used to generate input files for simulations of **carbon dioxide** adsorbed in **MOF-274** frameworks, or for **methane** adsorbed in **MOF-74**.

### Comments
I apologize for the poor documentation in this repo, especially the *create-LAMMPS-input-{74-CO2, 74-CH4, 274-CO2}.sh* scripts; they are functional but messy. If you spot any glaring errors, please reach out and I will be happy to fix them.

### Author
Rocío Mercado

### Link
https://github.com/rociomer/topo-tools-scripts/
