FROM alpine:edge

RUN apk add --no-cache \
    bash \
    poppler-utils \
    ghostscript=10.07.0-r0

COPY entrypoint.sh /entrypoint.sh
COPY optimize.sh /optimize.sh

RUN chmod +x /entrypoint.sh /optimize.sh

ENTRYPOINT ["/entrypoint.sh"]
