# Schema Design

The best way to structure things is to have many series and a single column named value or something consistent across all series.

In the 0.9.x version of InfluxDB, it is recommended that you encode most metadata into the series `Tags`. Tags are indexed within the InfluxDB system allowing fast querying by 1 or more tag values. Note that tag values are always interpreted as strings. And the optimal way to structure things is to have many series and a single column named "value" (or some other key of your choice) used consistently across all series.

It’s also a good idea to start the tag names and measurement names with a character in [a-z] or [A-Z], but not a requirement. It will just make writing queries easier later since you won’t have to wrap the names in double quotes.

Take a common example from the world of computer infrastucture monitoring. Imagine you need to record CPU load across you entire deployment. Furthermore, each CPU is actually composed of two cores, numbered 0 and 1. In this case you could send a datapoint like the following into InfluxDB:

```json
{
    "database": "mydb",
    "points": [
         {
            "name": "cpu_load",
            "tags": {
                "host": "server01",
                "core": 0
            },
            "timestamp": "2009-11-10T23:00:00Z",
            "fields": {
                "value": 0.45
            }
        },
        {
            "name": "cpu_load",
            "tags": {
                "host": "server01",
                "core": 1
            },
            "timestamp": "2009-11-10T23:00:00Z",
            "fields": {
                "value": 1.56
            }
        },
         {
            "name": "cpu_load",
            "tags": {
                "host": "server02",
                "core": 0
            },
            "timestamp": "2009-11-10T23:00:00Z",
            "fields": {
                "value": 0.72
            }
        },
        {
            "name": "cpu_load",
            "tags": {
                "host": "server02",
                "core": 1
            },
            "timestamp": "2009-11-10T23:00:00Z",
            "fields": {
                "value": 2.14
            }
        }
    ]
}
```
With the data in this format, querying and aggregating by various dimenension is straightforward -- filter by tags as necessary. For example, to see only CPU load information from `server01` simply add `host='server01'` to your query. This would return data for both cores on that machine. To only see data from core 1, add `host='server01',core='1'`. And so on.

## Series Name
Avoid using '.' in series names if possible, as names containing '.' must be quoted when queried.

