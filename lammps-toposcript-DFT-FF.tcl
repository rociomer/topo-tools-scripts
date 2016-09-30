#!/usr/bin/tclsh

ATOMSPERMOF
ATOMSPERGUEST
LATTICEVECTORA
LATTICEVECTORB
LATTICEVECTORC
REPLICASMOFX
REPLICASMOFY
REPLICASMOFZ
REPLICASGUEST
STRUCTURENAME

# my variables
set atomsPerMOF ATOMSPERMOF
set atomsPerGuest ATOMSPERGUEST
set latticeVectorA LATTICEVECTORA
set latticeVectorB LATTICEVECTORB
set latticeVectorC LATTICEVECTORC
set replicasMOFX REPLICASMOFX
set replicasMOFY REPLICASMOFY 
set replicasMOFZ REPLICASMOFZ
set replicasGuest REPLICASGUEST


# explicitly load topotools and pbctools packages since
# they are not automatically requred in text mode.
package require topotools
package require pbctools

# check for presence of coordinate file
if {! [file exists STRUCTURENAME.pdb]} {
   vmdcon -error "Required file 'STRUCTURENAME.pdb' not available. Exiting..."
   quit
}

# load coordinates but don't automatically compute bonds
set mol [mol new STRUCTURENAME.pdb autobonds no waitfor all]

# replicate
set newmol [::TopoTools::replicatemol $mol $replicasMOFX $replicasMOFY $replicasMOFZ ]
# delete old mol
mol delete $mol

# set atom name/type and radius
set sel [atomselect top {name Mof_H}]
$sel set radius 1.2
$sel set name Mof_H
$sel set type Mof_H
$sel set mass 1.008
$sel set charge 0.15

# set atom name/type and radius
set sel [atomselect top {name Zn1}]
$sel set radius 1.39
$sel set name Zn1
$sel set type Zn1
$sel set mass 65.382
$sel set charge 1.275

# set atom name/type and radius
set sel [atomselect top {name O1}]
$sel set radius 1.52
$sel set name O1
$sel set type O1
$sel set mass 15.999
$sel set charge -1.5

# set atom name/type and radius
set sel [atomselect top {name O2}]
$sel set radius 1.52
$sel set name O2
$sel set type O2
$sel set mass 15.999
$sel set charge -0.6

# set atom name/type and radius
set sel [atomselect top {name C1}]
$sel set radius 1.7
$sel set name C1
$sel set type C1
$sel set mass 12.011
$sel set charge 0.475

# set atom name/type and radius
set sel [atomselect top {name C2}]
$sel set radius 1.7
$sel set name C2
$sel set type C2
$sel set mass 12.011
$sel set charge 0.125

# set atom name/type and radius
set sel [atomselect top {name C3}]
$sel set radius 1.7
$sel set name C3
$sel set type C3
$sel set mass 12.011
$sel set charge -0.15

# bonds are computed based on distance criterion
# bond if 0.6 * (r_A + r_B) > r_AB.
# with radius 0.85 the cutoff is 1.02
# the example system has particles 1.0 apart.
mol bondsrecalc top

# set box dimensions
pbc set "[expr $boxlen * $replicasMOFX] [expr $boxlen * $replicasMOFY] [expr $boxlen * $replicasMOFZ] 90.0 90.0 90.0"

# add in PBC bonds
set sel [atomselect top all]
set lastindex [expr $atomsPerMOF * $replicasMOFX * $replicasMOFY * $replicasMOFZ]
for {set i 0} {$i < $lastindex} {incr i} {
    set atomid [atomselect top "index $i"]
    if {[$atomid get name] == "C3" && [$atomid get numbonds] == 2} {
        set connector [atomselect top "(name C3 and pbwithin 2 of index [$atomid get index]) and not index [$atomid get index]"]
        topo addbond [$atomid get index] [$connector get index]
    }
}

# now recompute bond types. 
# by default a string label: <atom type 1>-<atom type 2>
# we have two atom types A and B, but type B atoms are only
# at the end of the chain, so there should be only two bond
# types: A-A and A-B. Bond type B-A is identical to A-B and
# will be made canonical (lower string value first) by topotools.
topo retypebonds 
vmdcon -info "assigned [topo numbondtypes] bond types to [topo numbonds] bonds:"
vmdcon -info "bondtypes: [topo bondtypenames]"

# now derive angle definitions from bond topology.
# every two bonds that share an atom yield an angle.
topo guessangles
vmdcon -info "assigned [topo numangletypes] angle types to [topo numangles] angles:"
vmdcon -info "angletypes: [topo angletypenames]"

# now derive dihedral definitions from bond topology.
topo guessdihedrals
vmdcon -info "assigned [topo numdihedraltypes] dihedral types to [topo numdihedrals] dihedrals:"
vmdcon -info "dihedraltypes: [topo dihedraltypenames]"

# now derive improper definitions from bond topology.
topo guessimpropers tolerance 200
vmdcon -info "assigned [topo numimpropertypes] improper types to [topo numimpropers] impropers:"
vmdcon -info "impropertypes: [topo impropertypenames]"

# now let VMD reanalyze the molecular structure
# this is needed to detect fragments/molecules
# after we have recomputed the bonds
mol reanalyze top

# wrap to PBC
pbc wrap -orthorhombic 

# p-xylene
set mol [mol new p-xylene-trappe.xyz autobonds no waitfor all]

# set box dimensions
set extra 0
if {[expr $replicasGuest % (4 * $replicasMOFX * $replicasMOFY)] > 0} {
    set extra 1
}
set replicasGuestZ [expr $replicasGuest / (4 * $replicasMOFX * $replicasMOFY) + $extra]
pbc set "[expr $boxlen / 2] [expr $boxlen / 2] [expr $boxlen * $replicasMOFZ / $replicasGuestZ] 90.0 90.0 90.0"

# replicate
set newmolxyl [::TopoTools::replicatemol $mol [expr 2 * $replicasMOFX] [expr 2 * $replicasMOFY] $replicasGuestZ ]
# delete old mol
mol delete $mol
# delete extra atoms
set newmollessextra [atomselect top "index 0 to [expr $atomsPerGuest * $replicasGuest - 1]"]
$newmollessextra writepdb temp.pdb
mol delete $newmolxyl
mol delete $mollessextra
set mol [mol new temp.pdb autobonds no waitfor all]
exec rm temp.pdb

# set atom name/type and radius
set sel [atomselect top {name C}]
$sel set name C
$sel set type C
$sel set mass 12.011
$sel set charge 0.0

# set atom name/type and radius
set sel [atomselect top {name CH}]
$sel set name CH
$sel set type CH
$sel set mass 13.019
$sel set charge 0.0

# set atom name/type and radius
set sel [atomselect top {name CH3}]
$sel set name CH3
$sel set type CH3
$sel set mass 15.035
$sel set charge 0.0

# wrap to PBC
set sel [atomselect top all]
pbc wrap -orthorhombic
$sel moveby "[expr $boxlen / 4] [expr $boxlen / 4] 0"

# merge molecules
set midlist {}
lappend midlist $mol
lappend midlist $newmol
set mol [::TopoTools::mergemols $midlist]

# write out the result as a lammps data file
topo writelammpsdata system.data full

# do some post-processing to label molecules
exec python lammps-toposcript-assign-molecules.py system.data [expr $atomsPerMOF * $replicasMOFX * $replicasMOFY * $replicasMOFZ] [expr $atomsPerGuest * $replicasGuest]

# make non-bonded guest molecules easier to see
mol modstyle 0 4 VDW 1.000000 12.000000

# done. now exit vmd
quit
