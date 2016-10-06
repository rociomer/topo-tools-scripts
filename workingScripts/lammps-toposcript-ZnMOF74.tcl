#!/usr/bin/tclsh
# To run from terminal: vmd -dispdev text -e SCRIPT.tcl

# my variables
set structure Zn-MOF-74.pdb
set guest GUESTFILE
set atomsPerMOF 648
set atomsPerGuest ATOMSPERGUEST
set latticeVectorA 52.1907
set latticeVectorB 45.1984
set latticeVectorC 6.88181
set alpha 90.0
set beta 90.0
set gamma 90.0
set replicasMOFX 1
set replicasMOFY 1
set replicasMOFZ 4
set replicasGuest REPLICASGUEST


# explicitly load topotools and pbctools packages since
# they are not automatically requred in text mode.
package require topotools
package require pbctools

# check for presence of coordinate file
if {! [file exists $structure]} {
   vmdcon -error "Required file '$structure' not available. Exiting..."
   quit
}


# load coordinates but don't automatically compute bonds
set mol [mol new $structure autobonds no]

# replicate
set newmol [::TopoTools::replicatemol $mol $replicasMOFX $replicasMOFY $replicasMOFZ ]

# delete old mol
#mol delete $mol

# set atom name/type and radius
set sel [atomselect top {name Zn1}]
$sel set radius 1.31
$sel set name Zn1
$sel set type Zn1
$sel set mass 65.38
$sel set charge 1.209

# set atom name/type and radius
set sel [atomselect top {name O1}]
$sel set radius 0.73
$sel set name O1
$sel set type O1
$sel set mass 15.999
$sel set charge -0.719

# set atom name/type and radius
set sel [atomselect top {name O2}]
$sel set radius 0.73
$sel set name O2
$sel set type O2
$sel set mass 15.999
$sel set charge -0.671

# set atom name/type and radius
set sel [atomselect top {name O3}]
$sel set radius 0.73
$sel set name O3
$sel set type O3
$sel set mass 15.999
$sel set charge -0.74

# set atom name/type and radius
set sel [atomselect top {name C1}]
$sel set radius 0.77
$sel set name C1
$sel set type C1
$sel set mass 12.011
$sel set charge 0.841

# set atom name/type and radius
set sel [atomselect top {name C2}]
$sel set radius 0.77
$sel set name C2
$sel set type C2
$sel set mass 12.011
$sel set charge -0.298

# set atom name/type and radius
set sel [atomselect top {name C3}]
$sel set radius 0.77
$sel set name C3
$sel set type C3
$sel set mass 12.011
$sel set charge 0.376

# set atom name/type and radius
set sel [atomselect top {name C4}]
$sel set radius 0.77
$sel set name C4
$sel set type C4
$sel set mass 12.011
$sel set charge -0.17

# set atom name/type and radius
set sel [atomselect top {name H1}]
$sel set radius 0.37
$sel set name H1
$sel set type H1
$sel set mass 1.008
$sel set charge 0.172

# bonds are computed based on distance criterion
# bond if 0.6 * (r_A + r_B) > r_AB.
# with radius 0.85 the cutoff is 1.02
# the example system has particles 1.0 apart.
mol bondsrecalc top

# set box dimensions
pbc set "[expr $latticeVectorA * $replicasMOFX] [expr $latticeVectorB * $replicasMOFY] [expr $latticeVectorC * $replicasMOFZ] $alpha $beta $gamma"

# add in PBC bonds
set sel [atomselect top all]

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

# guest
set mol [mol new $guest autobonds no waitfor all]

# set box dimensions
set extra 0
if {[expr $replicasGuest % (4 * $replicasMOFX * $replicasMOFY)] > 0} {
    set extra 1
}
set replicasGuestZ [expr $replicasGuest / (4 * $replicasMOFX * $replicasMOFY) + $extra]
pbc set "[expr $latticeVectorA / 2] [expr $latticeVectorB / 2] [expr $latticeVectorC * $replicasMOFZ / $replicasGuestZ] $alpha $beta $gamma"

# replicate
set newmolGuest [::TopoTools::replicatemol $mol [expr 2 * $replicasMOFX] [expr 2 * $replicasMOFY] $replicasGuestZ ]
# delete old mol
mol delete $mol
# delete extra atoms
set newmollessextra [atomselect top "index 0 to [expr $atomsPerGuest * $replicasGuest - 1]"]
$newmollessextra writepdb temp.pdb
mol delete $newmolGuest
mol delete $mollessextra
set mol [mol new temp.pdb autobonds no waitfor all]
exec rm temp.pdb

# set atom name/type and radius
set sel [atomselect top {name CH4}]
$sel set name CH4
$sel set type CH4
$sel set mass 16.04
$sel set charge 0.0

# set atom name/type and radius
set sel [atomselect top {name Cg}]
$sel set name Cg
$sel set type Cg
$sel set mass 12.011
$sel set charge 0.6512

# set atom name/type and radius
set sel [atomselect top {name Og}]
$sel set name Og
$sel set type Og
$sel set mass 15.999
$sel set charge -0.3256

# set atom name/type and radius
set sel [atomselect top {name Hw}]
$sel set name Hw
$sel set type Hw
$sel set mass 1.008
$sel set charge 0.52422

# set atom name/type and radius
set sel [atomselect top {name Ow}]
$sel set name Ow
$sel set type Ow
$sel set mass 15.999
$sel set charge 0.0

# set atom name/type and radius
set sel [atomselect top {name M}]
$sel set name M
$sel set type M
$sel set mass 0.0
$sel set charge -1.04844

# wrap to PBC
set sel [atomselect top all]
pbc wrap -orthorhombic
$sel moveby "[expr $latticeVectorA / 4] [expr $latticeVectorB / 4] 0" 
# Rocio: check the above line

# merge molecules
set midlist {}
lappend midlist $mol
lappend midlist $newmol
set mol [::TopoTools::mergemols $midlist]

# write out the result as a lammps data file
topo writelammpsdata system.data atomic

# do some post-processing to label molecules
#exec python lammps-toposcript-assign-molecules.py system.data [expr $atomsPerMOF * $replicasMOFX * $replicasMOFY * $replicasMOFZ] [expr $atomsPerGuest * $replicasGuest]

# make non-bonded guest molecules easier to see
mol modstyle 0 4 VDW 1.000000 12.000000

# done. now exit vmd
quit
