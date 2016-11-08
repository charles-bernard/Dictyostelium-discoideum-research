#!/bin/bash

# This script is used to acquire the transcriptomic profile of a set of genes in Dictyostelium discoideum
# It provides:
# The expression of a gene as a function of time in Dictyostelium discoideum's life cycle
# The expression of a gene as a function of phenotype (prestalk, prespore) during the slug stage
# Author:	Charles Bernard
# Contact:	charles.bernard@cri-paris.org

printf "__________________________________________________________________\n\n"
printf "     Dictyostelium discoideum Transcriptomic data acquisition     \n" 
printf "__________________________________________________________________\n\n"
cat input_files/welcomeMsg.txt


printf "__________________________________________________________________\n\n"
printf "How many genes do you want to look at the expression profile ?\n"
read -p"-> " nbGenes


printf "Please enter the name or the dictybase_id of the gene(s)\n"
for (( i=1; i <= nbGenes; i++ ))
do
	read -p"Gene $i : -> " geneName[$i]
done


printf "__________________________________________________________________\n\n"
printf "data extraction: acquisition of dictybase Id of the gene(s)...\n"

for (( i=1; i <= nbGenes; i++ )) 
do
	isRealGene=false
	printf "Gene %d / %d \r" $i $nbGenes
	if [[ "${geneName[$i]}" =~ ^DDB_G0[0-9]{6}$ ]]; then
		geneId[$i]=${geneName[$i]}
		geneLink[$i]="http://dictybase.org/gene/"${geneId[$i]}
		geneName[$i]=`curl -s ${geneLink[$i]} | awk -f scripts/getGeneName.awk`
	else
		while [ "$isRealGene" = false ] 
		do
			queryLink="http://dictybase.org/db/cgi-bin/search/results.pl?class=dicty::UI::Search::Gene&query="${geneName[$i]} 
			geneId[$i]=`curl -s $queryLink | egrep -o DDB_G[0-9]{7}`
			if [ "${geneId[$i]}" == "" ]; then
				printf "\n\nSorry, there is no gene named \"%s\" hosted on dictybase\n" ${geneName[$i]}
				printf "Please enter the correct name or id of the gene\n"
				read -p"Gene $i : -> " geneName[$i]
			else
				isRealGene=true
			fi
		done
		geneLink[$i]="http://dictybase.org/gene/"${geneId[$i]}
	fi
done

printf "__________________________________________________________________\n\n"
	printf "Extraction of gene(s) Id achieved with success !\n"
	printf "Please, find the dictybase link to the gene(s) from the list below:\n\n"
for (( i=1; i <= nbGenes; i++ )) 
do
	printf "\t- %s | %s\n" ${geneName[$i]} ${geneLink[$i]} 
done
	printf "\nHere, you will find plenty of informations about your gene(s) !\n"

plottingMode=""
while [ "$plottingMode" != "c" ] && [ "$plottingMode" != "i" ] && [ "$plottingMode" != "b" ]
do
	if (( nbGenes > 1 )); then
		printf "__________________________________________________________________\n\n"
		printf "You have entered a set of several genes\n"
		printf "Please, enter the option you want:\n"
		printf "\t - compare their respective expression profile (c)\n"
		printf "\t - generate their respective expression profile individually (i)\n"
		printf "\t - both (b)\n"
		read -p"your choice -> " plottingMode
	else
		plottingMode="i"
	fi
done

printf "__________________________________________________________________\n\n"
printf "data extraction: acquisition of the RNA-seq reference of the gene(s)...\n"
for (( i=1; i <= nbGenes; i++ )) 
do
	geneRow_lifeCycle[$i]=`awk -v geneId="^"${geneId[$i]} '$0 ~ geneId { print NR }' input_files/parikh_dictyexpress.tab`
	geneRow_phenotype[$i]=`awk -v geneId="^"${geneId[$i]} '$0 ~ geneId { print NR }' input_files/parikh_normalized_data.txt`
	((geneRow_lifeCycle[$i]--))
	((geneRow_phenotype[$i]--))
done

printf "__________________________________________________________________\n\n"
printf "data presentation: plotting the expression profiles of the gene(s)...\n"
for (( i=1; i <= nbGenes; i++ )) 
do
	outputfile[$i]="output_files/"$i"_"${geneName[$i]}"_expressionProfile.pdf"
	Rscript scripts/getIndividualExpression.R ${geneName[$i]} ${outputfile[$i]} ${geneRow_lifeCycle[$i]} ${geneRow_phenotype[$i]}
done
printf "__________________________________________________________________\n\n"
printf "Do you want to open the pdf file(s) that contain(s) the individual\n"
printf "expression profile of your gene(s) ? (y/n)\n"
read -p"your choice -> " openPdf
if [ "$openPdf" == "y" ]; then
	for (( i=1; i <= nbGenes; i++ )) 
	do
		gnome-open ${outputfile[$i]}
	done
fi

printf "__________________________________________________________________\n\n"
