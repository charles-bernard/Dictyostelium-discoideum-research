BEGIN {
	FS = "\t";
} 

{
	if(NR==1 || NR == 2) { 
		print $0;
	} 
	if($3 ~ /^[0-9]/ && $4 ~ /^[0-9]+/) {
		print $0;
	} 
}
