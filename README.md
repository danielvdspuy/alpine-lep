[![Build Status](https://travis-ci.org/danielvdspuy/alpine-lep.svg?branch=master)](https://travis-ci.org/danielvdspuy/alpine-lep) [![Docker build status](https://img.shields.io/docker/pulls/danielvdspuy/alpine-lep.svg)]()

# Docker 'LEP' server
A Docker container running Nginx and PHP7-FPM. Running these services in separate containers seems to degrade functionality somewhat.

## Prepare image

### Pull from the Docker Hub Registry
```bash
docker pull danielvdspuy/alpine-lep:latest
```

### Build locally
```bash
docker build -t danielvdspuy/alpine-lep:latest https://github.com/danielvdspuy/alpine-lep.git
```

## Usage

### tl;dr
```bash
docker run --name foobar -P danielvdspuy/alpine-lep:latest
```

The `-P` flag publishes the exposed ports; 80 & 9000. You can manually expose or remap ports using `-p LOCALPORT:CONTAINERPORT`.

### docker-compose
Place your application in `./www` and your default server block config in `./default.conf`.

Add any other server blocks by adding a volume entry for each with the format: `- VHOSTNAME:/etc/nginx/sites-enabled/VHOSTNAME:ro`. Be sure to set the server root to something other than the default `/var/www` directory, and point a local directory there.

```yaml
version: '2'

services:
  lep:
    image: 'danielvdspuy/alpine-lep:latest'
    ports:
      - '80:80'
      - '9000:9000'
    volumes:
      - www:/var/www
      - default.conf:/etc/nginx/sites-enabled/default:ro
```
