
FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
#	Which is best? Either? Both?
#ENV DEBIAN_FRONTEND noninteractive

WORKDIR /root

#	ENTRYPOINT ???



#RUN apt-get update \
RUN apt update -y && apt upgrade -y \
	&& apt install -y apt-utils gcc g++ make software-properties-common libboost-all-dev git wget \
		pkg-config \
		zip unzip bzip2 libbz2-dev libncurses5-dev \
		openjdk-19-jre-headless openjdk-19-jdk-headless \
	&& apt clean -y && apt autoremove -y

#        && apt-get install -y apt-utils gcc g++ make software-properties-common libboost-all-dev git wget \
#					pkg-config \
#					zip unzip bzip2 libbz2-dev libncurses5-dev \
#					openjdk-19-jre-headless openjdk-19-jdk-headless \
#        && apt-get clean && apt-get autoremove

#	What do each of these do
# apt-get -y update 
# apt-get -y upgrade
#	apt-get -y full-upgrade - equivalent to dist-upgrade?
#	apt-get dist-upgrade - can upgrade kernel





#	boost


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
#ENV BOWTIE2_VERSION 2.5.0
#ENV HTSLIB_URL https://github.com/samtools/htslib/releases/download
#ENV SAMTOOLS_URL https://github.com/samtools/samtools/releases/download
#ENV BOWTIE2_URL https://sourceforge.net/projects/bowtie-bio/files/bowtie2
##ENV BOWTIE2_FILE bowtie2-${BOWTIE2_VERSION}-source.zip
#ENV BOWTIE2_FILE bowtie2-${BOWTIE2_VERSION}-linux-x86_64.zip
 
ARG HTSLIB_VERSION=1.16
ARG SAMTOOLS_VERSION=1.16.1
ARG BOWTIE2_VERSION=2.5.0
ARG HTSLIB_URL=https://github.com/samtools/htslib/releases/download
ARG SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download
ARG BOWTIE2_URL=https://sourceforge.net/projects/bowtie-bio/files/bowtie2
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

RUN cd / \
	&& wget ${BOWTIE2_URL}/${BOWTIE2_VERSION}/${BOWTIE2_FILE}/download -O ${BOWTIE2_FILE} \
	&& unzip ${BOWTIE2_FILE} \
	&& mv bowtie2-${BOWTIE2_VERSION}-linux-x86_64/bowtie2* /usr/local/bin/ \
	&& /bin/rm -rf /bowtie2-${BOWTIE2_VERSION}*

RUN wget https://raw.githubusercontent.com/ucsffrancislab/genomics/master/scripts/bowtie2.bash \
		-O /usr/local/bin/bowtie2.bash \
	&& chmod +x /usr/local/bin/bowtie2.bash



#	Test this on position-sorted bam files





#	MELT

#ADD --chown=root:root MELTv2.2.2.tar.gz /
#ADD --chown=root:root MELTv2.1.5fast.tar.gz /

#	MELT isn't available to freely download so ...

ADD MELTv2.2.2.tar.gz /
RUN chown -R root:root /MELTv2.2.2
ADD MELTv2.1.5fast.tar.gz /
RUN chown -R root:root /MELTv2.1.5fast && \rm /._MELTv2.1.5fast 




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

#	INCLUDE A SCRIPT LIKE THIS THAT SORTS, OUTPUTS TO BAM, INDEXES
#	~/.local/bin/bowtie2_scratch.bash \
#		--very-sensitive --threads ${SLURM_NTASKS} \
#		-1 ${r1} -2 ${r2} --sort --output ${f} \
#		-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts

#	java -Xmx2G -jar ${MELTJAR} Preprocess \
#		-bamfile ${inbase}.bam \
#		-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa


#for mei in ALU HERVK LINE1 SVA ; do
#
#		java -Xmx6G -jar ${MELTJAR} IndivAnalysis \
#	  	-bamfile ${inbase}.bam \
#	  	-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
#	  	-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
#	  	-w $( dirname ${f} )


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


