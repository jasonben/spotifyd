FROM rust:bullseye AS builder
RUN \
  apt update && \
  apt install -y \
  alsa-utils \
  libpulse0 \
  libasound2-dev \
  libasound2-plugins \
  wget

RUN \
  cargo install spotifyd

FROM debian:bullseye-slim
ENV PULSE_SERVER=unix:/var/run/pulseaudio.sock
RUN \
  apt update && \
  apt-get install \
  --no-install-recommends -y -qq \
  curl bash ca-certificates \
  alsa-utils \
  libpulse0 \
  libasound2-dev \
  libasound2-plugins

COPY --from=builder /usr/local/cargo/bin/spotifyd /usr/local/bin/spotifyd
# https://github.com/joonas-fi/spotifyd-docker/blob/master/alsa.conf
COPY alsa.conf /usr/share/alsa/alsa.conf
ENTRYPOINT ["/usr/local/bin/spotifyd", "--no-daemon"]
