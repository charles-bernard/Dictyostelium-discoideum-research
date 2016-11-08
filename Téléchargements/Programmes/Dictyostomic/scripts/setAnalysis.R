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

library(gplots)

files = commandArgs(trailingOnly = TRUE);
input = files[1]
output = files[2]

references = read.table(input, header = T, sep = "\t");
geneNames = references[,2];
row_lifeCycle = as.integer(references[,3]);
row_phenotype = as.integer(references[,4]);
n = length(geneNames)

parikh_phenotype = read.table("input_files/parikh_normalized_data.txt", header = T, sep = "\t");
parikh_phenotypeMat = data.matrix(parikh_phenotype)
mean_pst = rowMeans(parikh_phenotypeMat[row_phenotype, c(17,19)], 1)
mean_psp = rowMeans(parikh_phenotypeMat[row_phenotype, c(16,18)], 1)
cellType_differential = mean_pst / mean_psp
rank_differential = rank(cellType_differential)
geneNames_differential = geneNames[rank_differential]
differentialMat = replicate(2, sort(cellType_differential))
log_differentialMat = t(apply(differentialMat, 1, log2))

rosengarten_lifeCycle = read.table("input_files/rosengarten_dictyexpress.tab", header = T, sep = "\t");
rosengarten_lifeCycleMat = data.matrix(rosengarten_lifeCycle);
log_rosengarten_lifeCycleMat = t(apply(rosengarten_lifeCycleMat[row_lifeCycle, 2:20], 1, log2))
normLog_rosengarten_lifeCycleMat = quantile_normalisation(log_rosengarten_lifeCycleMat)
normRaw_rosengarten_lifeCycleMat = t(apply(rosengarten_lifeCycleMat[row_lifeCycle, 2:20], 1, function(x)(x-min(x))/(max(x)-min(x))))

pdf(output, height = n + 15 * (1/log10(n)), width = 30)
par(mar = c(20,60,30,60), lheight = 1)
image(c(1:2), c(1:n), t(log_differentialMat),
	ylab = "",
	xlab = "",
	xaxt = "n",
	yaxt = "n")
axis(2, at = c(1:n), labels = geneNames_differential, las = 2, cex.axis = 2)
title("Hierarchy of Ratios:\n Expression in Pst cells / Expression in Psp cells", outer = T, line = -12, cex.main = 5)
mtext("Method = Each ratio log2-transformed\nSource: Parikh et al. (2010)", outer = T, line = -22, cex = 3)
heatmap.2(normRaw_rosengarten_lifeCycleMat,
	Colv = FALSE,
	margins = c(20,20),
	dendrogram = "row",
	trace = "none",
	density.info = "none",
	lmat=rbind( c(0, 3), c(2,1), c(0,4) ), lhei=c(0.25, log10(n), 0.25 ),
	labRow = geneNames,
	labCol = c(0:12, seq(14,24, by = 2)),
	cexRow = 3,
	cexCol = 4,
	xlab  = "Time (Hour)",
	cex.lab = 5,
	key = FALSE)
title("Expression Profile of the set of Genes\nClustered mainly according to Expression Change along the Life Cycle", outer = T, line = -12, cex.main = 5)
mtext("Method = Each row individually normalized\nSource: Rosengarthen et al. (2015)", outer = T, line = -22, cex = 3)
heatmap.2(normLog_rosengarten_lifeCycleMat,
	Colv = FALSE,
	margins = c(20,20),
	dendrogram = "row",
	trace = "none",
	density.info = "none",
	lmat=rbind( c(0, 3), c(2,1), c(0,4) ), lhei=c(0.25, log10(n), 0.25 ),
	labRow = geneNames,
	labCol = c(0:12, seq(14,24, by = 2)),
	cexRow = 3,
	cexCol = 4,
	xlab  = "Time (Hour)",
	cex.lab = 5,
	key = FALSE)
title("Expression Profile of the set of Genes\nClustered mainly according to Expression Intensity", outer = T, line = -12, cex.main = 5)
mtext("Method = All Intensities log2-transformed and further quantiles-normalized \nSource: Rosengarthen et al. (2015)", outer = T, line = -22, cex = 3)

invisible(dev.off())
