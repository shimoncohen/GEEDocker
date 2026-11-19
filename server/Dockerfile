ARG BASE_IMAGE=geebuild:v1
FROM ${BASE_IMAGE} AS base

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

WORKDIR /opt/myapp/earthenterprise/earth_enterprise/src/installer

# Install dependencies
RUN apt-get update &&\
	apt-get -y install --no-install-recommends python-pil=3.1.2-0ubuntu1.6\
	python-tornado=4.2.1-1ubuntu3.1

# Install earth server
RUN echo 'C\nn' | bash install_server.sh -hnf

# Build arguments
ARG IP=""

# Set server address to localhost
RUN sed -i "s/#ServerName www.example.com:80/ServerName ${IP}/g" /opt/google/gehttpd/conf/gehttpd.conf

EXPOSE 80

ENTRYPOINT ["bash", "/entrypoint.sh"]
