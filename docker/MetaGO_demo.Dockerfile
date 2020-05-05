#
#	docker build -t metago --file MetaGO_Dockerfile .
#	docker run --rm -it metago
#
##	mkdir /root/MetaGO_Result
##	cd /root/github/MetaGO/MetaGO_SourceCode/
#
#	bash /root/github/MetaGO/MetaGO_SourceCode/MetaGO.sh -I RAW -F /root/github/MetaGO/MetaGO_SourceCode/fileList.txt -N 25 -M 25 -K 10 -m 1 -P 4 -A 0.65 -X 0.1 -L 0.5 -W ASS -O /root/MetaGO_Result -U -S
#
#	bash /root/github/MetaGO/MetaGO_SourceCode/MetaGO.sh -I RAW -F /root/github/MetaGO/MetaGO_SourceCode/fileList.txt -N 25 -M 25 -K 10 -m 1 -P 4 -C 0.1 -X 0.1 -L 0.5 -W chi2-test -O /root/MetaGO_Result -U -S
#




FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update ; apt-get -y full-upgrade ; \
	apt-get -y install git python r-base software-properties-common default-jdk wget curl ; \
	apt-get -y autoremove
#	apt-get -y install git python3 python3-pip r-base software-properties-common default-jdk wget ; \

#	python-pip for python hard to find
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"; python get-pip.py

#	FROM amazonlinux:latest
#	RUN yum -y install which unzip aws-cli tar gzip bzip2 gcc g++ zlib-devel bzip2-devel xz-devel make libcurl-devel ncurses-devel openssl-devel wget procps htop python3 boto3 perl


RUN cd /root/ ; \
	wget http://apache.mirrors.hoobly.com/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz ; \
	tar xfvz spark-2.4.5-bin-hadoop2.7.tgz ; \
	/bin/rm -rf spark-2.4.5-bin-hadoop2.7.tgz
	

#RUN ln -s /usr/bin/python3 /usr/bin/python
#RUN ln -s /usr/bin/pip3 /usr/bin/pip

RUN pip install --upgrade awscli pip numpy scipy boto3 pyspark sklearn

#	FYI: ~ / $HOME is /root

RUN mkdir ~/github/
RUN mkdir -p ~/.local/bin

RUN cd ~/github/; \
	git clone https://github.com/VVsmileyx/MetaGO.git ; \
	cd MetaGO ; tar xfvz MetaGO_SourceCode.tar.gz
#RUN cd ~/github/; \
#	git clone https://github.com/ucsffrancislab/MetaGO.git 
##	; \ cd MetaGO ; tar xfvz MetaGO_SourceCode.tar.gz

RUN cd ~/github/; \
	git clone https://github.com/VVsmileyx/TestData.git ; \
	cd TestData ; unzip testDATA.zip

RUN cd ~/github/; \
	git clone https://github.com/VVsmileyx/Tools.git ; \
	cd Tools ; tar xfvz dsk-1.6066.tar.gz ; \
	cp /root/github/Tools/dsk-1.6066/dsk ~/.local/bin/ ; \
	cp /root/github/Tools/dsk-1.6066/parse_results ~/.local/bin/



#ENV BOWTIE2_INDEXES=/bowtie2


ENV PATH="/root/.local/bin:/root/github/MetaGO/MetaGO_SourceCode:${PATH}"

RUN ls -1 /root/github/TestData/testDATA/H*.fasta  > /root/github/MetaGO/MetaGO_SourceCode/fileList.txt
RUN ls -1 /root/github/TestData/testDATA/P*.fasta >> /root/github/MetaGO/MetaGO_SourceCode/fileList.txt




RUN mkdir /root/MetaGO_Result
WORKDIR /root/github/MetaGO/MetaGO_SourceCode/







#	ARG SAMTOOLS_VERSION=1.9
#	ARG SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download
#	ARG HTSLIB_URL=https://github.com/samtools/htslib/releases/download
#	 
#	RUN cd / \
#		&& wget ${HTSLIB_URL}/${SAMTOOLS_VERSION}/htslib-${SAMTOOLS_VERSION}.tar.bz2 \
#		&& tar xvfj htslib-${SAMTOOLS_VERSION}.tar.bz2 \
#		&& cd htslib-${SAMTOOLS_VERSION} \
#		&& ./configure \
#		&& make \
#		&& make install \
#		&& cd ~ \
#		&& /bin/rm -rf /htslib-${SAMTOOLS_VERSION}*
#	 
#	RUN cd / \
#		&& wget ${SAMTOOLS_URL}/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
#		&& tar xvfj samtools-${SAMTOOLS_VERSION}.tar.bz2 \
#		&& cd samtools-${SAMTOOLS_VERSION} \
#		&& ./configure \
#		&& make \
#		&& make install \
#		&& cd ~ \
#		&& /bin/rm -rf /samtools-${SAMTOOLS_VERSION}*
#	
#	
#	
#	
#	
#	RUN cd / \
#		&& wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.9.0/ncbi-blast-2.9.0+-x64-linux.tar.gz \
#		&& tar xvfz ncbi-blast-2.9.0+-x64-linux.tar.gz \
#		&& mv ncbi-blast-2.9.0+/bin/* /usr/local/bin/ \
#		&& /bin/rm -rf ncbi-blast-2.9.0+-x64-linux.tar.gz ncbi-blast-2.9.0+ 
#	
#	ENV BLASTDB=/blastdb
#	
#	#	ADD will actually untar and gunzip for you.
#	ADD references/viral.masked.tar.gz /blastdb/
#	ADD references/viral.raw.tar.gz /blastdb/
#	
#	#	
#	#	USING DIAMOND INSTEAD OF BLASTN
#	#	Actually, gonna run BLASTN now too.
#	#
#	
#	RUN cd / \
#		&& wget https://github.com/bbuchfink/diamond/releases/download/v0.9.30/diamond-linux64.tar.gz \
#		&& tar xvfz diamond-linux64.tar.gz \
#		&& mv diamond /usr/local/bin/ \
#		&& /bin/rm -rf diamond-linux64.tar.gz
#	
#	ENV DIAMOND=/diamond
#	
#	#	ADD will actually untar and gunzip for you.
#	#	doesn't seem to gunzip
#	ADD references/viral.dmnd.tar.gz /diamond/
#	
#	
#	
#	
#	
#	
#	
#	RUN cd / \
#		&& wget https://github.com/BenLangmead/bowtie2/releases/download/v2.4.1/bowtie2-2.4.1-linux-x86_64.zip \
#		&& unzip bowtie2-2.4.1-linux-x86_64.zip \
#		&& mv bowtie2-2.4.1-linux-x86_64/bowtie2* /usr/local/bin/ \
#		&& /bin/rm -rf bowtie2-2.4.1-linux-x86_64.zip bowtie2-2.4.1-linux-x86_64
#	
#	ENV BOWTIE2_INDEXES=/bowtie2
#	RUN mkdir /bowtie2 && chmod a+w /bowtie2
#	
#	#	ADD will actually untar and gunzip for you.
#	#	doesn't seem to gunzip
#	ADD references/herpes.bt2.tar.gz /bowtie2/
#	ADD references/hg38.bt2.tar.gz /bowtie2/
#	
#	#	This reference is large and creates a large image
#	#	which takes quite a while to upload.
#	#	Should probably build on an AWS EC2 instance and upload from there.
#	#	aws s3 --no-sign-request --region eu-west-1 sync s3://ngi-igenomes/igenomes/Homo_sapiens/UCSC/hg38/Sequence/Bowtie2Index/ ./
#	#	rename genome hg38 genome*bt2
#	#	rm genome.fa
#	
#	#	aws s3 sync --no-sign-request --exclude \*fa --dryrun s3://ngi-igenomes/igenomes/Homo_sapiens/UCSC/hg38/Sequence/Bowtie2Index/ /bowtie2/
#	
#	
#	
#	
#	ADD array_handler.bash /usr/local/bin/array_handler.bash
#	ADD viral_identification.bash /usr/local/bin/viral_identification.bash
#	
#	
#	#	RUN aws s3 cp --no-sign-request s3://1000genomes/sequence.index - | awk -F"\t" '(NR>1) && ($13 ~ /ILLUMINA/) && ($25 != "not available") && ($26 ~ /coverage/){print $25,"s3://1000genomes/phase3/"$1}' | sort -n -r | awk '{print $2}' > /tmp/1000genomes.urls
#	ADD urls/1000genomes.urls /tmp/
#	
#	#	RUN curl https://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/E-GEUV-1.sdrf.txt | awk -F"\t" '(NR>1){print $35}' > /tmp/geuvadis.urls
#	ADD urls/geuvadis.urls /tmp/
#	
#	#	RUN curl https://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/E-GEUV-1.sdrf.txt | awk -F"\t" '(NR>1){print "https://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/"$27".bam"}' | uniq > geuvadis.bam.urls 
#	ADD urls/geuvadis.bam.urls /tmp/
#	
#	#	RUN aws s3 ls --recursive --no-sign-request s3://1000genomes/phase3/ | grep ".unmapped.ILLUMINA." | grep "_coverage." | grep ".bam$" | awk '{print "s3://1000genomes/"$4}' > 1000genomes.unmapped.urls
#	#	RUN aws s3 cp --no-sign-request s3://1000genomes/alignment.index - | grep ".unmapped.ILLUMINA." | grep ".low_coverage." | awk '{print "s3://1000genomes/phase3/"$1}' > 1000genomes.unmapped.urls
#	ADD urls/1000genomes.unmapped.urls /tmp/
#	
#	
#	ADD urls/my.geuvadis.bam.urls /tmp/
#	
#	#wc -l *.urls
#	# 108873 1000genomes.urls
#	#    924 geuvadis.urls
#	#   2535 1000genomes.unmapped.urls
#	#    462 geuvadis.bam.urls
#	
#	
#	
#	#	DO THIS ONLY FOR LOCAL TESTING
#	#	tar xfvz aws.tar.gz
#	#	chmod 666 .aws/c*
#	#COPY .aws /.aws/
#	
#	
#	
#	#
#	#	docker run --rm gwendt/fetch_and_run will execute the following command and remove itself ...
#	#	Either include the script to be run in the docker image itself 
#	#	or place on S3 and pass as environment variable to job.
#	#
#	#ADD fetch_and_run.sh /usr/local/bin/fetch_and_run.sh
#	WORKDIR /tmp
#	USER nobody
#	#
#	#ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]
