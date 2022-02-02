fasta_paths=$1

echo ${fasta_paths}

# Run your commands
# ,model_2,model_3,model_4,model_5

DATA_DIR=$SCRATCH/proteinGAN/pro_out_seq   # Set the appropriate path to your supporting data
REPO_DIR=$SCRATCH/alphafold # Set the appropriate path to AlphaFold's cloned repo
DOWNLOAD_DIR=$SCRATCH/alphafold/reduced_data  # Set the appropriate path to your downloaded data

python ${REPO_DIR}/run_alphafold.py \
   --data_dir ${DOWNLOAD_DIR} \
   --uniref90_database_path ${DOWNLOAD_DIR}/uniref90/uniref90.fasta \
   --mgnify_database_path ${DOWNLOAD_DIR}/mgnify/mgy_clusters_2018_12.fa \
   --small_bfd_database_path ${DOWNLOAD_DIR}/small_bfd/bfd-first_non_consensus_sequences.fasta \
   --pdb70_database_path ${DOWNLOAD_DIR}/pdb70/pdb70 \
   --template_mmcif_dir ${DOWNLOAD_DIR}/pdb_mmcif/mmcif_files \
   --obsolete_pdbs_path ${DOWNLOAD_DIR}/pdb_mmcif/obsolete.dat \
   --fasta_paths ${fasta_paths} \
   --max_template_date 2022-01-31 \
   --hhblits_binary_path ${EBROOTHHMINSUITE}/bin/hhblits \
   --hhsearch_binary_path ${EBROOTHHMINSUITE}/bin/hhsearch \
   --jackhmmer_binary_path ${EBROOTHMMER}/bin/jackhmmer \
   --kalign_binary_path ${EBROOTKALIGN}/bin/kalign \
   --model_names model_1 \
   --output_dir $SCRATCH/proteinGAN/structure_gen_seq/ \
   --preset reduced_dbs