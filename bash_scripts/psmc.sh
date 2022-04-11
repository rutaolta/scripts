#!/bin/bash -i
#SBATCH --job-name=psmc                 # Job name
#SBATCH --mail-type=END                 # Mail events
#SBATCH --mail-user=yakupovaar@ya.ru    # Where to send mail
#SBATCH --cpus-per-task=30              # Number of CPU cores per task (max 32)
#SBATCH --mem=250gb                     # Job memory request (max 256gb)
#SBATCH --time=150:00:00                # Time limit hrs:min:sec
#SBATCH --output=/nfs/home/ayakupova/pinnipeds/pusa_sibirica/psmc/logs/psmc.log
#SBATCH --error=/nfs/home/ayakupova/pinnipeds/pusa_sibirica/psmc/logs/psmc.err

FASTA=/mnt/tank/scratch/ayakupova/pcms/draft_HiC.fasta
FASTA_FAI=/mnt/tank/scratch/skliver/common/pinnipeds/varcaller/data_output/assembly_stats/draft_HiC.fai

ASSEMBLY_NAME=draft_HiC
declare -a SAMPLE_NAME=(male female)
d=7 # -d - медианное покрытие/3
D=50 # -D - медианное покрытие*2.5

MAVR_DIR=/nfs/home/ayakupova/tools/MAVR/
ALIGN_DIR=/mnt/tank/scratch/skliver/common/pinnipeds/varcaller/data_output/alignment/

OUTDIR=/mnt/tank/scratch/skliver/common/pinnipeds/PSMC/

hostname; date

conda activate psmc;

mkdir -p $OUTDIR
cd $OUTDIR

for SAMPLE in ${SAMPLE_NAME[@]}; do
    echo $SAMPLE; date
    mkdir -p split/bcf/$SAMPLE/ #split/mpileup/$SAMPLE/

    echo "--------------------------------";

# 1. Запуск mosdepth, для получения медианы
    # echo "START: mosdepth"; date
    # PREFIX=$OUTDIR/$ASSEMBLY_NAME.$SAMPLE.coverage
    BAM=$ALIGN_DIR/$SAMPLE/$ASSEMBLY_NAME.$SAMPLE.sorted.mkdup.bam
    # # mosdepth --threads 20 $PREFIX $BAM
    # # echo "END: mosdepth"; date

    echo "--------------------------------";
    echo "FASTA_FAI="$FASTA_FAI
    echo "FASTA="$FASTA
    echo "BAM="$BAM
    echo "--------------------------------";

# 2. Коллинг вариантов
    echo "START: 1. varcalling"; date
    python3 $MAVR_DIR/scripts/sequence/prepare_region_list.py -r $FASTA_FAI -s -m 1500000 -n 1 -g samtools -x 1000 2>/dev/null | parallel -j 10 'samtools mpileup -C 50 -uf '$FASTA' -r {} '$BAM' | bcftools view -b -c - > split/bcf/'$SAMPLE'/tmp.{#}.bcf';
    echo "END: varcalling"; date
    echo "--------------------------------";

# 3. Конкатенация bcf файлов
    echo "START: 2. concatenate bcf"; date
    bcftools cat `ls split/bcf/$SAMPLE/tmp.*.bcf | sort -V` >> $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.bcf;
    echo "[OUTPUT] "$OUTDIR/$ASSEMBLY_NAME.$SAMPLE.bcf;
    echo "END: concatenate bcf"; date

    echo "--------------------------------";

# 4. Конвертация bcf в vcf
    echo "START: 3.1. convert bcf into vcf"; date
    bcftools view $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.bcf >> $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.vcf;
    echo "[OUTPUT] "$OUTDIR/$ASSEMBLY_NAME.$SAMPLE.vcf
    echo "END: convert bcf into vcf"; date

    echo " ";
    
    echo "START: 3.2. pigz vcf"; date
    pigz -p 5 $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.vcf
    echo "[OUTPUT] "$OUTDIR/$ASSEMBLY_NAME.$SAMPLE.vcf.gz
    echo "END: pigz vcf"; date

    echo "--------------------------------";

# 5. Создание fastq файла
    echo "START: 4. create fastq"; date
    zcat $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.vcf.gz | vcfutils.pl vcf2fq -d $d -D $D | gzip > $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.fq.gz;
    echo "[OUTPUT] "$OUTDIR/$ASSEMBLY_NAME.$SAMPLE.fq.gz
    echo "END: create fastq"; date

    echo "--------------------------------";

# 6. Запуск PSMC
    echo "START: 5. PSMC"; date
    cd /nfs/home/ayakupova/tools/
    echo "5.1 PSMC: fq2psmcfa"; date
    psmc/utils/fq2psmcfa -q20 $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.fq.gz > $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.diploid.psmcfa
    echo "[OUTPUT] "$OUTDIR/$ASSEMBLY_NAME.$SAMPLE.diploid.psmcfa;
    echo ""

    echo "5.2 PSMC: splitfa"; date
    psmc/utils/splitfa $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.diploid.psmcfa > $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.split.psmcfa
    echo "[OUTPUT] "$OUTDIR/$ASSEMBLY_NAME.$SAMPLE.split.psmcfa;
    echo ""

    echo "5.3 PSMC: psmc"; date
    psmc/psmc -N25 -t15 -r5 -p "4+25*2+4+6" -o $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.diploid.psmc $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.diploid.psmcfa
    echo "[OUTPUT] "$OUTDIR/$ASSEMBLY_NAME.$SAMPLE.diploid.psmc;
    echo ""

    echo "5.4 PSMC: plot"; date
    psmc/utils/psmc_plot.pl $OUTDIR/$ASSEMBLY_NAME.$SAMPLE $OUTDIR/$ASSEMBLY_NAME.$SAMPLE.diploid.psmc
    echo "[OUTPUT] "$OUTDIR/$ASSEMBLY_NAME.$SAMPLE.plot;
    echo ""

    echo "END: PSMC"; date

    echo "--------------------------------";

done

echo 'done';
date;
