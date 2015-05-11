# Reading and Writing Data
There are many ways to write data into InfluxDB including the built-in HTTP API, client libraries and integrations with external data sources such as Collectd.

## Writing data using the HTTP API
The HTTP API is the primary means of getting data into InfluxDB. To write data simply send a `POST` to the endpoint `/write`. The body of the POST contains the destination database, retention policy, and time-series data you wish to store. An example request sent to InfluxDB running on localhost, which writes a single point, is shown below.

```
# Create your new database, this only needs to be done once.
curl -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"

# Write your data to your new database.
curl -XPOST 'http://localhost:8086/write' -d '
{
    "database": "mydb",
    "retentionPolicy": "default",
    "points": [
        {
            "name": "cpu_load_short",
            "tags": {
                "host": "server01",
                "region": "us-west"
            },
            "time": "2009-11-10T23:00:00Z",
            "fields": {
                "value": 0.64
            }
        }
    ]
}
'
```

In the example above the destination database is `mydb`, and the data will be stored in the retention policy named `default`, which is created automatically. The actual data represents the short-term CPU-load on a server _server01_ in region _us-west_. `database` must be specified in the request body, but `retentionPolicy` is optional. If `retentionPolicy` is not specified, the default retention policy for the database is used. Tags are also optional, but very useful. Finally, if you do not set the time, the server's local timestamp at the time the data was received will be used.

#### Schemaless Design
InfluxDB is schemaless so the series, and columns for that series, get created on the fly. You can add columns to existing series without penalty, and integers, floats, strings, booleans, and raw bytes, are all supported as types. If you change a column type later by writing in data with a different type (writing a string for a column value that was previously an integer), InfluxDB will reject the data.

#### Writing multiple points
As you can see from the example above, you can post multiple points to multiple series at the same time. Batching points in this manner will result in much higher performance. Furthermore, if `tags`, `time` are common to some of your points, these keys may be placed alongside `database` and `retentionPolicy`. Any points without these keys will then use the shared values. If there are shared tags, and tags specifically for the point, they will be merged, except in the case of `time`, when the point's timestamp takes precedence. For example, the JSON data shown below is a valid write request.

```json
{
    "database": "mydb",
    "retentionPolicy": "default",
    "tags": {
        "host": "server01",
        "region": "us-west"
    },
    "time": "2009-11-10T23:00:00Z",
    "points": [
        {
            "name": "cpu_load_short",
            "fields": {
                "value": 0.64
            }
        },
        {
            "name": "cpu_load_short",
            "fields": {
                "value": 0.55
            },
            "time": 1422568543702900257,
            "precision": "n"
        },
        {
            "name": "network",
            "tags": {
                "direction": "in"
            },
            "fields": {
                "value": 23422
            }
        }
    ]
}
```

### Tags
Each point can have a set of key-value pairs associated with it. Both keys and values must be strings. Tags allow data to be easily and efficient queried, including or excluding data that matches a set of keys with particular values.

### Time format
The following time formats are accepted:

_RFC3339_

Both UTC and formats with timezone information are supported. Nanosecond precision is also supported. Examples of each are shown below.

```
"time": "2015-01-29T21:50:44Z"
"time": "2015-01-29T14:49:23-07:00"
"time": "2015-01-29T21:51:28.968422294Z"
"time": "2015-01-29T14:48:36.127798015-07:00"
```

_Epoch and Precision_

Timestamps can also be supplied as an integer value, with the precision specified separately. For example to set the time in nanoseconds, use the following two keys in the JSON request.

```
"time": 1422568543702900257,
"precision": "n"
```

`n`, `u`, `ms`, `s`, `m`, and `h` are all supported and represent nanoseconds, microseconds, milliseconds, seconds, minutes, and hours, respectively. If no precision is specified, seconds is assumed.

### Response
Once a quorum of Brokers has acknowledged the write, the Data node that initially received the write responds with `HTTP 200 OK`.

#### Errors
If an error was encountered while processing the data, InfluxDB will respond with either a `HTTP 400 Bad Request` or, in certain cases, with `HTTP 200 OK`. The former is returned if the request could not be understood. In the latter, InfluxDB could understand the request, but processing cannot be completed. In this case a JSON response is included in the body of the response with additional error information.

For example, issuing a bad query such as:

```
curl -G http://localhost:8086/query --data-urlencode "db=foo" --data-urlencode "q=show"
```

will result in `HTTP 400 Bad Request` with the the following JSON in the body of the response:

```json
{"error":"error parsing query: found EOF, expected SERIES, CONTINUOUS, MEASUREMENTS, TAG, FIELD, RETENTION at line 1, char 6"}
```

## Querying data using the HTTP API
The HTTP API is also the primary means for querying data contained within InfluxDB. To perform a query send a `GET` to the endpoint `/query`, set the URL parameter `db` as the target database, and set the URL parameter `q` as your query. An example query, sent to a locally-running InfluxDB server, is shown below.

```
curl -G 'http://localhost:8086/query' --data-urlencode "db=mydb" --data-urlencode "q=SELECT value FROM cpu_load_short WHERE region='us-west'"
```

Which returns data that looks like so:

```json
{
    "results": [
        {
            "series": [
                {
                    "name": "cpu_load_short",
                    "tags": {
                        "host": "server01",
                        "region": "us-west"
                    },
                    "columns": [
                        "time",
                        "value"
                    ],
                    "values": [
                        [
                            "2015-01-29T21:51:28.968422294Z",
                            0.64
                        ]
                    ]
                }
            ]
        }
    ]
}
```

In general the response body will be of the following form:

```json
{
    "results": [
        {
            "series": [{}],
            "error": "...."
        }
    ],
    "error": "...."
}
```

There are two top-level keys. `results` is an array of objects, one for each query, each containing a `series` keys. Each _row_ contains a data point returned by the query. If there was an error processing the query, the `error` key will be present, and will contained detailed information explaining why the query failed. An example of this type of failure would be attempt to query a series that does not exist.

The second top-level key is also named `error`, and is set if the API called failed before InfluxDB could perform any *query* operations. A example of this kind of failure would be invalid authentication credentials.

### Timestamp Format
The format of the returned timestamps complies with RFC3339, and has nanosecond precision.

### Multiple queries

Multiple queries can be sent to InfluxDB in a single API call. Simply delimit each query using a semicolon, as shown in the example below.

```
curl -XGET 'http://localhost:8086/query' --data-urlencode "db=mydb" --data-urlencode "q=SELECT * FROM cpu_load_short WHERE region=us-west;SELECT * FROM cpu_load_long"
```

## Authentication
Authentication is disabled by default, but if authentication is enabled, user credentials must be supplied with every query. These can be supplied via the URL parameters `u` and `p`. For example, if the  user is "bob" and Bob's password is "mypass", then endpoint URL should take the form `/query?u=bob&p=mypass`.

The credentials may also be passed using _Basic Authentication_. If both types of authentication are present in a request, the URL parameters take precedence.

Bootstrapping a secured system requires that the first administrator is created on the system with authentication disabled. Once this initial administrator has been created, the system can then be restarted with authentication enabled.

## Pretty Printing
When working directly with the API it’s often convenient to have pretty-printed JSON output. To enable pretty-printed output, append `pretty=true` to the URL. For example:

```
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=mydb" --data-urlencode "q=SELECT * FROM cpu_load_short"
```

Pretty-printed output is useful for debugging or querying directly using tools like `curl`, etc., It is not recommended for production use, such as in client libraries, or client code, as it consumes unnecessary network bandwidth.
