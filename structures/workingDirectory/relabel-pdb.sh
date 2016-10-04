#!/bin/bash

# Gives arbitrary labels to the different atom types
# Useful for converting between formats while keeping track
# of the different atom types.

fromXxToMof_Xx=true
fileExt="pdb"


# Labeling back to correct atom types:

if $fromXxToMof_Xx ; then
  if [ ${fileExt} == "pdb" ]; then
    for i in *.${fileExt}
    do 
      #sed -i 's/\sO   LIG\s*[0-9]*\s/Oa   LIG 1 /g' $i
      #sed -i 's/\sBR   LIG\s*[0-9]*\s/ Ob   LIG 1 /g' $i
      #sed -i 's/\sCL   LIG\s*[0-9]*\s/ Oc   LIG 1 /g' $i
      #sed -i 's/\sC   LIG\s*[0-9]*\s/Ca   LIG 1 /g' $i
      #sed -i 's/\sF   LIG\s*[0-9]*\s/Cb   LIG 1 /g' $i
      #sed -i 's/\sN   LIG\s*[0-9]*\s/Cc   LIG 1 /g' $i
      #sed -i 's/\sB   LIG\s*[0-9]*\s/Cd   LIG 1 /g' $i
      #sed -i 's/\sH   LIG\s*[0-9]*\s/ H   LIG 1 /g' $i
      #sed -i 's/\sCO   LIG\s*[0-9]*\s/ Co   LIG 1 /g' $i
      #sed -i 's/\sMG   LIG\s*[0-9]*\s/ Mg   LIG 1 /g' $i
      #sed -i 's/\sMN   LIG\s*[0-9]*\s/ Mn   LIG 1 /g' $i
      #sed -i 's/\sFE   LIG\s*[0-9]*\s/ Fe   LIG 1 /g' $i
      #sed -i 's/\sZN   LIG\s*[0-9]*\s/ Zn   LIG 1 /g' $i
      #sed -i 's/\sNI   LIG\s*[0-9]*\s/ Ni   LIG 1 /g' $i
      #sed -i 's/\sKR   LIG\s*[0-9]*\s/CH4   LIG 1 /g' $i
      sed -i 's/\sO   LIG/Oa   LIG/g' $i
      sed -i 's/\sBR   LIG/ Ob   LIG/g' $i
      sed -i 's/\sCL   LIG/ Oc   LIG/g' $i
      sed -i 's/\sC   LIG/Ca   LIG/g' $i
      sed -i 's/\sF   LIG/Cb   LIG/g' $i
      sed -i 's/\sN   LIG/Cc   LIG/g' $i
      sed -i 's/\sB   LIG/Cd   LIG/g' $i
      sed -i 's/\sH   LIG/ H   LIG/g' $i
      sed -i 's/\sCO   LIG/ Co   LIG/g' $i
      sed -i 's/\sMG   LIG/ Mg   LIG/g' $i
      sed -i 's/\sMN   LIG/ Mn   LIG/g' $i
      sed -i 's/\sFE   LIG/ Fe   LIG/g' $i
      sed -i 's/\sZN   LIG/ Zn   LIG/g' $i
      sed -i 's/\sNI   LIG/ Ni   LIG/g' $i
      sed -i 's/\sKR   LIG/CH4   LIG/g' $i
      sed -i 's/\s\s\sO/Oa/g' $i
      sed -i 's/\s\s\sBr/ Ob/g' $i
      sed -i 's/\s\s\sCl/ Oc/g' $i
      sed -i 's/\s\s\sC/Ca/g' $i
      sed -i 's/\s\s\sF/Cb/g' $i
      sed -i 's/\s\s\sN/Cc/g' $i
      sed -i 's/\s\s\sB/Cd/g' $i
      sed -i 's/\s\s\sH/ H/g' $i
      sed -i 's/\s\s\sCo/ Co/g' $i
      sed -i 's/\s\s\sMg/ Mg/g' $i
      sed -i 's/\s\s\sMn/ Mn/g' $i
      sed -i 's/\s\s\sFe/ Fe/g' $i
      sed -i 's/\s\s\sZn/ Zn/g' $i
      sed -i 's/\s\s\sNi/ Ni/g' $i
      sed -i 's/\s\s\sKr/CH4/g' $i
      sed -i 's/2+//g' $i
      sed -i 's/1-//g' $i
    done
  fi
fi
