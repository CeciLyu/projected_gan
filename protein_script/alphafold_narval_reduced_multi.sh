#!/bin/bash
#SBATCH --job-name=af_pro_gan_str
#SBATCH --account=def-mikeuoft # adjust this to match the accounting group you are using to submit jobs
#SBATCH --time=4:00:00         # adjust this to match the walltime of your job
#SBATCH --nodes=1      
#SBATCH --ntasks=1
#SBATCH --gres=gpu:a100:1           # You need to request one GPU to be able to run AlphaFold properly
#SBATCH --cpus-per-task=4      # adjust this if you are using parallel commands
#SBATCH --mem=32G              # adjust this according to the memory requirement per node you need
#SBATCH --mail-user=cecilianlv@icloud.com # adjust this to match your email address
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j-af_pro_gan_str.out

cd $SCRATCH 

# Load your modules as before
module load gcc openmpi cuda/11.1 cudacore/.11.1.1 cudnn/8.2.0 kalign hmmer hh-suite openmm/7.5.0 python/3.7

# Generate your virtual environment in $SLURM_TMPDIR
virtualenv --no-download ${SLURM_TMPDIR}/my_env && source ${SLURM_TMPDIR}/my_env/bin/activate

# Set the path to download dir
DATA_DIR=$SCRATCH/proteinGAN/pro_out_seq/gen32_sparse_1  # Set the appropriate path to your supporting data
REPO_DIR=$SCRATCH/alphafold # Set the appropriate path to AlphaFold's cloned repo
DOWNLOAD_DIR=$SCRATCH/alphafold/reduced_data  # Set the appropriate path to your downloaded data

# Install alphafold and dependencies
pip install --no-index six==1.15 numpy==1.21.2 scipy==1.4.1 pdbfixer alphafold typing-extensions==3.7.4.3+computecanada jaxlib==0.1.74+cuda11.cudnn82.computecanada 

for file in ${DATA_DIR}/*
do
	bash $SCRATCH/proteinGAN/projected_gan/protein_script/alphafold_graham_reduced_single.sh $file
done