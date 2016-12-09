#!/bin/bash

cp documentTemplate.tex Document.tex

#plot self-diffusion coefficients
echo "\section{Computed self-diffusion coefficients}" >> Document.tex
 
for j in Mg Zn Ni
do 
  echo "\subsection{${j}-MOF-74}" >> Document.tex
  for i in ${j}-MOF-74-CH4-313K-plotCoefficients.png 
  do
    filename=${i}
    echo "\begin{figure}[H]" >> Document.tex
    echo "  \includegraphics[width=3.25in]{${filename}}" >> Document.tex
    echo "  \centering" >> Document.tex
    echo "  \caption{\text{Calculated self-diffusion coefficients versus pressure in ${j}-MOF-74 (313 K).}}" >> Document.tex
    echo "  \centering" >> Document.tex
    echo "\end{figure}" >> Document.tex
    echo "\\" >> Document.tex
  done
done

#plot MSDs
echo "\section{Mean-squared displacements}" >> Document.tex
 
for j in Mg Zn Ni
do
  echo "\subsection{Log-log MSD plots -- ${j}-MOF-74}" >> Document.tex
  for i in ${j}*K/Pressure*/plotMSD_loglog.png 
  do
    filename=${i}
    pressureTmp=${i#*K/Pressure}
    pressure=${pressureTmp%/plotMSD*}
    echo "\begin{figure}[H]" >> Document.tex
    echo "  \includegraphics[width=3.25in]{${filename}}" >> Document.tex
    echo "  \centering" >> Document.tex
    echo "  \caption{\text{Log-log plot of MSD versus time in ${j}-MOF-74 for simulation at ${pressure} Pa and 313 K uptake.}}" >> Document.tex
    echo "  \centering" >> Document.tex
    echo "\end{figure}" >> Document.tex
    echo "\\" >> Document.tex
  done
done

for j in Mg Zn Ni
do
  echo "\subsection{Lin-lin and fit of MSD plots -- ${j}-MOF-74}" >> Document.tex
  for i in ${j}*K/Pressure*/plotMSD_linlin.png 
  do
    filename=${i}
    pressureTmp=${i#*K/Pressure}
    pressure=${pressureTmp%/plotMSD*}
    echo "\begin{figure}[H]" >> Document.tex
    echo "  \includegraphics[width=3.25in]{${filename}}" >> Document.tex
    echo "  \centering" >> Document.tex
    echo "  \caption{\text{(\textit{Blue points}) Plot of MSD versus time in ${j}-MOF-74 for simulation at ${pressure} Pa and 313 K uptake. \textit{Black line} Best fit line to points in diffusive regime.}}" >> Document.tex
    echo "  \centering" >> Document.tex
    echo "\end{figure}" >> Document.tex
    echo "\\" >> Document.tex
  done
done

for j in Mg Zn Ni
do
  echo "\subsection{MSD fits -- ${j}-MOF-74}" >> Document.tex
  for i in ${j}*K/Pressure*/plotMSD_linlin_zoom.png 
  do
    filename=${i}
    pressureTmp=${i#*K/Pressure}
    pressure=${pressureTmp%/plotMSD*}
    echo "\begin{figure}[H]" >> Document.tex
    echo "  \includegraphics[width=3.25in]{${filename}}" >> Document.tex
    echo "  \centering" >> Document.tex
    echo "  \caption{\text{(\textit{Blue points}) Plot of MSD versus time in ${j}-MOF-74 for simulation at ${pressure} Pa and 313 K uptake, zoomed in on points in the diffusive regime. \textit{Black line} Best fit line to points in diffusive regime.}}" >> Document.tex
    echo "  \centering" >> Document.tex
    echo "\end{figure}" >> Document.tex
    echo "\\" >> Document.tex
  done
done

#create appendix
#echo "\section{Appendix}" >> Document.tex
#echo "\begin{appendix}" >> Document.tex
#echo "  \listoffigures" >> Document.tex
#echo "\end{appendix}" >> Document.tex

#end document
echo "\end{document}" >> Document.tex

#compile
pdflatex Document.tex
