FROM nvcr.io/nvidia/pytorch:20.07-py3

MAINTAINER Rafael Palomar <rafael.palomar@rr-research.no>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
	apt-utils emacs-nox\
	sudo\
	libsm-dev\
	libxrender-dev\
	libxext-dev

RUN pip install setuptools\
	tqdm==4.41.0\
	opencv-python==3.3.0.10\
	pytorch-lightning\
	matplotlib\
	monai\
	pyyaml\
	argparse\
	nibabel\
	scikit-image\
	scikit-learn\
	msgpack==0.5.6\
	regex==2018.01.10

#RUN conda install pytorch-lightning -c conda-forge -y
RUN conda install torchvision -c pytorch -y

# Replace 1000 with your user / group id
RUN export uid=1008 gid=1008 && \
	mkdir -p /home/developer && \
	echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:${uid}:" >> /etc/group && \
	echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
	chmod 0440 /etc/sudoers.d/developer && \
	chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer
