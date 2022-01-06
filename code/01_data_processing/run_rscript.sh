#!/bin/bash
#SBATCH --job-name=R_test   #Job name	
#SBATCH --mail-type=END,FAIL   # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=djlemas@ufl.edu   # Where to send mail	
#SBATCH --ntasks=2
#SBATCH --mem=1gb   # Per processor memory
#SBATCH --time=00:05:00   # Walltime
#SBATCH --output=r_job.%j.out   # Name output file 
#Record the time and compute node the job ran on
date; hostname; pwd
#Use modules to load the environment for R
module load R

#Run R script 
Rscript 00_link_gravid_to_delivery.R

date