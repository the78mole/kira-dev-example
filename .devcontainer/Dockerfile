# Base image: Ubuntu 22.04 LTS (Jammy) – required by Yocto Langdale/Mickledore
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# ── System dependencies required by Yocto / BitBake ─────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    gawk \
    wget \
    git \
    diffstat \
    unzip \
    texinfo \
    gcc \
    g++ \
    build-essential \
    chrpath \
    socat \
    cpio \
    python3 \
    python3-pip \
    python3-pexpect \
    xz-utils \
    debianutils \
    iputils-ping \
    libsdl1.2-dev \
    xterm \
    pylint \
    mesa-common-dev \
    libegl1-mesa \
    libgles2-mesa-dev \
    libtinfo5 \
    libncurses5 \
    lz4 \
    zstd \
    file \
    locales \
    sudo \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── Locale: Yocto requires en_US.UTF-8 ──────────────────────────────────────
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# ── Install KAS (Yocto build system orchestrator) via pip ────────────────────
RUN pip3 install --no-cache-dir kas

# ── Non-root user "builder" (UID 1000) – BitBake refuses to run as root ──────
RUN groupadd -g 1000 builder \
    && useradd -m -u 1000 -g 1000 -s /bin/bash builder \
    && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/builder \
    && chmod 0440 /etc/sudoers.d/builder

# ── Switch to builder user ───────────────────────────────────────────────────
USER builder
WORKDIR /home/builder

# Ensure pip-installed binaries (like kas) are on PATH for the builder user
ENV PATH="/home/builder/.local/bin:${PATH}"
