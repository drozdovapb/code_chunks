##pies

svg("distribution.svg")
par(mfrow=c(2, 3))
pie(x = c(98, 12), labels = c("Other genera", "Dictyocoela"), main = "Gammarus duebeni", 
    col = c("white", "green"))
pie(x = c(10, 3), labels = c("Other genera", "Dictyocoela"), main = "G. fossarum", 
    col = c("white", "green"))
pie(x = c(1, 53), labels = c("Other genera", "Dictyocoela"), main = "G. lacustris", 
    col = c("white", "green"))
pie(x = c(13, 26), labels = c("Other genera", "Dictyocoela"), main = "G. pulex", 
    col = c("white", "green"))
pie(x = c(146, 170), labels = c("Other genera", "Dictyocoela"), main = "G. roeselii", 
    col = c("white", "green"))
dev.off()
