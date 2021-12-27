FROM geebuild:v1 AS base

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

WORKDIR /opt/myapp/earthenterprise/earth_enterprise/src/installer

# Install dependencies
RUN apt-get update &&\
	apt-get -y install --no-install-recommends python-pil\
	python-tornado

# Install earth server
RUN echo 'C\nn' | bash install_server.sh

# Build arguments
ARG ADMIN_PASSWORD=""
ARG IP=""

# Set server address to localhost
RUN sed -i "s/#ServerName www.example.com:80/ServerName ${IP}/g" /opt/google/gehttpd/conf/gehttpd.conf

# Set the admin password if given
RUN if [ -n "$ADMIN_PASSWORD" ]; then echo "$ADMIN_PASSWORD" | /opt/google/gehttpd/bin/htpasswd -ci /opt/google/gehttpd/conf.d/.htpasswd geapacheuser; fi;

EXPOSE 80

ENTRYPOINT ["bash", "/entrypoint.sh"]
