#!/bin/bash

cp input_template.msd input.msd
numberOfParticles=$(sed '4q;d' traj.GUEST.10.dump)
boxA=$(sed '6q;d' traj.GUEST.10.dump)
boxB=$(sed '7q;d' traj.GUEST.10.dump)
boxC=$(sed '8q;d' traj.GUEST.10.dump)
sed -i "s/numberOfParticles/${numberOfParticles}/g" input.msd
sed -i "s/boxA/${boxA}/g" input.msd
sed -i "s/boxB/${boxB}/g" input.msd
sed -i "s/boxC/${boxC}/g" input.msd

rm traj.GUEST.10.dump.dat
cat traj.GUEST.10.dump >> traj.GUEST.10.dump.dat
sed -i '/ITEM\: NUMBER OF ATOMS/i newline' traj.GUEST.10.dump.dat
sed -i '/ITEM\: BOX BOUNDS/,+3d' traj.GUEST.10.dump.dat
sed -i '/ITEM/d' traj.GUEST.10.dump.dat
echo "# this line is a comment" >> traj.GUEST.10.dump.dat.copy
echo "# this line is a comment" >> traj.GUEST.10.dump.dat.copy
echo "# this line is a comment" >> traj.GUEST.10.dump.dat.copy
awk -v RS='^$' -v ORS="" '{gsub(/\nnewline\n/," ")}7' traj.GUEST.10.dump.dat >> traj.GUEST.10.dump.dat.copy
mv traj.GUEST.10.dump.dat.copy traj.GUEST.10.dump.dat
