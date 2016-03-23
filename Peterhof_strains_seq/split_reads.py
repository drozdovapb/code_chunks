#!/usr/bin/python

import argparse
from Bio import SeqIO

MAGIC_LENGTH = 36

def read_reads(reads):
    for seq_record in SeqIO.parse(reads, "fastq"):
        MAGIC_NUMBER = len(seq_record.seq) / 36
        for i in range(MAGIC_NUMBER):
            print '>'+seq_record.id+':'+str(i)
            start = MAGIC_LENGTH * i
            end = MAGIC_LENGTH * (i + 1)
            print seq_record.seq[start:end]

if __name__ == '__main__' :
    parser = argparse.ArgumentParser()
    parser.add_argument('reads')
    args = parser.parse_args()
    read_reads(args.reads)
