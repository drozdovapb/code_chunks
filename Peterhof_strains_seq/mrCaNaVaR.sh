strains=( 15V 1B 25b 25m 25P)
for strain in "${strains[@]}"; do ~/lib/split_reads_new.py /storage1/s_pdrozdova/Peterhof_strains_seq/Reads/Trimmed/$strain.cutadapt.fastq >Split_reads/$strain.split.fastq; done

#for 74
~/lib/split_reads_new.py /storage1/s_pdrozdova/Peterhof_strains_seq/Reads/Raw/74D_sequence.fastq >Split_reads/74.split.fastq

strains=( 15V 1B 25b 25m 25P 74)
for strain in "${strains[@]}"; do mrfast --search S288c.hard.masked.fsa --seq Split_reads/$strain.split.fastq -o Alignments/$strain.sam; done


strains=( 15V 1B 25b 25m 25P 74)
for strain in "${strains[@]}"; do mrcanavar --prep -fasta S288c.hard.masked.fsa -gaps S288C.gaps.bed --seq Split_reads$strain.split.fastq -lw_side 1000 -lw_slide 500 -conf $strain.cnvr; done
#S288C.gaps.bed is just an empty file 

#read mode
for strain in "${strains[@]}"; do mrcanavar --read -conf $strain.cnvr -samdir Alignments -depth $strain.depth; done
for strain in "${strains[@]}"; do mrcanavar --call -conf $strain.cnvr -depth $strain.depth -o $strain; done

awk '{print $1, $2, $3, $4, $5/2}' 15V.copynumber.bed >15V.haploid.copynumber.bed

#amplified and deleted genes

strains=( 15V 25b 1B 74 6P)
for strain in "${strains[@]}"; do bedtools intersect -a $strain.ampl.intervals.bed -b ./S288C.Verified.gff -wb >|$strain.mrcanavar.amplified.genes.gff; done
for strain in "${strains[@]}"; do bedtools intersect -a $strain.del.intervals.bed -b ./S288C.Verified.gff -wb >|$strain.mrcanavar.deleted.genes.gff; done
for strain in "${strains[@]}"; do grep -o 'ID=[^;]*' $strain.mrcanavar.amplified.genes.gff | sed -e 's/ID=//' >|$strain.amplified.genes.txt; done
for strain in "${strains[@]}"; do grep -o 'ID=[^;]*' $strain.mrcanavar.deleted.genes.gff | sed -e 's/ID=//' >|$strain.deleted.genes.txt; done

