FROM debian:trixie-slim

RUN apt-get update && apt-get install -y \
    poppler-utils \
    ghostscript=10.05.0~dfsg-1 \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY optimize.sh /optimize.sh

RUN chmod +x /entrypoint.sh /optimize.sh

ENTRYPOINT ["/entrypoint.sh"]
