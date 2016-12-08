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
indexToStartCounting=36
lastIndicesToIgnore=1

def getMSD(file, rowsToSkip, timeColumn, msdColumn, dimension):
    data = np.genfromtxt(file, skiprows=rowsToSkip)
    data = list(zip(*data))
    time = []
    timeLog = []
    msd = []
    msdLog = []
    for i in data[timeColumn]:
        time.append(i) #[ps]
        timeLog.append(math.log(i,10)) #[ps]
    for i in data[msdColumn]:
        msd.append(i) #[A^2]
        msdLog.append(math.log(i,10)) #[A^2]
    output = (time, msd, timeLog, msdLog)
    finalIndex=len(time)-1
    print('Full length of array to fit is ' + str(finalIndex))
    print('Index for 0.001 ps:' + str(time.index(0.001)))
    print('Index for 0.01 ps:' + str(time.index(0.01)))
    print('Index for 0.1 ps:' + str(time.index(0.1)))
    print('Index for 1.0 ps:' + str(time.index(1.0)))
    print('Index for 10.0 ps:' + str(time.index(10.0)))
    print('Index for 100.0 ps:' + str(time.index(100.0)))
    print('Index for 1000.0 ps:' + str(time.index(1000.0)))
    return output, dimension

def plotMSD(inputArray, colorToPlot):
    time = inputArray[0]
    msd = inputArray[1]
    plt.plot(time, msd, marker='o', color=colorToPlot, linestyle='-', alpha=0.7)

def plotSettingsLogLog(inputArray, filename):
    xlim = [0.0001, max(inputArray[0])*10]
    ylim = [0.0001, max(inputArray[1])*10]
    plt.xlabel('Time (ps)')
    plt.ylabel('Mean squared displacement ($\AA^2$)' )
    plt.grid()
    plt.xscale('log') 
    plt.yscale('log') 
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.tight_layout()
    plt.savefig(filename + '_loglog.png', format='png', dpi=300)

def plotSettingsLinLin(inputArray, filename):
    xlim = [0.0001, max(inputArray[0])*1.1]
    ylim = [0.0001, max(inputArray[1])*1.5]
    plt.xlabel('Time (ps)')
    plt.ylabel('Mean squared displacement ($\AA^2$)' )
    plt.grid()
    plt.xscale('linear') 
    plt.yscale('linear') 
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.tight_layout()
    plt.savefig(filename + '_linlin.png', format='png', dpi=300)

def getDiffusionCoeff(inputArray, dimension):
    # check if in the diffusive regime
    finalIndex=len(inputArray[0])-1-lastIndicesToIgnore
    XLOG = inputArray[2][indexToStartCounting:finalIndex]
    YLOG = inputArray[3][indexToStartCounting:finalIndex]
    fit = np.polyfit(XLOG, YLOG, deg=1)
    slopeLog = float(fit[0])
    yInterceptLog = float(fit[1])
    print('Best fit line to log-log data has form ' + str(slopeLog) + 'x + ' + str(yInterceptLog))
    X = inputArray[0][indexToStartCounting:finalIndex]
    Y = inputArray[1][indexToStartCounting:finalIndex]
    results  = sm.OLS(Y,sm.add_constant(X)).fit()
    yIntercept = results.params[0]
    slope = results.params[1]
    print('Best fit line to MSD has form ' + str(slope) + 'x + ' + str(yIntercept))
    print(results.summary())
    diffusionCoeff = slope / (2 * dimension) 
    print('Diffusion coefficient: ' + str(diffusionCoeff) + ' angstroms^2 / ps')
    return slope, yIntercept, diffusionCoeff # slope, y-int

def plotBestFit(slope, yIntercept, colorToPlot):
    x = np.arange(0,1000)
    y =  slope * x + yIntercept
    plt.plot(x, y, color=colorToPlot)

outputArray, dimension = getMSD("./msd_total_self.dat", 2, 0, 4, 3)
plt.figure()
plotMSD(outputArray, 'b')
plotSettingsLogLog(outputArray, 'plotMSD')
plt.close()
plt.figure()
plotMSD(outputArray, 'b')
slope, yIntercept, D = getDiffusionCoeff(outputArray, dimension)
plotBestFit(slope, yIntercept, 'black')
plotSettingsLinLin(outputArray, 'plotMSD')
plt.close()
