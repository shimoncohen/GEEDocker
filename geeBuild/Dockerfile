ARG UBUNTU_IMAGE="ubuntu:16.04@sha256:1f1a2d56de1d604801a9671f301190704c25d604a416f59e03c04f5c6ffee0d6"

FROM ${UBUNTU_IMAGE} AS build

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
    apt-get -y install --no-install-recommends sudo=1.8.16-0ubuntu1.10 \
    scons=2.4.1-1 python-pip=8.1.1-2ubuntu0.6 git=1:2.7.4-0ubuntu1.10 \
    ca-certificates=20210119~16.04.1 curl=7.47.0-1ubuntu2.19 rsync=3.1.1-3ubuntu1.3 \
    lsb-release=9.20160110ubuntu0.2 \
    alien=8.95 autoconf=2.69-9 automake=1:1.15-4ubuntu1 bison++=1.21.11-3.1 \
    bisonc++=4.13.01-1 cmake=3.5.1-1ubuntu3 doxygen=1.8.11-1ubuntu0.1 \
    dpkg=1.18.4ubuntu1.7 \
    flex=2.6.0-11 freeglut3-dev=2.8.1-2 g++=4:5.3.1-1ubuntu1 gcc=4:5.3.1-1ubuntu1 \
    gettext=0.19.7-2ubuntu3.1 \
    libboost-all-dev=1.58.0.1ubuntu1 libc6=2.23-0ubuntu11.3 libc6-dev=2.23-0ubuntu11.3 \
    libcap-dev=1:2.24-12 libfreetype6=2.6.1-0.1ubuntu2.5 libfreetype6-dev=2.6.1-0.1ubuntu2.5 \
    libgdbm-dev=1.8.3-13.1 libgeos-dev=3.5.0-1ubuntu2 libgeos++-dev=3.5.0-1ubuntu2 \
    libgif-dev=5.1.4-0.3~16.04.1 libgtest-dev=1.7.0-4ubuntu1 \
    libjpeg-dev=8c-2ubuntu8 libjpeg8-dev=8c-2ubuntu8 libmng-dev=2.0.2-0ubuntu3 \
    libogdi3.2-dev=3.2.0~beta2-7.1build1 \
    libperl4-corelibs-perl=0.003-2 libpng12-0=1.2.54-1ubuntu1.1 libpng12-dev=1.2.54-1ubuntu1.1 \
    libpq-dev=9.5.25-0ubuntu0.16.04.1 libproj-dev=4.9.2-2 \
    libstdc++6=5.4.0-6ubuntu1~16.04.12 libtool=2.4.6-0.1 \
    libx11-dev=2:1.6.3-1ubuntu2.2 libxcursor-dev=1:1.1.14-1ubuntu0.16.04.2 \
    libxerces-c-dev=3.1.3+debian-1 libxft-dev=2.3.2-1 libxinerama-dev=2:1.1.3-1 \
    libxml2-dev=2.9.3+dfsg1-1ubuntu0.7 libxml2-utils=2.9.3+dfsg1-1ubuntu0.7 \
    libxmu-dev=2:1.1.2-2 libxrandr-dev=2:1.5.0-1 libyaml-cpp-dev=0.5.2-4ubuntu1~16.04.4 \
    openssl=1.0.2g-1ubuntu4.20 libpcre3=2:8.38-3.1 libpcre3-dev=2:8.38-3.1 \
    python-dev=2.7.12-1~16.04 python-imaging=3.1.2-0ubuntu1.6 python-psycopg2=2.6.1-1build2 \
    python-setuptools=20.7.0-1 python2.7=2.7.12-1ubuntu0~16.04.18 \
    python2.7-dev=2.7.12-1ubuntu0~16.04.18 python-lxml=3.5.0-1ubuntu0.4 \
    python-git=1.0.1+git137-gc8b8379-2.1 \
    shunit2=2.1.6-1.1ubuntu1 swig=3.0.8-0ubuntu3 xorg-dev=1:7.7+13ubuntu3.1 \
    zlib1g-dev=1:1.2.8.dfsg-2ubuntu4.3

# pip 21+ dropped Python 2 support. Separate RUNs: within one RUN, dash keeps
# calling the old /usr/bin/pip after the upgrade.
COPY requirements-pip.txt requirements.txt ./
RUN pip install --require-hashes -r requirements-pip.txt
RUN pip install --require-hashes -r requirements.txt

# Create symbolic links to binaries needed in /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libz* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libtiff* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libfreetype* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/liblcms* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libtcl* /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libtk* /usr/lib/

# Clone GEE and check out the commit pinned for $TAG; a tag not listed stays mutable
COPY gee-commits.txt ./
RUN if test -e earthenterprise/earth_enterprise; then true; else git clone https://github.com/google/earthenterprise.git && cd earthenterprise && git checkout "$(awk -v t="$TAG" '$1==t{print $2}' ../gee-commits.txt | grep . || echo "$TAG")"; fi

WORKDIR /opt/myapp/earthenterprise

# Pull updates
# RUN git pull

# Download git-lfs
RUN apt-get update && apt-get -y install --no-install-recommends apt-transport-https=1.2.35 && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://packagecloud.io/github/git-lfs/gpgkey -o /tmp/git-lfs.key && \
    echo "cae1519c7874bbfce6aada3cc29ffd444ce3e1ad14d8c56d2f6d98d2753d2cd6  /tmp/git-lfs.key" | sha256sum -c - && \
    gpg --dearmor -o /etc/apt/keyrings/github_git-lfs-archive-keyring.gpg /tmp/git-lfs.key && \
    chmod 0644 /etc/apt/keyrings/github_git-lfs-archive-keyring.gpg && rm /tmp/git-lfs.key && \
    echo "deb [signed-by=/etc/apt/keyrings/github_git-lfs-archive-keyring.gpg] https://packagecloud.io/github/git-lfs/ubuntu/ xenial main" > /etc/apt/sources.list.d/github_git-lfs.list && \
    apt-get update && apt-get -y install --no-install-recommends git-lfs=3.2.0

# Download additional files using git-lfs
RUN git lfs pull

WORKDIR /opt/myapp/earthenterprise/earth_enterprise

# Build GEE
RUN scons -j"$(nproc)" release=1 build

# Build the install package
RUN scons -j"$(nproc)" release=1 stage_install

# Tests need the build tree, which the base stage deletes.
FROM build AS test

# Root bypasses file permissions, which fails permission tests such as KhxmlTest.CreateDocumentNoPerms.
RUN useradd -m geetest && \
    chown -R geetest:geetest /opt/myapp/earthenterprise/earth_enterprise/src/NATIVE-REL-x86_64

USER geetest

WORKDIR /opt/myapp/earthenterprise/earth_enterprise/src/NATIVE-REL-x86_64/bin/tests

RUN ./RunAllTests.pl

FROM build AS base

RUN mv /opt/myapp/earthenterprise/earth_enterprise/src/version.txt /version.txt && \
    mv /opt/myapp/earthenterprise/earth_enterprise/src/installer /installer && \
    mv /opt/myapp/earthenterprise/earth_enterprise/tutorial/FusionTutorial /FusionTutorial
RUN rm -frd /opt/myapp
RUN mkdir /opt/myapp/earthenterprise/earth_enterprise/src && \
    mkdir /opt/myapp/earthenterprise/earth_enterprise/tutorial && \
    mv /version.txt /opt/myapp/earthenterprise/earth_enterprise/src/version.txt && \
    mv /installer /opt/myapp/earthenterprise/earth_enterprise/src/installer && \
    mv /FusionTutorial /opt/myapp/earthenterprise/earth_enterprise/tutorial/FusionTutorial

FROM ${UBUNTU_IMAGE}

COPY --from=base / /
