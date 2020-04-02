FROM geebuild:v1

# Download xserver package
RUN apt-get update &&\
	apt-get -y install --no-install-recommends x11-xserver-utils

WORKDIR /

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

WORKDIR /opt/myapp/earthenterprise/earth_enterprise/src/installer

# Install fusion
RUN echo C | bash install_fusion.sh

# Remove build files
RUN rm -frd /opt/myapp/earthenterprise

# Set entrypoint
ENTRYPOINT ["bash", "/entrypoint.sh"]
