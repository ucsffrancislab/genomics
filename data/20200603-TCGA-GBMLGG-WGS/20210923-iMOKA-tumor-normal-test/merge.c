
#include <stdio.h>
// #include <stdlib.h>
#include <string.h>
//#include <math.h>

int usage(){
	printf("Ooops.\nYou messed up.\nYou shoulda did something else.\n");
/*
2 input count "matrices", tumor and normal
MUST be sorted alphabetically
*/
}

int main(int argc, char *argv[]) {

	char tumorfilename[1024];
	char normalfilename[1024];
	char outfilename[1024];

	int i;
	if( argc >= 2 ) {
		for(i = 1; i < argc; i++) {
			// Extract the first token
			char * token = strtok(argv[i], "=");
			// loop through the string to extract all other tokens
			while( token != NULL ) {
				if (strncmp(token, "-t", 3) == 0){
					token = strtok(NULL, "="); // guessing NULL means use previous leftovers
					strcpy(tumorfilename,token);
				}else if (strncmp(token, "-n", 3) == 0){
					token = strtok(NULL, "="); // guessing NULL means use previous leftovers
					strcpy(normalfilename,token);
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

	printf("Tumor file %s\n",tumorfilename);
	printf("Normal file %s\n",normalfilename);

	FILE* tumorfile=fopen(tumorfilename,"r");
	FILE* normalfile=fopen(normalfilename,"r");
	FILE* outfile=fopen(outfilename,"w");
	char  tumorsequence[256];
	float tumorcount=0;	
	char  normalsequence[256];
	float normalcount=0;	

	int tumorread;
	int normalread;
	int ret;

	tumorread=fscanf(tumorfile, "%s\t%f", tumorsequence, &tumorcount);
	normalread=fscanf(normalfile, "%s\t%f", normalsequence, &normalcount);

	while( tumorread != EOF && normalread != EOF ){

		//printf("Tumor : %s\t%i\t%f\n",tumorsequence,tumorread,tumorcount);
		//printf("Normal : %s\t%i\t%f\n",normalsequence,normalread,normalcount);

		ret = strcmp(tumorsequence, normalsequence);

		if(ret < 0) {
			//printf("tumor is less than normal\n");
			fprintf(outfile,"%s\t%f\t%f\n",tumorsequence,tumorcount,0.0);
			tumorread=fscanf(tumorfile, "%s\t%f", tumorsequence, &tumorcount);
		} else if(ret > 0) {
			//printf("normal is less than tumor\n");
			fprintf(outfile,"%s\t%f\t%f\n",normalsequence,0.0,normalcount);
			normalread=fscanf(normalfile, "%s\t%f", normalsequence, &normalcount);
		} else {
			//printf("normal is equal to tumor\n");
			fprintf(outfile,"%s\t%f\t%f\n",tumorsequence,tumorcount,normalcount);
			tumorread=fscanf(tumorfile, "%s\t%f", tumorsequence, &tumorcount);
			normalread=fscanf(normalfile, "%s\t%f", normalsequence, &normalcount);
		}

	}

	fclose(tumorfile);
	fclose(normalfile);
	fclose(outfile);


}
/*

gcc -o merge merge.c

time ./merge -t=15/preprocess/19-2629-01A/19-2629-01A.normalized.tsv -n=15/preprocess/19-2629-10A/19-2629-10A.normalized.tsv -o=15/preprocess/19-2629/19-2629.merge.tsv
20 minutes!

*/
