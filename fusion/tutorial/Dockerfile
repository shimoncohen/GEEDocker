FROM geefusion:v1 AS base

FROM alpine

COPY --from=base / /

# Set the working directory
WORKDIR /opt/google/share/tutorials/fusion

# Remove old etrypoint
RUN rm /entrypoint.sh

# Copy new entrypoint script
COPY entrypoint.sh /entrypoint.sh

RUN apt-get update &&\
	apt-get -y install --no-install-recommends wget

# Set entrypoint
ENTRYPOINT ["bash", "/entrypoint.sh", "tutorial"]