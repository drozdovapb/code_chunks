

## This folder provides details of the data analysis pipeline for Drozdova *et al.* manuscript *The levels of putative carotenoid-binding proteins as the mechanism of color formation in two species of endemic Lake Baikal amphipods* (submitted to PeerJ)

### Data analysis overview

The raw and assembled RNA-seq reads published in (Naumenko *et al.*, 2017, Drozdova *et al.*, 2019) 
were downloaded from NCBI with `sratoolkit v2.9.2`: 

```
##assemblies (amphipods)
fastq-dump --outdir Eulimnogammarus_cyaneus_GEPV01 -F --fasta GEPV01
fastq-dump --outdir Eulimnogammarus_cyaneus_GEPS01 -F --fasta GEPS01
fastq-dump --outdir Eulimnogammarus_vittatus_GHHW01 -F --fasta GHHW01
##reads for reassembly (E. vittatus)
fastq-dump --outdir Eulimnogammarus_vittatus --gzip \ 
--defline-seq '@$sn[_$rn]/$ri' --readids --split-3 SRR3467061
```

The were reassembled with `Trinity v2.8.5.` if necessary (example code for *E. vittatus*): 

```
Trinity --seqType fq --left SRR3467061_1.fastq.gz --right SRR3467061_2.fastq.gz  \ 
--CPU 6 --max_memory 32G --full_cleanup --output trinity_Eulimnogammarus_vittatus
```

Databases for mass spectrometry protein identification were prepared with TransDecoder v2.0.1 (example for *E. cyaneus*) and required some name editing before submitting to `SearchGUI`:
The file `crap.fa` was downloaded from ftp://ftp.thegpm.org/fasta/cRAP (version 3/4/19).

```
TransDecoder.LongOrfs -t Eulimnogammarus_cyaneus_GEPS01.fasta
TransDecoder.Predict -t Eulimnogammarus_cyaneus_GEPS01.fasta
cat Eulimnogammarus_cyaneus_GEPS01.fasta.transdecoder.pep crap.fa > Ecy_GEPS01_contam.fasta
sed -e's/gi.*gb|//' Ecy_GEPS01_contam.fasta >EcyGEPS01_and_contam.shortnames.fasta
```

The downloaded or assembled transcript sequences were also used as databases to search for the crustacyanin A2 of *H. gammarus* (https://www.uniprot.org/uniprot/P80007)

(Example code for one of the assemblies): 
```
$file=Eulimnogammarus_cyaneus_GHHW01/GHHW01.fasta
makeblastdb -in $file -dbtype nucl
tblastn -query Hga_A2.faa -db $file -outfmt 6 >Ecy_GHHW01.fasta.blastout.txt
```

The blast search returned from 22 to 40 hits from different species (supposedly, transcripts encoding different proteins of the lipocalin family). To further classify the obtained sequences, we annotated them with `diamond v0.9.23.124` (example code below). 
Interestingly, neither percent identity nor e-value turned out to be instrumental for choosing putative crustacyanins.

```
cut -f 2 Ecy_GHHW01.fasta.blastout.txt >Ecy_GHHW01.txt
xargs faidx GHHW01.fasta < Ecy_GHHW01.txt >Ecy_GHHW01.fa
getorf -find 1 Ecy_GHHW01.fa -out Ecy_GHHW01.faa -reverse no -minsize 300
diamond blastp --threads 6 --db $db/nrd201710207.dmnd --out Ecy_GHHW01.diamond.tsv  \ 
--sensitive --query Ecy_GHHW01.faa --max-target-seqs 10  -f 6 qseqid sseqid pident \
length mismatch gapopen qstart qend sstart send evalue bitscore stitle salltitles
grep crustacyanin Ecy_GHHW01.diamond.tsv | cut -f 1 | sort | uniq > Ecy_GHHW01_crust.txt
xargs faidx Ecy_GHHW01.faa < Ecy_GHHW01_crust.txt >Ecy_GHHW01_crust.faa
```

These protein sequences were processed with the SignalP-5.0 web server (http://www.cbs.dtu.dk/services/SignalP/), and their physical properties were predicted with the ExPaSy server (https://web.expasy.org/compute_pi/).

The sequences used to build the tree (protein sequences were predicted with `transDecoder` or `getorf` if necessary (see above); NCBI Genbank accounts are listed if avaiable; some sequences (`comp*` or `TRINITY*`) are internal IDs of the contigs in the assembly and are available from (Mojib et al., 2014) or Texts S2 and S3): 
```
>GEPS01030296_Eulimnogammarus_cyaneus
>GEPV01033026_Eulimnogammarus_vittatus
>GEPS01035623_Eulimnogammarus_cyaneus
>GEPV01033441_Eulimnogammarus_vittatus
>BJ929035_Daphnia_magna
>EFX89904_CBP_Daphnia_pulex
>EB409138_ApoD_Penaeus_monodon
>EFX87814_CBP_Daphnia_pulex
>comp54972_c1_CBP_Acartia_fossae
>comp37429_c0_CBP_Acartia_fossae
>comp456480_c0_CBP_Acartia_fossae
>comp54867_c0_CBP_Acartia_fossae
>CBY33375_CBP_Oikopleura_dioica
>CBY11780_CBP_Oikopleura_dioica
>CBY22422_CBP_Oikopleura_dioica
>comp52556_c0_CBP_Acartia_fossae
>comp51126_c0_CBP_Acartia_fossae
>EFX90456_CBP_Daphnia_pulex
>P80007_CRCN-A2_Homarus_gammarus
>ACL37112_CRCN-A1_precursor_Panulirus_cygnus
>HM370278_CRCN-A1_Fenneropenaeus_merguiensis
>KP790005_CRCN-A1_Penaeus_monodon
>MF627617_CRCN-A2_Penaeus_monodon
>P80029_CRCN-C1_Homarus_gammarus
>CV468290_CRCN-C1_Litopenaeus_vannamei
>FE049586_CRCN-C3_Litopenaeus_vannamei
>MF627612_CRCN-C3_Penaeus_monodon
>JR494407_CRCN-C2_Litopenaeus_vannamei
>KP790006_CRCN-C1_Penaeus_monodon
>QBO59873_CRCN-1_Eriocheir_sinensis
>QBO59874_CRCN-2_Eriocheir_sinensis
>TRINITY_DN24_c0_g1_i9_1_Eulimnogammarus_vittatus
>GHHW01017383_Eulimnogammarus_cyaneus
>EH269222_Gammarus_pulex
>EH270832_Gammarus_pulex
>XP_018027662_CRCN-A2-like_Hyalella_azteca
>GHHW01018656_Eulimnogammarus_cyaneus
>XP_018011458_CRCN-A2-like_Hyalella_azteca
>TRINITY_DN22674_c0_g2_i1_1_Eulimnogammarus_vittatus
>GHHW01007580_Eulimnogammarus_cyaneus
>GHHW01016324_Eulimnogammarus_cyaneus
>GHHW01011113_Eulimnogammarus_cyaneus 
```

Tree construction: 
```
prank -d=cleaner_set.faa -protein -o=CBPs
trimal -automated1 -in CBPs.best.fas >CBPs.best.trim.fas 
iqtree -s CBPs.best.trim.fas -alrt 1000 -abayes
```

The resulting tree was visualized in the `R` programming environment `v3.6.1` with the ggtree package `v1.16.6`. The code is available in `tree.R`.

Expression levels were estimated with with salmon v0.12.0 with the wrapper script from Trinity v2.8.5:

```
export assembly=trinity_Eulimnogammarus_cyaneus.Trinity.fasta
$appdir/trinityrnaseq-2.8.5/util/align_and_estimate_abundance.pl --transcripts $assembly \
                        --est_method salmon --trinity_mode --prep_reference

for readdir in $transcriptome_raw/Sample_EcyB*/; do
$appdir/trinityrnaseq-2.8.5/util/align_and_estimate_abundance.pl --transcripts $assembly \
--seqType fq --left $readdir/*R1.fastq.gz --right $readdir/*R2.fastq.gz --est_method salmon \
--aln_method salmon --prep_reference --output_dir $(basename $readdir); done
```

Finally, the expression level of particular transcripts was recovered with `grep`:

```
##match the Genbank IDs to the IDs in the reassembled transcriptome
exonerate --query CBP.faa --target Eulimnogammarus_cyaneus.Trinity.fasta --bestn 1
##get expression estimates 
grep TRINITY_DN36791_c0_g2_i1 Sample_EcyB*/quant.sf
```


### Other files 

* `CBPs.best.trim.fas`: alignment used to build tree (Fig. 5A).
* `CBPs.best.trim.fas.treefile`: newick tree file (Fig. 5A).
* `tree.R`: R code for tree visualization (Fig. 5A).
