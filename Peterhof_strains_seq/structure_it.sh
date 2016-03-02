cd /storage1/s_pdrozdova/Peterhof_strains_seq/Phylogeny/Structure/realigned
#copy all files
cp /storage1/s_pdrozdova/Peterhof_strains_seq/SNPs/15V.snps.vcf .
cp -r /storage1/s_pdrozdova/Peterhof_strains_seq/SNPs/YJM/*.snps.vcf .
#count the number 
number=$(ls *.snps.vcf |wc -l)
#prepare files for merging
for file in *.snps.vcf; do ./downgrade_vcf.sh $file; done
#finally merge 
vcf-merge *.vcf.gz >$number.merged.vcf
#filter with plink
~/bin/plinkf/plink --vcf $number.merged.vcf --make-bed --allow-extra-chr --indep-pairwise 10 10 0.4 --const-fid --set-missing-var-ids @:#
~/bin/plinkf/plink --bfile plink --extract plink.prune.in --out $number --make-bed --allow-extra-chr

#fastStructure
python ~/bin/fastStructure/structure.py -K 6 --input=$number --output=$number.pruned_out
python ~/bin/fastStructure/chooseK.py --input=$number.pruned_out
python ~/bin/fastStructure/distruct.py -K 6 --input=$number.pruned_out --output=$number.strains.no.title.svg --title=$number.strains
#python ~/bin/fastStructure/distruct.py -K 6 --input=$number.pruned_out --output=$number.strains.svg --title=$number.strains_groups --popfile=poplabels.txt
python ~/bin/fastStructure/distruct.py -K 6 --input=$number.pruned_out --output=$number.strains_labels.svg --title=$number.strains_groups --popfile=labels.txt

