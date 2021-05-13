## Proteomic dataset for *Eulimnogammarus verrucosus* hemocytes

Supplementary data for Zolotovskaya *et al.* (submitted to Biological Communications).

### Pipeline overview

0. The mass spectrometry proteomics data have been deposited to the ProteomeXchange Consortium via the PRIDE partner repository with the dataset identifier PXD023514 and 10.6019/PXD023514. </p>
The transcriptome assembly used in this work is published in Drozdova *et al.*, 2019 ([BMC Genomics](https://doi.org/10.1186/s12864-019-6024-3)).

1. Database for identification.

2. The raw MS data were processed with the SearchGUI v3.3.17 and Peptide Shaker v1.16.44 software.
CLI PeptideShaker report export:
`java -cp $appdir/PeptideShaker-1.16.45/PeptideShaker-1.16.45.jar eu.isas.peptideshaker.cmd.ReportCLI -in PeptideShaker_output.cpsx -reports "6" -out_reports .`

3. Sequence annotation: `diamond`, `panther`
4. cat all_found_proteins_mature.fasta all_found_proteins.fasta >mature_all_found_proteins.fasta
  538  /media/secondary/apps/seqkit rmdup -n mature_all_found_proteins.fasta 
  539  /media/secondary/apps/seqkit rmdup -n mature_all_found_proteins.fasta >mature_all_found_proteins_dedup.fasta 
 Funnily enough, it worked!
 
 
perl ~/lib/tmhmm-2.0c/bin/tmhmm mature_all_found_proteins.fasta >all_found_proteins_mature.tmhmm
## Даже быстрее, чем я думала.
##tmhmm устанавливается легко, требует только исправления расположения perl

[comment]: <> `grep "Number of predicted TMHs: " all_found_proteins_mature.tmhmm | grep -v "Number of predicted TMHs:  0" | sed -e's/_.*//g' | sed -e's/# ' >proteins_with_TMHs_main_accession.txt` </br>
`grep "Number of predicted TMHs: " all_found_proteins_mature.tmhmm | grep -v "Number of predicted TMHs:  0" | sed -e's/# //g' | sed -e 's/ .*//g' >Fig2A_proteins_with_TMHs_ids.txt` </br>
`grep "Number of predicted TMHs: " all_found_proteins_mature.tmhmm | grep -v "Number of predicted TMHs:  0" >proteins_with_TMHs_ids_numbers.txt` </br>

4. Table S1 construction.

5. Scripts used for plotting.


SignalP </br>
`./signalp-5.0 -fasta all_proteins.fasta -mature`
(Note to self: signalp-5.0b only runs from its folder or needs to be copied to /bin and /lib; see the manual)
(Another note to self: `signalp` only reports the mature sequences, not all sequences. TODO: make a script that replaces the trimmed sequences.)

TMHMM

`perl ~/lib/tmhmm-2.0c/bin/tmhmm all_found_proteins_mature.fasta >all_found_proteins_mature.tmhmm`
`grep "Number of predicted TMHs: " all_found_proteins_mature.tmhmm | grep -v "Number of predicted TMHs:  0" >proteins_with_TMHs_ids_numbers.txt`


used treeGrafter: https://github.com/pantherdb/TreeGrafter installed as a local perl script
Repo cloned on 07 January 2021

got the data
`wget ftp://ftp.pantherdb.org/downloads/TreeGrafter/treeGrafter1.01.tar.gz` `##2522036 KB 	3/12/19 	8:00:00 AM GMT+8`

Ran TreeGrafter:
`perl $appdir/TreeGrafter/treeGrafter.pl -f all_found_proteins.fasta -o all_found_proteins_with_panther.tsv -d $appdir/TreeGrafter/treeGrafter1.01_supplemental/ -auto`

