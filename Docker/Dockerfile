FROM hashicorp/terraform:latest

# Install required packages
RUN apk add --update curl jq bash

RUN addgroup -S ubuntu && adduser -u 1000 -S ubuntu -G ubuntu

RUN curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" | tar -zx
RUN mv cf /usr/local/bin