#!/usr/bin/env bash



#sudo apt-get -y install singularity	# NOT THIS SINGULARITY
#sudo apt-get -y install singularity-container	# NOT THIS SINGULARITY EITHER. TOO OLD.


sudo apt-get update && sudo apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    pkg-config


#	https://github.com/apptainer/singularity/blob/master/INSTALL.md

sudo apt-get update

sudo apt-get install -y \
    build-essential \
    libseccomp-dev \
    pkg-config \
    squashfs-tools \
    cryptsetup \
    curl wget git

sudo apt-get -y autoremove

export GOVERSION=1.17.3 OS=linux ARCH=amd64  # change this as you need

wget -O /tmp/go${GOVERSION}.${OS}-${ARCH}.tar.gz \
  https://dl.google.com/go/go${GOVERSION}.${OS}-${ARCH}.tar.gz
sudo tar -C /usr/local -xzf /tmp/go${GOVERSION}.${OS}-${ARCH}.tar.gz

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

git clone https://github.com/hpcng/singularity.git
cd singularity

git checkout v3.8.4

./mconfig
cd ./builddir
make
sudo make install

sudo chmod o+r /usr/local/etc/singularity/capability.json

singularity --version



