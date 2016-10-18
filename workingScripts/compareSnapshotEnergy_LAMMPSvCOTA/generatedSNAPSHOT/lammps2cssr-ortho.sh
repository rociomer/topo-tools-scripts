#!/bin/bash

                          ### SET VARIABLES HERE ###                           
###############################################################################
fractional=false # true for fractional, false for Cartesian
lammpsTrjExt="lammpstrj"
###############################################################################


min() 
{
  printf "%s\n" "$@" | sort -g | head -1
}


max() 
{
  printf "%s\n" "$@" | sort -g | tail -1
}


sin()
{
  # input in degrees and converted to radians
  echo "s($1*0.01745329251)" | bc -l
}


cos()
{
  # input in degrees and converted to radians
  echo "c($1*0.01745329251)" | bc -l
}


acos()
{
  # output in degrees
  if (( $(echo "$1 == 0" | bc -l) )); then 
      echo "a(1)*2/0.01745329251" | bc -l
  elif (( $(echo "(-1 <= $1) && ($1 < 0)" | bc -l) )); then
      echo "(a(1)*4 - a(sqrt((1/($1^2))-1)))/0.01745329251" | bc -l
  elif (( $(echo "(0 < $1) && ($1 <= 1)" | bc -l) )); then
      echo "a(sqrt((1/($1^2))-1))/0.01745329251" | bc -l
  else
      echo "acos input out of range"
      return 1
  fi
}


round()
{
  digits=$2
  echo $1 | xargs printf "%.*f\n" ${digits}
}


getBoxBounds()
{
  ###########################################################################
  # For an orthogonal unit cell in LAMMPS, the format for the BOX BOUNDS is i
  # as follows:
  # ITEM: BOX BOUNDS pp pp pp
  # 0 alpha
  # 0 beta
  # 0 gamma
  ###########################################################################
  BoxBounds=($(grep -A 3 "BOX BOUNDS pp pp pp" $1))
  a=${BoxBounds[7]} 
  b=${BoxBounds[9]} 
  c=${BoxBounds[11]} 
}


getNumberOfAtoms()
{
  numberOfAtoms=($(grep -A 1 "NUMBER OF ATOMS" $i))
  echo ${numberOfAtoms[4]}
}


writeCartesianCSSR()
{
  cssrFile=$(echo "${1%.lammpstrj}.cssr")
  echo "                        $(round $2 4) $(round $3 4) $(round $4 4)" \
  > $cssrFile
  echo "          $(round $5 4) $(round $6 4) $(round $7 4)   SPGR = 1 P 1 \
  OPT = 1" >> $cssrFile
  echo "$8   1" >> $cssrFile
  echo "0 ${1%.lammpstrj} : ${1%.lammpstrj}" >> $cssrFile
  grep -A $8 "ITEM: ATOMS element x y z" $1 | tail -$8 > tmpCoordinates
  count=1
  cat tmpCoordinates | while read line;
  do
    echo " $count $line  0  0  0  0  0  0  0  0  0.000000" >> tmpCSSR
    let count+=1
  done
  cat tmpCSSR | column -t >> $cssrFile
  rm tmpCSSR tmpCoordinates
}


writeFractionalCSSR()
{
  cssrFile=$(echo "${1%.lammpstrj}.cssr")
  echo "                        $(round $2 4) $(round $3 4) $(round $4 4)" \
  > $cssrFile
  echo "          $(round $5 4) $(round $6 4) $(round $7 4)   SPGR = 1 P 1 \
  OPT = 1" >> $cssrFile
  echo "$8   0" >> $cssrFile
  echo "0 ${1%.lammpstrj} : ${1%.lammpstrj}" >> $cssrFile
  grep -A $8 "ITEM: ATOMS element x y z" $1 | tail -$8 > tmpCoordinates
  cellVolume=$(echo "sqrt(1.0 - $(cos $5)^2 - $(cos $6)^2 - $(cos $7)^2 + \
  2*$(cos $5)*$(cos $6)*$(cos $7))" | bc -l)
  count=1
  cat tmpCoordinates | while read line;
  do
    lineList=(${line})
    xFrac=$(echo "${lineList[1]}/$2 - ${lineList[2]}*$(cos $7)/($2*$(sin $7)) \
    + ${lineList[3]}*($(cos $5)*$(cos $7) \
    - $(cos $6))/($2*$cellVolume*$(sin $7))" | bc -l)
    yFrac=$(echo "${lineList[2]}/($3*$(sin $7)) + \
    ${lineList[3]}*($(cos $6)*$(cos $7) - \
    $(cos $5))/($3*$cellVolume*$(sin $7))" | bc -l)
    zFrac=$(echo "${lineList[3]}*$(sin $7)/($4*$cellVolume)" | bc -l)
    if [ $(echo $xFrac'>'1.0 | bc -l) -eq 1 ]; then 
      xFrac=$(echo "$xFrac - ${xFrac%.*}" | bc -l) # shift back into unit cell 
    fi
    if [ $(echo $yFrac'>'1.0 | bc -l) -eq 1 ]; then 
      yFrac=$(echo "$yFrac - ${yFrac%.*}" | bc -l) # shift back into unit cell 
    fi
    if [ $(echo $zFrac'>'1.0 | bc -l) -eq 1 ]; then 
      zFrac=$(echo "$zFrac - ${zFrac%.*}" | bc -l) # shift back into unit cell 
    fi
    echo " $count ${lineList[0]} $(round $xFrac 6) $(round $yFrac 6) \
    $(round $zFrac 6) 0  0  0  0  0  0  0  0  0.000000" >> tmpCSSR
    let count+=1
  done
  cat tmpCSSR | column -t >> $cssrFile
  rm tmpCSSR tmpCoordinates
}


for i in *.${lammpsTrjExt}
do
  getBoxBounds $i
  atomsInStructure=$(getNumberOfAtoms $i)
  alpha=90.0
  beta=90.0
  gamma=90.0
  if $fractional ; then
    writeFractionalCSSR $i $a $b $c $alpha $beta $gamma $atomsInStructure
  else
    writeCartesianCSSR $i $a $b $c $alpha $beta $gamma $atomsInStructure
  fi 
done

