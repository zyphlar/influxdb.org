# Clustering
InfluxDB is designed to scale horizontally. This means that you can easily add more machines to your cluster. This will increase data ingestion performance and reduce query response time.

There are two ways you can scale your cluster.  Increasing hardware, such as memory and CPU (commonly referred to as scaling verticaly), or by adding more machines or data centers (commonly referred to as scaling horizontally).  A benefit to scaling horizontally is that it adds additional replication.  Replicating your data provides high-availability, allowing your cluster to remain fully functional, even if some nodes fail.

## Brokers and Data Nodes
The 0.9.0 release has a different clustering design than that used by earlier releases. At its core is a new Streaming Raft implementation optimized for our use case. In a cluster, each machine is either a _Broker_, a _Data Node_ or both. The Brokers represent a streaming Raft consensus group. The Data nodes host all the raw replicated data. Data nodes are the machines that answer queries. The function a particular machine is performing is known as its _role_.

A minimal configuration for a highly-available cluster requires three servers, each acting as both brokers and data nodes. In that setup if you had a replication factor of 3, you’d be able to sustain a single server failure and still have a cluster that could ingest data and respond to queries.

In a larger setup you’d have 3-7 dedicated brokers and have the remainder act as data nodes. The number of brokers you have is influenced by the number of failures you want to be able to sustain among the brokers. In a setup with 3, you can have 1 broker failure and your cluster will still be available for writes. With 5 brokers you can have 2 broker failures and with 7 you can have 3 failures.

It is important to note that while it doesn't affect performance, an odd number of brokers is best practice in cluster design.  This is due to how a leader is elected and always requires a quorum with the Raft consensus protocol.
