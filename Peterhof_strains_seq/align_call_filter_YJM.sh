strain=$1
accn=$1
strain=${2:-$accn}

cd /storage1/s_pdrozdova/Peterhof_strains_seq/Genomes

shracc=${accn:0:6}
wget ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/$shracc/$accn/$accn.sra

fastq-dump --split-files $strain.sra

cd /storage1/s_pdrozdova/Peterhof_strains_seq/Alignment_to_ref/
bowtie2-align -x /storage1/s_pdrozdova/Peterhof_strains_seq/reference/ -1 /storage1/s_pdrozdova/Peterhof_strains_seq/Genomes/"${strain}_1.fastq" -2 /storage1/s_pdrozdova/Peterhof_strains_seq/Genomes/"${strain}_2.fastq" -p 12 -S $strain.to.S288C.sam
samtools view -bS $strain.to.S288C.sam >$strain.to.S288C.bam
samtools sort $strain.to.S288C.bam $strain.to.S288C.sorted

cd /storage1/s_pdrozdova/Peterhof_strains_seq/SNPs/YJM
samtools mpileup -ugf /storage1/s_pdrozdova/Peterhof_strains_seq/reference/S288c_renamed18.fsa /storage1/s_pdrozdova/Peterhof_strains_seq/Alignment_to_ref/$strain.to.S288C.sorted.bam | bcftools call -vmO z -o $strain.vcf
bcftools view $strain.vcf | vcfutils.pl varFilter > $strain.filt.vcf
vcftools --vcf $strain.filt.vcf --minDP 3 --minQ 30 --remove-indels --recode --remove-filtered-all --stdout >$strain.snps.vcf
bedtools intersect -a $strain.snps.vcf -b ../../reference/S288c_renamed18.fsa.out.gff -v >$strain.snps.no-rep.vcf
vcftools --vcf $strain.filt.vcf --minDP 3 --minQ 30 --recode --remove-filtered-all --stdout >$strain.qual.vcf
bedtools intersect -a $strain.qual.vcf -b ../../reference/S288c_renamed18.fsa.out.gff -v >$strain.qual.no-rep.vcf
bedtools intersect -v -a $strain.qual.no-rep.vcf -b $strain.snps.no-rep.vcf >$strain.indels.vcf
grep -v '0/1' $strain.indels.vcf >$strain.homozygous.indels.vcf
