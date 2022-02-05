# before running this script: 

# module load python/3.8

# pip install --no-index biopython pillow matplotlib

import os
import numpy as np
from PIL import Image
import math
from matplotlib import pyplot as plt
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq
import argparse

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('--seq_dir', type=str,
                    help='name for the folder to keep this batch of seq result')
args = parser.parse_args()

# 21 col version ( w/o X)
ID_TO_AA = {
    0: 'A',
    1: 'C',  # Also U.
    2: 'D',  # Also B.
    3: 'E',  # Also Z.
    4: 'F',
    5: 'G',
    6: 'H',
    7: 'I',
    8: 'K',
    9: 'L',
    10: 'M',
    11: 'N',
    12: 'P',
    13: 'Q',
    14: 'R',
    15: 'S',
    16: 'T',
    17: 'V',
    18: 'W',
    19: 'Y',
    20: '-'
}

def read_fake(png_dir):
  fakes = {}
  for png in os.listdir(png_dir):
    full_png_dir = os.path.join(png_dir, png)
    fake = Image.open(full_png_dir)
    fake = np.array(fake)
    fake = np.mean(fake, axis=2)
    print(fake.shape)
    fakes[png.split('.')[0]] = fake
  return(fakes)

def get_aa(row_array):
  return(ID_TO_AA[np.argmax(row_array)])

def get_seq(fakes, seq_dir, res = 166):
  full_seq_dir = os.path.join('/home/suyuelyu/scratch/proteinGAN/pro_out_seq/', seq_dir)
  print(f'seqs saved in {full_seq_dir}')
  for key, fake in fakes.items():
    for i, col in enumerate(np.split(fake, 30, axis = 1)):
      for j, im in enumerate(np.split(col, 16)):
        pro_img = im[45:211,45:211].reshape([1, res*res])
        pro_img = pro_img[:, 0:27237].reshape([1297,21])  # conversion back tested in previous cell
        pro_np = np.apply_along_axis(get_aa, axis=1, arr=pro_img)
        
        pro_seq = Seq('')
        for aa in pro_np:
          if aa != '-':
            pro_seq += aa
        
        pro_seq_r = SeqRecord(pro_seq, id=f"{key}_{i}_{j}")
        if i%10 == 0 and j%5 == 0:
          file_name = os.path.join(full_seq_dir, f'{key}_{i}_{j}.fasta')
          with open(file_name, "w") as output_handle:
            SeqIO.write(pro_seq_r, output_handle, "fasta")

fakes = read_fake('/home/suyuelyu/scratch/proteinGAN/pro_out_png_to_be_prcd/')
get_seq(fakes, seq_dir = args.seq_dir, res = 166)