#!/bin/bash -e
curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" | tar -zx
mv cf /usr/local/bin
cf --version