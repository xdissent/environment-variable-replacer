FROM alpine

LABEL "name"="Environment Variable Replacer"

RUN apk update && \
    apk upgrade && \
    apk add bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
