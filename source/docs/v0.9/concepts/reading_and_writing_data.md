# Reading and Writing Data
There are many ways to write data into InfluxDB including the built-in HTTP API, client libraries and integrations with external data sources such as Collectd.

## Writing data using the HTTP API
The HTTP API is the primary means of getting data into InfluxDB. To write data simply send a `POST` to the endpoint `/write`. The body of the POST contains the destination database, retention policy, and time-series data you wish to store. An example request sent to InfluxDB running on localhost, which writes a single point, is shown below.

```
curl -XPOST 'httpp://localhost:8086/write' -d '
{
    "database": "mydb",
    "retentionPolicy": "mypolicy",
    "points": [
        {
            "name": "cpu_load_short",
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
'
```
In the example above the destination database is `mydb`, and the data will be stored in the retention policy named `mypolicy`. The actual data represents the short-term CPU-load on a server server01 in region _us-west_. `database` must be specified in the request body, but `retentionPolicy` is optional. If `retentionPolicy` is not specified, the default retention policy for the database is used.

#### Schemaless Design
InfluxDB is schemaless so the series and columns get created on the fly. You can add columns to existing series without penalty. It also means that if you change the column type later by writing in different data, InfluxDB won’t complain, but you might get unexpected results when querying.

#### Writing multiple points
As you can see from the example above, you can post multiple points to multiple series at the same time. Batching points in this manner will result in much higher performance.

### Tags
Each point can have a set of key-value pairs associated with it. Both keys and values must be strings. Tags allow data to be easily and efficient queried, including or excluding data that matches a set of keys with particular values.

### Timestamp format
Timestamps must be in RFC3339 format. Nanosecond precision is supported.

### Response
Once InfluxDB has accepted this data and safely persisted it to disk, it responds with `HTTP 200 OK`.

#### Errors
If an error was encountered while processing the data, InfluxDB will respond with `HTTP 500 Internal Error`.

## Querying data using the HTTP API
The HTTP API is also the primary means for querying data contained within InfluxDB. To perform a query send a `GET` to the endpoint `/query`, and set the URL parameter `q` as your query. An example query, sent to a locally-running InfluxDB server, is shown below.

```
curl -XGET 'http://localhost:8086/query' --data-urlencode "q=SELECT * from cpu.load.short WHERE region=us-west"
```

Which returns data that looks like so:

```json
{
    "results": [
        {
            "rows": [
                {
                    "name": "cpu_load_short",
                    "tags": {
                        "host": "servera",
                        "region": "us-west"
                    },
                    "columns": [
                        "timestamp",
                        "value"
                    ],
                    "values": [
                        1400425947368,
                        0.64
                    ]
                }
            ]
        }
    ]
}
```
InfluxDB supports a sophisticated query language. Consult the Query Language section to learn more.

## Authentication
If authentication is enabled, user credentials must be supplied. These may be suppled via the URL parameters `u` and `p`. For example, if the     user is "bob" and Bob's password is "mypass", then endpoint URL should take the form `/query?u=bob&p=mypass`.

_Basic Authentication_ is also supported. If both types of authentication are present in a request, the URL parameters take precedence.

## Pretty Printing
When working directly with the API it’s often convenient to have pretty-printed JSON output. To enable pretty-printed output, append `pretty=true` to the URL. For example:

```
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "q=SELECT * from cpu.load.short"
```

Pretty-printed output is not recommended otherwise, as it consumes unnecessary network bandwidth.
