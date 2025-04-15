# .devcontainer/Dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y curl git unzip

# Install Juliaup into the default location (~/.juliaup)
RUN curl -fsSL https://install.julialang.org | bash -s -- --yes

# Install curl, git, unzip, and Python
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    python3 \
    python3-pip \
    python3-venv && \
    ln -s /usr/bin/python3 /usr/bin/python

# Create a 'python' alias pointing to 'python3'
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Set ENV for Juliaup (this is where it's actually installed)
ENV PATH="/root/.juliaup/bin:${PATH}"

# Now we can run juliaup commands
RUN juliaup default release

# Optionally symlink the Julia binary
RUN ln -s /root/.juliaup/bin/julia /usr/local/bin/julia
