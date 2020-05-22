#
#	Build it
#		docker build -t impute --file docker/ImputationPrep.Dockerfile ./
#	Run it in the background
#		docker run -v /Some/path/to/share/:/data -itd impute
#	Connect to it
#		docker exec -it $( docker ps -aq ) bash
#

FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
	&& apt-get -y full-upgrade \
	&& apt-get -y install git python software-properties-common default-jdk wget curl htop make gcc \
		zlib1g-dev libncurses5-dev g++ vim cmake unzip libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev openssl \
	&& apt-get -y autoremove

#
#libcurl4-gnutls-dev/focal 7.68.0-1ubuntu2 amd64
#  development files and documentation for libcurl (GnuTLS flavour)
#
#libcurl4-nss-dev/focal 7.68.0-1ubuntu2 amd64
#  development files and documentation for libcurl (NSS flavour)
#
#libcurl4-openssl-dev/focal 7.68.0-1ubuntu2 amd64
#  development files and documentation for libcurl (OpenSSL flavour)
#
#libcurlpp-dev/focal 0.8.1-2build2 amd64
#  c++ wrapper for libcurl (development files)
#

#	apt-get -y install git python3 python3-pip r-base software-properties-common default-jdk wget ; \

#	python-pip for python2 hard to find
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"; python get-pip.py

RUN cpan install Term::ReadKey

ARG HTSLIB_VERSION=1.10.2
ARG HTSLIB_URL=https://github.com/samtools/htslib/releases/download

ARG SAMTOOLS_VERSION=1.10
ARG SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download
 
ARG BCFTOOLS_VERSION=1.10.2
ARG BCFTOOLS_URL=https://github.com/samtools/bcftools/releases/download
 
RUN cd / \
	&& wget ${HTSLIB_URL}/${SAMTOOLS_VERSION}/htslib-${SAMTOOLS_VERSION}.tar.bz2 \
	&& tar xvfj htslib-${SAMTOOLS_VERSION}.tar.bz2 \
	&& cd htslib-${SAMTOOLS_VERSION} \
	&& ./configure \
	&& make \
	&& make install \
	&& /bin/rm -rf /htslib-${SAMTOOLS_VERSION}*
 
RUN cd / \
	&& wget ${SAMTOOLS_URL}/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& tar xvfj samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& cd samtools-${SAMTOOLS_VERSION} \
	&& ./configure \
	&& make \
	&& make install \
	&& /bin/rm -rf /samtools-${SAMTOOLS_VERSION}*

RUN cd / \
	&& wget ${BCFTOOLS_URL}/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
	&& tar xvfj bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
	&& cd bcftools-${BCFTOOLS_VERSION} \
	&& ./configure \
	&& make \
	&& make install \
	&& /bin/rm -rf /bcftools-${BCFTOOLS_VERSION}*

#RUN mkdir /home

#
#	The instructions link says plink2, but points to plink 1.9
#	Using plink 1.9 for first try.
#
RUN cd /home && wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20200428.zip \
	&& unzip plink_linux_x86_64_20200428.zip \
	&& rm plink_linux_x86_64_20200428.zip LICENSE prettify toy.map toy.ped

RUN cd /home && wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip \
	&& unzip HRC-1000G-check-bim-v4.2.7.zip \
	&& rm HRC-1000G-check-bim-v4.2.7.zip LICENSE.txt

RUN cd /home && wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz \
	&& gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz

RUN cd /home && git clone https://github.com/ucsffrancislab/gotcloud.git \
	&& cd gotcloud/src \
	&& make

#RUN wget https://github.com/zhanxw/checkVCF/blob/master/checkVCF.py

RUN cd /home && wget http://qbrc.swmed.edu/zhanxw/software/checkVCF/checkVCF-20140116.tar.gz \
	&& tar xfvz checkVCF-20140116.tar.gz \
	&& rm checkVCF-20140116.tar.gz README.md example.vcf.gz

ENV PATH="/home:/home/gotcloud/bin:${PATH}"

WORKDIR /home

