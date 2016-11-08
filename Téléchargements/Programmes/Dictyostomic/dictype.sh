#!/bin/bash

# Author:	Charles Bernard
# Contact:	charles.bernard@cri-paris.org

printf "__________________________________________________________________\n\n"
printf "     Dictyostelium discoideum Transcriptomic data acquisition     \n" 
printf "__________________________________________________________________\n\n"
cat input_files/welcomeMsg2.txt

printf "__________________________________________________________________\n\n"
printf "Installation of R package gplots...\n"
Rscript scripts/install_gplots.R

printf "__________________________________________________________________\n\n"
printf "What kind of cell-type specific genes are you interested in ?\n"
printf "\t - Prestalk (t)\n"
printf "\t - Prespore (p)\n"
printf "\t - Both (b)\n"
read -p"-> " phenotype

if [ "$phenotype" = "t" ] || [ "$phenotype" = "b" ]; then
	printf "__________________________________________________________________\n\n"
	printf "Please, define some criteria of selection for the prestalk genes\n\n"
	printf "\tEnter the minimum gene expression level required \n"
	printf "\tduring the slug stage to be considered as a Pst gene?\n\n"
	printf "\tRecommanded value: 1000\n\n"
	read -p"Your expression threshold (in nb of transcripts) -> " pstThreshold
	printf "\n\tHow many times more expressed should be a gene \n"
	printf "\tinside Pst cells than inside Psp cells?\n\n"
	printf "\tRecommanded value: 6\n\n"
	read -p"Your segregation factor -> " pstFactor	
	pstDirectory="output_files/pstGenes"
	if [ ! -d $pstDirectory ]; then
		mkdir $pstDirectory
	fi
fi
if [ "$phenotype" = "p" ] || [ "$phenotype" = "b" ]; then
	printf "__________________________________________________________________\n\n"
	printf "Please, define some criteria of selection for the prespore genes\n\n"
	printf "\tEnter the minimum gene expression level required \n"
	printf "\tduring the slug stage to be considered as a Psp gene?\n\n"
	printf "\tRecommanded value: 1000\n\n"
	read -p"Your expression threshold (in nb of transcripts) -> " pspThreshold
	printf "\n\tHow many times more expressed should be a gene \n"
	printf "\tinside Psp cells than inside Pst cells?\n\n"
	printf "\tRecommanded value: 6\n\n"
	read -p"Your segregation factor -> " pspFactor
	pspDirectory="output_files/pspGenes"
	if [ ! -d $pspDirectory ]; then
		mkdir $pspDirectory
	fi
fi

printf "__________________________________________________________________\n\n"
printf "data acquisition: printing the id of cell-type specific Genes...\n\n"
if [ "$phenotype" = "t" ] || [ "$phenotype" = "b" ]; then
	Rscript scripts/getPstGenes.R $pstThreshold $pstFactor | awk -v threshold=$pstThreshold -v factor=$pstFactor 'BEGIN {FS = " "; printf("Criteria of selection of Pst genes: Expression Threshold = %s ; Segregation Factor = %s\n", threshold, factor)} {print $2}' > $pstDirectory"/pstGenesId.txt"
	printf "You will find the dictybase id of Pst Genes in the following file:\n"
	printf "\t/%s/pstGenesId.txt\n\n" $pstDirectory
fi
if [ "$phenotype" = "p" ] || [ "$phenotype" = "b" ]; then
	Rscript scripts/getPspGenes.R $pspThreshold $pspFactor | awk -v threshold=$pspThreshold -v factor=$pspFactor 'BEGIN {FS = " "; printf("Criteria of selection of Psp genes: Expression Threshold = %s ; Segregation Factor = %s\n", threshold, factor)} {print $2}' > $pspDirectory"/pspGenesId.txt"
	printf "You will find the dictybase id of Psp Genes in the following file:\n"
	printf "\t/%s/pspGenesId.txt\n\n" $pspDirectory
fi

nbPstGenes=`awk 'END {print NR-1}' $pstDirectory"/pstGenesId.txt"`
nbPspGenes=`awk 'END {print NR-1}' $pspDirectory"/pspGenesId.txt"`

printf "__________________________________________________________________\n\n"
printf "data extraction : acquisition of the names of these genes (this may takes a few minutes)\n"
if [ "$phenotype" = "t" ] || [ "$phenotype" = "b" ]; then
	printf "Extracting Pst gene Names...\n"
	for (( i=1; i <= nbPstGenes; i++ )) 
	do
		printf "Gene %d / %d \r" $i $nbPstGenes
		pstGeneName[$i]=`awk -v i=$i 'NR==i+1' $pstDirectory"/pstGenesId.txt"`
		if [[ "${pstGeneName[$i]}" =~ ^DDB_G0[0-9]{6}$ ]]; then
			pstGeneId[$i]=${pstGeneName[$i]}
			pstGeneLink[$i]="http://dictybase.org/gene/"${pstGeneId[$i]}
			pstGeneName[$i]=`curl -s ${pstGeneLink[$i]} | awk -f scripts/getGeneName.awk`
			if [ "${pstGeneName[$i]}" = "" ]; then
				pstGeneName[$i]=${pstGeneId[$i]}
			fi
		else
			queryLink="http://dictybase.org/db/cgi-bin/search/results.pl?class=dicty::UI::Search::Gene&query="${pstGeneName[$i]} 
			pstGeneId[$i]=`curl -s $queryLink | egrep -o DDB_G[0-9]{7}`
		fi
		pstGeneLink[$i]="http://dictybase.org/gene/"${pstGeneId[$i]}
	done
fi
if [ "$phenotype" = "p" ] || [ "$phenotype" = "b" ]; then
	printf "Extracting Psp gene Names...\n"
	for (( i=1; i <= nbPspGenes; i++ )) 
	do
		printf "Gene %d / %d \r" $i $nbPspGenes
		pspGeneName[$i]=`awk -v i=$i 'NR==i+1' $pspDirectory"/pspGenesId.txt"`
		if [[ "${pspGeneName[$i]}" =~ ^DDB_G0[0-9]{6}$ ]]; then
			pspGeneId[$i]=${pspGeneName[$i]}
			pspGeneLink[$i]="http://dictybase.org/gene/"${pspGeneId[$i]}
			pspGeneName[$i]=`curl -s ${pspGeneLink[$i]} | awk -f scripts/getGeneName.awk`
		else
			queryLink="http://dictybase.org/db/cgi-bin/search/results.pl?class=dicty::UI::Search::Gene&query="${pspGeneName[$i]} 
			pspGeneId[$i]=`curl -s $queryLink | egrep -o DDB_G[0-9]{7}`
		fi
		pspGeneLink[$i]="http://dictybase.org/gene/"${pspGeneId[$i]}
	done	
fi

printf "__________________________________________________________________\n\n"
printf "data extraction: acquisition of the RNA-seq reference of the genes...\n"
if [ "$phenotype" = "t" ] || [ "$phenotype" = "b" ]; then
	for (( i=1; i <= nbPstGenes; i++ )) 
	do
		pstGeneRow_lifeCycle[$i]=$(awk -v geneId="^"${pstGeneId[$i]} '$0 ~ geneId { print NR-1 }' input_files/parikh_dictyexpress.tab)
		pstGeneRow_phenotype[$i]=$(awk -v geneId="^"${pstGeneId[$i]} '$0 ~ geneId { print NR-1 }' input_files/parikh_normalized_data.txt)
	done
fi
if [ "$phenotype" = "p" ] || [ "$phenotype" = "b" ]; then
	for (( i=1; i <= nbPspGenes; i++ )) 
	do
		pspGeneRow_lifeCycle[$i]=$(awk -v geneId="^"${pspGeneId[$i]} '$0 ~ geneId { print NR-1 }' input_files/parikh_dictyexpress.tab)
		pspGeneRow_phenotype[$i]=$(awk -v geneId="^"${pspGeneId[$i]} '$0 ~ geneId { print NR-1 }' input_files/parikh_normalized_data.txt)
	done
fi

printf "__________________________________________________________________\n\n"
printf "Printing genes Infos...\n"
if [ "$phenotype" = "t" ] || [ "$phenotype" = "b" ]; then
	printf "Criteria of selection of Pst genes: Expression Threshold = %s ; Segregation Factor = %s\n" $pstThreshold $pstFactor > $pstDirectory"/pstTmp"
	printf "DictybaseLink\tName\tRNA-seqRef(lifecycle)\tRNA-seqRef(phenotype)\n" >> $pstDirectory"/pstTmp"
	for (( i=1; i <= nbPstGenes; i++ )) 
	do
		awk -v link=${pstGeneLink[$i]} -v name=${pstGeneName[$i]} -v rowLC=${pstGeneRow_lifeCycle[$i]} -v rowP=${pstGeneRow_phenotype[$i]} 'BEGIN {printf("%s\t%s\t%s\t%s\n", link, name, rowLC, rowP)}' >> $pstDirectory"/pstTmp"
	done
	awk -f scripts/eraseMissingData.awk $pstDirectory"/pstTmp" > $pstDirectory"/pstGenesInfo.txt"
	rm $pstDirectory"/pstTmp"
fi
if [ "$phenotype" = "p" ] || [ "$phenotype" = "b" ]; then
	printf "Criteria of selection of Psp genes: Expression Threshold = %s ; Segregation Factor = %s\n" $pspThreshold $pspFactor > $pspDirectory"/pspTmp"
	printf "Dictybase Link\tName\tRNA-seqRef(lifecycle)\tRNA-seqRef(phenotype)\n" >> $pspDirectory"/pspTmp"
	for (( i=1; i <= nbPspGenes; i++ )) 
	do
		awk -v link=${pspGeneLink[$i]} -v name=${pspGeneName[$i]} -v rowLC=${pspGeneRow_lifeCycle[$i]} -v rowP=${pspGeneRow_phenotype[$i]} 'BEGIN {printf("%s\t%s\t%s\t%s\n", link, name, rowLC, rowP)}' >> $pspDirectory"/pspTmp"
	done
	awk -f scripts/eraseMissingData.awk $pspDirectory"/pspTmp" > $pspDirectory"/pspGenesInfo.txt"
	rm $pspDirectory"/pspTmp"
fi

printf "__________________________________________________________________\n\n"
printf "Clustering the expression profile of the genes...\n"
if [ "$phenotype" = "t" ] || [ "$phenotype" = "b" ]; then
	Rscript scripts/pstAnalysis.R
fi
if [ "$phenotype" = "p" ] || [ "$phenotype" = "b" ]; then
	Rscript scripts/pspAnalysis.R
fi

printf "__________________________________________________________________\n\n"
printf "Do you want to plot the individual expression profile\n of each of these genes? (y/n)\n"
read -p"Your choice -> " getIndividualExp
if [ "$getIndividualExp" = "y" ]; then
	if [ "$phenotype" = "t" ] || [ "$phenotype" = "b" ]; then
		pstIndDirectory=$pstDirectory"/IndividualExpressions"
		if [ ! -d $pstIndDirectory ]; then
			mkdir $pstIndDirectory
		fi
		printf "Plotting Pst genes Expression...\n"
		for (( i=1; i <= nbPstGenes; i++ )) 
		do
			printf "Gene %d / %d \r" $i $nbPstGenes
			outputfile=$pstIndDirectory"/"$i"_"${pstGeneName[$i]}"_expressionProfile.pdf"
			Rscript scripts/getIndividualExpression.R ${pstGeneName[$i]} $outputfile ${pstGeneRow_lifeCycle[$i]} ${pstGeneRow_phenotype[$i]}
		done
	fi
	if [ "$phenotype" = "p" ] || [ "$phenotype" = "b" ]; then
		pspIndDirectory=$pspDirectory"/IndividualExpressions"
		if [ ! -d $pspIndDirectory ]; then
			mkdir $pspIndDirectory
		fi
		printf "Plotting Pst genes Expression...\n"
		for (( i=1; i <= nbPspGenes; i++ )) 
		do
			printf "Gene %d / %d \r" $i $nbPspGenes
			outputfile=$pspIndDirectory"/"$i"_"${pspGeneName[$i]}"_expressionProfile.pdf"
			Rscript scripts/getIndividualExpression.R ${pspGeneName[$i]} $outputfile ${pspGeneRow_lifeCycle[$i]} ${pspGeneRow_phenotype[$i]}
		done
	fi
fi