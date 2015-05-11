# Schema Design

In the 0.9.x version of InfluxDB, it is recommended that you encode most metadata into the series `Tags`. Tags are indexed within the InfluxDB system allowing fast querying by 1 or more tag values. Note that tag values are always interpreted as strings. And the optimal way to structure things is to have many series and a single column named "value" (or some other key of your choice) used consistently across all series.

It’s also a good idea to start the tag names and measurement names with a character in [a-z] or [A-Z], but not a requirement. It will just make writing queries easier later since you won’t have to wrap the names in double quotes.

Take a common example from the world of computer infrastructure monitoring. Imagine you need to record CPU load across you entire deployment. Furthermore, each CPU is actually composed of two cores, numbered 0 and 1. In this case you could send a datapoint like the following into InfluxDB:

```json
{
    "database": "mydb",
    "points": [
         {
            "name": "cpu_load",
            "tags": {
                "host": "server01",
                "core": "0"
            },
            "time": "2009-11-10T23:00:00Z",
            "fields": {
                "value": 0.45
            }
        },
        {
            "name": "cpu_load",
            "tags": {
                "host": "server01",
                "core": "1"
            },
            "time": "2009-11-10T23:00:00Z",
            "fields": {
                "value": 1.56
            }
        },
         {
            "name": "cpu_load",
            "tags": {
                "host": "server02",
                "core": "0"
            },
            "time": "2009-11-10T23:00:00Z",
            "fields": {
                "value": 0.72
            }
        },
        {
            "name": "cpu_load",
            "tags": {
                "host": "server02",
                "core": "1"
            },
            "time": "2009-11-10T23:00:00Z",
            "fields": {
                "value": 2.14
            }
        }
    ]
}
```
With the data in this format, querying and aggregating by various dimension is straightforward -- filter by tags as necessary. For example, to see only CPU load information from `server01` simply add `host='server01'` to your query. This would return data for both cores on that machine. To only see data from core 1, add `host='server01',core='1'`. And so on.

## Tags and cardinality
_Cardinality_ means the number of unique values a certain object has. For example if a tag, let's call it _host_, has two values in the database _server01_ and _server02_, the cardinality of the tag is 2. Cardinality has a significant impact on how InfluxDB operates.

Within InfluxDB, a series is defined as a combination of a _Measurement_ and all the tag key-value pairs associated with that Measurement. This means that if your tags have a high cardinality, there will be a large number of series in your system. In the extreme case, if a tag has a different value for every data point -- if the tag was a monotonically increasing integer, for example -- this would result in a large number of series being generated. This would significantly degrade both ingest and query performance of your system.

As a rule of thumb, keep tag cardinality below 100,000. The limit will vary depending on the resources available to InfluxDB, but it is best to keep tag cardinality as low as possible. If you have a value in your data with high cardinality, it should probably be a _field_, not a tag.

## Measurement names
Avoid using '.' in measurement names if possible, as names containing '.' must be quoted when queried.

