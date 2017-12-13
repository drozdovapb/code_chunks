#install and load necessary packages
{
    if (!("ggplot2" %in% installed.packages())) {
        install.packages(gglot2) }
    if (!("coin" %in% installed.packages())) {
        install.packages(gglot2) }
    #load necessary packages
    library(ggplot2)
    library(coin)
}
#The main function
plot_signif <- function(data, variable, contrast_factor, faceting_factor,
                        plot_type = "boxplot",
                        method = "mann_whitney", p.adjust_method = "holm"){
    #draw the initial plot
    p <- ggplot(data = data, aes_string(y = variable, x = contrast_factor)) +
        theme_bw() +
        stat_boxplot(geom ='errorbar', width = 0.25, coef=1000) + 
        geom_boxplot(outlier.size = 0) + facet_wrap(faceting_factor) 
    signif = NULL
    #get max and min values for nice plotting
    range_values <- c(min(data[,variable]), max(data[,variable]))
    p <- p + ylim(1.1 * range_values[1], 1.3 * range_values[2])
    
    
    #run the test (only Mann-Whitney implemented so far)
    #warn if the test is misspelled or not implemented
    if (!(method %in% c("mann_whitney"))) {
        message(paste0("The ", method, " method not been implemented yet. Please contact me if you need it."))}
    
    for (level in levels(data[,faceting_factor])) {
        cond_data <- data[match.fun("==")(data[,faceting_factor], level),]
        if (method == "mann_whitney") {
            test <- wilcox_test(formula = cond_data[,variable] ~ cond_data[,contrast_factor]) }
        signif <- c(signif, pvalue(test))
    }
    #correct the p values (Holm correction is used by default)
    signif_corr <- p.adjust(signif, method = p.adjust_method)
    #and now decide which of these are significant
    is_signif <- ifelse(signif_corr < 0.001, "***",
                        ifelse(signif_corr < 0.01, "**",
                               ifelse(signif_corr < 0.05, "*", "NS")))
    is_signif_df <- cbind(levels(data[,faceting_factor]), is_signif)
    #add lines and asterisks where appropriate
    for (facet in 1:nrow(is_signif_df)) {
        if (is_signif_df[facet, 2] == "NS") next #skip if not significant
        cond_data <- data[match.fun("==")(data[,faceting_factor], is_signif_df[facet,1]),]
        p <- p + geom_segment(data = cond_data,
                              aes(x = 1, xend=2,
                                  y = range_values[2]*1.1, yend = range_values[2]*1.1),
                              inherit.aes=F)
        p <- p + geom_text(data = cond_data, aes(label = is_signif_df[facet, 2],
                                                 x = 1.5, y = range_values[2]*1.25, size = 6),
                           show.legend = FALSE)
    }
    #finally print the plot (and return this object for further use)
    print(p)
    return(p)
}
#Generate sample data
{fact <- c(rep("cont", 20), rep("exp", 20))
    test_data1 <- data.frame(var=c(rnorm(20)*100, (rnorm(20)+3)*100),
                             contrast_fact=fact)
    test_data2 <- data.frame(var=c(rpois(20, lambda = 2)*100, (rpois(20, lambda = 1.5))*100),
                             contrast_fact=fact)
    test_data3 <- data.frame(var=c(runif(20)*100, (runif(20)+3)*100),
                             contrast_fact=fact)
    test_data <- rbind(test_data1, test_data2, test_data3)
    #test_data$facet_fact <- as.factor(c(rep("cond1", 40), rep("cond2", 40), rep("cond3", 40)))
    #if no faceting
    test_data$facet_fact <- as.factor(rep("c1", 120))
}
#run with sample data and all default values
plot_signif(test_data, "var", "contrast_fact", "facet_fact")
#plot_signif(test_data, "var", "contrast_fact", "facet_fact", method = "dlkfj")