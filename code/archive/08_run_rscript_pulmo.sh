#!/bin/bash
#SBATCH --job-name=pulmo_link   #Job name	
#SBATCH --mail-type=END,FAIL   # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=djlemas@ufl.edu   # Where to send mail	
#SBATCH --nodes=2                    # Run all processes on a single node	
#SBATCH --mem=10gb   # Per processor memory
#SBATCH --time=00:40:00   # Walltime
#SBATCH --output=08_pulmo.%j.out   # Name output file 
#Record the time and compute node the job ran on
date; hostname; pwd
#Use modules to load the environment for R
module load R

#Run R script 
Rscript 08_pulmonary.R

date