# Key Concepts

To understand InfluxDB, it is necessary to understand some key concepts. These concepts are outlined below.

## Storing Data

A **database** is quite similar to that of a traditional relational database, and is an organized collection of time-series data and retention policies. User privileges are also set on a per-database level.

A **retention policies** is a logical namespace which maps to one or more shards, and has a _split factor_ and _replication factor_, both of which must be at least 1. An integral part of a retention policy is the _retention period_ – the time after which data is automatically deleted within the InfluxDB system. Every database has at least one retention policy.

**Split** is a characteristic of a retention policy and determines how many shards comprise that retention policy. Split factor is how the write throughput of a retention policy is scaled horizontally. It is orthogonal to the _Replication Factor_. **Replication factor** determines how many copies of data within retention policy exist on an InfluxDB cluster. If only a single copy exists, the replication factor is 1.

## Time-Series Data

InfluxDB uses particular terms to describe the various components of time-series data, and the techniques used to categorize that data.

A **series** is defined as a set of time-stamped data points, which includes a _measurement_, _tags_ and _fields_.

**Measurement** is the name give to quantity being recorded by a time-series. InfluxDB also allows you to associate **Tags**. Tags are arbitrary key-value pairs associated with a single time-series data point. Tags are indexed by InfluxDB, allowing efficient and fast look-up of particular series. Finally a **field** s the part of a time-series data point that is not indexed by the system.


