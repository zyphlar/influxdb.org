# HTTP API
The HTTP API is the primary means of getting data into InfluxDB. To write data simply send a `POST` to the endpoint `/write`. The body of the POST contains the destination database, retention policy, and time-series data you wish to store. An example request, that writes a single point, is shown below.

```json
{
    "database": "mydb",
    "retentionPolicy": "mypolicy",
    "points": [
        {
            "name": "cpu.load.short",
            "tags": {
                "host": "server01",
                "region": "us-west"
            },
            "timestamp": "2009-11-10T23:00:00Z",
            "values": {
                "value": 0.64
            }
        }
    ]
}
```
In the example above the destination database is `mydb`, and the data will be stored in the retention policy named `mypolicy`. The actual data represents the short-term CPU-load on a server server01 in region _us-west_. `database` must be specified in the request body, but `retentionPolicy` is optional. If `retentionPolicy` is not specified, the default retention policy for the database is used.

### Writing Multiple Points
As you can see from the example above, you can post multiple points to multiple series at the same time. Batching points in this manner will result in much higher performance.

## Tags
Each point can have a set of key-value pairs associated with it. Both keys and values must be strings. Tags allow data to be easily and efficient queried, including or excluding data that matches a set of keys with particular values.

## Timestamp Format
Timestamps must be in RFC3339 format. Nanosecond precision is supported.

## Response
Once InfluxDB has accepted this data and safely persisted it to disk, it responds with `HTTP 200 OK`.

### Errors


