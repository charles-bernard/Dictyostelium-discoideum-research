args = commandArgs(trailingOnly = TRUE);
threshold = as.integer(args[1])
factor = as.integer(args[2])

parikh_phenotype = read.table("input_files/parikh_normalized_data.txt", header = T, sep = "\t");
parikh_phenotypeMat = data.matrix(parikh_phenotype);

geneId = parikh_phenotype[, 1];
dimMat = dim(parikh_phenotypeMat)
nbGenes = dimMat[1]

for(i in 1:nbGenes) {
	mean_pst = mean(parikh_phenotypeMat[i, c(17,19)])
	mean_psp = mean(parikh_phenotypeMat[i, c(16,18)])
	if(mean_pst > threshold && mean_pst > factor * mean_psp) {
		print(geneId[i], max.levels = 0)
	}
}