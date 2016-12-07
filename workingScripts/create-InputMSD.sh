#!/bin/bash
echo -n "# this line is a comment" > traj.GUEST.10.dump.dat
echo -n "# this line is a comment" >> traj.GUEST.10.dump.dat
echo -n "# this line is a comment" >> traj.GUEST.10.dump.dat
cat traj.GUEST.10.dump >> traj.GUEST.10.dump.dat
numberOfAtoms=11
numberOfAtomsPlus=$(echo "$numberOfAtoms + 2" | bc -l)
sed -i '/ITEM\: BOX BOUNDS/i newline' traj.GUEST.10.dump.dat
sed -i '/ITEM\: BOX BOUNDS/,+3d' traj.GUEST.10.dump.dat
sed -i '/ITEM/d' traj.GUEST.10.dump.dat
a="\$!N;"; b=""; for i in $(seq 1 $numberOfAtomsPlus); do b+=$a; done
sed -i ''"$b"'s/\n/ /g' traj.GUEST.10.dump.dat
sed -i 's/newline /\n/g' traj.GUEST.10.dump.dat
