FROM geefusion:v1 AS base

FROM alpine

COPY --from=base / /

WORKDIR /

# Remove old etrypoint
RUN rm /entrypoint.sh

# Copy new entrypoint script
COPY entrypoint.sh /entrypoint.sh

RUN apt-get update &&\
	apt-get install --no-install-recommends wget

WORKDIR /opt/google/share/tutorials/fusion

#RUN bash download_tutorial.sh

#VOLUME /opt/google/share/tutorials/fusion

# Set entrypoint
ENTRYPOINT ["bash", "/entrypoint.sh", "tutorial"]
