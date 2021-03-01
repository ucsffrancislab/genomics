
#	Manta / Strelka

Be sure to have installed manta and strelka in separate directories.
They contain some files of the same name that are not the same!
( ~/.local/manta and ~/.local/strelka )

```BASH
cd ~/github/illumina/manta
mkdir build
cd build
../configure --prefix=$HOME/.local/manta
make
make install

cd ~/github/illumina/strelka
mkdir build
cd build
../configure --prefix=$HOME/.local/strelka
make
make install
```



```BASH
./manta_strelka.bash
```


```BASH
module load bcftools/1.10.2

for f in out/*.*.manta_strelka/strelka/results/variants/somatic.snvs.vcf.gz ; do
echo $f
f100=${f/.???./.100.}
bcftools view --no-header $f | wc -l > $f.count 
bcftools view -f PASS --no-header $f | wc -l > $f.PASS_count 
bcftools isec -C ${f100} ${f} | wc -l > $f.100_isec_count
bcftools isec -f PASS -C ${f100} ${f} | wc -l > $f.PASS_100_isec_count
bcftools isec -C ${f} ${f100} | wc -l > $f.isec_100_count
bcftools isec -f PASS -C ${f} ${f100} | wc -l > $f.PASS_isec_100_count
bcftools isec -n =2 ${f} ${f100} | wc -l > $f.shared_100_isec_count
bcftools isec -f PASS -n =2 ${f} ${f100} | wc -l > $f.PASS_shared_100_isec_count
bcftools isec -n -1 ${f} ${f100} | wc -l > $f.diff_100_isec_count
bcftools isec -f PASS -n -1 ${f} ${f100} | wc -l > $f.PASS_diff_100_isec_count
done

./report.bash >> README.md
```





|    | 268325 | 439338 | 63185 | 634370 | 983899 |
| --- | --- | --- | --- | --- | --- |
| Calls 100 | 866127 | 459218 | 2084378 | 523933 | 1260400 |
| Calls 80a | 806884 | 386935 | 1685127 | 437618 | 1202164 |
| Calls 80b | 805826 | 386515 | 1684577 | 438168 | 1202033 |
| Calls 80c | 806499 | 386894 | 1683774 | 437914 | 1203035 |
| Calls 60a | 597880 | 325296 | 1583717 | 351015 | 1036929 |
| Calls 60b | 597966 | 325804 | 1584047 | 351200 | 1036722 |
| Calls 60c | 598581 | 325613 | 1583755 | 351694 | 1038703 |
| Calls 50a | 501082 | 308967 | 1426547 | 312599 | 859992 |
| Calls 50b | 500142 | 309264 | 1426866 | 311975 | 858949 |
| Calls 50c | 501686 | 309756 | 1425714 | 312124 | 861889 |
| % Calls 100/100 | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |
| % Calls 80a/100 | 93.16 | 84.25 | 80.84 | 83.52 | 95.37 |
| % Calls 80b/100 | 93.03 | 84.16 | 80.81 | 83.63 | 95.36 |
| % Calls 80c/100 | 93.11 | 84.25 | 80.78 | 83.58 | 95.44 |
| % Calls 60a/100 | 69.02 | 70.83 | 75.98 | 66.99 | 82.26 |
| % Calls 60b/100 | 69.03 | 70.94 | 75.99 | 67.03 | 82.25 |
| % Calls 60c/100 | 69.11 | 70.90 | 75.98 | 67.12 | 82.41 |
| % Calls 50a/100 | 57.85 | 67.28 | 68.43 | 59.66 | 68.23 |
| % Calls 50b/100 | 57.74 | 67.34 | 68.45 | 59.54 | 68.14 |
| % Calls 50c/100 | 57.92 | 67.45 | 68.39 | 59.57 | 68.38 |
| isec Diff Calls 100 100 | 0 | 0 | 0 | 0 | 0 |
| isec Diff Calls 100 80a | 545117 | 179085 | 1329573 | 190699 | 883952 |
| isec Diff Calls 100 80b | 545473 | 179425 | 1330491 | 191077 | 884625 |
| isec Diff Calls 100 80c | 545000 | 178710 | 1331564 | 191625 | 885039 |
| isec Diff Calls 100 60a | 747797 | 295360 | 2087333 | 311046 | 1276691 |
| isec Diff Calls 100 60b | 747467 | 295442 | 2087903 | 311263 | 1277012 |
| isec Diff Calls 100 60c | 745990 | 295065 | 2086641 | 311435 | 1277715 |
| isec Diff Calls 100 50a | 812545 | 355993 | 2220725 | 366502 | 1326786 |
| isec Diff Calls 100 50b | 812031 | 356736 | 2221392 | 366858 | 1326183 |
| isec Diff Calls 100 50c | 811305 | 356704 | 2220232 | 366957 | 1327611 |
| % isec Diff Calls 100/100 | 0 | 0 | 0 | 0 | 0 |
| % isec Diff Calls 80a/100 | 62.93 | 38.99 | 63.78 | 36.39 | 70.13 |
| % isec Diff Calls 80b/100 | 62.97 | 39.07 | 63.83 | 36.46 | 70.18 |
| % isec Diff Calls 80c/100 | 62.92 | 38.91 | 63.88 | 36.57 | 70.21 |
| % isec Diff Calls 60a/100 | 86.33 | 64.31 | 100.14 | 59.36 | 101.29 |
| % isec Diff Calls 60b/100 | 86.29 | 64.33 | 100.16 | 59.40 | 101.31 |
| % isec Diff Calls 60c/100 | 86.12 | 64.25 | 100.10 | 59.44 | 101.37 |
| % isec Diff Calls 50a/100 | 93.81 | 77.52 | 106.54 | 69.95 | 105.26 |
| % isec Diff Calls 50b/100 | 93.75 | 77.68 | 106.57 | 70.02 | 105.21 |
| % isec Diff Calls 50c/100 | 93.67 | 77.67 | 106.51 | 70.03 | 105.33 |
| isec Shared Calls 100 100 | 866127 | 459218 | 2084378 | 523933 | 1260400 |
| isec Shared Calls 100 80a | 563947 | 333534 | 1219966 | 385426 | 789306 |
| isec Shared Calls 100 80b | 563240 | 333154 | 1219232 | 385512 | 788904 |
| isec Shared Calls 100 80c | 563813 | 333701 | 1218294 | 385111 | 789198 |
| isec Shared Calls 100 60a | 358105 | 244577 | 790381 | 281951 | 510319 |
| isec Shared Calls 100 60b | 358313 | 244790 | 790261 | 281935 | 510055 |
| isec Shared Calls 100 60c | 359359 | 244883 | 790746 | 282096 | 510694 |
| isec Shared Calls 100 50a | 277332 | 206096 | 645100 | 235015 | 396803 |
| isec Shared Calls 100 50b | 277119 | 205873 | 644926 | 234525 | 396583 |
| isec Shared Calls 100 50c | 278254 | 206135 | 644930 | 234550 | 397339 |
| % isec Shared Calls 100/100 | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |
| % isec Shared Calls 80a/100 | 65.11 | 72.63 | 58.52 | 73.56 | 62.62 |
| % isec Shared Calls 80b/100 | 65.02 | 72.54 | 58.49 | 73.58 | 62.59 |
| % isec Shared Calls 80c/100 | 65.09 | 72.66 | 58.44 | 73.50 | 62.61 |
| % isec Shared Calls 60a/100 | 41.34 | 53.25 | 37.91 | 53.81 | 40.48 |
| % isec Shared Calls 60b/100 | 41.36 | 53.30 | 37.91 | 53.81 | 40.46 |
| % isec Shared Calls 60c/100 | 41.49 | 53.32 | 37.93 | 53.84 | 40.51 |
| % isec Shared Calls 50a/100 | 32.01 | 44.87 | 30.94 | 44.85 | 31.48 |
| % isec Shared Calls 50b/100 | 31.99 | 44.83 | 30.94 | 44.76 | 31.46 |
| % isec Shared Calls 50c/100 | 32.12 | 44.88 | 30.94 | 44.76 | 31.52 |
| PASS Calls 100 | 10101 | 14082 | 35235 | 6991 | 14114 |
| PASS Calls 80a | 7980 | 13087 | 25710 | 6642 | 11725 |
| PASS Calls 80b | 7940 | 13043 | 25798 | 6660 | 11888 |
| PASS Calls 80c | 8038 | 13027 | 25694 | 6659 | 11893 |
| PASS Calls 60a | 6281 | 11507 | 18981 | 6151 | 8961 |
| PASS Calls 60b | 6142 | 11495 | 19053 | 6183 | 8965 |
| PASS Calls 60c | 6367 | 11551 | 19068 | 6258 | 8864 |
| PASS Calls 50a | 6253 | 10266 | 14790 | 5889 | 7752 |
| PASS Calls 50b | 6173 | 10280 | 14880 | 5942 | 7647 |
| PASS Calls 50c | 6430 | 10324 | 14808 | 5980 | 7793 |
| PASS % Calls 100/100 | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |
| PASS % Calls 80a/100 | 79.00 | 92.93 | 72.96 | 95.00 | 83.07 |
| PASS % Calls 80b/100 | 78.60 | 92.62 | 73.21 | 95.26 | 84.22 |
| PASS % Calls 80c/100 | 79.57 | 92.50 | 72.92 | 95.25 | 84.26 |
| PASS % Calls 60a/100 | 62.18 | 81.71 | 53.86 | 87.98 | 63.49 |
| PASS % Calls 60b/100 | 60.80 | 81.62 | 54.07 | 88.44 | 63.51 |
| PASS % Calls 60c/100 | 63.03 | 82.02 | 54.11 | 89.51 | 62.80 |
| PASS % Calls 50a/100 | 61.90 | 72.90 | 41.97 | 84.23 | 54.92 |
| PASS % Calls 50b/100 | 61.11 | 73.00 | 42.23 | 84.99 | 54.18 |
| PASS % Calls 50c/100 | 63.65 | 73.31 | 42.02 | 85.53 | 55.21 |
| PASS isec Diff Calls 100 100 | 0 | 0 | 0 | 0 | 0 |
| PASS isec Diff Calls 100 80a | 6367 | 2549 | 29963 | 1859 | 12005 |
| PASS isec Diff Calls 100 80b | 6331 | 2627 | 30131 | 1775 | 12046 |
| PASS isec Diff Calls 100 80c | 6389 | 2589 | 29911 | 1828 | 12139 |
| PASS isec Diff Calls 100 60a | 9200 | 4371 | 38452 | 2636 | 15623 |
| PASS isec Diff Calls 100 60b | 9077 | 4395 | 38322 | 2606 | 15727 |
| PASS isec Diff Calls 100 60c | 9196 | 4429 | 38351 | 2655 | 15566 |
| PASS isec Diff Calls 100 50a | 10434 | 5642 | 38921 | 2980 | 16324 |
| PASS isec Diff Calls 100 50b | 10354 | 5674 | 38903 | 2973 | 16381 |
| PASS isec Diff Calls 100 50c | 10489 | 5662 | 38929 | 3025 | 16277 |
| PASS % isec Diff Calls 100/100 | 0 | 0 | 0 | 0 | 0 |
| PASS % isec Diff Calls 80a/100 | 63.03 | 18.10 | 85.03 | 26.59 | 85.05 |
| PASS % isec Diff Calls 80b/100 | 62.67 | 18.65 | 85.51 | 25.38 | 85.34 |
| PASS % isec Diff Calls 80c/100 | 63.25 | 18.38 | 84.89 | 26.14 | 86.00 |
| PASS % isec Diff Calls 60a/100 | 91.08 | 31.03 | 109.13 | 37.70 | 110.69 |
| PASS % isec Diff Calls 60b/100 | 89.86 | 31.21 | 108.76 | 37.27 | 111.42 |
| PASS % isec Diff Calls 60c/100 | 91.04 | 31.45 | 108.84 | 37.97 | 110.28 |
| PASS % isec Diff Calls 50a/100 | 103.29 | 40.06 | 110.46 | 42.62 | 115.65 |
| PASS % isec Diff Calls 50b/100 | 102.50 | 40.29 | 110.41 | 42.52 | 116.06 |
| PASS % isec Diff Calls 50c/100 | 103.84 | 40.20 | 110.48 | 43.26 | 115.32 |
| PASS isec Shared Calls 100 100 | 10101 | 14082 | 35235 | 6991 | 14114 |
| PASS isec Shared Calls 100 80a | 5857 | 12310 | 15491 | 5887 | 6917 |
| PASS isec Shared Calls 100 80b | 5855 | 12249 | 15451 | 5938 | 6978 |
| PASS isec Shared Calls 100 80c | 5875 | 12260 | 15509 | 5911 | 6934 |
| PASS isec Shared Calls 100 60a | 3591 | 10609 | 7882 | 5253 | 3726 |
| PASS isec Shared Calls 100 60b | 3583 | 10591 | 7983 | 5284 | 3676 |
| PASS isec Shared Calls 100 60c | 3636 | 10602 | 7976 | 5297 | 3706 |
| PASS isec Shared Calls 100 50a | 2960 | 9353 | 5552 | 4950 | 2771 |
| PASS isec Shared Calls 100 50b | 2960 | 9344 | 5606 | 4980 | 2690 |
| PASS isec Shared Calls 100 50c | 3021 | 9372 | 5557 | 4973 | 2815 |
| PASS % isec Shared Calls 100/100 | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |
| PASS % isec Shared Calls 80a/100 | 57.98 | 87.41 | 43.96 | 84.20 | 49.00 |
| PASS % isec Shared Calls 80b/100 | 57.96 | 86.98 | 43.85 | 84.93 | 49.44 |
| PASS % isec Shared Calls 80c/100 | 58.16 | 87.06 | 44.01 | 84.55 | 49.12 |
| PASS % isec Shared Calls 60a/100 | 35.55 | 75.33 | 22.36 | 75.13 | 26.39 |
| PASS % isec Shared Calls 60b/100 | 35.47 | 75.20 | 22.65 | 75.58 | 26.04 |
| PASS % isec Shared Calls 60c/100 | 35.99 | 75.28 | 22.63 | 75.76 | 26.25 |
| PASS % isec Shared Calls 50a/100 | 29.30 | 66.41 | 15.75 | 70.80 | 19.63 |
| PASS % isec Shared Calls 50b/100 | 29.30 | 66.35 | 15.91 | 71.23 | 19.05 |
| PASS % isec Shared Calls 50c/100 | 29.90 | 66.55 | 15.77 | 71.13 | 19.94 |



