---
title: InfluxDB Underlying Storage and Sharding
---

# Databases and Shard Spaces

Data in InfluxDB is organized into **databases** which have many **shard spaaces** which have many **shards**. A shard maps to an underlying storage engine database. That is, each shard will be a separate LevelDB or LMDB.

Data is assigned to a shard using the following algorithm:

* Look up the shard spaces for the database
* Loop through the spaces and use the first one that matches the series name
* Lookup the shards for the given time interval
* If no shards exist, create N shards for the interval based on `split`
* Assign the data to a given shard in the interval using the algorithm <br />`hash(series_name) % N`

Shard spaces have the following properties:

```json
{
  "name": "high_precision",
  "database": "pauls_db",
  "retentionPolicy": "7d",
  "shardDuration": "1d",
  "regex": "/^[a-z].*/",
  "replicatonFactor": 1,
  "split": 1
}
```

The best way to use shard spaces is to have high precision data write into a shard space with a lower retention policy. Then have continuous queries downsample from that data into new series that start with their interval (like `1h` or `10m`). Create a shard space that will match against those series names.

Shard duration should be something that is quite a bit less than the retention policy, but at least as big as the value you do `group by time()` queries on. Shards that are expired will be cleared from Influx automatically. In the example shard space above, you'd always have 7-8 days worth of data. Where a shard would get cleared once its `endTime` was past 7 days ago.

Dropping shard, shard spaces, and databases are very efficient operations. If you're going to be clearning out certain data regularly, it's best to use the shard spaces feature to organize things so that it's efficient.

Note that a duration of `inf` or an empty string will cause the shards in that space to never be automatically dropped. If you create a database and start writing data in, the following shard space will be created automatically:

```json
{
  "name": "default",
  "database": "pauls_db",
  "retentionPolicy": "inf",
  "shardDuration": "7d",
  "regex": "/.*/",
  "replicatonFactor": 1,
  "split": 1
}
```

The way to create databases and shard spaces is through the command line. Simply call:

```
influxdb -load-database-config="myconfig.json"
```

Or run ```influxdb -h``` to see all options.

You can only run this command once when initially creating the database. It will error out if the database already exists. Later on we'll have tools for working with existing databases.

Here is an [example database config json](https://github.com/influxdb/influxdb/blob/master/integration/database_conf.json). Note that shard spaces should be ordered in the file from least specific to most. If you have a generic catch all shard space, it should be listed as the first one.