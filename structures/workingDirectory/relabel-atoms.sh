#!/bin/bash

# Gives arbitrary labels to the different atom types
# Useful for converting between formats while keeping track
# of the different atom types.

fromMof_XxToXx=false
fromXxToMof_Xx=true
fromMof_XxToRealAtoms=false
fileExt="pdb"

# Relabeling from force field atom types to arbitrary labels:

if $fromMof_XxToXx ; then
  for i in *.${fileExt}; 
  do 
    sed -i 's/Mof_Oa/O/g' $i
    sed -i 's/Mof_Ob/Br/g' $i
    sed -i 's/Mof_Oc/Cl/g' $i
    sed -i 's/Mof_Ca/C/g' $i
    sed -i 's/Mof_Cb/F/g' $i
    sed -i 's/Mof_Cc/N/g' $i
    sed -i 's/Mof_Cd/B/g' $i
    sed -i 's/Mof_H/H/g' $i
    sed -i 's/Mof_Co/Co/g' $i
    sed -i 's/Mof_Mg/Mg/g' $i
    sed -i 's/Mof_Mn/Mn/g' $i
    sed -i 's/Mof_Fe/Fe/g' $i
    sed -i 's/Mof_Zn/Zn/g' $i
    sed -i 's/Mof_Ni/Ni/g' $i
    sed -i 's/CH4_sp3/Kr/g' $i
  done
fi

# Labeling back to correct atom types:

if $fromXxToMof_Xx ; then
  if [ ${fileExt} == "pdb" ]; then
    for i in *.${fileExt}
    do 
      sed -i 's/\sO   LIG\s*[0-9]*\s/ Mof_Oa LIG 1 /g' $i
      sed -i 's/\sBR   LIG\s*[0-9]*\s/ Mof_Ob LIG 1 /g' $i
      sed -i 's/\sCL   LIG\s*[0-9]*\s/ Mof_Oc LIG 1 /g' $i
      sed -i 's/\sC   LIG\s*[0-9]*\s/ Mof_Ca LIG 1 /g' $i
      sed -i 's/\sF   LIG\s*[0-9]*\s/ Mof_Cb LIG 1 /g' $i
      sed -i 's/\sN   LIG\s*[0-9]*\s/ Mof_Cc LIG 1 /g' $i
      sed -i 's/\sB   LIG\s*[0-9]*\s/ Mof_Cd LIG 1 /g' $i
      sed -i 's/\sH   LIG\s*[0-9]*\s/ Mof_H LIG 1 /g' $i
      sed -i 's/\sCO   LIG\s*[0-9]*\s/ Mof_Co LIG 1 /g' $i
      sed -i 's/\sMG   LIG\s*[0-9]*\s/ Mof_Mg LIG 1 /g' $i
      sed -i 's/\sMN   LIG\s*[0-9]*\s/ Mof_Mn LIG 1 /g' $i
      sed -i 's/\sFE   LIG\s*[0-9]*\s/ Mof_Fe LIG 1 /g' $i
      sed -i 's/\sZN   LIG\s*[0-9]*\s/ Mof_Zn LIG 1 /g' $i
      sed -i 's/\sNI   LIG\s*[0-9]*\s/ Mof_Ni LIG 1 /g' $i
      sed -i 's/\sKR   LIG\s*[0-9]*\s/ CH4_sp3 LIG 1 /g' $i
      sed -i 's/\sO/ Mof_Oa/g' $i
      sed -i 's/\sBr/ Mof_Ob/g' $i
      sed -i 's/\sCl/ Mof_Oc/g' $i
      sed -i 's/\sC/ Mof_Ca/g' $i
      sed -i 's/\sF/ Mof_Cb/g' $i
      sed -i 's/\sN/ Mof_Cc/g' $i
      sed -i 's/\sB/ Mof_Cd/g' $i
      sed -i 's/\sH/ Mof_H/g' $i
      sed -i 's/\sCo/ Mof_Co/g' $i
      sed -i 's/\sMg/ Mof_Mg/g' $i
      sed -i 's/\sMn/ Mof_Mn/g' $i
      sed -i 's/\sFe/ Mof_Fe/g' $i
      sed -i 's/\sZn/ Mof_Zn/g' $i
      sed -i 's/\sNi/ Mof_Ni/g' $i
      sed -i 's/\sKr/ CH4_sp3/g' $i
    done
  else 
    for i in *.${fileExt}
    do 
      sed -i 's/\sO\s/ Mof_Oa /g' $i
      sed -i 's/\sBr\s/ Mof_Ob /g' $i
      sed -i 's/\sCl\s/ Mof_Oc /g' $i
      sed -i 's/\sC\s/ Mof_Ca /g' $i
      sed -i 's/\sF\s/ Mof_Cb /g' $i
      sed -i 's/\sN\s/ Mof_Cc /g' $i
      sed -i 's/\sB\s/ Mof_Cd /g' $i
      sed -i 's/\sH\s/ Mof_H /g' $i
      sed -i 's/\sCo\s/ Mof_Co /g' $i
      sed -i 's/\sMg\s/ Mof_Mg /g' $i
      sed -i 's/\sMn\s/ Mof_Mn /g' $i
      sed -i 's/\sFe\s/ Mof_Fe /g' $i
      sed -i 's/\sZn\s/ Mof_Zn /g' $i
      sed -i 's/\sNi\s/ Mof_Ni /g' $i
      sed -i 's/\sKr\s/ CH4_sp3 /g' $i
    done
  fi
fi

# Label with correct atom (for vizualization)

if $fromMof_XxToRealAtoms ; then
  for i in *.${fileExt}; 
  do 
    sed -i 's/Mof_Oa/O/g' $i
    sed -i 's/Mof_Ob/O/g' $i
    sed -i 's/Mof_Oc/O/g' $i
    sed -i 's/Mof_Ca/C/g' $i
    sed -i 's/Mof_Cb/C/g' $i
    sed -i 's/Mof_Cc/C/g' $i
    sed -i 's/Mof_Cd/C/g' $i
    sed -i 's/Mof_H/H/g' $i
    sed -i 's/Mof_Co/Co/g' $i
    sed -i 's/Mof_Mg/Mg/g' $i
    sed -i 's/Mof_Mn/Mn/g' $i
    sed -i 's/Mof_Fe/Fe/g' $i
    sed -i 's/Mof_Zn/Zn/g' $i
    sed -i 's/Mof_Ni/Ni/g' $i
    sed -i 's/CH4_sp3/C/g' $i
  done
fi

