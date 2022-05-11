
#include <stdio.h>
// #include <stdlib.h>
#include <string.h>
//#include <math.h>

#include <zlib.h>

# define LL 8192   /* line length maximum */


char * gt1;
char * gt2;
char actualgt1[1024];
char actualgt2[1024];
gzFile vcffile;
char line[LL];
char  vcfchrom[256];
long  vcfpos=0;	


void read_vcf(){
	char  vcfid[256];
	char  vcfref[1024];
	char  vcfalt[1024];
	char  vcfqual[256];
	char  vcffilter[256];
	char  vcfinfo[256];
	char  vcfformat[256];
	char  vcfsample[256];
	int vcfread;

	gzgets( vcffile, line, 8192 );
	vcfread=sscanf(line, "%s\t%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s", vcfchrom, &vcfpos, vcfid, vcfref, vcfalt, vcfqual, vcffilter, vcfinfo, vcfformat, vcfsample);

	char * gt = strtok(vcfsample, ":");
	char * vcfalt1 = strtok(vcfalt, ",");
	char * vcfalt2 = strtok(NULL, ",");

	gt1 = strtok(gt, "/");
	gt2 = strtok(NULL, "/");

//printf("%s",line);
//printf("%d\t%s\t%s\n",vcfpos, vcfref, vcfalt);

	if (strncmp(gt1, "0", 1) == 0)
		strcpy(actualgt1,vcfref);
	else if (strncmp(gt1, "1", 1) == 0)
		strcpy(actualgt1,vcfalt1);
	else if (strncmp(gt1, "2", 1) == 0)
		strcpy(actualgt1,vcfalt2);

	if (strncmp(gt2, "0", 1) == 0)
		strcpy(actualgt2,vcfref);
	else if (strncmp(gt2, "1", 1) == 0)
		strcpy(actualgt2,vcfalt1);
	else if (strncmp(gt2, "2", 1) == 0)
		strcpy(actualgt2,vcfalt2);

}


int usage(){
	printf("Ooops.\nYou messed up.\nYou shoulda did something else.\n");
	return 1;
}



int main(int argc, char *argv[]) {

	// For some reason, the first line is missing the gt values unless the following is done.
	setvbuf(stdout, NULL, 0, _IONBF);

	char gzvcffilename[1024];
	char positionsfilename[1024];

	int i;
	if( argc >= 2 ) {
		for(i = 1; i < argc; i++) {
			// Extract the first token
			char * token = strtok(argv[i], "=");
			// loop through the string to extract all other tokens
			while( token != NULL ) {
				if (strncmp(token, "-v", 3) == 0){
					token = strtok(NULL, "="); // guessing NULL means use previous leftovers
					strcpy(gzvcffilename,token);
				}else if (strncmp(token, "-p", 3) == 0){
					token = strtok(NULL, "="); // guessing NULL means use previous leftovers
					strcpy(positionsfilename,token);
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

//	printf("GZ VCF file %s\n",gzvcffilename);
//	printf("Positions file %s\n",positionsfilename);

	//gzFile vcffile=gzopen(gzvcffilename,"r");
	vcffile=gzopen(gzvcffilename,"r");
	FILE* posfile=fopen(positionsfilename,"r");

	char  other[256];
	char  poschrom[256];
	long  pospos=0;	
	char  posref[256];

	int posread;
	int compare_chrom;

	do {
		gzgets( vcffile, line, 8192 );
	} while ( line[0] == '#'	 );

	read_vcf();

	posread=fscanf(posfile, "%s\t%d\t%s", poschrom, &pospos, posref);

	while ( ! gzeof( vcffile ) && ! feof(posfile) ){

		compare_chrom = strcmp(vcfchrom, poschrom);

		if ( ( compare_chrom > 0 ) || ( ( compare_chrom == 0 ) && ( pospos > vcfpos ) ) ) {
			//			printf("positions is ahead of vcf\n");
			// increment vcf

			read_vcf();

		} else if ( ( compare_chrom < 0 )	|| ( ( compare_chrom == 0 ) && ( pospos < vcfpos ) ) ) {
			//			printf("vcf is ahead of position\n");
			// missing chrom and position
			// print the chrom, position and REFERENCE gt

			// assuming if its not in the VCF as a variant, it is reference

			printf("%s\t%d\t%s/%s\n",poschrom,pospos,posref,posref);

			posread=fscanf(posfile, "%s\t%d\t%s", poschrom, &pospos, posref);

		} else {
			// same chrom and position
			// print the chrom, position and VCF gt
			//printf("%s\t%d\t%s\n",poschrom,pospos,gt);
			//printf("2:%s\t%d\t%s/%s\n",poschrom,pospos,gt1,gt2);
			printf("%s\t%d\t%s/%s\n",vcfchrom,vcfpos,actualgt1,actualgt2);

			read_vcf();
			posread=fscanf(posfile, "%s\t%d\t%s", poschrom, &pospos, posref);
		}

	}

	gzclose(vcffile);
	fclose(posfile);

}
/*


GT : genotype, encoded as allele values separated by either of / or |. The allele values are 0 for the reference
allele (what is in the REF field), 1 for the first allele listed in ALT, 2 for the second allele list in ALT and
so on. For diploid calls examples could be 0/1, 1 | 0, or 1/2, etc. For haploid calls, e.g. on Y, male nonpseudoautosomal X, or mitochondrion, only one allele value should be given; a triploid call might look like
0/0/1. If a call cannot be made for a sample at a given locus, ‘.’ should be specified for each missing allele
in the GT field (for example ‘./.’ for a diploid genotype and ‘.’ for haploid genotype). The meanings of the
separators are as follows (see the PS field below for more details on incorporating phasing information into the
genotypes):
◦ / : genotype unphased
◦ | : genotype phased



#	Also there can be 1/2
#	ALT can be XXX,YYY


gcc -lz -o extract extract.c


./extract -v=out/HMN83552.call.vcf.gz -p=out/B1-c1/souporcell/positions -o=test
GZ VCF file out/HMN83552.call.vcf.gz
Positions file out/B1-c1/souporcell/positions
Out file test


*/
