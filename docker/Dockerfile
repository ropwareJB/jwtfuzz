# debian:buster-slim
FROM debian:buster-slim@sha256:d6ecd2ec241bc6c672f1af7d2b102e4916998735a95fe4112457e804e62bfc03

RUN apt-get update \
  && apt-get install -y libgmp10 \
  && rm /var/cache/apt/*.bin

