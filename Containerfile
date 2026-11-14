FROM debian:forky-slim

RUN apt-get update && apt-get install -y \
    poppler-utils \
    python3-pikepdf \
    ghostscript \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY optimize.sh /optimize.sh
COPY repair_tounicode.py /repair_tounicode.py

RUN chmod +x /entrypoint.sh /optimize.sh /repair_tounicode.py

ENTRYPOINT ["/entrypoint.sh"]
