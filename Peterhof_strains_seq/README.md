Peterhof_strains_seq
===========

This repository contains the code and parameters used in analysis of the data in the Peterhof strains sequencing project.
The data are published at Drozdova et al., 2016 // PLoS ONE (https://doi.org/10.1371/journal.pone.0154722) and Matveenko & Drozdova et al., 2019 // Data in Brief, (https://doi.org/10.1016/j.dib.2019.01.042).

#### QC and trimming of reads

Example pipeline:

`fastx_trimmer -Q33 -f 40 -l 200 -i IonXpress_005.R_2014_08_12_23_18_13_user_SN1-10-4YeastSrainsPD.fastq -o 005_trimmed.fastq`
`cutadapt -a ATCACCGACTGCCCATAGAGAGGCTGAGAC -o ~/Peterhof_strains_seq/Reads/Trimmed/15V.cutadapt.4.fastq ~/Peterhof_strains_seq/Reads/Trimmed/15V_trimmed_merged.fastq`

#### Genome assembly

SPAdes-3.1.0 for IonTorrent data

`strains=( 15V 1B 25b 74)`
`for strain in "${strains[@]}" spades.py --iontorrent -k 29,53,67,127 -o ~/Peterhof_strains_seq/$strain.cutadapt.up/ -s ~/Peterhof_strains_seq/Reads/Trimmed/$strain.cutadapt.fastq`

SPAdes-3.6.1 for Illumina data

`~/lib/SPAdes-3.6.0-Linux/bin/spades.py -o ~/Peterhof_strains_seq/Assembly/SPAdes_3.6/74.3.6/ -s ~/Peterhof_strains_seq/Reads/Raw/74D_sequence.fastq`

#### Gene annotation

`maker*.ctl` contains example options for one of the files.

#### Phylogeny and population structure

`list_common_genes.R` was used to extract common genes to build the ORF-based tree.

`mainparams` and `extraparams` contain parameters for an example STRUCTURE run.
`clumpp.paramfile` contains CLUMPP parameters.

#### CNV analysis

`split_reads.py` was used to pre-process reads before aligning them to the reference with rmfast.
`mrCaNaVaR.sh` described subsequent steps.
`count_merge_intervals.R` described post-processing.

#### SNV analysis

`align_call_filter.sh` does all the work on alignment to reference and SNV calling.
`SNP_distribution_v7.0.R` describes the steps taken to plot SNV distribution.
