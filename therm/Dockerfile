# Debian-based Python, named directly (no BUILD_FROM): the Supervisor passes
# BUILD_FROM=ghcr.io/home-assistant/base (Alpine, no pip) when build.yaml is
# absent, and Streamlit needs pyarrow, which has no Alpine (musllinux) wheels.
# python:3.12-slim-bookworm is multi-arch; the Supervisor selects the platform. Pinned to a
# reviewed multi-arch index digest so builds are reproducible; bump it when the tag moves on
# (base-image security updates).
FROM python:3.12-slim-bookworm@sha256:392307d22300de8b5986851a12d9176dfc0fc073e65bf6523ebd7dcbeb23564e

# Set by the Supervisor for local builds (from config.yaml's version and the host's arch).
ARG BUILD_VERSION
ARG BUILD_ARCH

# io.hass.* labels are required for images not built with Home Assistant's builder actions
# (developers.home-assistant.io/docs/apps/configuration).
LABEL io.hass.version="${BUILD_VERSION}" \
      io.hass.type="app" \
      io.hass.arch="${BUILD_ARCH}" \
      org.opencontainers.image.title="therm" \
      org.opencontainers.image.description="Heat pump performance analysis for Home Assistant" \
      org.opencontainers.image.source="https://github.com/therm-heatpump/therm"

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONUNBUFFERED=1 \
    THERM_DATA_DIR=/config

# nginx: the Ingress gatekeeper in front of Streamlit (nginx.conf).
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*
COPY nginx.conf /etc/therm/nginx.conf

# Dependencies first so code-only changes rebuild quickly. constraints.txt pins every
# package, so builds on amd64 and aarch64 get the same versions.
COPY app/requirements.txt app/constraints.txt /app/
RUN pip install -r /app/requirements.txt -c /app/constraints.txt

# therm's Python source (./app).
COPY app/ /app/
COPY run.sh /run.sh
RUN chmod a+x /run.sh

WORKDIR /app
CMD ["/run.sh"]
