#!/bin/bash
#SBATCH --job-name=alphafold_GAN_gen_seqs
#SBATCH --account=def-mikeuoft # adjust this to match the accounting group you are using to submit jobs
#SBATCH --time=00:15:00         # adjust this to match the walltime of your job
#SBATCH --nodes=1      
#SBATCH --ntasks=1
#SBATCH --gres=gpu:v100:1           # You need to request one GPU to be able to run AlphaFold properly
#SBATCH --cpus-per-task=4      # adjust this if you are using parallel commands
#SBATCH --mem=32G              # adjust this according to the memory requirement per node you need
#SBATCH --mail-user=cecilianlv@icloud.com # adjust this to match your email address
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j-alphafold_GAN_gen_seqs.out

cd $SCRATCH 

# Load your modules as before
module load gcc openmpi cuda/11.1 cudacore/.11.1.1 cudnn/8.2.0 kalign hmmer hh-suite openmm python/3.7

# Generate your virtual environment in $SLURM_TMPDIR
virtualenv --no-download ${SLURM_TMPDIR}/my_env && source ${SLURM_TMPDIR}/my_env/bin/activate

# Set the path to download dir
DATA_DIR=$SCRATCH/ProteinGAN/generated_pro_seqs   # Set the appropriate path to your supporting data
REPO_DIR=$SCRATCH/alphafold # Set the appropriate path to AlphaFold's cloned repo
DOWNLOAD_DIR=$SCRATCH/alphafold/reduced_data  # Set the appropriate path to your downloaded data

# Install alphafold and dependencies
pip install --no-index six==1.15 numpy==1.19.2 scipy==1.4.1 pdbfixer alphafold jaxlib-0.1.74+cuda11.cudnn82.computecanada typing-extensions-3.7.4.3+computecanada

for file in ${DATA_DIR}/*
do
	bash $SCRATCH/ProteinGAN/projected_gan/protein_script/alphafold_graham_reduced_single.sh $file
done