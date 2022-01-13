import timm
import argparse
import os
import torch

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model_name", required=True, 
                        type=str, help="name of the model needed, a full list of all modle available \
                        from timm can be found with timm.list_models()")
    parser.add_argument("--outdir",required=True, default="/scratch/suyuelyu/proteinGAN/projected_gan/leg_pkl",
                        type=str, help="output_dir")      
    return parser.parse_args()

parameters = parse_args()

# load and save whatever model needed to a local pkl
model = timm.create_model(parameters.model_name, pretrained=True)

model_dir = os.path.join(parameters.outdir, f'{parameters.model_name}.pkl')
with open(model_dir, "wb") as file:
    torch.save(model, file)

