#$ -S /bin/sh
#$ -cwd
#$ -q all*

# Email at beginning and end of job.
#$ -m n 
#$ -M rocio@berkeley.edu 

# User set variables

# Set the location within your home directory of your 
# COTA data directory. The directory you set in this 
# variable should contain the share directory.

DATADIR=cota
export MOLSIM_DIR=${HOME}/${DATADIR}

# For testing, you can comment out the line above
# and use the system-wide COTA data directory by
# uncommenting the line below.

# export MOLSIM_DIR=/share/apps

# Set the location of the COTA binary. The default
# is the system-wide binary. If you compiled your
# own binary, set COTABINDIR to the directory that
# contains the 'simulate' binary file.

COTABINDIR=${HOME}

# Setup the jobs directory. Please provide the location
# within your home directory of the jobs directory. This
# directory will contain symlinks to the directories
# where your simulations were launched, identified by 
# job ID and description field.

JOBSDIR=jobs

#
#
#
# MOST LIKELY DON'T NEED TO MAKE ANY CHANGES BELOW THIS POINT
#
#
#

# Test for jobs directory. If not available, create it.

if [ ! -d ${HOME}/${JOBSDIR} ]; then
    mkdir ${HOME}/${JOBSDIR}
fi
if [ ! -d ${HOME}/${JOBSDIR}/running ]; then
    mkdir ${HOME}/${JOBSDIR}/running
fi
if [ ! -d ${HOME}/${JOBSDIR}/completed ]; then
    mkdir ${HOME}/${JOBSDIR}/completed
fi
if [ ! -e ${HOME}/${JOBSDIR}/jobs.log ]; then
    touch ${HOME}/${JOBSDIR}/jobs.log
fi

# Record the current location.
CURDIR=`pwd`

TIMESTAMP=`date '+%m-%d-%y %H:%M:%S'`

# Determine whether the restart directory should be set as the inital configuration
RESTARTFLAG=`awk '/RestartFile/ {print $2}' simulation.input`

if [ "${RESTARTFLAG}" == "yes" ]
then
    mv Restart RestartInitial
fi

# Link to the running jobs directory

ln -s "${CURDIR}" ${HOME}/${JOBSDIR}/running/${JOB_ID}-${JOB_NAME}

echo "${TIMESTAMP} [SGE] Job ${JOB_ID}: ${JOB_NAME} started on ${HOSTNAME}" >> ${HOME}/${JOBSDIR}/jobs.log

# Run the simulation
${COTABINDIR}/molsim/version150623/bin/simulate

ENDTIME=`date '+%m-%d-%y %H:%M:%S'`

echo "${ENDTIME} [SGE] Job ${JOB_ID}: ${JOB_NAME} completed" >> ${HOME}/${JOBSDIR}/jobs.log

rm -f ${HOME}/${JOBSDIR}/running/${JOB_ID}-${JOB_NAME}
ln -s "${CURDIR}" ${HOME}/${JOBSDIR}/completed/${JOB_ID}-${JOB_NAME}

