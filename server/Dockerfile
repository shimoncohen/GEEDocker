FROM geebuild:v1 AS base

# Build arguments
ARG ADMIN_PASSWORD

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

WORKDIR /opt/myapp/earthenterprise/earth_enterprise/src/installer

# Install dependencies
RUN apt-get update &&\
	apt-get -y install --no-install-recommends python-pil\
	python-tornado

# Install earth server
RUN echo 'C\nn' | bash install_server.sh

# Remove build files
RUN rm -frd /opt/myapp/earthenterprise /tmp

FROM alpine

COPY --from=base / /

# Set server address to localhost
RUN sed -i "s/#ServerName www.example.com:80/ServerName localhost/g" /opt/google/gehttpd/conf/gehttpd.conf

# Set the admin password
RUN echo "$ADMIN_PASSWORD\n$ADMIN_PASSWORD" | /opt/google/gehttpd/bin/htpasswd -c .htpasswd geapacheuser

# Declare a pgsql data volume
VOLUME /var/opt/google/pgsql/data

EXPOSE 80

ENTRYPOINT ["bash", "/entrypoint.sh"]