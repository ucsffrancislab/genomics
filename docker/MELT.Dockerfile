#
#FROM ubuntu:latest
#
#docker run -v $PWD:/pwd --rm melt java -Xmx6G -jar /MELT/MELTv2.1.5fast.jar
#Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/commons/cli/ParseException
#	at java.base/java.lang.Class.getDeclaredMethods0(Native Method)
#	at java.base/java.lang.Class.privateGetDeclaredMethods(Class.java:3458)
#	at java.base/java.lang.Class.getMethodsRecursive(Class.java:3599)
#	at java.base/java.lang.Class.getMethod0(Class.java:3585)
#	at java.base/java.lang.Class.getMethod(Class.java:2275)
#	at org.eclipse.jdt.internal.jarinjarloader.JarRsrcLoader.main(JarRsrcLoader.java:57)
#Caused by: java.lang.ClassNotFoundException: org.apache.commons.cli.ParseException
#	at java.base/java.net.URLClassLoader.findClass(URLClassLoader.java:445)
#	at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:588)
#	at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:521)
#	... 6 more
#
#	Not sure what's missing, but start with a different docker base image or MELT 2.1.5 fails
#
FROM openjdk:8-jre-slim
MAINTAINER Jake Wendt <jakewendt@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive
#	Which is best? Either? Both?
#ENV DEBIAN_FRONTEND noninteractive

WORKDIR /root
#WORKDIR /opt

#	ENTRYPOINT ???


#	libboost-all-dev - not compiling libmaus2 so do I need this anymore
#
#	which ? just want java
#	openjdk-19-jre-headless - jvm takes up 500MB
#	openjdk-19-jdk-headless - jvm takes up 500MB
#		default-jre-headless \

#RUN apt-get update \
RUN apt update -y && apt upgrade -y \
	&& apt install -y apt-utils gcc g++ make software-properties-common git wget \
		pkg-config zip unzip bzip2 libbz2-dev libncurses5-dev zlib1g-dev \
		bc gzip python3 \
	&& apt clean -y && apt autoremove -y

#		openjdk-19-jre \
#openjdk-19-jre-headless \

#	What do each of these do
# apt-get -y update 
# apt-get -y upgrade
#	apt-get -y full-upgrade - equivalent to dist-upgrade?
#	apt-get dist-upgrade - can upgrade kernel


#	libmaus2
#	
#	RUN cd ~ \
#		&& git clone https://gitlab.com/german.tischler/libmaus2 \
#		&& cd libmaus2 \
#		&& libtoolize \
#		&& aclocal \
#		&& autoreconf -i -f \
#		&& ./configure \
#		&& make \
#		&& make install \
#		&& cd ~ \
#		&& /bin/rm -rf libmaus2
#	
#	
#	Apparently only a thing on Mac
#
#+++ b/src/libmaus2/util/MemoryStatistics.hpp
#@@ -18,6 +18,7 @@
# #if ! defined(LIBMAUS2_UTIL_MEMORYSTATISTICS_HPP)
# #define LIBMAUS2_UTIL_MEMORYSTATISTICS_HPP
# 
#+#include <sys/sysctl.h>
# #include <libmaus2/types/types.hpp>
# #include <libmaus2/arch/PageSize.hpp>
# #include <libmaus2/exception/LibMausException.hpp>
#	
#	
#	biobambam2
#	git clone https://gitlab.com/german.tischler/biobambam2.git
#	for bam to paired fastq. Doesn't require sorting and tolerates missing data
#	
#	- autoreconf -i -f
#	- ./configure --with-libmaus2=${LIBMAUSPREFIX} \
#		--prefix=${HOME}/biobambam2
#	- make install
#	
#	RUN cd ~ \
#		&& git clone https://gitlab.com/german.tischler/biobambam2 \
#		&& cd biobambam2 \
#		&& autoreconf -i -f \
#		&& ./configure \
#		&& make \
#		&& make install \
#		&& cd ~ \
#		&& /bin/rm -rf biobambam2

RUN cd / \
	&& wget https://gitlab.com/german.tischler/biobambam2/uploads/ffbf93e1b4ca3a695bba8f10b131cf44/biobambam2_x86_64-linux-gnu_2.0.180.tar.xz \
	&& tar xvfJ biobambam2_x86_64-linux-gnu_2.0.180.tar.xz \
	&& mv biobambam2/x86_64-linux-gnu/2.0.180/bin/* /usr/local/bin/ \
	&& mv biobambam2/x86_64-linux-gnu/2.0.180/lib/* /usr/local/lib/ \
	&& cd ~ \
	&& /bin/rm -rf /biobambam2*


#ENV HTSLIB_VERSION 1.16
#ENV SAMTOOLS_VERSION 1.16.1
#ENV BOWTIE2_VERSION 2.5.1
#ENV HTSLIB_URL https://github.com/samtools/htslib/releases/download
#ENV SAMTOOLS_URL https://github.com/samtools/samtools/releases/download
#ENV BOWTIE2_URL https://sourceforge.net/projects/bowtie-bio/files/bowtie2
##https://github.com/BenLangmead/bowtie2/releases/download/v2.5.1/bowtie2-2.5.1-linux-x86_64.zip
##ENV BOWTIE2_FILE bowtie2-${BOWTIE2_VERSION}-source.zip
#ENV BOWTIE2_FILE bowtie2-${BOWTIE2_VERSION}-linux-x86_64.zip
 
ARG HTSLIB_VERSION=1.16
ARG SAMTOOLS_VERSION=1.16.1
ARG BOWTIE2_VERSION=2.5.1
ARG HTSLIB_URL=https://github.com/samtools/htslib/releases/download
ARG SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download
#ARG BOWTIE2_URL=https://sourceforge.net/projects/bowtie-bio/files/bowtie2
ARG BOWTIE2_URL=https://github.com/BenLangmead/bowtie2/releases/download
ARG BOWTIE2_FILE=bowtie2-${BOWTIE2_VERSION}-linux-x86_64.zip
 
#RUN cd / \
#	&& wget ${HTSLIB_URL}/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
#	&& tar xvfj htslib-${HTSLIB_VERSION}.tar.bz2 \
#	&& cd htslib-${HTSLIB_VERSION} \
#	&& ./configure \
#	&& make \
#	&& make install \
#	&& cd ~ \
#	&& /bin/rm -rf /htslib-${HTSLIB_VERSION}*
 
RUN cd / \
	&& wget ${SAMTOOLS_URL}/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& tar xvfj samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& cd samtools-${SAMTOOLS_VERSION} \
	&& ./configure \
	&& make \
	&& make install \
	&& cd ~ \
	&& /bin/rm -rf /samtools-${SAMTOOLS_VERSION}*

#	&& wget ${BOWTIE2_URL}/${BOWTIE2_VERSION}/bowtie2-${BOWTIE2_VERSION}-source.zip/download -O bowtie2-${BOWTIE2_VERSION}-source.zip \


#RUN cd / \
#	&& wget ${BOWTIE2_URL}/${BOWTIE2_VERSION}/${BOWTIE2_FILE}/download -O ${BOWTIE2_FILE} \
#	&& unzip ${BOWTIE2_FILE} \
#	&& cd bowtie2-${BOWTIE2_VERSION} \
#	&& make \
#	&& make install \
#	&& cd ~ \
#	&& /bin/rm -rf /bowtie2-${BOWTIE2_VERSION}*

#	&& wget ${BOWTIE2_URL}/${BOWTIE2_VERSION}/${BOWTIE2_FILE}/download -O ${BOWTIE2_FILE} \

RUN cd / \
	&& wget ${BOWTIE2_URL}/v${BOWTIE2_VERSION}/${BOWTIE2_FILE} -O ${BOWTIE2_FILE} \
	&& unzip ${BOWTIE2_FILE} \
	&& mv bowtie2-${BOWTIE2_VERSION}-linux-x86_64/bowtie2* /usr/local/bin/ \
	&& /bin/rm -rf /bowtie2-${BOWTIE2_VERSION}*

RUN wget https://raw.githubusercontent.com/ucsffrancislab/genomics/master/scripts/bowtie2.bash \
		-O /usr/local/bin/bowtie2.bash \
	&& chmod +x /usr/local/bin/bowtie2.bash


#	MELT

#ADD --chown=root:root MELTv2.2.2.tar.gz /
#ADD --chown=root:root MELTv2.1.5fast.tar.gz /
#
#	MELT isn't available to freely download so have to have it local
#
#ADD MELTv2.2.2.tar.gz /usr/local/bin/
#RUN chown -R root:root /usr/local/bin/MELTv2.2.2
#ADD MELTv2.1.5fast.tar.gz /usr/local/bin/
#RUN chown -R root:root /usr/local/bin/MELTv2.1.5fast && \rm /usr/local/bin/._MELTv2.1.5fast 

#ADD MELT.tar /opt/
#RUN chown -R root:root /opt/MELT
ADD MELT.tar /
RUN chown -R root:root /MELT


#COPY MELTv2.2.2.bash /usr/local/bin/

#	MELTv2.1.5fast.tar.gz
#	https://genome.cshlp.org/content/suppl/2021/11/12/gr.275323.121.DC1/Supplemental_Code_S1.zip
#	CloudMELT-1.0.1/docker/MELTv2.1.5fast.tar.gz

#COPY test.bash /usr/local/bin/





RUN git clone https://github.com/chmille4/bamReadDepther.git \
	&& cd bamReadDepther \
	&& g++ -o bamReadDepther bamReadDepther.cpp \
	&& mv bamReadDepther /usr/local/bin/ \
	&& cd .. && /bin/rm -rf bamReadDepther

# docker run -v $PWD:/pwd --rm melt bash -c "cat /pwd/HT-7604-01A-11D-2088.bam.bai | bamReadDepther"



#	Cloud MELT used ...
#	ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa
#	Is it different than what we have?

#	Cloud MELT also used mosdepth for coverage computation I think
#	version 0.2.5 is from Mar 7, 2019
#RUN curl -LO https://github.com/brentp/mosdepth/releases/download/v0.2.5/mosdepth && chmod ugo+x mosdepth && mv mosdepth /usr/local/bin/
RUN wget https://github.com/brentp/mosdepth/releases/download/v0.2.5/mosdepth && chmod ugo+x mosdepth && mv mosdepth /usr/local/bin/
#	v0.3.3 is available from Feb 2, 2022

# docker run -v $PWD:/pwd --rm melt mosdepth -n --fast-mode -t 4 --by 1000 /pwd/output /pwd/DU-6542-10A-01D-1891.bam
# ~/CloudMelt/CloudMELT-1.0.1/docker/mosdepth2cov.py output.mosdepth.global.dist.txt
#	2.5




COPY ave_read_length.bash /usr/local/bin/
COPY mosdepth_coverage.bash /usr/local/bin/
COPY mosdepth2cov.py /usr/local/bin/
COPY coverage.bash /usr/local/bin/




#	docker build -t melt --file MELT.Dockerfile ./
#	docker run --rm -it melt
#	docker run --rm melt java -jar /MELTv2.2.2/MELT.jar
#	docker run --rm melt bamtofastq -h
#	docker run --rm melt bowtie2
#	docker run --rm melt samtools
#	docker run -v $PWD:/pwd --rm melt samtools view /pwd/NA21144.unmapped.ILLUMINA.bwa.GIH.low_coverage.20130415.bam
#	docker run -v $PWD:/pwd --rm melt bamtofastq filename=/pwd/NA21144.chrom20.ILLUMINA.bwa.GIH.low_coverage.20130415.bam exclude=SECONDARY,QCFAIL,DUP,SUPPLEMENTARY F=/pwd/NA21144_R1.fastq.gz F2=/pwd/NA21144_R2.fastq.gz S=/pwd/NA21144_S.fastq.gz O=/pwd/NA21144_O1.fastq.gz O2=/pwd/NA21144_O2.fastq.gz
#
#	Individually ...
#
#	docker run -v $PWD:/pwd --rm melt bamtofastq filename=/pwd/NA21144.chrom20.ILLUMINA.bwa.GIH.low_coverage.20130415.bam exclude=SECONDARY,QCFAIL,DUP,SUPPLEMENTARY F=/pwd/NA21144_R1.fastq.gz F2=/pwd/NA21144_R2.fastq.gz
#
#for mei in ALU HERVK LINE1 SVA ; do
#
#		java -Xmx6G -jar ${MELTJAR} IndivAnalysis \
#	  	-bamfile ${inbase}.bam \
#	  	-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
#	  	-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
#	  	-w $( dirname ${f} )

#
#	As a group
#
#for mei in ALU HERVK LINE1 SVA ; do
#
#		java -Xmx4G -jar ${MELTJAR} GroupAnalysis \
#			-discoverydir ${OUT}/${mei}DISCOVERYIND/ \
#			-w $( dirname ${f} ) \
#			-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
#			-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
#			-n ~/.local/MELTv2.2.2/add_bed_files/Hg38/Hg38.genes.bed

#
#	Individually
#
#for mei in ALU HERVK LINE1 SVA ; do
#
#		java -Xmx2G -jar ${MELTJAR} Genotype \
#			-bamfile ${inbase}.bam \
#			-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
#			-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
#			-w $( dirname ${f} ) \
#			-p ${OUT}/${mei}DISCOVERYGROUP/

#
#	As a group
#
#for mei in ALU HERVK LINE1 SVA ; do
#
#		java -Xmx4G -jar ${MELTJAR} MakeVCF \
#			-genotypingdir ${OUT}/${mei}DISCOVERYGENO/ \
#			-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
#			-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
#			-w $( dirname ${f} ) \
#			-p ${OUT}/${mei}DISCOVERYGROUP/	\
#			-o $( dirname ${f} )

#
#[jake@Francis-Lab ~/github/ucsffrancislab/genomics/docker]$ docker run -v $PWD:/pwd --rm melt java -Xmx6G -jar /MELT/MELTv2.1.5fast.jar
#Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/commons/cli/ParseException
#	at java.base/java.lang.Class.getDeclaredMethods0(Native Method)
#	at java.base/java.lang.Class.privateGetDeclaredMethods(Class.java:3166)
#	at java.base/java.lang.Class.getMethodsRecursive(Class.java:3307)
#	at java.base/java.lang.Class.getMethod0(Class.java:3293)
#	at java.base/java.lang.Class.getMethod(Class.java:2106)
#	at org.eclipse.jdt.internal.jarinjarloader.JarRsrcLoader.main(JarRsrcLoader.java:57)
#Caused by: java.lang.ClassNotFoundException: org.apache.commons.cli.ParseException
#	at java.base/java.net.URLClassLoader.findClass(URLClassLoader.java:476)
#	at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:589)
#	at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:522)
#	... 6 more
#

#	docker run -v $PWD:/pwd --rm melt bamtofastq filename=/pwd/NA21144.chrom20.ILLUMINA.bwa.GIH.low_coverage.20130415.bam exclude=SECONDARY,QCFAIL,DUP,SUPPLEMENTARY F=/pwd/NA21144_R1.fastq.gz F2=/pwd/NA21144_R2.fastq.gz gz=1 level=9 O=/dev/null O2=/dev/null S=/dev/null


#	docker run --rm melt java -Xmx2G -jar /MELT/MELTv2.2.2.jar Preprocess

#	docker run --rm melt java -Xmx6G -jar /MELT/MELTv2.2.2.jar IndivAnalysis

#	docker run -v $PWD:/pwd --rm melt java -Xmx6G -jar /MELT/MELTv2.2.2.jar Single -bamfile /pwd/NA21144.chrom20.ILLUMINA.bwa.GIH.low_coverage.20130415.hg38.chrXYM_alts.bam -t /pwd/MELT/me_refs/Hg38/HERVK_MELT.zip -h /pwd/hg38.chrXYM_alts.fa -n /pwd/MELT/add_bed_files/Hg38/Hg38.genes.bed -w .



#	docker run -v $PWD:/pwd --rm melt java -Xmx6G -jar /MELT/MELTv2.2.2.jar Single -bamfile /pwd/DU-6542-10A-01D-1891.bam -t /pwd/MELT/me_refs/Hg38/ALU_MELT.zip /pwd/CloudMELT/MELTv2.2.2/prior_files/ALU.1KGP.sites.vcf -h /pwd/hg38.chrXYM_alts.fa -n /pwd/MELT/add_bed_files/Hg38/Hg38.genes.bed -w /pwd/DU-6542-10A-01D-1891/

#	docker run -v $PWD:/pwd --rm melt java -Xmx6G -jar /MELT/MELTv2.2.2.jar Single -bamfile /pwd/HT-7604-01A-11D-2088.bam -t /pwd/MELT/me_refs/Hg38/ALU_MELT.zip /pwd/CloudMELT/MELTv2.2.2/prior_files/ALU.1KGP.sites.vcf -h /pwd/hg38.chrXYM_alts.fa -n /pwd/MELT/add_bed_files/Hg38/Hg38.genes.bed -w /pwd/HT-7604-01A-11D-2088/

#	docker run -v $PWD:/pwd --rm melt java -Xmx6G -jar /MELT/MELTv2.2.2.jar Single -bamfile /pwd/HT-7604-01A-11D-2088.bam -t /pwd/MELT/me_refs/Hg38/ALU_MELT.zip	/pwd/ALU.final_comp.vcf -h /pwd/hg38.chrXYM_alts.fa -n /pwd/MELT/add_bed_files/Hg38/Hg38.genes.bed -w /pwd/HT-7604-01A-11D-2088-prior/
#	docker run -v $PWD:/pwd --rm melt java -Xmx6G -jar /MELT/MELTv2.2.2.jar Single -bamfile /pwd/DU-6542-10A-01D-1891.bam -t /pwd/MELT/me_refs/Hg38/ALU_MELT.zip	/pwd/ALU.final_comp.vcf -h /pwd/hg38.chrXYM_alts.fa -n /pwd/MELT/add_bed_files/Hg38/Hg38.genes.bed -w /pwd/DU-6542-10A-01D-1891-prior/

#	java -Xmx6G -jar MELT/MELTv2.2.2.jar Single -bamfile DU-6542-10A-01D-1891.bam -t ALU_transposon_file_list.txt -h hg38.chrXYM_alts.fa -n MELT/add_bed_files/Hg38/Hg38.genes.bed -w DU-6542-10A-01D-1891-run5/ -bowtie /Users/jake/github/benLangmead/bowtie2/unaltered/bowtie2


