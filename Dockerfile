ARG CUDA="10.2"

FROM nvcr.io/nvidia/cuda:10.2-runtime-ubuntu18.04

RUN apt-get -qq update
# libsm6 and libxext6 are needed for cv2
RUN apt-get update && apt-get install -y curl libxext6 libsm6 libxrender1 build-essential sudo \
    libgl1-mesa-glx git wget rsync tmux nano dcmtk fftw3-dev liblapacke-dev libpng-dev libopenblas-dev jq && \
  rm -rf /var/lib/apt/lists/*
RUN ldconfig

WORKDIR /tmp
RUN git clone https://github.com/mrirecon/bart.git
WORKDIR bart
RUN make -j4
RUN make install

# Create a working directory
RUN mkdir /workdir
WORKDIR /workdir

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /workdir
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user
RUN chmod 777 /workdir

# Install Miniconda and Python 3.7
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PATH=/home/user/miniconda/bin:$PATH
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh \
&& chmod +x ~/miniconda.sh \
&& ~/miniconda.sh -b -p ~/miniconda \
&& rm ~/miniconda.sh \
&& conda clean -ya

RUN conda update -n base conda -yq
RUN conda install python=3.7
RUN conda install numpy pyyaml mkl mkl-include setuptools cmake cffi typing boost
RUN conda install scipy pandas scikit-learn scikit-image=0.16 -yq
RUN conda install tensorflow-gpu -c anaconda
RUN python -m pip install opencv-python simpleitk h5py -q
RUN python -m pip install niftynet

ENV PYTHONPATH /tmp/bart/python:/workdir
ENV PATH "/tmp/bart/:$PATH"


# Provide an open entrypoint for the docker
ENTRYPOINT $0 $@

