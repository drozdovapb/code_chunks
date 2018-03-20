getTaxonomy <- function(thisassembly) {
    #setwd("/media/drozdovapb/big/Research/Projects/DE/annotation/") #change path
    #get taxids from diamond results (particular column # depends on diamond options)
    ##cut -f 13  GlaBCd6T24T_deep_FR.diamond.tsv >GlaBCd6T24T_deep_FR.taxid
    ## cut -f 13  GlaBCdTP1_cor.diamond.tsv >GlaBCdTP1_cor.taxid
    ##cut -f 13  EcyBCdTP1_cor.diamond.tsv >EcyBCdTP1_cor.taxid
    ids <- readLines(thisassembly)
    #remove multiple numbers in one entry, as they cannot be processed by NCBI
    sids <- sapply(strsplit(ids, split=";"), '[', 1)
    #summarize + sort (mostly for convenience)
    tids <- sort(table(sids))
    write.csv(tids, paste0(thisassembly, "tids.csv"))} 

matchTaxonomy <- function(tax_report, thisassembly) {
    #linker to the previous function:
    #https://www.ncbi.nlm.nih.gov/Taxonomy/TaxIdentifier/tax_identifier.cgi
    #got full taxonomy report
    #taxonomy report:
    trec <- read.delim(tax_report)
    tl <- strsplit(as.character(trec$lineage), " ")
    #choose kingdom ids
    kingdom <- lapply(tl, function(x) x[length(x)-3])
    #make vector from list
    vkingdom <- unlist(lapply(kingdom, "[", 1))
    #write and return
    tids <- read.csv(paste0(thisassembly, "tids.csv"))
    qq <- data.frame(kingdom=as.numeric(vkingdom), num=as.numeric(tids$Freq), taxon=tids$sids)
    return(qq)}


volcanoplot <- function(merged, thiscolor) {
    sig <- ifelse(abs(merged$log2FoldChange) > 3 & merged$padj < 0.001, thiscolor, "black")
    p <- ggplot(merged, aes(log2FoldChange, -log10(padj))) +
        geom_point(col=sig, alpha=0.3) + ylim(0, 50) + xlim(-15, 15) +
        ggtitle(paste0(thispecies, theseconditions[2], "_vs_", theseconditions[1]))
    return(p)
}

select.metazoa <- function(tbl, qq) {
    tbl$taxon <- tbl$V13
    evem <- merge(x = tbl, y=qq, by="taxon", all.x=T, all.y=F)
    evem_metazoa <- evem[evem$kingdom==33208 & !is.na(evem$kingdom),]
    return(evem_metazoa)
}


deselect.contaminants <- function(tbl, qq) {
    tbl$taxon <- tbl$V13
    evem <- merge(x = tbl, y=qq, by="taxon", all.x=T, all.y=F)
    evem_decont <- evem[evem$kingdom==33208 | is.na(evem$kingdom),] #NA also appears here, so not blasted should be retained...
    return(evem_decont)
}


perform.de <- function(dir, thispecies, theseconditions) {
    #this is the main function for differential expression
    #Setup
    setwd(dir)
    #read samples table (metadata)
    samples <- read.csv("./samples.csv")
    #create a vector of paths to files
    files <- file.path(dir, "gc", samples$salmon.folder, "quant.sf")
    names(files) <- paste0("sample", 1:6)
    #check whether everything is fine and all the files exist
    all(file.exists(files))
    
    #now, get colors right for plotting
    palette <- c("Blues", "Greens", "Oranges")
    colors <- c("blue4", "green4", "orange4")
    species <- c("Ecy", "Eve", "Gla")
    thispalette <- palette[which(species ==  thispecies)]
    thiscolor <- colors[which(species == thispecies)]
    
    ###Transcripts need to be associated with gene IDs for gene-level summarization.
    ###should I be fine with transcript-level summarization?
    
    #choose which samples to compare
    tocompare <- which(samples$species==thispecies & samples$condition %in% theseconditions)
    txi <- tximport(files[tocompare], type = "salmon", txOut=TRUE)
    #one of the longest stages, several minutes
    
    #construct a DESeq2 object
    library(DESeq2) #just in case
    sampleTable <- data.frame(condition=samples$condition[tocompare])
    rownames(sampleTable) <- samples$sample[tocompare]
    colnames(txi$counts) <- samples$sample[tocompare]
    dds <- DESeqDataSetFromTximport(txi, sampleTable, ~condition)
    #red rid of non-expressed contigs (<10 reads)
    keep <- rowSums(counts(dds)) >= 10
    dds <- dds[keep,]
    
    #differential expression! 
    dds <- DESeq(dds)
    res <- results(dds)
    res$log10padj <- -log10(res$padj)
    
    #Transformed data for some playing around (PCA)
    vsd <- vst(dds, blind=FALSE)
    svg(filename = paste0(thispecies, theseconditions[2],"_PCA",".svg"), 
        width=3.5, height=3.5)
    pl <- plotPCA(vsd, intgroup=c("condition")) + 
        ggtitle(paste0(thispecies, theseconditions[2])) +
                    theme_bw() +  scale_color_manual(values = c("black", "red")) 
    print(pl)
    dev.off()
    
    sampleDists <- dist(t(assay(vsd)))
    ###clustering
    library("RColorBrewer")
    library("pheatmap") 
    sampleDistMatrix <- as.matrix(sampleDists)
    rownames(sampleDistMatrix) <- colnames(vsd)
    colnames(sampleDistMatrix) <- NULL
    colors <- colorRampPalette( rev(brewer.pal(9, thispalette)))(255)
    svg(filename = paste0(thispecies,theseconditions[2], "_clust",".svg"), 
        width=6, height=4)
        pheatmap(sampleDistMatrix,
                 clustering_distance_rows=sampleDists,
                 clustering_distance_cols=sampleDists,
                 col=colors, fontsize = 16)
    dev.off()
    
    resOrdered <- res[order(res$log2FoldChange),]
    
    #write full results
    write.csv(resOrdered, paste0(thispecies,theseconditions[2],"_ordered.csv"))
    
    ##Merge with 'annotation'
    diamond <- read.delim(
        paste0("/media/drozdovapb/big/Research/Projects/DE/annotation/", thisassembly, ".diamond.tsv"), 
        head=F, stringsAsFactors = F)
    names(diamond)[1] <- "gene"
    diamond$V13 <- sapply(strsplit(diamond$V13, split=";"), '[', 1)
    resOrdered$gene <- row.names(resOrdered)
    merged <- merge(y = diamond[,c(1,13,14)], x=as.data.frame(resOrdered), all.x=T, all.y=FALSE , by="gene")
    mergedOrdered <- merged[order(merged$log2FoldChange),]
    
    #write full annotated data
    write.table(mergedOrdered[,c("gene","baseMean","log2FoldChange", "padj", "log10padj", "V13", "V14")], paste0(thispecies,theseconditions[2],"_annot.csv"))
    
    #select and write DE expressed genes only
    de <- mergedOrdered[abs(mergedOrdered$log2FoldChange) > 3 & mergedOrdered$padj < 0.0001,]
    de <- de[complete.cases(de),]
    write.table(de[,c("gene","baseMean","log2FoldChange", "padj", "log10padj", "V14")], paste0(thispecies,theseconditions[2],"_annot_de.csv"))
    
    #volcanoplot
    p1 <- volcanoplot(merged, thiscolor)
    ggsave(paste0(thispecies,theseconditions[2],".png"), 
           p1, device = "png", width = 3, height = 3)

    setwd(dir)
    
    #now select Metazoa (#33208 in the NCBI classification)
    merged.metazoa <- select.metazoa(merged, qq)
    merged.metazoa <- merged.metazoa[order(merged.metazoa$log2FoldChange),]
    write.csv(merged.metazoa[,c("gene","baseMean","log2FoldChange", "padj", "log10padj", "V14")], paste0(thispecies,theseconditions[2],"_metazoa.csv"))
    
    merged.metazoa.de <- merged.metazoa[abs(merged.metazoa$log2FoldChange) > 3 & merged.metazoa$padj < 0.001,]    
    merged.metazoa.de <- merged.metazoa.de[complete.cases(merged.metazoa.de),]
    write.csv(merged.metazoa.de[,c("gene","baseMean","log2FoldChange", "padj", "log10padj", "V14")],
              paste0(thispecies,theseconditions[2],"_metazoa_de.csv"))
    
    p2 <- volcanoplot(merged.metazoa, thiscolor) + 
        ggtitle(paste0(thispecies, theseconditions[2], "_vs_", theseconditions[1], "_Metazoa"))
    ggsave(paste0(thispecies,theseconditions[2],"_metazoa.png"), 
           p2, device = "png", width = 3, height = 3)
    
    #Or deselect contaminants
    merged.decont <- deselect.contaminants(merged, qq)
    merged.decont <- merged.decont[order(merged.decont$log2FoldChange),]
    write.csv(merged.decont[,c("gene","baseMean","log2FoldChange", "padj", "log10padj", "V14")], paste0(thispecies,theseconditions[2],"_decont.csv"))
    
    merged.decont.de <- merged.decont[abs(merged.decont$log2FoldChange) > 3 & merged.decont$padj < 0.001,]    
    merged.decont.de <- merged.decont.de[complete.cases(merged.decont.de$gene),]
    write.csv(merged.decont.de[,c("gene","baseMean","log2FoldChange", "padj", "log10padj", "V14")],
              paste0(thispecies,theseconditions[2],"_decont_de.csv"))
    
    p3 <- volcanoplot(merged.decont, thiscolor) + 
        ggtitle(paste0(thispecies, theseconditions[2], "_vs_", theseconditions[1], "-contam-n"))
    ggsave(paste0(thispecies,theseconditions[2],"_decont.png"), 
           p3, device = "png", width = 3, height = 3)
}
