FROM alpine:3.21

RUN apk add --no-cache \
    bash \
    poppler-utils \
    ghostscript

COPY entrypoint.sh /entrypoint.sh
COPY optimize.sh /optimize.sh

RUN chmod +x /entrypoint.sh /optimize.sh

ENTRYPOINT ["/entrypoint.sh"]
