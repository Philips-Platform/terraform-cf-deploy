FROM terraform:latest

# Install required packages
RUN apk add --update curl jq bash
