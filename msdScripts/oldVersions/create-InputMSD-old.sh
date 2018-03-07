#!/bin/bash

rm traj.GUEST.10.dump.dat
cat traj.GUEST.10.dump >> traj.GUEST.10.dump.dat
numberOfAtoms=$(awk 'FNR==4{print $1}' traj.GUEST.10.dump)
numberOfAtomsPlus=$(echo "$numberOfAtoms + 2" | bc -l)
sed -i '/ITEM\: BOX BOUNDS/i newline' traj.GUEST.10.dump.dat
sed -i '/ITEM\: BOX BOUNDS/,+3d' traj.GUEST.10.dump.dat
sed -i '/ITEM/d' traj.GUEST.10.dump.dat
a="\$!N;"; b=""; for i in $(seq 1 $numberOfAtomsPlus); do b+=$a; done
sed -i ''"$b"'s/\n/ /g' traj.GUEST.10.dump.dat
sed -i 's/newline /\n/g' traj.GUEST.10.dump.dat
echo "# this line is a comment" >> traj.GUEST.10.dump.dat.copy
echo "# this line is a comment" >> traj.GUEST.10.dump.dat.copy
echo "# this line is a comment" >> traj.GUEST.10.dump.dat.copy
cat traj.GUEST.10.dump.dat >> traj.GUEST.10.dump.dat.copy
mv traj.GUEST.10.dump.dat.copy traj.GUEST.10.dump.dat
