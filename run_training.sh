#!/bin/bash
#SBATCH --job-name=pro_gan_installation_test
#SBATCH --account=def-mikeuoft # adjust this to match the accounting group you are using to submit jobs
#SBATCH --time=00:15:00         # adjust this to match the walltime of your job
#SBATCH --nodes=1      
#SBATCH --ntasks=1
#SBATCH --gres=gpu:a100:2           # You need to request one GPU to be able to run AlphaFold properly
#SBATCH --cpus-per-task=4      # adjust this if you are using parallel commands
#SBATCH --mem=32G              # adjust this according to the memory requirement per node you need
#SBATCH --mail-user=cecilianlv@icloud.com # adjust this to match your email address
#SBATCH --mail-type=ALL
#SBATCH --output=slurm-%j-pro_gan_installation_test.out

cd $SCRATCH 

# Load your modules as before
module load gcc openmpi cuda/11.1 cudacore/.11.1.1 cudnn/8.2.0 openmm python/3.8 

# Generate your virtual environment in $SLURM_TMPDIR
 virtualenv --no-download ${SLURM_TMPDIR}/my_env && source ${SLURM_TMPDIR}/my_env/bin/activate
# source proteinGAN_ENV/bin/active

pip install --no-index -r /scratch/suyuelyu/proteinGAN/projected_gan/requirements.txt

DATA_DIR=/home/suyuelyu/scratch/proteinGAN/image-data     
REPO_DIR=/scratch/suyuelyu/proteinGAN/projected_gan 
OUTPUT_DIR=/scratch/suyuelyu/proteinGAN/projected_gan/image_out

python ${REPO_DIR}/train.py \
    --outdir=${OUTPUT_DIR} \
    --cfg=fastgan_lite \
    --data=${DATA_DIR}/few-shot-image-datasets.zip \
    --gpus=2 \
    --batch=4 \
    --mirror=1 \
    --snap=50 \
    --batch-gpu=2 \
    --kimg=10000 \