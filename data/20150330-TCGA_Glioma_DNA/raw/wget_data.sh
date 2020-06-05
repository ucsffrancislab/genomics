#!/bin/sh -x

{
#wget https://costellolab.ucsf.edu/steve/G2145.TCGA-06-0152-01A-02D.12_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G2146.TCGA-06-0185-01A-01D.9_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G2147.TCGA-06-0648-01A-01D.7_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26360.TCGA-32-1970-01A-01D-1494-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26362.TCGA-06-0157-01A-01D-1491-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26363.TCGA-19-2624-01A-01D-1495-08.2_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26366.TCGA-06-0686-01A-01D-1492-08.2_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26368.TCGA-19-2629-01A-01D-1495-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26370.TCGA-27-1831-01A-01D-1494-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26374.TCGA-06-5415-01A-01D-1486-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26375.TCGA-27-2528-01A-01D-1494-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26376.TCGA-27-2523-01A-01D-1494-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26380.TCGA-06-0744-01A-01D-1492-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26381.TCGA-14-1823-01A-01D-1494-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26382.TCGA-06-2557-01A-01D-1494-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26386.TCGA-06-0745-01A-01D-1492-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26387.TCGA-19-2620-01A-01D-1495-08.2_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26391.TCGA-26-5135-01A-01D-1486-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26396.TCGA-41-5651-01A-01D-1696-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26397.TCGA-19-5960-01A-11D-1696-08.2_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26398.TCGA-06-5411-01A-01D-1696-08.2_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26401.TCGA-15-1444-01A-02D-1696-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26402.TCGA-06-2570-01A-01D-1495-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G26405.TCGA-14-2554-01A-01D-1494-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G49538.TCGA-06-0190-01A-01D-1491-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G49538.TCGA-06-0210-01A-01D-1491-08.1_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G49538.TCGA-14-1034-01A-01D-1492-08.3_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/G49538.TCGA-14-1402-01A-01D-1493-08.3_unmapped.bam
#wget https://costellolab.ucsf.edu/steve/TCGA-06-0214-01A-02D-0512-09_unmapped.bam
#
#chmod -w *bam

chmod +w md5sums
md5sum G2145.TCGA-06-0152-01A-02D.12_unmapped.bam >> md5sums
md5sum G2146.TCGA-06-0185-01A-01D.9_unmapped.bam >> md5sums
md5sum G2147.TCGA-06-0648-01A-01D.7_unmapped.bam >> md5sums
md5sum G26360.TCGA-32-1970-01A-01D-1494-08.1_unmapped.bam >> md5sums
md5sum G26362.TCGA-06-0157-01A-01D-1491-08.1_unmapped.bam >> md5sums
md5sum G26363.TCGA-19-2624-01A-01D-1495-08.2_unmapped.bam >> md5sums
md5sum G26366.TCGA-06-0686-01A-01D-1492-08.2_unmapped.bam >> md5sums
md5sum G26368.TCGA-19-2629-01A-01D-1495-08.1_unmapped.bam >> md5sums
md5sum G26370.TCGA-27-1831-01A-01D-1494-08.1_unmapped.bam >> md5sums
md5sum G26374.TCGA-06-5415-01A-01D-1486-08.1_unmapped.bam >> md5sums
md5sum G26375.TCGA-27-2528-01A-01D-1494-08.1_unmapped.bam >> md5sums
md5sum G26376.TCGA-27-2523-01A-01D-1494-08.1_unmapped.bam >> md5sums
md5sum G26380.TCGA-06-0744-01A-01D-1492-08.1_unmapped.bam >> md5sums
md5sum G26381.TCGA-14-1823-01A-01D-1494-08.1_unmapped.bam >> md5sums
md5sum G26382.TCGA-06-2557-01A-01D-1494-08.1_unmapped.bam >> md5sums
md5sum G26386.TCGA-06-0745-01A-01D-1492-08.1_unmapped.bam >> md5sums
md5sum G26387.TCGA-19-2620-01A-01D-1495-08.2_unmapped.bam >> md5sums
md5sum G26391.TCGA-26-5135-01A-01D-1486-08.1_unmapped.bam >> md5sums
md5sum G26396.TCGA-41-5651-01A-01D-1696-08.1_unmapped.bam >> md5sums
md5sum G26397.TCGA-19-5960-01A-11D-1696-08.2_unmapped.bam >> md5sums
md5sum G26398.TCGA-06-5411-01A-01D-1696-08.2_unmapped.bam >> md5sums
md5sum G26401.TCGA-15-1444-01A-02D-1696-08.1_unmapped.bam >> md5sums
md5sum G26402.TCGA-06-2570-01A-01D-1495-08.1_unmapped.bam >> md5sums
md5sum G26405.TCGA-14-2554-01A-01D-1494-08.1_unmapped.bam >> md5sums
md5sum G49538.TCGA-06-0190-01A-01D-1491-08.1_unmapped.bam >> md5sums
md5sum G49538.TCGA-06-0210-01A-01D-1491-08.1_unmapped.bam >> md5sums
md5sum G49538.TCGA-14-1034-01A-01D-1492-08.3_unmapped.bam >> md5sums
md5sum G49538.TCGA-14-1402-01A-01D-1493-08.3_unmapped.bam >> md5sums
md5sum TCGA-06-0214-01A-02D-0512-09_unmapped.bam >> md5sums


bam2fastx --fasta --all -N G2145.TCGA-06-0152-01A-02D.12_unmapped.bam > G2145.fasta
bam2fastx --fasta --all -N G2146.TCGA-06-0185-01A-01D.9_unmapped.bam > G2146.fasta
bam2fastx --fasta --all -N G2147.TCGA-06-0648-01A-01D.7_unmapped.bam > G2147.fasta
bam2fastx --fasta --all -N G26360.TCGA-32-1970-01A-01D-1494-08.1_unmapped.bam > G26360.fasta
bam2fastx --fasta --all -N G26362.TCGA-06-0157-01A-01D-1491-08.1_unmapped.bam > G26362.fasta
bam2fastx --fasta --all -N G26363.TCGA-19-2624-01A-01D-1495-08.2_unmapped.bam > G26363.fasta
bam2fastx --fasta --all -N G26366.TCGA-06-0686-01A-01D-1492-08.2_unmapped.bam > G26366.fasta
bam2fastx --fasta --all -N G26368.TCGA-19-2629-01A-01D-1495-08.1_unmapped.bam > G26368.fasta
bam2fastx --fasta --all -N G26370.TCGA-27-1831-01A-01D-1494-08.1_unmapped.bam > G26370.fasta
bam2fastx --fasta --all -N G26374.TCGA-06-5415-01A-01D-1486-08.1_unmapped.bam > G26374.fasta
bam2fastx --fasta --all -N G26375.TCGA-27-2528-01A-01D-1494-08.1_unmapped.bam > G26375.fasta
bam2fastx --fasta --all -N G26376.TCGA-27-2523-01A-01D-1494-08.1_unmapped.bam > G26376.fasta
bam2fastx --fasta --all -N G26380.TCGA-06-0744-01A-01D-1492-08.1_unmapped.bam > G26380.fasta
bam2fastx --fasta --all -N G26381.TCGA-14-1823-01A-01D-1494-08.1_unmapped.bam > G26381.fasta
bam2fastx --fasta --all -N G26382.TCGA-06-2557-01A-01D-1494-08.1_unmapped.bam > G26382.fasta
bam2fastx --fasta --all -N G26386.TCGA-06-0745-01A-01D-1492-08.1_unmapped.bam > G26386.fasta
bam2fastx --fasta --all -N G26387.TCGA-19-2620-01A-01D-1495-08.2_unmapped.bam > G26387.fasta
bam2fastx --fasta --all -N G26391.TCGA-26-5135-01A-01D-1486-08.1_unmapped.bam > G26391.fasta
bam2fastx --fasta --all -N G26396.TCGA-41-5651-01A-01D-1696-08.1_unmapped.bam > G26396.fasta
bam2fastx --fasta --all -N G26397.TCGA-19-5960-01A-11D-1696-08.2_unmapped.bam > G26397.fasta

bam2fastx --fasta --all -N G26398.TCGA-06-5411-01A-01D-1696-08.2_unmapped.bam > G26398.fasta
bam2fastx --fasta --all -N G26401.TCGA-15-1444-01A-02D-1696-08.1_unmapped.bam > G26401.fasta
bam2fastx --fasta --all -N G26402.TCGA-06-2570-01A-01D-1495-08.1_unmapped.bam > G26402.fasta
bam2fastx --fasta --all -N G26405.TCGA-14-2554-01A-01D-1494-08.1_unmapped.bam > G26405.fasta

bam2fastx --fasta --all -N G49538.TCGA-06-0190-01A-01D-1491-08.1_unmapped.bam > G49538-06-0190.fasta
bam2fastx --fasta --all -N G49538.TCGA-06-0210-01A-01D-1491-08.1_unmapped.bam > G49538-06-0210.fasta
bam2fastx --fasta --all -N G49538.TCGA-14-1034-01A-01D-1492-08.3_unmapped.bam > G49538-14-1034.fasta
bam2fastx --fasta --all -N G49538.TCGA-14-1402-01A-01D-1493-08.3_unmapped.bam > G49538-14-1402.fasta
bam2fastx --fasta --all -N TCGA-06-0214-01A-02D-0512-09_unmapped.bam > Gunknown.fasta

chmod -w *fasta
md5sum *fasta >> md5sums
chmod -w md5sums

mv *fasta /my/home/ccls/data/nobackup/TCGA_Glioma/

} 1>>wget_data.log 2>&1
