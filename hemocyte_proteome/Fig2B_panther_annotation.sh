## used treeGrafter: https://github.com/pantherdb/TreeGrafter installed as a local perl script
## Repo cloned on 07 January 2021

## got the data
wget ftp://ftp.pantherdb.org/downloads/TreeGrafter/treeGrafter1.01.tar.gz ##2522036 KB 	3/12/19 	8:00:00 AM GMT+8

## Ran TreeGrafter:
perl $appdir/TreeGrafter/treeGrafter.pl -f all_found_proteins.fasta -o all_found_proteins_with_panther.tsv -d $appdir/TreeGrafter/treeGrafter1.01_supplemental/ -auto

