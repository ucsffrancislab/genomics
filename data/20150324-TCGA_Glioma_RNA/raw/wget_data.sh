#!/bin/sh -x

{

wget https://costellolab.ucsf.edu/steve/TCGA-02-2483-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-02-2485-01A-01R-1849-01.2_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-0125-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-0157-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-0190-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-0210-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-0686-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-0744-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-0745-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-2557-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-2570-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-5411-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-06-5415-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-14-1034-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-14-1823-01A-01R-1849-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-14-2554-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-15-1444-01A-02R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-19-2620-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-19-2624-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-19-2629-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-19-5960-01A-11R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-26-5132-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-26-5135-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-27-1831-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-27-2528-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-32-1970-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-41-5651-01A-01R-1850-01_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-AA-3966-01A-01R-1113-07_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-C5-A1M9-01A-11R-A13Y-07_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-C5-A1MI-01A-11R-A14Y-07_unmapped.bam
wget https://costellolab.ucsf.edu/steve/TCGA-GV-A3JZ-01A-11R-A21D-07_unmapped.bam

chmod -w *bam

chmod +w md5sums
md5sum *bam >> md5sums

#bam2fastx --fasta --all -N TCGA-06-0214-01A-02D-0512-09_unmapped.bam > Gunknown.fasta
#
#chmod -w *fasta
#md5sum *fasta >> md5sums
#chmod -w md5sums
#
#mv *fasta /my/home/ccls/data/nobackup/TCGA_Glioma/

} 1>>wget_data.log 2>&1
