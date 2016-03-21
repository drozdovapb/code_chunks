vcf-merge ../100G_SGD_SGRP.NS128.VIF1_67_upd.vcf.gz ../bwa15V2/15V.bwa.vcf.gz -R '0' >101.with.15V.bwa.merged.vcf

cut -f 1-9,36,39,40-42,53,55,60-153 101.with.15V.bwa.merged.vcf >merged.true.101.with.bwa.15V.strains.vcf
~/bin/plinkf/plink --vcf merged.true.101.with.bwa.15V.strains.vcf --make-bed --allow-extra-chr --indep-pairwise 20 10 0.4 --const-fid --set-missing-var-ids @:# --geno 0.01

cp -r ../structure101_take2/plink* .
~/bin/plinkf/plink --bfile plink --extract plink.prune.in --allow-extra-chr --recode vcf-iid --out pruned
		22139 variants and 101 people pass filters and QC.

~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.000001 --max-maf 0.050000 --out bin01 --set-missing-var-ids @:#
	#18975 variants and 100 people pass filters and QC.
~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.050001 --max-maf 0.100000 --out bin02 --set-missing-var-ids @:#
	#1994 variants and 100 people pass filters and QC. 
~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.100001 --max-maf 0.150000 --out bin03 --set-missing-var-ids @:#
	#458 variants and 100 people pass filters and QC. #=> 42 / 0.0017
~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.150001 --max-maf 0.200000 --out bin04 --set-missing-var-ids @:#
	#157 variants and 100 people pass filters and QC. #=> 
~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.200001 --max-maf 0.250000 --out bin05 --set-missing-var-ids @:#
	#89 variants and 100 people pass filters and QC.
~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.250001 --max-maf 0.300000 --out bin06 --set-missing-var-ids @:#
	#65 variants and 100 people pass filters and QC.
~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.300001 --max-maf 0.350000 --out bin07 --set-missing-var-ids @:#
	#63 variants and 100 people pass filters and QC.
~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.350001 --max-maf 0.400000 --out bin08 --set-missing-var-ids @:#
	#95 variants and 100 people pass filters and QC.
~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.400001 --max-maf 0.450000 --out bin09 --set-missing-var-ids @:#
	#104 variants and 100 people pass filters and QC.
~/bin/plinkf/plink --vcf pruned.vcf --make-bed --allow-extra-chr --maf 0.450001 --max-maf 0.499999 --out bin10 --set-missing-var-ids @:#
	#126 variants and 100 people pass filters and QC.
#here i cannot take 121 from each... I can take 60 from each


~/bin/plinkf/plink --bfile bin01 --thin-count 60 --make-bed --out thin01 --aec
~/bin/plinkf/plink --bfile bin02 --thin-count 60 --make-bed --out thin02 --aec
~/bin/plinkf/plink --bfile bin03 --thin-count 60 --make-bed --out thin03 --aec
~/bin/plinkf/plink --bfile bin04 --thin-count 60 --make-bed --out thin04 --aec
~/bin/plinkf/plink --bfile bin05 --thin-count 60 --make-bed --out thin05 --aec
~/bin/plinkf/plink --bfile bin06 --thin-count 60 --make-bed --out thin06 --aec
~/bin/plinkf/plink --bfile bin07 --thin-count 60 --make-bed --out thin07 --aec
~/bin/plinkf/plink --bfile bin08 --thin-count 60 --make-bed --out thin08 --aec
~/bin/plinkf/plink --bfile bin09 --thin-count 60 --make-bed --out thin09 --aec
~/bin/plinkf/plink --bfile bin10 --thin-count 60 --make-bed --out thin10 --aec

~/bin/plinkf/plink --bfile thin01 --merge-list files.txt --out 600withmine --aec --recode vcf-iid

java -Xmx1024m -Xms512m -jar ~/bin/PGDSpider_2.1.0.0/PGDSpider2-cli.jar -inputfile 600withmine.vcf -inputformat VCF -outputfile 101.spider.str.in -outputformat STRUCTURE -spid 101.spid



#our, only their positions
cd /storage1/s_pdrozdova/Peterhof_strains_seq/Phylogeny/Structure/structure101_take9
vcf-merge ../100G_SGD_SGRP.NS128.VIF1_67_upd.vcf.gz ../bwa15V2/15V.bwa.vcf.gz >101.with.15V.bwa.merged.vcf



				grep -v \# 101.with.15V.bwa.merged.vcf |grep -v '.    .       .       .       .       .       .       .       .       .       .       .       .       .       .       .' -c
				24360


grep -v '.    .       .       .       .       .       .       .       .       .       .       .       .       .       .       .' 101.with.15V.bwa.merged.vcf >101.24360.vcf
cut -f 1-9,36,39,40-42,53,55,60-153 101.24360.vcf >true.101.24360.vcf

#try with imputation and without it!!!

#without
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.000001 --max-maf 0.050000 --out bin01 --set-missing-var-ids @:#
	#18951
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.050001 --max-maf 0.100000 --out bin02 --set-missing-var-ids @:#
	#2830
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.100001 --max-maf 0.150000 --out bin03 --set-missing-var-ids @:#
	#738
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.150001 --max-maf 0.200000 --out bin04 --set-missing-var-ids @:#
	#306
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.200001 --max-maf 0.250000 --out bin05 --set-missing-var-ids @:#
	#201
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.250001 --max-maf 0.300000 --out bin06 --set-missing-var-ids @:#
	#179
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.300001 --max-maf 0.350000 --out bin07 --set-missing-var-ids @:#
	#224
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.350001 --max-maf 0.400000 --out bin08 --set-missing-var-ids @:#
	#276
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.400001 --max-maf 0.450000 --out bin09 --set-missing-var-ids @:#
	#329
~/bin/plinkf/plink --vcf true.101.24360.vcf --make-bed --allow-extra-chr --maf 0.450001 --max-maf 0.499999 --out bin10 --set-missing-var-ids @:#
	#244

#with imputation
#take10
~/bin/plinkf/plink --vcf true.101.24360.vcf --allow-extra-chr --out sorted.101.24360 --make-bed
~/bin/plinkf/plink --bfile sorted.101.24360 --allow-extra-chr --out imputed.101.24360 --make-bed --fill-missing-a2
mkdir ../structure101_take10; cd ../structure101_take10
mv ../structure101_take9/imputed.101.24360* .
#~/bin/plinkf/plink --bfile imputed.101.24360 --aec --recode vcf-iid --out imputed.101.24360
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.000001 --max-maf 0.050000 --out bin01 --set-missing-var-ids @:#
	#19130
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.050001 --max-maf 0.100000 --out bin02 --set-missing-var-ids @:#
	#2669
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.100001 --max-maf 0.150000 --out bin03 --set-missing-var-ids @:#
	#704
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.150001 --max-maf 0.200000 --out bin04 --set-missing-var-ids @:#
	#299
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.200001 --max-maf 0.250000 --out bin05 --set-missing-var-ids @:#
	#201
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.250001 --max-maf 0.300000 --out bin06 --set-missing-var-ids @:#
	#180
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.300001 --max-maf 0.350000 --out bin07 --set-missing-var-ids @:#
	#224
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.350001 --max-maf 0.400000 --out bin08 --set-missing-var-ids @:#
	#271
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.400001 --max-maf 0.450000 --out bin09 --set-missing-var-ids @:#
	#334
~/bin/plinkf/plink --bfile imputed.101.24360 --make-bed --allow-extra-chr --maf 0.450001 --max-maf 0.499999 --out bin10 --set-missing-var-ids @:#
	#244


==============this in both folders
~/bin/plinkf/plink --bfile bin01 --thin-count 121 --make-bed --out thin11 --aec
~/bin/plinkf/plink --bfile bin02 --thin-count 121 --make-bed --out thin12 --aec
~/bin/plinkf/plink --bfile bin03 --thin-count 121 --make-bed --out thin13 --aec
~/bin/plinkf/plink --bfile bin04 --thin-count 121 --make-bed --out thin14 --aec
~/bin/plinkf/plink --bfile bin05 --thin-count 121 --make-bed --out thin15 --aec
~/bin/plinkf/plink --bfile bin06 --thin-count 121 --make-bed --out thin16 --aec
~/bin/plinkf/plink --bfile bin07 --thin-count 121 --make-bed --out thin17 --aec
~/bin/plinkf/plink --bfile bin08 --thin-count 121 --make-bed --out thin18 --aec
~/bin/plinkf/plink --bfile bin09 --thin-count 121 --make-bed --out thin19 --aec
~/bin/plinkf/plink --bfile bin10 --thin-count 121 --make-bed --out thin20 --aec
~/bin/plinkf/plink --bfile bin01 --thin-count 121 --make-bed --out thin21 --aec
~/bin/plinkf/plink --bfile bin02 --thin-count 121 --make-bed --out thin22 --aec
~/bin/plinkf/plink --bfile bin03 --thin-count 121 --make-bed --out thin23 --aec
~/bin/plinkf/plink --bfile bin04 --thin-count 121 --make-bed --out thin24 --aec
~/bin/plinkf/plink --bfile bin05 --thin-count 121 --make-bed --out thin25 --aec
~/bin/plinkf/plink --bfile bin06 --thin-count 121 --make-bed --out thin26 --aec
~/bin/plinkf/plink --bfile bin07 --thin-count 121 --make-bed --out thin27 --aec
~/bin/plinkf/plink --bfile bin08 --thin-count 121 --make-bed --out thin28 --aec
~/bin/plinkf/plink --bfile bin09 --thin-count 121 --make-bed --out thin29 --aec
~/bin/plinkf/plink --bfile bin10 --thin-count 121 --make-bed --out thin30 --aec
~/bin/plinkf/plink --bfile bin01 --thin-count 121 --make-bed --out thin31 --aec
~/bin/plinkf/plink --bfile bin02 --thin-count 121 --make-bed --out thin32 --aec
~/bin/plinkf/plink --bfile bin03 --thin-count 121 --make-bed --out thin33 --aec
~/bin/plinkf/plink --bfile bin04 --thin-count 121 --make-bed --out thin34 --aec
~/bin/plinkf/plink --bfile bin05 --thin-count 121 --make-bed --out thin35 --aec
~/bin/plinkf/plink --bfile bin06 --thin-count 121 --make-bed --out thin36 --aec
~/bin/plinkf/plink --bfile bin07 --thin-count 121 --make-bed --out thin37 --aec
~/bin/plinkf/plink --bfile bin08 --thin-count 121 --make-bed --out thin38 --aec
~/bin/plinkf/plink --bfile bin09 --thin-count 121 --make-bed --out thin39 --aec
~/bin/plinkf/plink --bfile bin10 --thin-count 121 --make-bed --out thin40 --aec
~/bin/plinkf/plink --bfile bin01 --thin-count 121 --make-bed --out thin41 --aec
~/bin/plinkf/plink --bfile bin02 --thin-count 121 --make-bed --out thin42 --aec
~/bin/plinkf/plink --bfile bin03 --thin-count 121 --make-bed --out thin43 --aec
~/bin/plinkf/plink --bfile bin04 --thin-count 121 --make-bed --out thin44 --aec
~/bin/plinkf/plink --bfile bin05 --thin-count 121 --make-bed --out thin45 --aec
~/bin/plinkf/plink --bfile bin06 --thin-count 121 --make-bed --out thin46 --aec
~/bin/plinkf/plink --bfile bin07 --thin-count 121 --make-bed --out thin47 --aec
~/bin/plinkf/plink --bfile bin08 --thin-count 121 --make-bed --out thin48 --aec
~/bin/plinkf/plink --bfile bin09 --thin-count 121 --make-bed --out thin49 --aec
~/bin/plinkf/plink --bfile bin10 --thin-count 121 --make-bed --out thin50 --aec

~/bin/plinkf/plink --bfile thin11 --merge-list first10.txt --out set1 --aec --recode vcf-iid
~/bin/plinkf/plink --bfile thin21 --merge-list second10.txt --out set2 --aec --recode vcf-iid
~/bin/plinkf/plink --bfile thin31 --merge-list third10.txt --out set3 --aec --recode vcf-iid
~/bin/plinkf/plink --bfile thin41 --merge-list fourth10.txt --out set4 --aec --recode vcf-iid

java -Xmx1024m -Xms512m -jar ~/bin/PGDSpider_2.1.0.0/PGDSpider2-cli.jar -inputfile set1.vcf -inputformat VCF -outputfile set.1.str.in -outputformat STRUCTURE -spid 101.spid
java -Xmx4096m -Xms512m -jar ~/bin/PGDSpider_2.1.0.0/PGDSpider2-cli.jar -inputfile set2.vcf -inputformat VCF -outputfile set.2.str.in -outputformat STRUCTURE -spid 101.spid
java -Xmx4096m -Xms512m -jar ~/bin/PGDSpider_2.1.0.0/PGDSpider2-cli.jar -inputfile set3.vcf -inputformat VCF -outputfile set.3.str.in -outputformat STRUCTURE -spid 101.spid
java -Xmx4096m -Xms512m -jar ~/bin/PGDSpider_2.1.0.0/PGDSpider2-cli.jar -inputfile set4.vcf -inputformat VCF -outputfile set.4.str.in -outputformat STRUCTURE -spid 101.spid
cp ../structure101_take8/*params .
#=====hmmm...ready to use structure???


first, imputed!!!! 10
for rep in {1..3}; do /home/otarasov/bin/Structure/structure -m mainparams.1 -K 6 -o set.1_k6_rep${rep}; done
for rep in {1..3}; do /home/otarasov/bin/Structure/structure -m mainparams.2 -K 6 -o set.2_k6_rep${rep}; done
for rep in {1..3}; do /home/otarasov/bin/Structure/structure -m mainparams.3 -K 6 -o set.3_k6_rep${rep}; done
for rep in {1..3}; do /home/otarasov/bin/Structure/structure -m mainparams.4 -K 6 -o set.4_k6_rep${rep}; done

