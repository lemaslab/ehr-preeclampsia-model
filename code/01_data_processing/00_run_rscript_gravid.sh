#!/bin/bash
#SBATCH --job-name=00_gravid   #Job name	
#SBATCH --mail-type=END,FAIL   # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=djlemas@ufl.edu   # Where to send mail	
#SBATCH --nodes=2                    # Run all processes on a single node	
#SBATCH --mem=10gb   # Per processor memory
#SBATCH --time=01:30:00   # Walltime
#SBATCH --output=00_gravid.%j.out   # Name output file 
#Record the time and compute node the job ran on
date; hostname; pwd
#Use modules to load the environment for R
module load R

#Run R script 
Rscript 00_gravid.R

date