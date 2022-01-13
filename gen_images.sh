#!/bin/bash
#SBATCH --job-name=pro_gan_installation_test
#SBATCH --account=def-mikeuoft # adjust this to match the accounting group you are using to submit jobs
#SBATCH --time=00:15:00         # adjust this to match the walltime of your job
#SBATCH --nodes=1      
#SBATCH --ntasks=1
#SBATCH --gres=gpu:a100:1           # You need to request one GPU to be able to run AlphaFold properly
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

pip install --no-index -r /scratch/suyuelyu/proteinGAN/projected_gan/requirements.txt

python /scratch/suyuelyu/proteinGAN/projected_gan/gen_images.py --outdir=/scratch/suyuelyu/proteinGAN/projected_gan/image_out --trunc=1.0 --seeds=10-15 \
  --network=/scratch/suyuelyu/proteinGAN/projected_gan/leg_pkl/2020-01-11-skylion-stylegan2-animeportraits-networksnapshot-024664.pkl

python /scratch/suyuelyu/proteinGAN/projected_gan/gen_images.py --outdir=/scratch/suyuelyu/proteinGAN/projected_gan/image_out --trunc=1.0 --seeds=10-15 \
  --network=/scratch/suyuelyu/proteinGAN/projected_gan/leg_pkl/2020-01-11-skylion-stylegan2-animeportraits-networksnapshot-024664.pkl