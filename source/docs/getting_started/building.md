---
title: InfluxDB Documentation
---

## Building InfluxDB From Source

For all systems, the best way to get the source is to clone the repository from GitHub.

``` shell
git clone https://github.com/influxdb/influxdb.git
```

### OS X

First, install the build dependencies of the project (via Homebrew):

``` shell
brew install protobuf bison flex leveldb go hg bzr
```

Then run `./test.sh`. This will build the server and run the tests.

### Linux

- You need to [get Go from Google Code](http://code.google.com/p/go/downloads/list).
- Ensure `go` is on your `PATH`.
- If you're on a Red Hat-based distro:

``` bash
sudo yum install hg bzr protobuf-compiler flex bison valgrind
```

- If you're on a Debian-based distro:

``` bash
sudo apt-get install mercurial bzr protobuf-compiler flex bison valgrind
```

- Run `./test.sh`. This will build the server and run the tests.
