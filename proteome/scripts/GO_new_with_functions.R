
library(reshape2)
# BiocManager::install("topGO")
library(topGO)
options(stringsAsFactors = F)

#testing only
#sep = ","; upORdown = "up"; gocat = "BP"; FA_filename = "/homes/brauerei/polina/Documents/transcriptome_annotation/EveBCdTP_AnnotationTableFull.txt"

## this was the total transcriptome assembly, I don't want it anymore
annotation <- read.delim("~/Research/Projects/DE/annotation/EcyBCdTP1_cor_AnnotationTable.txt")
## and these are the contigs used in the proteome prediction
predproteome <- readLines("../data/predicted.proteome.contigs.txt")
annotation <- annotation[annotation$Sequence.Name %in% predproteome, ]

gomake <- function(gocat, underORover) {
  #read annotation
  # now the annotation is outside of the function
  
  #get detected
  de <- readLines("../data/found_contigs.txt")

  #get GO terms
    if (gocat == "BP") BP <- annotation[,c("Sequence.Name", "GO.Biological.Process")]
    if (gocat == "MF") BP <- annotation[,c("Sequence.Name", "GO.Molecular.Function")]
    if (gocat == "CC") BP <- annotation[,c("Sequence.Name", "GO.Cellular.Component")]
    
    #get only non-empty ones (I just cannot analyze all the rest)
    if (gocat == "BP") BPGO <- BP[BP$GO.Biological.Process != "-",]
    if (gocat == "MF") BPGO <- BP[BP$GO.Molecular.Function != "-",]
    if (gocat == "CC") BPGO <- BP[BP$GO.Cellular.Component != "-",]
    #get all GO terms in machine-readable way (in a list + without names, only numbers)
    
    if (gocat == "BP") GOs <- strsplit(BPGO$GO.Biological.Process, split = "| ", fixed = T)
    if (gocat == "MF") GOs <- strsplit(BPGO$GO.Molecular.Function, split = "| ", fixed = T)
    if (gocat == "CC") GOs <- strsplit(BPGO$GO.Cellular.Component, split = "| ", fixed = T)
    names(GOs) <- BPGO$Sequence.Name
    
    GOsTop <- lapply(X = GOs, function(x) gsub(" .*", "", x)) #remove human-readable name
  #get DE genes for the object
    if (underORover == "under") {
      DElist <- factor(as.integer(!names(GOsTop) %in% de))  
    } else DElist <- factor(as.integer(names(GOsTop) %in% de))  
    
    names(DElist) <- names(GOsTop)
  #construct a GOdat object (topGO package)
    GOdata <- new("topGOdata", ontology = gocat, allGenes = DElist, annot = annFUN.gene2GO, gene2GO = GOsTop)
    f <- runTest(GOdata, algorithm = "elim", statistic = "fisher") 
    print(str(f))
    #from the manual: We like to interpret the p-values returned by these methods as corrected or not affected by multiple testing.    
    signif_at_0.01 <- sum(f@score < 0.01)
    signres <- GenTable(object = GOdata, f, topNodes = signif_at_0.01, numChar = 100) 
    #allres <- GenTable(object = GOdata, f, topNodes = 100500, numChar = 100)        
    
    write.csv(signres, paste0("GO_overrepresented_", gocat, ".csv"))
    
    #add genes
    #####signres$Genes <- NA
    #####for (i in 1:length(signres$Genes)) {
      #####temp <- genesInTerm(GOdata, signres$GO.ID[i])[[1]]
      #####tempde <- temp[temp %in% de]
      #####namestempde <- annotation[annotation$gene %in% tempde, "best.hit.to.nr"]
      #####signres$Genes[i] <- paste(namestempde, collapse = ", ")
    #####}

    
    ####write.csv(signres, paste0("GO_overrepresented_", gocat, underORover, ".csv"))
    #return(allRes)
          
}

uBP <- gomake(gocat = "BP", underORover = "under")
oBP <- gomake(gocat = "BP", underORover = "over")
uMF <- gomake(gocat = "MF", underORover = "under")
oMF <- gomake(gocat = "MF", underORover = "over")
uCC <- gomake(gocat = "CC", underORover = "under")
oCC <- gomake(gocat = "CC", underORover = "over")





goenrich <- function(gocat, underORover, defname) {
  #read annotation
  # now the annotation is outside of the function
  
  #get detected
  de <- readLines(defname)
  
  #get GO terms
  if (gocat == "BP") BP <- annotation[,c("Sequence.Name", "GO.Biological.Process")]
  if (gocat == "MF") BP <- annotation[,c("Sequence.Name", "GO.Molecular.Function")]
  if (gocat == "CC") BP <- annotation[,c("Sequence.Name", "GO.Cellular.Component")]
  
  #get only non-empty ones (I just cannot analyze all the rest)
  if (gocat == "BP") BPGO <- BP[BP$GO.Biological.Process != "-",]
  if (gocat == "MF") BPGO <- BP[BP$GO.Molecular.Function != "-",]
  if (gocat == "CC") BPGO <- BP[BP$GO.Cellular.Component != "-",]
  #get all GO terms in machine-readable way (in a list + without names, only numbers)
  
  if (gocat == "BP") GOs <- strsplit(BPGO$GO.Biological.Process, split = "| ", fixed = T)
  if (gocat == "MF") GOs <- strsplit(BPGO$GO.Molecular.Function, split = "| ", fixed = T)
  if (gocat == "CC") GOs <- strsplit(BPGO$GO.Cellular.Component, split = "| ", fixed = T)
  names(GOs) <- BPGO$Sequence.Name
  
  GOsTop <- lapply(X = GOs, function(x) gsub(" .*", "", x)) #remove human-readable name
  #get DE genes for the object
  if (underORover == "under") {
    DElist <- factor(as.integer(!names(GOsTop) %in% de))  
  } else DElist <- factor(as.integer(names(GOsTop) %in% de))  
  
  names(DElist) <- names(GOsTop)
  #construct a GOdat object (topGO package)
  GOdata <- new("topGOdata", ontology = gocat, allGenes = DElist, annot = annFUN.gene2GO, gene2GO = GOsTop)
  f <- runTest(GOdata, algorithm = "elim", statistic = "fisher") 
  print(str(f))
  #from the manual: We like to interpret the p-values returned by these methods as corrected or not affected by multiple testing.    
  signif_at_0.01 <- sum(f@score < 0.01)
  signres <- GenTable(object = GOdata, f, topNodes = signif_at_0.01, numChar = 100) 
  #allres <- GenTable(object = GOdata, f, topNodes = 100500, numChar = 100)        
  
  write.csv(signres, paste0("GO_overrepresented_", gocat, ".csv"))
  
  #add genes
  #####signres$Genes <- NA
  #####for (i in 1:length(signres$Genes)) {
  #####temp <- genesInTerm(GOdata, signres$GO.ID[i])[[1]]
  #####tempde <- temp[temp %in% de]
  #####namestempde <- annotation[annotation$gene %in% tempde, "best.hit.to.nr"]
  #####signres$Genes[i] <- paste(namestempde, collapse = ", ")
  #####}
  
  
  ####write.csv(signres, paste0("GO_overrepresented_", gocat, underORover, ".csv"))
  #return(allRes)
  
}

goenrich(gocat = "BP", defname = "../data/female_specific.txt", underORover = "over")
