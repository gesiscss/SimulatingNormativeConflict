#!/bin/bash -1

#SBATCH --job-name NormSimulation
#SBATCH --output NormSimulation-%j.out
#SBATCH --ntasks=1
#SBATCH --mem=1gb
#SBATCH --time=01:00:00
#SBATCH --account=UniKoeln

module load R/3.5.1_intel_mkl_parallel

SimulationScript="FILEPATH/RSCRIPT.R"
MyArgs="ARG1 ARG2 ARG3 usw."

# start Simulation Script
time R --vanilla -f $SimulationScript --args $MyArgs 
