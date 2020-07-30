FROM hashicorp/terraform:latest

# Install required packages
RUN apk add --update curl jq bash

RUN addgroup -S ubuntu2 && adduser -u 1004 -S ubuntu2 -G ubuntu2

RUN curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" | tar -zx
RUN mv cf /usr/local/bin