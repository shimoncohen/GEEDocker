FROM ubuntu:16.04

ARG GEE_path=earthenterprise
ARG TAG="5.3.5-1610.20"

RUN mkdir -p /opt/myapp

WORKDIR /opt/myapp

# Copy path if exists
COPY temp.txt $GEE_path* /opt/myapp/earthenterprise/

# Remove temporary file
RUN if test -e earthenterprise; then cd earthenterprise && rm temp.txt; else rm temp.txt; fi

# Install GEE dependencies
RUN apt-get update &&\
	apt-get -y install --no-install-recommends sudo\
	scons python-pip git ca-certificates curl rsync lsb-release\
	alien autoconf automake bison++ bisonc++ cmake doxygen dpkg \
    flex freeglut3-dev g++ gcc gettext \
    libboost-all-dev libc6 libc6-dev libcap-dev libfreetype6 libfreetype6-dev \
    libgdbm-dev libgeos-dev libgeos++-dev libgif-dev libgtest-dev \
    libjpeg-dev libjpeg8-dev libmng-dev libogdi3.2-dev \
    libperl4-corelibs-perl libpng12-0 libpng12-dev libpq-dev libproj-dev \
    libstdc++6 libtool \
    libx11-dev libxcursor-dev libxerces-c-dev libxft-dev libxinerama-dev \
    libxml2-dev libxml2-utils libxmu-dev libxrandr-dev libyaml-cpp-dev \
    openssl libpcre3 libpcre3-dev \
    python-dev python-imaging python-psycopg2 \
    python-setuptools python2.7 python2.7-dev python-lxml python-git \
    shunit2 swig xorg-dev zlib1g-dev

RUN pip install --upgrade pip
RUN pip install setuptools gcg

# Create symbolic links to binaries needed in /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libz* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libtiff* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libfreetype* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/liblcms* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libtcl* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libtk* /usr/lib/

# Clone GEE from repository
RUN if test -e earthenterprise/earth_enterprise; then true; else git clone --branch $TAG https://github.com/google/earthenterprise.git; fi

WORKDIR /opt/myapp/earthenterprise

# Pull updates
# RUN git pull

# Download git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && sudo apt-get -y install --no-install-recommends git-lfs

# Download additional files using git-lfs
RUN git lfs pull

WORKDIR /opt/myapp/earthenterprise/earth_enterprise

# Build GEE
RUN scons -j3 release=1 build

# Build the install package
RUN scons -j3 release=1 stage_install
