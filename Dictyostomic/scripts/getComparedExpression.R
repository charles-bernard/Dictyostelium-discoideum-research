quantile_normalisation <- function(data) {
  data_ranked <- apply(data, 2, rank, ties.method="min")
  data_sorted <- data.frame(apply(data_ranked, 2, sort))
  data_mean <- apply(data_sorted, 1, mean)
   
  index_to_mean <- function(my_index, my_mean) {
    return(my_mean[my_index])
  }
   
  data_final <- apply(data_ranked, 2, index_to_mean, my_mean = data_mean)
  return(data_final)
}

if (!require("gplots")) {
   	install.packages(pkgs ="gplots", dependencies = TRUE)
   	library(gplots)
}

references = read.table("input_files/pst_genes.txt");
row_lifeCycle = references[,3];
geneNames = references[,2];

rosengarten_lifeCycle = read.table("input_files/rosengarten_dictyexpress.tab", header = T, sep = "\t");
rosengarten_lifeCycleMat = data.matrix(rosengarten_lifeCycle);
log_rosengarten_lifeCycleMat = t(apply(rosengarten_lifeCycleMat[row_lifeCycle, 2:20], 1, log2))
normLog_rosengarten_lifeCycleMat = quantile_normalisation(log_rosengarten_lifeCycleMat)
normRaw_rosengarten_lifeCycleMat = t(apply(rosengarten_lifeCycleMat[row_lifeCycle, 2:20], 1, function(x)(x-min(x))/(max(x)-min(x))))
pdf("test.pdf", height = length(geneNames)/2, width = 30)
heatmap.2(normRaw_rosengarten_lifeCycleMat,
	Colv = FALSE,
	margins = c(7,20),
	dendrogram = "row",
	trace = "none",
	density.info = "none",
	lmat=rbind( c(0, 3), c(2,1), c(0,4) ), lhei=c(0.25, 4, 0.25 ),
	labRow = geneNames,
	labCol = c(0:12, seq(14,24, by = 2)),
	cexRow = 3,
	cexCol = 4,
	xlab  = "Time (Hour)",
	cex.lab = 5,
	key = FALSE)
title("Expression Profile of Prestalk Genes\nClustered mainly according to Expression Change along the Life Cycle", outer = T, line = -15, cex.main = 5)
mtext("Method = Each row individually normalized\nSource: Rosengarthen et al. (2015)", outer = T, line = -25, cex = 3)
heatmap.2(normLog_rosengarten_lifeCycleMat,
	Colv = FALSE,
	margins = c(7,20),
	dendrogram = "row",
	trace = "none",
	density.info = "none",
	lmat=rbind( c(0, 3), c(2,1), c(0,4) ), lhei=c(0.25, 4, 0.25 ),
	labRow = geneNames,
	labCol = c(0:12, seq(14,24, by = 2)),
	cexRow = 3,
	cexCol = 4,
	key = FALSE,
	vline = c(4,8,16))
title("Expression Profile of Prestalk Genes\nClustered mainly according to Expression Intensity", outer = T, line = -10, cex.main = 5)
mtext("Method = All Intensities log-transformed and further quantiles-normalized \nSource: Rosengarthen et al. (2015)", outer = T, line = -20, cex = 3)

invisible(dev.off())