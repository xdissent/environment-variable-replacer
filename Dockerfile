FROM alpine

LABEL "name"="Environment Variable Replacer"

RUN apk update && \
    apk upgrade && \
    apk add bash && \
    apk add coreutils

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
