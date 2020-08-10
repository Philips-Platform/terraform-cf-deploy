FROM hashicorp/terraform:latest

# Install required packages
RUN apk add --update curl jq bash

# added this user in the image before the user mapping between Agent VM and docker triggers
# By default this terraform image doesn't have any user which can be used 
# and Jenkins would end up replicating its own user
# the mapped user will not have correct profile which was causing build failures. 
RUN addgroup -S ubuntu && adduser -u 1000 -S ubuntu -G ubuntu

# installing CF
RUN curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" | tar -zx
RUN mv cf /usr/local/bin