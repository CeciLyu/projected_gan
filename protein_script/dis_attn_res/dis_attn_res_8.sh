#!/bin/bash
#SBATCH --job-name=dis_attn_res_8
#SBATCH --account=def-mikeuoft # adjust this to match the accounting group you are using to submit jobs
#SBATCH --time=00:05:00         # adjust this to match the walltime of your job
#SBATCH --nodes=1      
#SBATCH --ntasks=1
#SBATCH --gres=gpu:a100:1           # You need to request one GPU to be able to run AlphaFold properly
#SBATCH --cpus-per-task=4      # adjust this if you are using parallel commands
#SBATCH --mem=16G              # adjust this according to the memory requirement per node you need
#SBATCH --mail-user=cecilianlv@icloud.com # adjust this to match your email address
#SBATCH --mail-type=ALL

#SBATCH --output=slurm-%j-dis_attn_res_8.out

cd $SCRATCH 

# export CUDA_LAUNCH_BLOCKING=1

# Load your modules as before
module load gcc openmpi cuda/11.1 cudacore/.11.1.1 cudnn/8.2.0 openmm python/3.8 

# Generate your virtual environment in $SLURM_TMPDIR
 virtualenv --no-download ${SLURM_TMPDIR}/my_env && source ${SLURM_TMPDIR}/my_env/bin/activate
# source proteinGAN_ENV/bin/active

pip install --no-index -r /scratch/suyuelyu/proteinGAN/projected_gan/requirements.txt

# unzipped the downloaded few-shot.zip and procced pokemon
# python dataset_tool.py --source=/scratch/suyuelyu/proteinGAN/image-data/few-shot-images/pokemon \
# --dest=/scratch/suyuelyu/proteinGAN/image-data/processed_few_shot_pokemon.zip --resolution=256x256 --transform=center-crop
DATA_DIR=/home/suyuelyu/scratch/proteinGAN/pro_training_data_wo_X_21
REPO_DIR=/scratch/suyuelyu/proteinGAN/projected_gan 
OUTPUT_DIR=/scratch/suyuelyu/proteinGAN/pro_out

python ${REPO_DIR}/train.py \
    --outdir=${OUTPUT_DIR} \
    --cfg=fastgan_lite \
    --data=${DATA_DIR} \
    --gpus=1 \
    --batch=64 \
    --mirror=False \
    --snap=50 \
    --batch-gpu=64 \
    --kimg=10000 \
    --d_attn_res=8 \
    --desc=dis_attn_res_8