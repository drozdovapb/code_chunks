import ete3
texttree = ""
with open("LTPs123_SSU_only_tree.newick", "r") as fh:
    for line in fh.readlines():
        texttree += line.rstrip()
#LTPs123_SSU_only_tree.newick differs from LTPs123_SSU_tree.newick by not having the header things (removed them manually)
#texttree: line of length867375
#format=1 is important
t = ete3.Tree(texttree, format=1)

#prepare a list for pruning
cut -f 1 ../sp_data.txt >sp_list.txt

species = []
with open("species_list.txt", "r") as sp_list_fh:
    for line in sp_list_fh.readlines():
        species.append(line.rstrip())
        

leaf_list = []
for aspecies in species:
    for aleaf in t:
        if aspecies in aleaf.name:
            leaf_list.append(aleaf.name)

# len(leaf_list) #165 found

leaf_list.remove("Haloarcula_marismortuiAY596297Halobacteriaceae")
#twice! i'm not joking
leaf_list.remove("Haloarcula_marismortuiAY596297Halobacteriaceae")


t.prune(leaf_list)

#writing tree!!!
t.write(format=1, outfile="short_LTPs123_SSU_tree.newick")