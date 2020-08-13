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
	tqdm==4.19.4\
	torch==0.3.1\
	opencv-python==3.3.0.10\
	torchvision==0.1.9
		 
# Replace 1000 with your user / group id
RUN export uid=1001 gid=1001 && \
	mkdir -p /home/developer && \
	echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:${uid}:" >> /etc/group && \
	echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
	chmod 0440 /etc/sudoers.d/developer && \
	chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer

