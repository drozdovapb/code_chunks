## Load packages and functions
library(openxlsx)

## The central function from the obsolete CLAC package
## Here with default values for yeast data sets

clac.plarray.lines<-function(sample, samplename, clustindex,
  chr = smooth$Chromosome.Number, chrnames = c(as.character(as.roman(1:16)), "mito"),
  nucposi = smooth$Nucleotide.Position, graylevel=0.9) {

  n=length(chr)
  Ch=max(chr)
  ran=range(nucposi)
  plot(nucposi,rep(1,length(nucposi)),type="n",axes=F,ylim=c(0,max(chr)+1),
       xlim=c(ran[1]-100000, ran[2]),ylab="",xlab="", main= samplename)
  
  upcol<-gray(0.5)
  downcol<-gray(0.5)
  #graylevel=.8
  
  con<-log(10)
  sample<-sample/con * log(2)
  
  chset<-unique(chr) #chset=1:16
  #Ch = 1
  
  ###########
  ## First, draw background scales
  for(j in c(sort(chset), Ch+1)){
    jp=Ch-j+1
    nuc<-nucposi[chr==j | chr==j-1]
    xlim=range(0, max(nuc))
    for(copy in 2:10)
      segments(xlim[1], jp+log(copy)/con, xlim[2], jp+log(copy)/con, col=gray(graylevel))
  }
  
  ## Second, mark chromosomes
  for(j in c(sort(chset))){
    jp=Ch-j + 0.6
      text(x = 15000, y = jp, labels = chrnames[j], pos = 2, cex = .75)
  }
  
  ##########
  ## Finally, draw the data
  for(j in sort(chset)){
    jp=Ch-j+.5
    nuc=nucposi[chr==j]
    y=sample[chr==j]
    indexy<-clustindex[chr==j]
    
    y[is.na(y)]<-0
    y[y==999]<-0
    yposi<-y
    yposi[y<0]<-0
    ynega<-y
    ynega[y>0]<-0
    
    pick<-(1:length(indexy))[indexy!=0]
    npick<-(1:length(indexy))[indexy==0]
    
    ### plot unpicked one
    if(length(npick)>0)
    {
      segments(nuc[npick],jp,nuc[npick],jp+yposi[npick],col=upcol)
      segments(nuc[npick],jp,nuc[npick],jp+ynega[npick],col=downcol)
    }
    ### plot picked one
    if(length(pick)>0)
    {
      segments(nuc[pick],jp,nuc[pick],jp+yposi[pick],col=2)
      segments(nuc[pick],jp,nuc[pick],jp+ynega[pick],col=3)
    }
    xlim=range(0,max(nuc))
    segments(xlim[1],jp,xlim[2],jp)
    ## intended for human chromosomes...
  #   if(j<23)
  #     text(-5000000,jp,labels=j,cex=.7)
  #   if(j==23)
  #     text(-5000000, jp, labels="X", cex=0.7)
  #   if(j==24)
  #     text(-5000000, jp, labels="Y", cex=0.7)
  #   segments(centr[j],jp+0.25,centr[j],jp-0.25,col=6)
   }
}

## First pack of slides
smooth <- read.xlsx("./100715/27547_sorted.xltm", sheet = "CLACAverageSmooth")
sign <- read.xlsx("./100715/27547_sorted.xltm", sheet = "CLACRegionMean")


## Example for comparison
# png("105-1A_1.png", width = 20, height = 20, units = "cm", res = 300)  
# clac.plarray.lines(sample = smooth$`1a.105.#1.vs.PSL2`, samplename = "105-1A #1 vs PSL2",
#                     clustindex = sign$`1a.105.#1.vs.PSL2`, 
#                     graylevel=0.9)
# dev.off()

for (i in 7:14){
  this.sample <- names(smooth)[i]
  png(paste0(this.sample, ".png"), width = 20, height = 20, units = "cm", res = 300)
  clac.plarray.lines(sample = smooth[, this.sample], samplename = this.sample,
                     clustindex = sign[, this.sample],
                     graylevel=0.9)
  dev.off()
}




## Second pack of slides
smooth <- read.xlsx("./100915/2390_sorted.xlsm", sheet = "CLACAverageSmooth")
sign <- read.xlsx("./100915/2390_sorted.xlsm", sheet = "CLACRegionMean")

for (i in 7:14){
  this.sample <- names(smooth)[i]
  png(paste0(this.sample, ".png"), width = 20, height = 20, units = "cm", res = 300)
  clac.plarray.lines(sample = smooth[, this.sample], samplename = this.sample,
                     clustindex = sign[, this.sample],
                     graylevel=0.9)
  dev.off()
}
