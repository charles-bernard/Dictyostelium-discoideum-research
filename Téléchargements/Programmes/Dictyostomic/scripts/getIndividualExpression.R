args = commandArgs(trailingOnly = TRUE);
gene = args[1]
outputFile = args[2]
row_lifeCycle = as.integer(args[3])
row_phenotype = as.integer(args[4])

rosengarten_lifeCycle = read.table("input_files/rosengarten_dictyexpress.tab", header = T, sep = "\t");
parikh_lifeCycle = read.table("input_files/parikh_dictyexpress.tab", header = T, sep = "\t");
parikh_phenotype = read.table("input_files/parikh_normalized_data.txt", header = T, sep = "\t");

rosengarten_lifeCycleMat = data.matrix(rosengarten_lifeCycle);
parikh_lifeCycleMat = data.matrix(parikh_lifeCycle);
parikh_phenotypeMat = data.matrix(parikh_phenotype);

pdf(outputFile, height = 10, width = 16)
yMax = max(rosengarten_lifeCycleMat[row_lifeCycle, 2:20])
par(mar = c(9, 9, 9, 5) + 0.1)
plot(c(0:12, seq(14,24, by = 2)), rosengarten_lifeCycleMat[row_lifeCycle, 2:20],
		xlab = "Time (Hour)",
		ylab = "Expression (RPKM)",
		cex.lab = 2,
		xlim = c(0, 24),
		ylim = c(0, round(1.25 * yMax)),
		xaxs = "i",
		yaxs = "i",
		xaxt = "n",
		type = "b",
		pch = 19,
		lwd = 3,
		col = "darkblue")
axis(1, at = c(0:24))
abline(v=c(4,8,16,18,20), lty = "dashed")
text(2, yMax * 1.2, labels = "INDIVIDUALS", cex = 1.4)
text(6, yMax * 1.2, labels = "AGGREGATES", cex = 1.4)
text(12, yMax * 1.2, labels = "MOUNDS", cex = 1.4)
text(17, yMax * 1.2, labels = "SLUGS", cex = 1.4)
text(19, yMax * 1.2, labels = "M. HATS", cex = 1.4)
text(22, yMax * 1.2, labels = "FRUITING BODIES", cex = 1.4)
title(paste("Expression profile of", gene, "during D. discoideum Life Cycle"), line = 5, cex.main = 2.5)
mtext("Source: Rosengarten et al. (2015)", line = 2.5, cex = 1.5)

yMax = max(parikh_lifeCycleMat[row_lifeCycle,2:8])
par(mar = c(9, 9, 9, 5) + 0.1)
plot(seq(0,24, by = 4), parikh_lifeCycleMat[row_lifeCycle, 2:8],
		xlab = "Time (Hour)",
		ylab = "Expression (RPKM)",
		cex.lab = 2,
		xlim = c(0, 24),
		ylim = c(0, round(1.25 * yMax)),
		xaxs = "i",
		yaxs = "i",
		xaxt = "n",
		type = "b",
		pch = 19,
		lwd = 3,
		col = "darkblue")
axis(1, at = c(0:24))
abline(v=c(4,8,16,18,20), lty = "dashed")
text(2, yMax * 1.2, labels = "INDIVIDUALS", cex = 1.4)
text(6, yMax * 1.2, labels = "AGGREGATES", cex = 1.4)
text(12, yMax * 1.2, labels = "MOUNDS", cex = 1.4)
text(17, yMax * 1.2, labels = "SLUGS", cex = 1.4)
text(19, yMax * 1.2, labels = "M. HATS", cex = 1.4)
text(22, yMax * 1.2, labels = "FRUITING BODIES", cex = 1.4)
title(paste("Expression profile of", gene, "during D. discoideum Life Cycle"), line = 5, cex.main = 2.5)
mtext("Source: Parikh et al. (2010)", line = 2.5, cex = 1.5)

par(mfrow = c(1,3), oma = c(0, 0, 2, 0))
par(mar = c(15, 10, 20, 22) + 0.1)

yMax = max(parikh_phenotypeMat[row_phenotype, 16:17])
barplot(parikh_phenotypeMat[row_phenotype, 16:17],
		ylab = "nb of transcripts",
		cex.lab = 2.5,
		names.arg = c("Prespore", "Prestalk"),
		cex.names = 2.7,
		col = c("lightgoldenrod1", "grey94"),
		width = 3.5,
		space = c(0.3, 0.25),
		xlim = c(0, 3),
		ylim = c(0, round(yMax * 1.15)),
		cex.axis = 1.7)
axis(2, at=c(0,round(yMax) * 1.15), cex.axis = 1.7, labels = F)
title("sample 1", line = 4.5, cex.main = 2.5)

yMax = max(parikh_phenotypeMat[row_phenotype, 18:19])
barplot(parikh_phenotypeMat[row_phenotype, 18:19],
		ylab = "nb of transcripts",
		cex.lab = 2.5,
		names.arg = c("Prespore", "Prestalk"),
		cex.names = 2.7,
		col = c("lightgoldenrod1", "grey94"),
		width = 3.5,
		space = c(0.3, 0.25),
		xlim = c(0, 3),
		ylim = c(0, round(yMax * 1.15)),
		cex.axis = 1.7)
axis(2, at=c(0, round(yMax) * 1.15), cex.axis = 1.7, labels = F)
title("sample 2", line = 4.5, cex.main = 2.5)

mean_pst = mean(parikh_phenotypeMat[row_phenotype, c(17,19)])
mean_psp = mean(parikh_phenotypeMat[row_phenotype, c(16,18)])
yMax = max(c(mean_pst, mean_psp))
barplot(c(mean_psp, mean_pst),
		ylab = "nb of transcripts",
		cex.lab = 2.5,
		names.arg = c("Prespore", "Prestalk"),
		cex.names = 2.7,
		col = c("lightgoldenrod1", "grey94"),
		width = 3.5,
		space = c(0.3, 0.25),
		xlim = c(0, 3),
		ylim = c(0, round(yMax * 1.15)),
		cex.axis = 1.7)
axis(2, at=c(0,round(yMax) * 1.15), cex.axis = 1.7, labels = F)
title("mean", line = 4.5, cex.main = 2.5)

title(paste("Expression Level of", gene, "as a function of cell-type during the slug stage"), outer = T, line = -5, cex.main = 3.5)
mtext("Source: Parikh et al. (2010)", outer = T, line = -9, cex = 1.5)
invisible(dev.off())