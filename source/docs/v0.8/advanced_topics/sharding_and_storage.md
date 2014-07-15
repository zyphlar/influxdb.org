---
title: InfluxDB Underlying Storage and Sharding
---

# Storage Engines

InfluxDB can use different storage engines for the underlying storage of data. The current options are LevelDB, RocksDB, HyperLevelDB, and LMDB. The first three are Log Structured Merge Trees with Rocks and Hyper being forks of LevelDB. LMDB is a memory-mapped Copy on Write B+Tree. We've performed some [initial testing on the different storage engines](http://influxdb.com/blog/2014/06/20/leveldb_vs_rocksdb_vs_hyperleveldb_vs_lmdb_performance.html). RocksDB seems to come out on top so we've made it the default. See the configuration file for more information about [configuring the different storage engines](https://github.com/influxdb/influxdb/blob/master/config.sample.toml#L83).

# Databases and Shard Spaces

Data in InfluxDB is organized into **databases** which have many **shard spaaces** which have many **shards**. A shard maps to an underlying storage engine database. That is, each shard will be a separate LevelDB or LMDB. The implications of this are that if you want to keep your underlying storage engine databases small, configure things so your data will be split across many shards.

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

You can see that a shard space belongs to a specific database. The `retentionPolicy` is the period of time that data will be kept around. The exact semantics are that data is kept **at least** that long. The amount of time it is kept after that is determined by the `shardDuration`.

Shard duration should be something that is quite a bit less than the retention policy, but at least as big as the value you do `group by time()` queries on. Shards that are expired will be cleared from Influx automatically. In the example shard space above, you'd always have 7-8 days worth of data. A shard would get cleared once its `endTime` was past 7 days ago.

The `replicationFactor` setting tells the InfluxDB cluster how many servers should have a copy of each shard in the given shard space. Finally, `split` tells the cluster how many shards to create for a given interval of time. Data for that interval will be distributed across the shards. This setting is how you achieve write scalability. You may want to have `replicationFactor * split == number of servers`. That will ensure that every server in the cluster will be hot for writes at any given time.

Data is assigned to a shard using the following algorithm:

* Look up the shard spaces for the InfluxDB database
* Loop through the spaces and use the first one that matches the series name
* Lookup the shards for the given time interval
* If no shards exist, create N shards for the interval based on `split`
* Assign the data to a given shard in the interval using the algorithm <br />`hash(series_name) % N`

The best way to use shard spaces is to have high precision data write into a shard space with a lower retention policy. Then have continuous queries downsample from that data into new series that start with their interval (like `1h` or `10m`). Create a shard space that will match against those series names.

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

# Configuration

Start by creating a json config file, listing your databases and their shard definitions.
The sharding rules will automatically be applied to series matching the regex property of the shards.
Note that shard spaces should be ordered in the file from least specific to most. If you have a generic catch all shard space, it should be listed as the first one.
[Here's an example file](https://github.com/influxdb/influxdb/blob/master/integration/database_conf.json). 


Then, create databases and shard definitions via the command line. Like so:

```
influxdb -load-database-config="myconfig.json"
```

Or run ```influxdb -h``` to see all options.

You can only run this command once when initially creating the database. It will error out if the database already exists. Later on we'll have tools for working with existing databases.

