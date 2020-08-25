FROM geebuild:v1 AS base

# Download xserver package
RUN apt-get update &&\
	apt-get -y install --no-install-recommends x11-xserver-utils

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

FROM alpine:3.12

COPY --from=base / /

# Put GEE executables in path
ENV PATH="/opt/google/bin:${PATH}"

# Set the working directory
WORKDIR /gevol/fusion

# Set entrypoint
ENTRYPOINT ["bash", "/entrypoint.sh"]
