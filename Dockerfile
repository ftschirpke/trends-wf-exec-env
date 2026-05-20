FROM davidfrantz/force:3.10.04

USER root

RUN mkdir -p /var/cache/apt/archives/partial /var/lib/apt/lists/partial

RUN apt-get update && \
    apt-get install -y \
    openjdk-17-jre-headless \
    curl \
    tar \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN curl -s https://get.nextflow.io | bash 
RUN mv nextflow /usr/local/bin/

USER ubuntu
