FROM debian:buster

# Copied from https://raw.githubusercontent.com/crossbario/crossbar/master/docker/armhf/Dockerfile.cpy3

# Application home
ENV HOME /node
ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED 1

# install dependencies and Crossbar.io
RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
               python3 \
               python3-dev \
               python3-pip \
               python3-setuptools \
               ca-certificates \
               expat \
               build-essential \
               libssl-dev \
               libffi-dev \
               libunwind-dev \
               libsnappy-dev \
               libbz2-dev \
    # install Crossbar.io from PyPI. rgd pip: https://github.com/pypa/pip/issues/6158 and https://github.com/pypa/pip/issues/6197
    && python3 -m pip install --upgrade pip \
    && pip3 install --no-cache-dir crossbar \
    # minimize image
    && rm -rf ~/.cache \
    && rm -rf /var/lib/apt/lists/*

# install manually, as environment markers don't work when installing crossbar from pypi
RUN pip3 install --no-cache-dir "wsaccel>=0.6.2" "vmprof>=0.4.12"

# test if everything installed properly
RUN crossbar version

# add our user and group
RUN adduser --system --group --uid 242 --home /node crossbar

# initialize a Crossbar.io node
COPY ./.node/ /node/
RUN chown -R crossbar:crossbar /node

# make /node a volume to allow external configuration
VOLUME /node

# set the Crossbar.io node directory as working directory
WORKDIR /node

# run under this user, and expose default port
USER crossbar
EXPOSE 8080 8000

# entrypoint for the Docker image is the Crossbar.io executable
ENTRYPOINT ["crossbar", "start", "--cbdir", "/node/.crossbar"]