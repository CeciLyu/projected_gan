#!/bin/bash
#SBATCH --job-name=pro_gan_blastp
#SBATCH --account=def-mikeuoft # adjust this to match the accounting group you are using to submit jobs
#SBATCH --time=4:00:00         # adjust this to match the walltime of your job
#SBATCH --nodes=1      
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4      # adjust this if you are using parallel commands
#SBATCH --mem=32G              # adjust this according to the memory requirement per node you need
#SBATCH --mail-user=cecilianlv@icloud.com # adjust this to match your email address
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j-pro_gan_blastp.out

# # This script is for preping the data needed as input for protein_projGAN

# # 1. database prep: run this step on login/ datatransfer node before step2

# module load StdEnv/2020  gcc/9.3.0 blast+/2.12.0

# mkdir $SCRATCH/proteinGAN/blastdb

# export BLASTDB=$SCRATCH/proteinGAN/blastdb # can add this to .bashrc, then source .bashrc

# cd $SCRATCH/proteinGAN/blastdb
# update_blastdb.pl --passive --decompress nr # this will take very long ~1h

module load StdEnv/2020  gcc/9.3.0 blast+/2.12.0

# 2. running actual blastp on compute node by submitting this script
blastp -query ad5_hexon.fasta -db nr -out ad5_nr_blastp_default.txt



