#
# Scala and sbt Dockerfile
#
# https://github.com/hseeberger/scala-sbt
#

# Pull base image
FROM  openjdk:8u181-jdk

ARG SCALA_VERSION=2.12.4
ARG SBT_VERSION=0.13.8

RUN export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    echo 'locales locales/locales_to_be_generated multiselect     en_US.UTF-8 UTF-8' | debconf-set-selections; \
    echo 'locales locales/default_environment_locale      select  en_US.UTF-8' | debconf-set-selections; \
    echo 'tzdata tzdata/Areas select America' | debconf-set-selections; \
    echo 'tzdata tzdata/Zones/America select New_York' | debconf-set-selections; \
    apt-get update -qqy && apt-get install -qqy --no-install-recommends tzdata locales && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8

# Scala expects this file
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion

# Define working directory
WORKDIR /root