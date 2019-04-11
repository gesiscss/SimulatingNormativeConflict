#!/bin/bash -1

#SBATCH --job-name TestRun
#SBATCH --output TestRun-%j.out
#SBATCH --ntasks=1
#SBATCH --mem=1gb
#SBATCH --time=01:00:00
#SBATCH --account=UniKoeln

module load R/3.5.1_intel_mkl_parallel

TestRun="home/fkarimi2/Test/Test.R"
MyArgs=""

# start Simulation Script
time R --vanilla -f $TestRun --args $MyArgs 
