# Copyright 2021 DeepMind Technologies Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG CUDA=12.2.2
FROM nvidia/cuda:${CUDA}-cudnn8-runtime-ubuntu20.04
# FROM directive resets ARGS, so we specify again (the value is retained if
# previously set).
ARG CUDA

# Use bash to support string substitution.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        build-essential \
        cmake \
        cuda-command-line-tools-$(cut -f1,2 -d- <<< ${CUDA//./-}) \
        git \
        hmmer \
        kalign \
        tzdata \
        wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

# Compile HHsuite from source.
RUN git clone --branch v3.3.0 https://github.com/soedinglab/hh-suite.git /tmp/hh-suite \
    && mkdir /tmp/hh-suite/build \
    && pushd /tmp/hh-suite/build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/hhsuite .. \
    && make -j 4 && make install \
    && ln -s /opt/hhsuite/bin/* /usr/bin \
    && popd \
    && rm -rf /tmp/hh-suite

# Install Miniconda package manager.
RUN wget -q -P /tmp \
  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm /tmp/Miniconda3-latest-Linux-x86_64.sh

# Install conda packages.
#ENV PATH="/opt/conda/bin:$PATH"
#ENV LD_LIBRARY_PATH="/opt/conda/lib:$LD_LIBRARY_PATH"
#RUN conda install -qy conda==24.1.2 pip python=3.11 \
#    && conda install -y -c nvidia cuda=${CUDA_VERSION} \
#    && conda install -y -c conda-forge openmm=8.0.0 pdbfixer \
#    && conda clean --all --force-pkgs-dirs --yes

#/bin/bash: /opt/conda/lib/libtinfo.so.6: no version information available (required by /bin/bash)


ENV PATH="/opt/conda/bin:$PATH"
ENV LD_LIBRARY_PATH="/opt/conda/lib:$LD_LIBRARY_PATH"
RUN conda install -qy conda==24.5.0 pip python=3.11 \
 && conda install -y -c nvidia cuda=12.2.2 cuda-tools=12.2.2 cuda-toolkit=12.2.2 cuda-version=12.2 cuda-command-line-tools=12.2.2 cuda-compiler=12.2.2 cuda-runtime=12.2.2 \
 && conda install -y -c conda-forge ncurses openmm=8.0.0 pdbfixer \
 && conda clean --all --force-pkgs-dirs --yes


#	MAKE SURE THAT THERE'S NOTHING BIG OR SECRET HERE!
COPY . /app/alphafold
RUN wget -q -P /app/alphafold/alphafold/common/ \
  https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt


#	requests.exceptions.InvalidURL: Not supported URL scheme http+docker
#	Recommend requests < 2.32.0 for the time being

#Traceback (most recent call last):
#  File "/app/alphafold/run_alphafold_test.py", line 23, in <module>
#    import mock
#ModuleNotFoundError: No module named 'mock'


#	https://github.com/google-deepmind/alphafold/issues/867
# 'requests<2.29.0' 'urllib3<2.0'
#	TypeError: HTTPConnection.request() got an unexpected keyword argument 'chunked'

#/opt/conda/lib/python3.11/site-packages/requests/__init__.py:109: RequestsDependencyWarning: urllib3 (2.2.2) or chardet (None)/charset_normalizer (3.3.2) doesn't match a supported version!



#    && pip3 install -r /app/alphafold/requirements.txt 'requests<2.29.0' 'urllib3<2.0' --no-cache-dir \
#	requests==2.28.2
# Install pip packages.
RUN pip3 install --upgrade pip --no-cache-dir \
    && pip3 install -r /app/alphafold/requirements.txt mock --no-cache-dir \
    && pip3 install --upgrade --no-cache-dir \
      jax==0.4.28 \
      jaxlib==0.4.28+cuda12.cudnn89 \
      -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html

#      jax==0.4.26 \
#      jaxlib==0.4.26+cuda12.cudnn89 \

# Add SETUID bit to the ldconfig binary so that non-root users can run it.
RUN chmod u+s /sbin/ldconfig.real

# Currently needed to avoid undefined_symbol error.
RUN ln -sf /usr/lib/x86_64-linux-gnu/libffi.so.7 /opt/conda/lib/libffi.so.7

# We need to run `ldconfig` first to ensure GPUs are visible, due to some quirk
# with Debian. See https://github.com/NVIDIA/nvidia-docker/issues/1399 for
# details.
# ENTRYPOINT does not support easily running multiple commands, so instead we
# write a shell script to wrap them up.
WORKDIR /app/alphafold
RUN echo $'#!/bin/bash\n\
ldconfig\n\
python /app/alphafold/run_alphafold.py "$@"' > /app/run_alphafold.sh \
  && chmod +x /app/run_alphafold.sh
ENTRYPOINT ["/app/run_alphafold.sh"]


#	run the test data. Works in docker, but in singularity need to change directory.
#	Conversion to singularity does not respect the WORKDIR or ENTRYPOINT options
RUN echo $'#!/bin/bash\n\
ldconfig\n\
cd /app/alphafold/\n\
python run_alphafold_test.py "$@"' > /app/run_alphafold_test.sh \
  && chmod +x /app/run_alphafold_test.sh

#	I just can't get this to work in docker no matter which package versions I use.
#	I don't think that this would ever work in singularity.
#RUN echo $'#!/bin/bash\n\
#ldconfig\n\
#cd /app/alphafold/\n\
#python docker/run_docker.py "$@"' > /app/run_docker.sh \
#  && chmod +x /app/run_docker.sh

RUN echo $'#!/bin/bash\n\
ldconfig\n\
cd /app/alphafold/\n\
python run_alphafold220.py "$@"' > /app/run_alphafold220.sh \
  && chmod +x /app/run_alphafold220.sh

