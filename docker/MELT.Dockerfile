
FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
#	Which is best? Either? Both?
ENV DEBIAN_FRONTEND noninteractive




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
#	Apparently on a thing on Mac
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


ENV HTSLIB_VERSION 1.16
ENV SAMTOOLS_VERSION 1.16.1
ENV BOWTIE2_VERSION 2.5.0

ENV HTSLIB_URL https://github.com/samtools/htslib/releases/download
ENV SAMTOOLS_URL https://github.com/samtools/samtools/releases/download
ENV BOWTIE2_URL https://sourceforge.net/projects/bowtie-bio/files/bowtie2
#ENV BOWTIE2_FILE bowtie2-${BOWTIE2_VERSION}-source.zip
ENV BOWTIE2_FILE bowtie2-${BOWTIE2_VERSION}-linux-x86_64.zip
 
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

#RUN apt-get update \
#        && apt-get install -y libtbb-dev \
#        && apt-get clean


#RUN apt-get update \
#	&& apt-get install -y apt-utils dialog bzip2 gcc gawk \
#		zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev make \
#		libssl-dev libncurses5-dev zip g++ git libtbb-dev wget \
#	&& apt-get clean


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


#	bamtofastq (be aware that bedtools has a bamToFastq)
#	exclude=<[SECONDARY,QCFAIL,DUP,SUPPLEMENTARY]>               : exclude alignments matching any of the given flags
#	F=<[stdout]>                                      : matched pairs first mates
#	F2=<[stdout]>                                     : matched pairs second mates
#	S=<[stdout]>                                      : single end
#	O=<[stdout]>                                      : unmatched pairs first mates
#	O2=<[stdout]>                                     : unmatched pairs second mates






#	Test this on position-sorted bam files





#	MELT

#ADD --chown=root:root MELTv2.2.2.tar.gz /
#ADD --chown=root:root MELTv2.1.5fast.tar.gz /

#	MELT isn't available to freely download so ...

ADD MELTv2.2.2.tar.gz /
RUN chown -R root:root /MELTv2.2.2
ADD MELTv2.1.5fast.tar.gz /
RUN chown -R root:root /MELTv2.1.5fast




#	docker build -t melt --file MELT.Dockerfile ./
#	docker run --rm -it melt
#	docker run --rm melt java -jar /MELTv2.2.2/MELT.jar
#	docker run --rm melt bamtofastq -h
#	docker run --rm melt bowtie2
#	docker run --rm melt samtools



