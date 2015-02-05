# Key Concepts

To understand InfluxDB, it is necessary to understand some key concepts. These concepts are outlined below.

## Storing Data

A **database** is quite similar to that of a traditional relational database, and is an organized collection of time-series data and retention policies. User privileges are also set on a per-database level.

A **retention policy** is a logical namespace which maps to one or more shards, and has a _replication factor_. The replication factor must be at least 1. An integral part of a retention policy is the _retention period_ – the time after which data is automatically deleted within the InfluxDB system. Every database has at least one retention policy.

## Time-Series Data

InfluxDB uses particular terms to describe the various components of time-series data, and the techniques used to categorize that data.

A **series** is defined as a combination of a _measurement_ and set of _tag_ key-values. Combined with _fields_ (columns) and _values_, these make up series _data_.

**Measurement** is the name give to quantity being recorded by a time-series. For example `cpu_load`.

InfluxDB also allows you to associate **tags**. Tags are arbitrary key-value pairs associated with a single time-series data point. Series data is indexed by tags, allowing efficient and fast look-up of series that match a given set of tags. Finally a **field** is the part of a time-series data point that is not indexed by the system.


