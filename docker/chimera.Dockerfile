FROM ubuntu


#	Apparently, a new "image" is created after every "step" so cleanup after yourself.


#ENV HOME /root
#	stop complaints like 
#	debconf: (Can't locate Term/ReadLine.pm 
#	with ...
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /root
 
RUN apt-get update \
	&& apt-get install -y apt-utils dialog bzip2 gcc gawk \
		zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev make \
		libssl-dev libncurses5-dev zip g++ git libtbb-dev wget \
	&& apt-get clean

#	using wget in RUN rather that ADD and then RUN does save a tiny bit of size on the final image.

ENV SAMTOOLS_VERSION 1.5
ENV BOWTIE2_VERSION 2.3.2

ENV SAMTOOLS_URL https://github.com/samtools/samtools/releases/download
ENV HTSLIB_URL https://github.com/samtools/htslib/releases/download
ENV BOWTIE2_URL https://sourceforge.net/projects/bowtie-bio/files/bowtie2
ENV BOWTIE2_FILE bowtie2-${BOWTIE2_VERSION}-source.zip
 
RUN cd / \
	&& wget ${HTSLIB_URL}/${SAMTOOLS_VERSION}/htslib-${SAMTOOLS_VERSION}.tar.bz2 \
	&& tar xvfj htslib-${SAMTOOLS_VERSION}.tar.bz2 \
	&& cd htslib-${SAMTOOLS_VERSION} \
	&& ./configure \
	&& make \
	&& make install \
	&& cd ~ \
	&& /bin/rm -rf /htslib-${SAMTOOLS_VERSION}*
 
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

RUN cd / \
	&& wget ${BOWTIE2_URL}/${BOWTIE2_VERSION}/${BOWTIE2_FILE}/download -O ${BOWTIE2_FILE} \
	&& unzip ${BOWTIE2_FILE} \
	&& cd bowtie2-${BOWTIE2_VERSION} \
	&& make \
	&& make install \
	&& cd ~ \
	&& /bin/rm -rf /bowtie2-${BOWTIE2_VERSION}*

RUN cd ~ \
	&& git clone http://github.com/unreno/chimera \
	&& cd chimera \
	&& ln -s Makefile.example Makefile \
	&& make BASE_DIR="/usr/local" install \
	&& cd ~ \
	&& /bin/rm -rf chimera



#	Create with ...
#
#		docker build -t chimera .
#		docker run -ti chimera
#
