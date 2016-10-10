#! /usr/bin/env python

import sys
import os

filename = sys.argv[1]
atoms_MOF = int(sys.argv[2])
atoms_GUEST = int(sys.argv[3])
atoms_per_GUEST = int(sys.argv[4])

with open (filename, 'r') as f_in, open(filename + 'temp', 'w') as f_out:
    line = f_in.readline()
    f_out.write(line)
    while (line != ''):
        line = f_in.readline()
        if 'Atoms' in line:
            f_out.write(line)
            line = f_in.readline()
            f_out.write(line)
            for i in range(atoms_GUEST):
                line = f_in.readline()
                line_split = line.split(' ')
                line_split[1] = str(i//atoms_per_GUEST+1) + ' ' + str(line_split[1])
                line = ' '.join(line_split)
                f_out.write(line)
            for i in range(atoms_MOF):
                line = f_in.readline()
                line_split = line.split(' ')
                line_split[1] = str(atoms_GUEST//atoms_per_GUEST+1) + ' ' + str(line_split[1])
                line = ' '.join(line_split)
                f_out.write(line)
        else:
            f_out.write(line)

os.rename(filename + 'temp', filename)
