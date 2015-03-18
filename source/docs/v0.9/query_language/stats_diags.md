# Server Statistics
InfluxDB can display statistical and diagnostic information about each node. This information can be very useful for troubleshooting and performance monitoring.

To see node stats execute the command `SHOW STATS`. An example is shown below.

```sql
SHOW STATS
```

```json
{
    "results": [
        {
            "series": [
                {
                    "name": "server",
                    "columns": [
                        "broadcastMessageRx",
                        "batchWriteRx",
                        "pointWriteRx",
                        "writeSeriesMessageTx"
                    ],
                    "values": [
                        [
                            37
                        ],
                        [
                            299984
                        ],
                        [
                            2789
                        ],
                        [
                            25
                        ]
                    ]
                }
            ]
        }
    ]
}
```

The statistics returned by `SHOW STATS` are stored in memory only, and are reset to zero when the node is restarted.

InfluxDB also supports writing statistics to an internal database, allowing server performance to be recorded over the long term. This data is written as standard time-series data, allowing the full power of `InfluxQL` to be used. Check the [example configuration file](https://github.com/influxdb/influxdb/blob/master/etc/config.sample.toml) for full details.
