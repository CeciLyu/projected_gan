#!/bin/bash
#SBATCH --job-name=pro_gan_blastp
#SBATCH --account=def-mikeuoft # adjust this to match the accounting group you are using to submit jobs
#SBATCH --time=1:00:00         # adjust this to match the walltime of your job
#SBATCH --nodes=1      
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8      # adjust this if you are using parallel commands
#SBATCH --mem=8GB               # adjust this according to the memory requirement per node you need
#SBATCH --mail-user=cecilianlv@icloud.com # adjust this to match your email address
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j-pro_gan_blastp.out

module load StdEnv/2020  gcc/9.3.0 clustal-omega/1.2.4

clustalo --in /scratch/suyuelyu/proteinGAN/ad5_hexon_seqdump_unaligned.fasta \
         --out ad5_hexon_seqdump_5000 \
         --outfmt=clu \
         --maxnumseq=8000 \
         --maxseqlen=2000 \
         --threads=4 \
         --verbose


