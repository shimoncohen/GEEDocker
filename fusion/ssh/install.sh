#!/bin/bash

docker build --rm --build-arg ROOT_PASSWORD=<wanted_password> -t geefusion-ssh:v1 -f Dockerfile .
