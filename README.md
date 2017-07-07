## Description

This repository contains a custom built [Logstash][logstash] Docker image, based on the official image by
[Elastic][elastic].

Documentation can be found on the [Elastic website](https://www.elastic.co/guide/en/logstash/current/docker.html).

[logstash]: https://www.elastic.co/products/logstash
[elastic]: https://www.elastic.co/

## Available images on Dockerhub  

See https://hub.docker.com/r/m00re/logstash/

## Requirements
A full build and test requires:
* Docker
* GNU Make
* Python 3.5 with Virtualenv

## Differences compared to official image

* This image includes the following plugins:
  * Beats input plugin: https://github.com/logstash-plugins/logstash-input-beats
* The build process has been simplified - you only need Docker to build your own image.

## Building the image

Building this image is divided into two steps:

1. Building a small helper called ```env2yml``` that is later responsible for the mapping of environment variables to 
YAML variables.
   ```
   $ docker build ./env2yaml/ -t golang:env2yaml
   $ docker run --rm -i -v ${PWD}/env2yaml:/usr/local/src/env2yaml:Z golang:env2yaml
   ``` 
2. Building the logstash image itself.
   ```
   $ docker build . -t m00re/logstash:5.4.3
   ```

## Additional remarks

This image is built on [Centos 7][centos-7].

[centos-7]: https://github.com/CentOS/sig-cloud-instance-images/blob/50281d86d6ed5c61975971150adfd0ede86423bb/docker/Dockerfile
