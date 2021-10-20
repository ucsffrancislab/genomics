
#include <stdio.h>

// #include <stdlib.h>
#include <string.h>
// #include <conio.h>
#include <math.h>

int usage(){
	printf("Ooops.\nYou messed up.\nYou shoulds did something else.\n");
/*
		-k|--kmer|--kmer_length)
			shift; kmer_length=$1; shift;;
		-l|--length|--read_length)
			shift; read_length=$1; shift;;
		-c|--count|--read_count)
			shift; read_count=$1; shift;;
		-i|--in|--in_file)
			shift; in_file=$1; shift;;
		-o|--out|--out_file)
			shift; out_file=$1; shift;;
*/
}

int main(int argc, char *argv[]) {

	unsigned short int kmer_length=0;
	unsigned short int read_length=0;
	unsigned long int  read_count=0;	
	unsigned long int  kmer_count=0;	
	float              norm_factor=0;	

	/* unsigned long int      - [0, 4,294,967,295] %lu */
	/* unsigned long long int - [0, +18,446,744,073,709,551,615] %llu */
	
	char infilename[1024];
	char outfilename[1024];

	int i;
	if( argc >= 2 ) {
		for(i = 1; i < argc; i++) {
			// Extract the first token
			char * token = strtok(argv[i], "=");
			// loop through the string to extract all other tokens
			while( token != NULL ) {
				if (strncmp(token, "-k", 3) == 0){
					token = strtok(NULL, "="); // guessing NULL means use previous leftovers
					kmer_length=atoi(token);
				}else if (strncmp(token, "-l", 3) == 0){
					token = strtok(NULL, "="); // guessing NULL means use previous leftovers
					read_length=atoi(token);
				}else if (strncmp(token, "-c", 3) == 0){
					token = strtok(NULL, "="); // guessing NULL means use previous leftovers
					read_count=atoi(token);
				}else if (strncmp(token, "-i", 3) == 0){
					token = strtok(NULL, "="); // guessing NULL means use previous leftovers
					strcpy(infilename,token);
				}else if (strncmp(token, "-o", 3) == 0){
					token = strtok(NULL, "="); // guessing NULL means use previous leftovers
					strcpy(outfilename,token);
				} else{
					printf("%s\n",argv[i]);
					printf("%s\n",token);
					usage();
					return 1;
				}
				token=NULL;
			}
		}
	} else {
		usage();
	}

	printf("Kmer length %hu\n",kmer_length);
	printf("Read length %hu\n",read_length);
	printf("Read count %lu\n",read_count);
	kmer_count=(read_count*read_length)+((1-kmer_length)*read_count);
	printf("kmer count %lu\n",kmer_count);
	norm_factor=pow(10,9)/kmer_count;
	printf("norm factor %f\n",norm_factor);
	printf("In file %s\n",infilename);
	printf("Out file %s\n",outfilename);

	FILE* infile=fopen(infilename,"r");
	FILE* outfile=fopen(outfilename,"w");
	char sequence[256];
	unsigned long int count=0;	
	float             norm_count=0;	
	
	while ( fscanf(infile, "%s\t%d", sequence, &count) != EOF ){
		norm_count=norm_factor*count;
		fprintf(outfile,"%s\t%f\n",sequence,norm_count);
	}

	fclose(infile);
	fclose(outfile);

	return 0;
}

/*

Took me longer to write this than it does to run.

gcc -o normalize normalize.c              

cat /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/19-2629-01A*R1.fastq.gz.average_length.txt 
101

cat /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/19-2629-01A*R1.fastq.gz.read_count.txt
648880870
echo $((2*648880870))
1297761740

cat /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/19-2629-10A*R1.fastq.gz.average_length.txt 
101
cat /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/19-2629-10A*R1.fastq.gz.read_count.txt
578708416
echo $((2*578708416))
1157416832

time ./normalize -k=15 -l=101 -c=1297761740 -i=15/preprocess/19-2629-01A/19-2629-01A.tsv -o=15/preprocess/19-2629-01A/19-2629-01A.normalized.tsv 
10 minutes!

time ./normalize -k=15 -l=101 -c=1157416832 -i=15/preprocess/19-2629-10A/19-2629-10A.tsv -o=15/preprocess/19-2629-10A/19-2629-10A.normalized.tsv 
11 minutes!

*/
