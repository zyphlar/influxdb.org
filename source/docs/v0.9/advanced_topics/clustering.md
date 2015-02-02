---
_PLEASE NOTE 0.9.0 IS PRE-RELEASE SOFTWARE. THESE DOCUMENTS ARE TESTING REFERENCES_.

# Clustering
InfluxDB is design to scale horizontally. This means that you can easily add more machines to your cluster, to increase data ingestion performance, and reduce query response time.

While you can always scale your cluster vertically by running InfluxDB on more powerful hardware, growing a cluster by adding more machines also allows you to replicate your data across machines, and even data centers. Replicating your data provides high-availability, meaning your cluster will remain fully functional, even if some nodes fail.

## Brokers and Data Nodes
The 0.9.0 release has a different clustering design than that used by earlier releases. At its core is a new Streaming Raft implementation optimized for our use case. In a cluster, each machine is either a _Broker_, a _Data Node_ or both. The Brokers represent a streaming Raft consensus group. The Data nodes host all the raw replicated data. Data nodes are the machines that answer queries. The function a particular machine is performing is known as its _role_.

In the most simple highly available cluster, you run three servers, each acting as both brokers and data nodes. In that setup if you had a replication factor of 3, you’d be able to sustain a single server failure and still have a cluster that could ingest data and respond to queries.

In a larger setup you’d have 3-7 dedicated brokers and have the remainder act as data nodes. The number of brokers you have is influenced by the number of failures you want to be able to sustain among the brokers. In a setup with 3, you can have 1 broker failure and your cluster will still be available for writes. With 5 brokers you can have 2 broker failures and with 7 you can have 3 failures.
