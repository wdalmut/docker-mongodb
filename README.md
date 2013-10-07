# docker-mongo

This is a [Docker](http://docker.io) project to bring up a local
[MongoDB](http://www.mongodb.org/) cluster.

## Running

### Clone Repository

```bash
$ git clone https://github.com/wdalmut/docker-mongodb.git
$ cd docker-mongodb
$ make mongodb-container
```

The statement `make mongodb-container` will download the image from docker
index.

### Launch cluster

```bash
$ make start-cluster
```

### Stop Cluster

```bash
$ make stop-cluster
```

