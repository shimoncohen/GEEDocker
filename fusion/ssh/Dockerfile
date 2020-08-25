FROM geebuild:v1 AS base

# Build arguments
ARG ROOT_PASSWORD

# Download xserver package
RUN apt-get update &&\
	apt-get -y install --no-install-recommends openssh-server

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

WORKDIR /opt/myapp/earthenterprise/earth_enterprise/src/installer

# Install fusion
RUN echo C | bash install_fusion.sh

# Copy tutorial script
RUN cp /opt/myapp/earthenterprise/earth_enterprise/tutorial/FusionTutorial/download_tutorial.sh /download_tutorial.sh

# Remove build and server files
RUN rm -frd /opt/myapp/earthenterprise &&\
	rm -frd /tmp/fusion_os_install &&\
	rm -d /gevol/src /gevol/assets

# From: https://docs.docker.com/engine/examples/running_ssh_service/
RUN mkdir /var/run/sshd
RUN echo "root:$ROOT_PASSWORD" | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


FROM alpine:3.12

COPY --from=base / /

# Put GEE executables in path
ENV PATH="/opt/google/bin:${PATH}"

# Set the working directory
WORKDIR /gevol/fusion

EXPOSE 22

# Set entrypoint
ENTRYPOINT ["bash", "/entrypoint.sh"]
