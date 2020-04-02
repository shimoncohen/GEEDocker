FROM geebuild:v1

WORKDIR /

COPY entrypoint.sh /entrypoint.sh

WORKDIR /opt/myapp/earthenterprise/earth_enterprise/src/installer

RUN apt-get update &&\
	apt-get install --no-install-recommends python-pil\
	python-tornado

# Install earth server
RUN echo 'C\ny' | bash install_server.sh

RUN rm -frd /opt/myapp/earthenterprise

EXPOSE 80

ENTRYPOINT ["bash", "/entrypoint.sh"]
