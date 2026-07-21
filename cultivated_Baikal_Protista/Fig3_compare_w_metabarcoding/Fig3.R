library(ggplot2)
library(dplyr)
library(ggpubr)
library(rnaturalearth)
library(rnaturalearthdata)
library(scales)
#library(ggthemes) ## didn't use

searchres <- read.delim("SRA_blasting_res.csv")

## get latitude and longitude from coordinate string
gsub(" E", "", searchres$lat_lon) %>% strsplit(" N ") -> latlon
sapply(latlon, "[", 1) %>% as.numeric() -> lat
sapply(latlon, "[", 2) %>% as.numeric() -> lon
## and put them back to the main dataframe
searchres$lat <- lat; searchres$lon <- lon

russia <- ne_download(scale = 'large', returnclass = "sf", type='lakes', category='physical')
russia2 <- ne_download(scale = 'large', returnclass = "sf", type='rivers_lake_centerlines', category='physical')


plotBaikaldistrib <- function (colname) {
  ggplot(data=searchres) + 
    geom_sf(data = russia, color = "skyblue", fill="#ACC2D9") +
    geom_sf(data = russia2, colour = "skyblue", linewidth = 0.2, alpha=0.5) + 
    geom_point(data=searchres, aes(x=lon, y=lat, col=.data[[colname]]), size=1.5) + 
    coord_sf(xlim = c(102.5, 110.5), ylim = c(51, 56), expand = FALSE) + 
    scale_color_gradient(low="beige", high="red", na.value = "transparent",
                         limits = c(82, 100), oob = scales::squish,
                         breaks=c(85, 90, 95, 100), guide = "colorbar") + 
    geom_point(data=searchres[searchres[[colname]]==100, ], 
               aes(x=lon, y=lat), shape=8, col="red", size=2) + 
    labs(x="", y="", color = "% идентичности с наилучшим совпадением") + 
    theme_minimal(ink = "black", base_size = 14)
}

pCAd15m <- plotBaikaldistrib("Cad.15m")
pCAd16m <- plotBaikaldistrib("Cad.16m")
pCAd17m <- plotBaikaldistrib("Cad.17m")

ggarrange(pCAd15m, pCAd16m, pCAd17m, nrow=1, labels=c("(а)", "(б)", "(в)"),
          common.legend = TRUE, legend="bottom")
ggsave("Fig3_draft.svg", device=svg, width=28, height=12, units="cm")

