# HUGE shoutouts @vgmoose, mostly his Dockerfile
# Downloads the graphics-experimental-fs from https://github.com/reswitched/libtransistor - change it in the path to whatever you want.
#
# build/update it via:
# docker build --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) . -t libtransistor_shell
#
# Run it via:
#   docker run -it libtransistor_shell
#
# Run it with shared folders:
#   docker run -v X:/PATH/TO/SHARED/FOLDER:/build/share -it libtransistor_shell

FROM debian:stretch
MAINTAINER reswitched

RUN echo "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch main \n\
	deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch main \n\
	# 4.0 \n\
	deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-4.0 main \n\
	deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-4.0 main \n\
	# 5.0 \n\
	deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-5.0 main \n\
	deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-5.0 main" >> /etc/apt/sources.list \
	&& apt-get update \ 
	&& apt-get install -y sudo git build-essential wget squashfs-tools python3 python3-pip autoconf \
	&& wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
	&& apt-get update \
	&& apt-get install -y clang-5.0 lld-5.0 \
	&& mkdir -p /tmp/bin/cmake \
	&& wget --no-check-certificate --quiet -O - http://www.cmake.org/files/v3.4/cmake-3.4.3-Linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /tmp/bin/cmake

ENV PATH="/tmp/bin/cmake/bin:${PATH}"

ENV LIBTRANSISTOR_HOME=/build/libtransistor/dist

RUN useradd -m docker
RUN usermod -aG sudo docker
RUN usermod -aG root docker
RUN echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER docker
RUN sudo mkdir /build && sudo chown -R docker /build

WORKDIR /build

# We are using the graphics-experimental-fs branch, seems to be the most stable one (currently)
# Replace it with the branch/version you want to use
RUN git clone --recursive https://github.com/reswitched/libtransistor -b release-1.2.x

WORKDIR /build/libtransistor
RUN sudo pip3 install -r requirements.txt \
	&& make LLVM_POSTFIX=-5.0 LD=ld.lld-5.0

# Set a cache_date so we can force updating it.
ARG CACHE_DATE=2000-01-01

RUN git pull \
	&& git pull --recurse-submodules \
	&& make LLVM_POSTFIX=-5.0 LD=ld.lld-5.0

WORKDIR /build

RUN echo "echo \"You are now in a shell that can compile libtransistor projects.\nFiles outside of volume shares will be deleted when this shell is exited.\nTo use a share, add it to the docker run command; see the readme for more info.\"" >> /home/docker/.bashrc

CMD /bin/bash


# USAGE:
# Install/Build the docker via "docker build -t libtransistor_shell ." in an empty folder.
#
# Run the docker via: 
# 	docker run -it libtransistor_shell
#
#	 	(To have access to your normal filesystem, add a shared folder.)
# 		(docker run -v X:\PATH\TO\SHAREDFOLDER:/MAPPED/PATH/IN/DOCKER -it libtransistor_shell)
#
# To run run the make directly from windows in one single line (e.g. for Codeblocks integration)
# May I present you? The most complicated way to compile libtransistor app via docker in a single cmd.
# We need to copy the project files into an non-shared folder, otherwise the python script fails.
# Replace any "PROJECT_FOLDER_NAME" with the name of your project inside the "X:\PATH\TO\PROJECT" folder.
#
# docker run -v X:\PATH\TO\PROJECT:/build/share -w /build/share/ libtransistor_shell /bin/sh -c "cp . /build/tmp -r && cd /build/tmp && make clean && make LLVM_POSTFIX=-5.0 && cp ./*.nro /build/share/"
