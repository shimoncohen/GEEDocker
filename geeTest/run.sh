#!/bin/bash

# Extra arguments go to docker build, e.g. --build-arg TAG=<wanted_tag>
docker build --rm --target test -t geetest:v1 "$@" ../geeBuild
