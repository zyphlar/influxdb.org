# Glossary
This page describes the key terms and concepts within the InfluxDB system.

**Broker** Brokers are nodes within an InfluxDB cluster that are responsible for managing the Raft-based Distributed Consensus. Brokers also host Shard Topics.

**Continuous Query** A Continuous Query is a query constructed by a user that runs independently within an InfluxDB system. Continuous queries serve two purposes in InfluxDB: denormalizing data  into many series or into a single series and aggregating and  downsampling data. We refer to these as `fan-out`, `fan-in`, or `aggregation`.

**Data Node** A Data node is a node within an InfluxDB cluster that hosts actual time-series data in the form of shards. It does not participate in Distributed Consensus, but is responsible for  writing time-series data to disk and serving that data in response to queries.

**Field** A field is the part of a time-series data point that is not indexed by the system. By comparison Measurements and Tags are indexed.

**Join** Two separate series, joined with a function into one series.

**Merge** Merge meanto take multiple series, and compute aggregate across all those series.

**Measurement** A Measurement is the name give to quantity being recorded by a time-series. For example CPU load or disk writes. A Measurement does not have any tag data associated with it. For example, if the time-series datum is the following:

    cpu.load region=uswest server=mywebserver 1418864335 3

`cpu.load` is the measurement.

**Raft** The Distributed Consensus protocol used by InfluxDB.

**Replica** A Replica is a copy of a shard. Even if there is only one copy, that is sometimes still called a Replica. Within the source code, a Replica represents a Data node and its subscription to shard topics on a Broker node.

**Replication Factor** This factor determines how many copies of a given Shard exist on an InfluxDB cluster. If only a single copy exists, the Replication Factor is 1.

**Retention Policy** A Retention Policy is a logical namespace which maps to one or more  shards, and has a Split Factor and Replication Factor, both of which must be at least 1. An integral part of a Retention Policy is the Retention Period -- the time after which data is deleted within that Retention Policy.

**Series** A Series is a set of time-stamped data points, which includes a Measurement, Tags and Fields.

**Shard** A Shard is a logical concept, each of which represents a single split of a Retention Policy. For example if a Retention Policy has a split of 3, that Retention Policy is said to have 3 Shards. Each Shard maps to 1 or more BoltDB instances, depending on the Replication Factor. For example if a Retention Policy has a split of 2 and a Replication Factor of 3, the Shard will comprise 6 BoltDB instances across the entire cluster. Sharding is the fundamental way that an InfluxDB cluster distributes read and write load across the cluster.

**Shard Data** A BoltDB instance that stores the raw shard data points.

**Split** Split is a characteristic of a Retention Policy and determines how many shards comprise that Retention Policy. Split Factor is how the write throughput of a Retention Policy is scaled. It is orthogonal to Replication Factor.

**Tag** A Tag is an arbitrary key-value pair associated with a single time-series data point. For example, the following time-series data point is tagged by region and server:

    cpu.load region=uswest server=mywebserver 1418864335 3

Tags allow users to categorize their time-series data and query only certain subsets of that data.
