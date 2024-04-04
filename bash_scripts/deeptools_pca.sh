#!/bin/bash

#SBATCH -J pca
#SBATCH --get-user-env
#SBATCH --clusters=
#SBATCH --partition=
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=end
#SBATCH --mail-user=
#SBATCH --export=NONE
#SBATCH --time=18:00:00

hostname; date;
module load anaconda3/2021.05;
source ~/.bashrc;
#conda create --name deeptools -c bioconda deeptools;
conda activate deeptools;

output=~/pca/X/;
path=/dss/dsslegfs01/pr53da/pr53da-dss-0019/tobecleaned/b2016179_nobackup/private/Pop_gen/Hi_C/Split_by_chr/X;

echo 'multiBamSummary';
cd $path;
bamlist=($(cat  $output/All_sea_lion_CM019819.2.bamlist.txt))
multiBamSummary bins --bamfiles $(echo ${bamlist[@]}) -o $output/all_sea_lions_CM019819.npz;
# multiBamSummary bins --bamfiles $(ls *_merged_duprm_*.bam) -r CM019819.2 -o $output/all_sea_lions_CM019820.npz;

echo 'pca';
plotPCA -in $output/all_sea_lions_CM019819.npz -o $output/all_sea_lions_CM019819.png -T "PCA of read counts";

echo 'end';

date;



