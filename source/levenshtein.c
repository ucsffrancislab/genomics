
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <math.h>

int usage(){
	printf("Ooops.\nYou messed up.\nYou shoulda did something else.\n");
	exit(1);
/*
2 input count "matrices", tumor and normal
MUST be sorted alphabetically
*/
}

// modified from https://www.lemoda.net/c/levenshtein/l.c

int main(int argc, char *argv[]) {

	char word1[1024];
	char word2[1024];

	if( argc == 3 ){
		// argv[0] is the script name
		strcpy(word1,argv[1]);
		strcpy(word2,argv[2]);
	} else {
		usage();
	}

	int word1_length;
	int word2_length;
	word1_length = strlen (word1);
	word2_length = strlen (word2);

	int matrix[word1_length + 1][word2_length + 1];
	int i;
	for (i = 0; i <= word1_length; i++) {
		matrix[i][0] = i;
	}
	for (i = 0; i <= word2_length; i++) {
		matrix[0][i] = i;
	}
	for (i = 1; i <= word1_length; i++) {
		int j;
		char c1;

		c1 = word1[i-1];
		for (j = 1; j <= word2_length; j++) {
			char c2;

			c2 = word2[j-1];
			if (c1 == c2) {
				matrix[i][j] = matrix[i-1][j-1];
			} else {
				int delete;
				int insert;
				int substitute;
				int minimum;

				delete = matrix[i-1][j] + 1;
				insert = matrix[i][j-1] + 1;
				substitute = matrix[i-1][j-1] + 1;
				minimum = delete;
				if (insert < minimum) {
					minimum = insert;
				}
				if (substitute < minimum) {
					minimum = substitute;
				}
				matrix[i][j] = minimum;
			}
		}
	}
	printf("%s\t%s\t%d\n",word1,word2,matrix[word1_length][word2_length]);

	return(0);
}
/*

gcc -o levenshtein levenshtein.c

./levenshtein apples oranges
5

./levenshtein kitten sitting
3

./levenshtein maximum minimum
2



*/
