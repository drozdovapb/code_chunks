library(rnaturalearth)
library(sp)
library(sf)
library(grImport)
library(plotrix)
load(file="NE.RData")


#svg("map.svg", width=10, height=9)
png("map.png", width=10, height=5, units="in", res=300)

par(mar = c(0, 0, 0, 0))
loc <- list(x=c(-7, 140), y=c(45, 50))
#loc <- list(x=c(50, 130), y=c(40, 75))
plot(countries50, col="white", border=NA, xlim=loc[[1]], ylim=loc[[2]], bg="#a3ccffff")
#plot(coast50, col="white", add=TRUE)
plot(lakes110, col="#a3ccffff", border="#a3ccffff", add=TRUE)

r1 <- 3; r2 <- 2
pcr <- "green"
rna <- "orchid1"

draw.ellipse(x=33.05, y=66.27, a=r1, b=r2, col=pcr, border=NA)
draw.ellipse(x=33.05, y=66.27, a=r1, b=r2, border=pcr)

draw.ellipse(x=90.2004, y=54.4853, a=r1, b=r2, col=pcr, border=NA)
draw.ellipse(x=90.2004, y=54.4853, a=r1, b=r2, border=pcr)

draw.ellipse(x=94.89, y=28.69, a=r1, b=r2, col=rna, segment=c(90, 90 + 360*1/3), arc.only=FALSE, border=NA)
draw.ellipse(x=94.89, y=28.69, a=r1, b=r2, border=rna)

draw.ellipse(x=-3.999, y=56.672, a=r1, b=r2, col=pcr, border=NA)
draw.ellipse(x=-3.999, y=56.672, a=r1, b=r2, border=pcr)

draw.ellipse(x=105, y=55, a=r1, b=r2, col=pcr, segment=c(90, 90 + 360*42/43), arc.only=FALSE, border=NA)
draw.ellipse(x=105, y=55, a=r1, b=r2, border=pcr)
draw.ellipse(x=113.3, y=55, a=r1, b=r2, col=rna, segment=c(90, 90 + 360*48/65), arc.only=FALSE, border=NA)
draw.ellipse(x=113.3, y=55, a=r1, b=r2, border=rna)


text(x=33.05, y=66.27, "3")
text(x=-3.999, y=56.672, "1")
text(x=90.2004, y=54.4853, "2")
text(x=94.89, y=28.69, "3")

text(x=105, y=55, "43")
text(x=113.3, y=55, "65")

text(x=46, y=62.7, "Kartesh, coast of White Sea", cex=1.2)
text(x=78, y=54.4853, "Lake Shira", cex=1.2)
text(x=94.89, y=34.5, "A water body in\nTibetan plateau", cex=1.2)
text(x=9.5, y=52.3, "Loch Kinardochy", cex=1.2)
text(x=113, y=60.5, "Small water bodies\naround Lake Baikal", cex=1.2)


draw.ellipse(x=-5, y=32, a=r1, b=r2, col=pcr, segment=c(90, 360), arc.only=FALSE, border=NA)
draw.ellipse(x=-5, y=32, a=r1, b=r2, border=pcr)
draw.ellipse(x=-5, y=27.7, a=r1, b=r2, col=rna, segment=c(90, 360), arc.only=FALSE, border=NA)
draw.ellipse(x=-5, y=27.7, a=r1, b=r2, border=rna)
text(x=-5, y=23.4, "1")
#text(x=0, y=22, "Total number of sequences/samples per location", pos=4)

af <- 0.7
legend(-1, 32, substitute(paste("Proportion of ", italic('Dictyocoela'), " within DNA sequences in NCBI")), yjust=0.5, box.lwd=0, bg=adjustcolor('white', alpha.f=af))
legend(-1, 27.7, substitute(paste("Proportion of RNA sequencing samples infected by ", italic('Dictyocoela'))), yjust=0.5, box.lwd=0, bg=adjustcolor('white', alpha.f=af))
legend(-1, 23.4, "Total number of sequences/samples per location", yjust=0.5, box.lwd=0, bg=adjustcolor('white', alpha.f=af))

dev.off()
