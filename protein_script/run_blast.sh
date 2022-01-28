#!/bin/bash
#SBATCH --job-name=pro_gan_blastp
#SBATCH --account=def-mikeuoft # adjust this to match the accounting group you are using to submit jobs
#SBATCH --time=3:00:00         # adjust this to match the walltime of your job
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

# Search Parameters
# Program	blastp
# Word size	6
# Expect value	0.05
# Hitlist size	5000
# Gapcosts	11,1
# Matrix	BLOSUM62
# Filter string	F
# Genetic Code	1
# Window Size	40
# Threshold	21
# Composition-based stats	2
# Database
# Posted date	Jan 21, 2022 2:41 AM
# Number of letters	172,641,082,995
# Number of sequences	454,232,076
# Entrez query	
# None
# Karlin-Altschul statistics
# Lambda	0.31728	0.267
# K	0.134211	0.041
# H	0.406499	0.14
# Alpha	0.7916	1.9
# Alpha_v	4.96466	42.6028
# Sigma		43.6362

# 2. running actual blastp on compute node by submitting this script
blastp -query $SCRATCH/proteinGAN/ad5_hexon.fasta \
       -db nr \
       -word_size 6 \
       -evalue 0.05 \
       -gapopen 11 \
       -gapextend 1 \
       -window_size 40 \
       -threshold 21 \
       -comp_based_stats 2 \
       -num_threads 4 \
       -max_target_seqs 30000 \
       -outfmt 5 \
       -out $SCRATCH/proteinGAN/ad5_nr_blastp.xml \





