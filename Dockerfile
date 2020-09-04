FROM nvcr.io/nvidia/cuda:10.2-runtime-ubuntu18.04

RUN apt update && apt upgrade -y

# Install some basic utilities
RUN apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
	python3-pip \
 && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir /app
WORKDIR /app

RUN pip3 install monai argparse

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda and Python 3.7
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PATH=/home/user/miniconda/bin:$PATH
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && conda install -y python==3.7.9 \
 && conda clean -ya

# CUDA 10.2-specific steps
RUN conda update --all
RUN conda install -y -c pytorch \
    cudatoolkit=10.2 \
    "pytorch=1.5.0=py3.7_cuda10.2.89_cudnn7.6.5_0" \
    "torchvision=0.6.0=py37_cu102" \
 && conda clean -ya

RUN conda install -y -c conda-forge \
	pytorch-lightning \
	tqdm \
	pyyaml \
	nibabel \
	matplotlib \
	scikit-image \
	scikit-learn \
	msgpack-python \
	regex

RUN conda install -y \
	opencv

# Set the default command to python3
CMD ["python3"]
