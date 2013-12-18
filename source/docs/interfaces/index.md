# Overview

InfluxDB ships with a default administration interface, which allows for management of users and databases, but also has a built-in structure for creating [custom interfaces](/docs/interfaces/custom.html) that can offer arbitrary data visualization and manipulation.

### The Administration Interface

By default, the admin interface runs on port `8083` by default, but this can be changed in the configuration file. Accessing this port with a browser on a running InfluxDB instance will serve up the default interface, which prompts you to log in as either a cluster administrator or a database user.

InfluxDB also ships with a default Data Interface, which offers a simple tool for reading and writing data.
