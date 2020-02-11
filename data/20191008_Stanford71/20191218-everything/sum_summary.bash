#!/usr/bin/env bash



gawk -F"\t" '
( tolower($1) ~ /phage/ ){
	for(i=2;i<=NF;i++) phage[i]+=$i
	next
}
( tolower($1) ~ /adeno/ ){
	for(i=2;i<=NF;i++) adeno[i]+=$i
	next
}
( tolower($1) ~ /herpes/ ){
	for(i=2;i<=NF;i++) herpes[i]+=$i
	next
}
{print}
END {
	printf("Adeno\t")
	for(i=2;i<=NF;i++) 
		printf("%i\t",adeno[i])
	printf("\n")
	printf("Phage\t")
	for(i=2;i<=NF;i++) 
		printf("%i\t",phage[i])
	printf("\n")
	printf("Herpes\t")
	for(i=2;i<=NF;i++) 
		printf("%i\t",herpes[i])
	printf("\n")
}' $1
