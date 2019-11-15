This folder contains code for the analysis of microsporidian parasites in *Gammarus lacustris* (submitted to the Journal of Invertebrate Pathology). 


###Analysis (code examples)

1. Got data from NCBI with NCBI eutils like that: 
`efetch -db nuccore -format fasta -id AF397404`
`$appdir/sratoolkit.2.9.2-ubuntu64/bin/fastq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files --gzip -A SRX3651990`

2. bbduk (**check for Microsporidia in RNA-seq data**) 
For one sample: 
`bbduk.sh -Xmx16g -in1=sample_R1.fastq.gz -in2=sample_R2.fastq.gz ref=genbank_sequences.fa k=63 hdist=0 outm=sample.microsporidia.fq stats=sample.stats.txt; done`

For a folder: 
`for sample in `ls $folder_with_reads/*1.fastq.gz`; do base=$(basename $sample "_1.fastq.gz"); folder=$(dirname $sample); bbduk.sh -Xmx16g -in1=$folder/${base}_1.fastq.gz -in2=$folder/${base}_2.fastq.gz ref=../genbank_sequences.fa k=63 hdist=0 outm=$base.microsporidia.fq stats=$base.stats.txt; done`

3. Consensus sequences from RNA-seq data

For one file
(align; variant calling; vcf => fastq => fasta; get meaningful names for the sequences):

`export file=SRX3651990.microsporidia.fq`
`bbmap.sh -Xmx16g in=SRX3651990.microsporidia.fq ref=Dde.fasta outm=alignment_Dde/SRX3651990.microsporidia.fq.sam threads=6`
`cd alignment_Dde`
`samtools sort SRX3651990.microsporidia.fq.sam -o SRX3651990.microsporidia.fq.sam_sorted.bam $appdir/bcftools-1.9/bcftools mpileup -f ../Dde.fasta $file.sam_sorted.bam | $appdir/bcftools-1.9/bcftools call -c >$file.vcf`
`vcfutils.pl vcf2fq $file.vcf  > ${file}_cns.fastq`
`seqtk seq -aQ64 -q5 -n N ${file}_cns.fastq > $file.fasta`
`awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $file.fasta |sed -e 's/.microsporidia.fq.sam.vcf_cns.fastq//g' >$file.fasta.done.fasta`


The same for the folder.
(align; variant calling; vcf => fastq => fasta; get meaningful names for the sequences)
`for file in Sample_Gla*.fq; do bbmap.sh -Xmx16g in=$file ref=Dde.fasta outm=alignment_Dde/$file.sam threads=6; done`
`cd alignment_Dde`
`for file in *sam; do samtools sort $file -o ${file}_sorted.bam; $appdir/bcftools-1.9/bcftools mpileup -C 50 -f ../Dde.fasta $file_sorted.bam | $appdir/bcftools-1.9/bcftools call -c >$file.vcf; done`
`for file in *vcf; do vcfutils.pl vcf2fq $file  > ${file}_cns.fastq; done`
`for file in *fastq; do seqtk seq -aQ64 -q5 -n N $file > $file.fasta; done`
`for fastafile in *fasta; do awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $fastafile | sed -e 's/.microsporidia.fq.sam.vcf_cns.fastq//g' >$fastafile.done.fasta; done`

`cat *done.fasta >fromRNA.fasta`

3. Cleaning up data
At this point we may get into trouble with consensus files from non-infected samples, as they are close to NNN.

`cat ../tree_with_RNAseq/2classify_D.fa ../alignment_Dde/fromRNA.fasta >2classify_D_w_RNAseq_Dde.fa`
`grep -c \> 2classify_D_w_RNAseq_Dde.fa` #123
`faFilter 2classify_D_w_RNAseq_Dde.fa -maxN=200 2classify_D_w_RNAseq_Dde_good.fa`
`grep -c \> 2classify_D_w_RNAseq_Dde_good.fa` #104


4. Tree with RNAseq data

`cat 2classify_D_w_RNAseq_Dde_good.fa BaikalD.fa > Gla_RNAseq_Baikal.fa`
`mafft --auto Gla_RNAseq_Baikal.fa >Gla_RNAseq_Baikal.aln`
`$appdir/iqtree-1.6.10-Linux/bin/iqtree -s Gla_RNAseq_Baikal.trim.aln -abayes -alrt 1000` 

5. Tree with other microsporidian genera 

`mafft --auto 2classify_Gla_Microsporidia.fa >2classify_Gla_Microsporidia.aln` ## L-INS-i (Probably most accurate, very slow)
`~/apt/trimal/source/trimal -in 2classify_Gla_Microsporidia.aln -out 2classify_Gla_Microsporidia_trim.aln` ##strict is too strict
`~/apt/iqtree-1.6.7-Linux/bin/iqtree -s 2classify_Gla_Microsporidia_trim.aln -abayes -alrt 1000`

###R code and data for the figures
Fig. 1A: `Fig1A_map.R`. The data are available from Table S2.
Fig. 1B: `Fig1B_data.xlsx` and `Fig1B_distribution.R`.
Fig. 2: `Fig2_bbduk_results_allGla.csv` and `Fig2_Microsporidia_statistics_bbduk_lacustris.R`.
Fig. 3: `Fig3_S3_Gla_RNAseq_Baikal_renamed.treefile` (newick from iqtree) and `Fig3_S3_tree_circle.R`.

