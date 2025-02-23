# syntax=docker/dockerfile:1.4

# https://askubuntu.com/questions/972516/debian-frontend-environment-variable
ARG DEBIAN_FRONTEND=noninteractive

FROM deps AS vim4-deps
ARG TARGETARCH

# Install dependencies
RUN --mount=type=bind,source=docker/vim4/install_deps.sh,target=/deps/install_deps.sh \
    /deps/install_deps.sh

ENV DEFAULT_FFMPEG_VERSION="vim4"
ENV INCLUDED_FFMPEG_VERSIONS="${DEFAULT_FFMPEG_VERSION}:${INCLUDED_FFMPEG_VERSIONS}"

WORKDIR /opt/frigate/
COPY --from=rootfs / /
