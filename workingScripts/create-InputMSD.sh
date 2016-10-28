#!/bin/bash

head -10 traj.GUEST.10.dump >> temp.header
sed -i '//d' traj.GUEST.10.dump
