#!/bin/bash -l

#SBATCH --job-name TestRun
#SBATCH --output TestRun-%j.out
#SBATCH --ntasks=150
#SBATCH --mem-per-cpu=15gb
#SBATCH --time=360:00:00
#SBATCH --account=UniKöln

# loading the parallel R library for MPI runs
module load R/3.5.1_intel_mkl_parallel

# specifying library location on server
export R_LIBS_USER=$HOME/R/3.5.1

# specifying location of the R-script
TestRun="$HOME/SimulatingNormativeConflict//ServerFiles/SimulationSetupForMPICluster.R"

# setting arguments to pass to the R script
MyArgs=""

# start Simulation Script with
time R --vanilla -f $TestRun --args $MyArgs 
