FROM centos:7
LABEL maintainer "Jens Mittag <kontakt@jensmittag.de>"

# Version configuration
ARG LOGSTASH_VERSION=5.4.3
ARG LOGSTASH_PACK_URL=https://artifacts.elastic.co/downloads/logstash-plugins

# Install Java and the "which" command, which is needed by Logstash's shell scripts.
RUN yum update -y && yum install -y java-1.8.0-openjdk-devel which && \
    yum clean all

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 logstash && \
    adduser --uid 1000 --gid 1000 \
      --home-dir /usr/share/logstash --no-create-home \
      logstash

# Add Logstash itself.
RUN curl -Lo - https://artifacts.elastic.co/downloads/logstash/logstash-$LOGSTASH_VERSION.tar.gz | \
    tar zxf - -C /usr/share && \
    mv /usr/share/logstash-$LOGSTASH_VERSION /usr/share/logstash && \
    chown --recursive logstash:logstash /usr/share/logstash/ && \
    ln -s /usr/share/logstash /opt/logstash

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$PATH

# Provide a minimal configuration, so that simple invocations will provide
# a good experience.
ADD config/logstash.yml config/log4j2.properties /usr/share/logstash/config/
ADD pipeline/default.conf /usr/share/logstash/pipeline/logstash.conf
RUN chown --recursive logstash:logstash /usr/share/logstash/config/ /usr/share/logstash/pipeline/

# Ensure Logstash gets a UTF-8 locale by default.
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Place the startup wrapper script.
ADD bin/docker-entrypoint /usr/local/bin/
RUN chmod 0755 /usr/local/bin/docker-entrypoint

USER logstash

RUN cd /usr/share/logstash && LOGSTASH_PACK_URL=$LOGSTASH_PACK_URL logstash-plugin install x-pack
RUN cd /usr/share/logstash && LOGSTASH_PACK_URL=$LOGSTASH_PACK_URL logstash-plugin install logstash-input-gelf
RUN cd /usr/share/logstash && LOGSTASH_PACK_URL=$LOGSTASH_PACK_URL logstash-plugin install logstash-input-beats

ADD env2yaml/env2yaml /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
