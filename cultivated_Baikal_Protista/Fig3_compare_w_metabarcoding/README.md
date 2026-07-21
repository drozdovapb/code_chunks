Data from six studies on metabarcoding of Baikal eukaryotic plankton were reanalyzed.

#### I. Mikhailov et al., 2019

> <small> Mikhailov IS, Zakharova YR, Bukin YS, Galachyants YP, Petrova DP, Sakirko MV, Likhoshway YV. Co-occurrence networks among bacteria and microbial eukaryotes of Lake Baikal during a spring phytoplankton bloom. Microbial ecology. 2019 Jan 1;77(1):96-109. https://doi.org/10.1007/s00248-018-1212-2 </small>

These data contain the V3 18S rRNA region, which was also sequences for the three isolates studied in this work.

The data are not demultiplexed; instructions (barcodes) are provided in the comments for the SRA run, so barcode files were created using the information about the kit (https://www.seqanswers.com/filedata/fetch?id=303687).

```
mkdir Mikhailov2019; cd Mikhailov2019/
##download data with fasterq-dump from SRA toolkit.
fasterq-dump SRR2027823
## quality trim
cutadapt -q 30 -o SRR2027823_qualtrim_q30.fastq SRR2027823.fastq 
## split into 2 files for samples
grep -A 3 HXH779K01 SRR2027823_qualtrim_q30.fastq > SRR2027823_HXH779K01.fastq 
grep -A 3 HXH779K02 SRR2027823_qualtrim_q30.fastq > SRR2027823_HXH779K02.fastq 
## demultiplex
cutadapt -e 1 -g file:barcodes_HXH779K01.fasta -o "trimmed-{name}.fastq.gz" SRR2027823_HXH779K01.fastq 
cutadapt -e 1 -g file:barcodes_HXH779K02.fasta -o "trimmed-{name}.fastq.gz" SRR2027823_HXH779K02.fastq 
## organize
rm trimmed-unknown.fastq.gz
mkdir demultiplexed/
mv trimmed*fastq.gz demultiplexed/
## remove primers
for file in demultiplexed/*; do cutadapt -g ATTAGGGTTCGATTCCGGAGAGG -a CTGGAATTACCGCGGSTGCTG -o $file.primerremoved.fastq.gz $file; done
## mostly 100% reads with adapters
## organize
cd demultiplexed/
mkdir primer_removed
mv *primerremoved* primer_removed/
## prepare fasta files 
cd primer_removed/
for file in *fastq.gz; do seqkit fq2fa $file > $file.fa; done
mkdir fasta_databases
mv *fa fasta_databases/
cd fasta_databases/
## make databases for blast
for file in *fa; do makeblastdb -in $file -dbtype nucl; done
## run blastn search
for file in *fa; do echo $file; blastn -db $file -query ../../../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 5; done
```

#### II. Annenkova et al. 2020 data

> <small> Annenkova NV, Giner CR, Logares R. Tracing the origin of planktonic protists in an ancient lake. Microorganisms. 2020;8(4):543. http://dx.doi.org/10.3390/microorganisms8040543 </small>

```
mkdir Annenkova2020; cd Annenkova2020
fasterq-dump ERR2247272
...
fasterq-dump ERR2247294
## quality trim
for file in *fastq; do cutadapt -q 30 -o $file.q30.fastq $file; done
## primer trimming left out, as those seem to be already trimmed
## merge R1 and R2
for file in *_1.fastq.q30.fastq; do 
  id="${file%_*}"; \
  flash -m 20 -M 150 ${id}_1.fastq.q30.fastq ${id}_2.fastq.q30.fastq -o $id; \
done
## cleaning up:
mkdir 0_raw
mkdir 1_merged
mv *extendedFrags* 1_merged/
mv *fastq 0_raw/
rm *hist
rm *histogram
## make blast databases and run blastn
cd 1_merged/
for file in *fastq; do seqkit fq2fa $file >$file.fa; done
for file in *fa; do makeblastdb -in $file -dbtype nucl; done
#for file in *fa; do echo $file; blastn -db $file -query ../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 5; done
for file in *fa; do echo $file; blastn -db $file -query ../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 1; done
```

#### III. David et al., 2020

> <small> David GM, Moreira D, Reboul G, Annenkova NV, Galindo LJ, Bertolino P, López‐Archilla AI, Jardillier L, López‐García P. Environmental drivers of plankton protist communities along latitudinal and vertical gradients in the oldest and deepest freshwater lake. Environmental Microbiology. 2021;23(3):1436-51. https://doi.org/10.1111/1462-2920.15346 </small>

```
## download fastq
cat ids.txt | xargs -I {} fasterq-dump --split-files {}
## quality trim
for file in *fastq; do cutadapt -q 30 -o $file.q30.fastq $file; done
## primer trim
for file in *_1.fastq.q30.fastq; do 
  id="${file%_*}"; \
  cutadapt -g GCAGTTAAAAAGCTCGTAGT -G TTTAAGTTTCAGCCTTGCG -o ${id}_1.trim.fastq -p ${id}_2.trim.fastq --discard-untrimmed --minimum-length 150 ${id}_1.fastq.q30.fastq ${id}_2.fastq.q30.fastq; \
done
## about 50% written
## merge
for file in *_1.fastq.q30.fastq; do 
  id="${file%_*}"; \
  flash -m 20 -M 200 ${id}_1.trim.fastq ${id}_2.trim.fastq -o $id; \
done
## cleaning up:
mkdir 0_raw; mkdir 1_merged
mv *extendedFrags* 1_merged/; mv *fastq 0_raw/
rm *hist; rm *histogram
## make databases and run blastn
cd 1_merged/
for file in *fastq; do seqkit fq2fa $file >$file.fa; done
for file in *fa; do makeblastdb -in $file -dbtype nucl; done
#for file in *fa; do echo $file; blastn -db $file -query ../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 5; done
for file in *fa; do echo $file; blastn -db $file -query ../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 1; done
```

#### IV. Reboul et al., 2021

> <small> Reboul G, Moreira D, Annenkova NV, Bertolino P, Vershinin KE, López-García P. Marine signature taxa and core microbial community stability along latitudinal and vertical gradients in sediments of the deepest freshwater lake. The ISME Journal. 2021;15(11):3412-7. https://doi.org/10.1038/s41396-021-01011-y </small>

```
mkdir Reboul2021; cd Reboul2021/

mkdir 0_raw; cd 0_raw/
fasterq-dump SRR13348950
...
fasterq-dump SRR13348964
## quality trim
for file in *fastq; do cutadapt -q 30 -o $file.q30.fastq $file; done
## trim primers
for file in *_1.fastq.q30.fastq; do 
id="${file%_*}"; \
cutadapt -g GCAGTTAAAAAGCTCGTAGT -G TTTAAGTTTCAGCCTTGCG -o ${id}_1.trim.fastq -p ${id}_2.trim.fastq --discard-untrimmed --minimum-length 150 ${id}_1.fastq.q30.fastq ${id}_2.fastq.q30.fastq; \
done
# primers found in ~50%, which is suspicious, but proceeding
## merge
for file in *_1.fastq.q30.fastq; do 
  id="${file%_*}"; \
  flash -m 10 ${id}_1.trim.fastq ${id}_2.trim.fastq -o $id; \
done
## clean up
mkdir ../1_merged
mv *extendedFrags* ../1_merged/
## make fasta files for databases
cd ../1_merged
for file in *fastq; do seqkit fq2fa $file >$file.fa; done
## make databases and run blastn
for file in *fa; do makeblastdb -in $file -dbtype nucl; done
for file in *fa; do echo $file; blastn -db $file -query ../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 5; done
```

#### V. Bukin et al., 2023

> <small> Bukin YS, Mikhailov IS, Petrova DP, Galachyants YP, Zakharova YR, Likhoshway YV. The effect of metabarcoding 18S rRNA region choice on diversity of microeukaryotes including phytoplankton. World Journal of Microbiology and Biotechnology. 2023;39(9):229. https://doi.org/10.1007/s11274-023-03678-1 </small>

```
## download files (in a cycle)
cat ids.txt | xargs -I {} fasterq-dump --split-files {}
## quality trim
for file in *fastq; do cutadapt -q 30 -o $file.q30.fastq $file; done
## primer trim
for file in *_1.fastq.q30.fastq; do 
  id="${file%_*}"; \
  cutadapt -g CCAGCASCYGCGGTAATTCC -G ACTTTCGTTCTTGAT -o ${id}_1.trim.fastq -p ${id}_2.trim.fastq --discard-untrimmed --minimum-length 150 ${id}_1.fastq.q30.fastq ${id}_2.fastq.q30.fastq; \
done
# about 80% written, finally!
## merge
for file in *_1.fastq.q30.fastq; do 
  id="${file%_*}"; \
  flash -m 20 -M 200 ${id}_1.trim.fastq ${id}_2.trim.fastq -o $id; \
done
# percent combined close to 100%!!
## cleaning up:
mkdir 0_raw; mkdir 1_merged
mv *extendedFrags* 1_merged/; mv *fastq 0_raw/
rm *hist; rm *histogram
## make databases and run blastn
cd 1_merged/
for file in *fastq; do seqkit fq2fa $file >$file.fa; done
for file in *fa; do makeblastdb -in $file -dbtype nucl; done
#for file in *fa; do echo $file; blastn -db $file -query ../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 5; done
for file in *fa; do echo $file; blastn -db $file -query ../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 1; done
```

#### VI. Morozov et al., 2023

> <small> Morozov A, Galachyants Y, Marchenkov A, Zakharova Y, Petrova D. Revealing the differences in Ulnaria acus and Fragilaria radians distribution in Lake Baikal via analysis of existing metabarcoding data. Diversity. 2023;15(2):280. https://doi.org/10.3390/d15020280 </small>

```
## download files
fasterq-dump SRR12737838
fasterq-dump SRR12737844
## quality trim
for file in *fastq; do cutadapt -q 30 -o $file.q30.fastq $file; done
## primer trim
for file in *_1.fastq.q30.fastq; do 
  id="${file%_*}"; \
  cutadapt -g CCAGCASCYGCGGTAATTCC -G ACTTTCGTTCTTGAT -o ${id}_1.trim.fastq -p ${id}_2.trim.fastq --discard-untrimmed --minimum-length 150 ${id}_1.fastq.q30.fastq ${id}_2.fastq.q30.fastq; \
done
# written >90%, good!
## merge files
for file in *_1.fastq.q30.fastq; do 
  id="${file%_*}"; \
  flash -m 20 -M 200 ${id}_1.trim.fastq ${id}_2.trim.fastq -o $id; \
done
# percent combined >99%!
## cleaning up:
mkdir 0_raw; mkdir 1_merged
mv *extendedFrags* 1_merged/; mv *fastq 0_raw/
rm *hist; rm *histogram
## making blast databases and running blastn
cd 1_merged/
for file in *fastq; do seqkit fq2fa $file >$file.fa; done
for file in *fa; do makeblastdb -in $file -dbtype nucl; done
#for file in *fa; do echo $file; blastn -db $file -query ../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 5; done
for file in *fa; do echo $file; blastn -db $file -query ../../our_seqs/query_seqs_x3.fasta -outfmt 6  -max_target_seqs 1; done
```
