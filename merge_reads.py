import itertools
from copy import deepcopy
from Bio.Seq import Seq

#read fasta as a dictionary

names = list()
seqs = list()

continues = False

with open("reads.fasta") as fh:
    for line in fh:
        if line.startswith(">"):
            names.append(line[1:].rstrip())
            continues = False
        else:
            if continues:
                seqs[-1] += line.rstrip()
            else:
                seqs.append(line.rstrip())
            continues = True

print(len(names))
print(len(seqs))

myfasta = dict(zip(names, seqs))
#for (k, v) in myfasta.items():
#    print(k, v)

#I'm not looking for intersections and a path in the graph

#with open("/media/drozdovapb/big/Peterhof_strains_seq/NonS288c_genes/2015-09-28-SUCN/res1.txt", 'w') as fh2:
#    for product in itertools.permutations(myfasta.keys(), 2):
#        #print(product)
#        first, second = product[0], product[1]
#        if myfasta[first][-3:] == myfasta[second][:3]:
#            fh2.write(' '.join(product) + '\n')
#            print(' '.join(product))

len(myfasta)

#I. get rid of duplicated reads

myfasta_unique = deepcopy(myfasta)

already_here = set()
for key, value in myfasta.items():
    if value in already_here or Seq(value).reverse_complement() in already_here:
        del myfasta_unique[key]
    else:
        already_here.add(value)


len(myfasta_unique)
#No duplicates? Fine.

#II. Get rid of reads that are only substrings

#myfasta_2 = dict()

#with open("/media/drozdovapb/big/Peterhof_strains_seq/NonS288c_genes/2015-09-28-SUCN/res1.txt", 'w') as fh2:
#for product in itertools.combinations(myfasta_unique.keys(), 2):
#    first, second = product[0], product[1]
    #print(myfasta_unique[first])
    #print(myfasta_2.keys())
#    if myfasta_unique[first] not in myfasta_unique[second] and myfasta_unique[second] not in myfasta_unique[first]:
#        myfasta_2.update({first: myfasta_unique[first]})

#Appending doesn't work for some reason

#take 2

myfasta_3 = deepcopy(myfasta_unique)

print(myfasta_3["33BBB:01618:01420"])

for product in itertools.combinations(myfasta_unique.keys(), 2):
    first, second = product[0], product[1]
    if myfasta_unique[first] in myfasta_unique[second] and first in myfasta_3.keys():
        del myfasta_3[first]
    elif myfasta_unique[second] in myfasta_unique[first] and second in myfasta_3.keys():
        del myfasta_3[second]

#Deleting works
print(len(myfasta), len(myfasta_unique), len(myfasta_3))

#395 is better


#reverse complementarity cases

#myfasta_4 = deepcopy(myfasta_3)

#for product in itertools.combinations(myfasta_3.keys(), 2):
#    firstseq, secondseq = Seq(myfasta_3[product[0]]), Seq(myfasta_3[product[1]])
#    if (firstseq.reverse_complement() in secondseq or secondseq.reverse_complement() in firstseq \
#        or firstseq in secondseq.reverse_complement() or secondseq in firstseq.reverse_complement())\
#            and product[0] in myfasta_3.keys():
#        del myfasta_4[product[0]]

#print(len(myfasta_3), len(myfasta_4))

#Merging if everything else does not help
#merging 100 bp

with open("merged_reads.fasta", 'w') as fh2:
    for product in itertools.permutations(myfasta_3.keys(), 2):
        #print(product)
        first, second = product[0], product[1]
        if myfasta_3[first][-100:] == myfasta_3[second][:100]:
            fh2.write('>' + first + second + '\n')
            fh2.write(myfasta_3[first] + myfasta_3[second][101:] + '\n')
#            print(' '.join(product))
