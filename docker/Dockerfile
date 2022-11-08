FROM jwtfuzz-exe-builder:latest AS builder
COPY . /app
RUN cd /app \
  && make bin

FROM debian:buster-slim@sha256:d6ecd2ec241bc6c672f1af7d2b102e4916998735a95fe4112457e804e62bfc03
RUN apt-get update \
  && apt-get install -y libgmp10 \
  && apt-get clean

COPY --from=builder /app/bin/jwtfuzz-exe /app/jwtfuzz-exe
WORKDIR /app
CMD ["./jwtfuzz-exe"]
