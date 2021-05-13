## Proteomic dataset for *Eulimnogammarus verrucosus* hemocytes

Supplementary data for Zolotovskaya *et al.* (submitted to Biological Communications).

The mass spectrometry proteomics data have been deposited to the ProteomeXchange Consortium via the PRIDE partner repository with the dataset identifier PXD023514 and 10.6019/PXD023514.

Should contain: 
1. Exported PeptideShaker reports
`java -cp $appdir/PeptideShaker-1.16.45/PeptideShaker-1.16.45.jar eu.isas.peptideshaker.cmd.ReportCLI -in PeptideShaker_output.cpsx -reports "6" -out_reports .`

2. The code used to create figures and input data for reproducibility.


SignalP
`./signalp-5.0 -fasta all_proteins.fasta -mature`
(Note to self: signalp-5.0b only runs from its folder or needs to be copies to /bin and /lib; see the manual)

TMHMM

`perl ~/lib/tmhmm-2.0c/bin/tmhmm all_found_proteins_mature.fasta >all_found_proteins_mature.tmhmm`
`grep "Number of predicted TMHs: " all_found_proteins_mature.tmhmm | grep -v "Number of predicted TMHs:  0" >proteins_with_TMHs_ids_numbers.txt`


## used treeGrafter: https://github.com/pantherdb/TreeGrafter installed as a local perl script
## Repo cloned on 07 January 2021

## got the data
wget ftp://ftp.pantherdb.org/downloads/TreeGrafter/treeGrafter1.01.tar.gz ##2522036 KB 	3/12/19 	8:00:00 AM GMT+8

## Ran TreeGrafter:
perl $appdir/TreeGrafter/treeGrafter.pl -f all_found_proteins.fasta -o all_found_proteins_with_panther.tsv -d $appdir/TreeGrafter/treeGrafter1.01_supplemental/ -auto

