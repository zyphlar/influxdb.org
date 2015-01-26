---
_PLEASE NOTE 0.9.0 IS PRE-RELEASE SOFTWARE. THESE DOCUMENTS ARE TESTING REFERENCES_.

# Installation

If you're ready to use InfluxDB but don't want to install any software, you may want to check out our [managed hosted InfluxDB offering](http://customers.influxdb.com). But if you want to run your own InfluxDB system, this page provides directions on downloading and starting InfluxDB.

## Requirements
Installation of InfluxDB requires root privileges on the host machine.

### Networking
By default InfluxDB will use TCP ports `8083`, `8086`, `8090`, and `8099`, so these ports should be available on your system. Once you install you can change those ports and other options in the configuration file, which is located by default in `/etc/opt/influxdb`.

## Ubuntu & Debian
Debian users can install by downloading the package and installing it like this:

```bash
# for 64-bit systems
wget http://s3.amazonaws.com/influxdb/influxdb_latest_amd64.deb
sudo dpkg -i influxdb_latest_amd64.deb

# for 32-bit systems
wget http://s3.amazonaws.com/influxdb/influxdb_latest_i386.deb
sudo dpkg -i influxdb_latest_i386.deb
```

Then start the daemon by running:

```
sudo /etc/init.d/influxdb start
```

## RedHat & CentOS
RedHat and CentOS users can install by downloading and installing the rpm like this:

```bash
# for 64-bit systems
wget http://s3.amazonaws.com/influxdb/influxdb-latest-1.x86_64.rpm
sudo rpm -ivh influxdb-latest-1.x86_64.rpm

# for 32-bit systems
wget http://s3.amazonaws.com/influxdb/influxdb-latest-1.i686.rpm
sudo rpm -ivh influxdb-latest-1.i686.rpm
```

Then start the daemon by running:

```
sudo /etc/init.d/influxdb start
```

<a href="getting_started.html"><font size="6"><b>Now get started!</b></font></a>
