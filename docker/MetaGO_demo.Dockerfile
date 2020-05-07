#
#	docker build -t metago --file docker/MetaGO_demo.Dockerfile ./
#	docker run --rm -it metago
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



ENV PATH="/root/.local/bin:/root/github/MetaGO/MetaGO_SourceCode:${PATH}"

RUN ls -1 /root/github/TestData/testDATA/H*.fasta  > /root/github/MetaGO/MetaGO_SourceCode/fileList.txt
RUN ls -1 /root/github/TestData/testDATA/P*.fasta >> /root/github/MetaGO/MetaGO_SourceCode/fileList.txt

RUN mkdir /root/MetaGO_Result
WORKDIR /root/github/MetaGO/MetaGO_SourceCode/


