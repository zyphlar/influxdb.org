
---
title: Replacing Collectd network server with InfluxDB
---

Since version 0.8.4 Influxdb supports the native collect network protocole hence it can replace a collectd network server transparently.

To active the network collectd server add this declaration in the configuration file.
```[input_plugins.collectd]
enabled = true
port = 25826
database = "collectd"
typesdb = "/usr/share/collectd/types.db"
```

The ```port``` if not specified will be set by default to ```25826```, the one that collectd use too.
the definition ```typesdb``` define the [types definition)[https://collectd.org/documentation/manpages/types.db.5.shtml] file to use. It can be found

And restart the server to a^pply the change.
