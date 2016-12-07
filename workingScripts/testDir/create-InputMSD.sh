#!/bin/bash
cp traj.GUEST.10.dump.test.copy traj.GUEST.10.dump.test
numberOfAtoms=11
numberOfAtomsPlus=$(echo "$numberOfAtoms + 1" | bc -l)
sed -i '/ITEM\: BOX BOUNDS/,+3d' traj.GUEST.10.dump.test
sed -i '/ITEM/d' traj.GUEST.10.dump.test
a="\$!N;"; b=""; for i in $(seq 1 $numberOfAtomsPlus); do b+=$a; done
sed -i ''"$b"'s/\n/ /g' traj.GUEST.10.dump.test
