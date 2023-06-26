#### Software
# sratoolkit.2.9.2-ubuntu64
# SPAdes-3.13.1

## TransDecoder v5.7.0
## amphipod assemblies are available from Harvard Dataverse (https://doi.org/10.7910/DVN/XG1BJC) as rnaspades_reassemblies/
for assembly in rnaspades_reassemblies/*_rnaspades.fasta; do TransDecoder.LongOrfs -t $assembly; TransDecoder.Predict -t $assembly --single_best_only; rm -r *dir*; done
# download something for the moth
fastq-dump --gzip --defline-seq '@$sn[_$rn]/$ri' --readids --split-3 -A SRR4242253
fastqc; multiqc => ok (at least no adapters)
## assemble
rnaspades.py -t 8 -1 SRR4242253_1.fastq.gz -2 SRR4242253_2.fastq.gz -o Helicoverpa_armigera_SRR4242253_rnaspades
## copy the result
cp /media/quaternary/drozdovapb/PGP/Helicoverpa_armigera/Helicoverpa_armigera_SRR4242253_rnaspades/transcripts.fasta Helicoverpa_armigera_SRR4242253_spades.fasta

## cd-hit for each assembly
for proteome in *pep; do $appdir/cd-hit-v4.8.1-2019-0228/cd-hit -i $proteome -o cdhit_aa/$proteome.repr.faa -c 0.95; done

## run ABC_scan
cd Baikal_selection/cdhit_aa
for file in *; do ../../ABC_scan/ABC_scan.sh -proteome $file -threads 2 -outdir ../Baikal_selection_ABC/ -prefix $file; done
cd ../
for assembly in Helicoverpa_armigera/*fsa_nt; do TransDecoder.LongOrfs -t $assembly; TransDecoder.Predict -t $assembly --single_best_only; rm -r *dir*; rm *cds; rm *gff; done
for proteome in G*nt*pep; do $appdir/cd-hit-v4.8.1-2019-0228/cd-hit -i $proteome -o cdhit_aa/$proteome.repr.faa -c 0.95; done
for assembly in /media/quaternary/TSA/Parhyale_hawaiensis_GFVL01/*fasta; do TransDecoder.LongOrfs -t $assembly; TransDecoder.Predict -t $assembly --single_best_only; rm -r *dir*; rm *cds; rm *gff3; done
for proteome in Eulimnogammarus_verrucosus_rnaspades.fasta.transdecoder.pep; do $appdir/cd-hit-v4.8.1-2019-0228/cd-hit -i $proteome -o cdhit_aa/$proteome.repr.faa -c 0.95; done

## return the names to fasta headers
for folder in *faa; do export bn=$(basename $folder); sed -e "s/>/>$bn/g" $folder/Final_ABCs.faa > $folder/Final_ABCs_wname.faa; done
cat */Final_ABCs_wname.faa >../Final_ABCs.faa

## get busco where not available
python2 run_BUSCO.py -i ~/PGP/2021/transdecoder/Helicoverpa_armigera_SRR4242253_spades.fasta -o Helicoverpa_armigera_SRR4242253_busco -l arthropoda_odb9/ -m transcriptome -c 1 -t 8
python2 run_BUSCO.py -i ./transdecoder/cdhit_aa/GFWI01.1.fsa_nt.transdecoder.pep.repr.faa -o Helicoverpa_armigera_GFWI_pep_cdhit_busco -l arthropoda_odb9/ -m proteins -c 1 -t temp


## now clean up ABC_scan files
#cd Baikal_selection_ABC/
ls */*/junk
rm -r  */*/junk
ls */*/Filtered*
rm */*/Filtered*
rm */*/*long.faa
rm */*/*long.faa.sl.faa
rm */*/*wname.faa
