import numpy as np
import matplotlib
#Force matplotlib to not use any Xwindows backend
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import statsmodels.api as sm
import math
import os

matplotlib.rc('lines', linewidth=1)
matplotlib.rc('font', size=8)
matplotlib.rc('lines', markersize=3)
matplotlib.rc('xtick.major', size=3)
matplotlib.rc('ytick.major', size=3)
matplotlib.rc('axes', labelsize=9)
matplotlib.rc('axes', titlesize=9)
matplotlib.rc('figure', figsize=(3.25,2.95))
LEGENDSIZE=6

colors=['b', 'g', 'r', 'c', 'm', 'y', 'black', 'grey']

def getCoefficients(file, rowsToSkip, pressureColumn, coefficientColumn):
    data = np.genfromtxt(file, skiprows=rowsToSkip)
    data = list(zip(*data))
    pressure = []
    coefficient = []
    for i in data[pressureColumn]:
        pressure.append(i/100000) #[pa to bar]
    for i in data[coefficientColumn]:
        coefficient.append(i/100000000) #[A^2/ps to m^2/s]
    output = (pressure, coefficient)
    return output

def plotCoefficients(inputArray, colorToPlot):
    pressure = inputArray[0]
    coefficient = inputArray[1]
    plt.plot(pressure, coefficient, marker='o', color=colorToPlot, linestyle='-', alpha=0.7)

def plotSettings(inputArray, filename):
    #xlim = [min(inputArray[0]), max(inputArray[0])*1.1]
    xlim = [0,5]
    ylim = [min(inputArray[1])*0.1, max(inputArray[1])*10]
    plt.xlabel('Pressure (bar)')
    plt.ylabel('Self-diffusion coefficient (m$^2$/s)' )
    plt.grid()
    plt.xscale('linear') 
    plt.yscale('log') 
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.tight_layout()
    plt.savefig(filename + '.png', format='png', dpi=300)

files = [f for f in os.listdir("./") if f.endswith("results.txt")] 
for f in files:
    outputArray = getCoefficients("./" + str(f), 1, 0, 1)
    plt.figure()
    plotCoefficients(outputArray, 'b')
    plotSettings(outputArray, str(f)[:-12] + '-plotCoefficients')
    plt.close()
