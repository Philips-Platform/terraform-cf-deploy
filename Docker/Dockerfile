FROM hashicorp/terraform:latest

# Install required packages
RUN apk add --update curl jq bash

RUN useradd -u 1004 -ms /bin/bash ubuntu

RUN curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" | tar -zx
RUN mv cf /usr/local/bin